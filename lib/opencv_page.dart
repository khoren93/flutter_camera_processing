import 'dart:async';
// import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_camera_processing/flutter_camera_processing.dart';

class OpencvPage extends StatefulWidget {
  const OpencvPage({
    Key? key,
    this.onControllerCreated,
    this.scanFps = const Duration(milliseconds: 500),
    this.resolution = ResolutionPreset.high,
  }) : super(key: key);

  final Function(CameraController?)? onControllerCreated;
  final Duration scanFps;
  final ResolutionPreset resolution;

  @override
  State<OpencvPage> createState() => _OpencvPageState();
}

class _OpencvPageState extends State<OpencvPage> {
  late List<CameraDescription> cameras;
  CameraController? controller;

  bool _isProcessing = false;

  final resultStream = StreamController<Uint8List>.broadcast();

  bool isAndroid() => Theme.of(context).platform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();

    FlutterCameraProcessing.startCameraProcessing();

    availableCameras().then((cameras) {
      setState(() {
        this.cameras = cameras;
        onNewCameraSelected(cameras.first);
      });
    });

    SystemChannels.lifecycle.setMessageHandler((message) async {
      debugPrint(message);
      final CameraController? cameraController = controller;
      if (cameraController == null || !cameraController.value.isInitialized) {
        return;
      }
      if (mounted) {
        if (message == AppLifecycleState.paused.toString()) {
          cameraController.dispose();
        }
        if (message == AppLifecycleState.resumed.toString()) {
          onNewCameraSelected(cameraController.description);
        }
      }
      return null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    FlutterCameraProcessing.stopCameraProcessing();
    controller?.dispose();
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }

    controller = CameraController(
      cameraDescription,
      widget.resolution,
      enableAudio: false,
      imageFormatGroup:
          isAndroid() ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888,
    );

    try {
      await controller?.initialize();
      controller?.startImageStream((image) async {
        processCameraImage(image);
      });
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    controller?.addListener(() {
      if (mounted) setState(() {});
    });

    if (mounted) {
      setState(() {});
    }

    widget.onControllerCreated?.call(controller);
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void showInSnackBar(String message) {}

  void logError(String code, String? message) {
    if (message != null) {
      debugPrint('Error: $code\nError Message: $message');
    } else {
      debugPrint('Error: $code');
    }
  }

  processCameraImage(CameraImage image) async {
    if (!_isProcessing) {
      _isProcessing = true;
      try {
        final result =
            await FlutterCameraProcessing.opencvProcessCameraImage(image);
        if (result == null) return;
        resultStream.add(Uint8List.fromList(result));
      } on FileSystemException catch (e) {
        debugPrint(e.message);
      } catch (e) {
        debugPrint(e.toString());
      }
      _isProcessing = false;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenCV Demo'),
      ),
      body: Stack(
        children: [
          // Camera preview
          Center(child: _cameraPreviewWidget()),
          // Processing overlay
          Positioned(
            top: 10,
            left: 10,
            child: StreamBuilder<Uint8List>(
              stream: resultStream.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Center(
                    child: RotatedBox(
                      quarterTurns: 0,
                      child: Image.memory(
                        snapshot.requireData,
                        width: size.width / 2,
                        height: size.height / 2,
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return const CircularProgressIndicator();
    } else {
      final size = MediaQuery.of(context).size;
      var cameraMaxSize = max(size.width, size.height);
      return Stack(
        children: [
          SizedBox(
            width: cameraMaxSize,
            height: cameraMaxSize,
            child: ClipRRect(
              child: OverflowBox(
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: cameraMaxSize,
                    child: CameraPreview(
                      cameraController,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}
