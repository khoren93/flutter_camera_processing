import 'dart:async';
// import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_camera_processing/flutter_camera_processing.dart';
import 'package:flutter_camera_processing/image_converter.dart';

import 'scanner_overlay.dart';

class ZxingPage extends StatefulWidget {
  const ZxingPage({
    Key? key,
    required this.onScan,
    this.onControllerCreated,
    this.beep = true,
    this.showCroppingRect = true,
    this.scanFps = const Duration(milliseconds: 500),
    this.cropPercent = 0.3, // 30%
    this.resolution = ResolutionPreset.high,
  }) : super(key: key);

  final Function(String) onScan;
  final Function(CameraController?)? onControllerCreated;
  final bool beep;
  final bool showCroppingRect;
  final Duration scanFps;
  final double cropPercent;
  final ResolutionPreset resolution;

  @override
  State<ZxingPage> createState() => _ZxingPageState();
}

class _ZxingPageState extends State<ZxingPage> {
  late List<CameraDescription> cameras;
  CameraController? controller;

  bool _shouldScan = false;

  final resultStream = StreamController<Uint8List>.broadcast();

  bool isAndroid() => Theme.of(context).platform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();

    availableCameras().then((cameras) {
      setState(() {
        this.cameras = cameras;
        onNewCameraSelected(cameras.first);
      });
    });

    Timer.periodic(widget.scanFps, (timer) {
      _shouldScan = true;
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
    if (_shouldScan) {
      _shouldScan = false;
      try {
        final bytes = await convertImage(image);
        final cropSize =
            (max(image.width, image.height) * widget.cropPercent).round();
        FlutterCameraProcessing.zxingProcessStream(
            bytes, image.width, image.height, cropSize);
        // final img = imglib.Image.fromBytes(image.width, image.height, result);
        // final resultBytes = Uint8List.fromList(imglib.encodeJpg(img));
        // resultStream.add(resultBytes);
      } on FileSystemException catch (e) {
        debugPrint(e.message);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cropSize =
        min(size.width, size.height) * widget.cropPercent * 2.0 * 0.8;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zxing Demo'),
      ),
      body: Stack(
        children: [
          // Camera preview
          Center(child: _cameraPreviewWidget(cropSize)),
          // Processing overlay
          Positioned(
            top: 10,
            left: 10,
            child: StreamBuilder<Uint8List>(
              stream: resultStream.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(cropSize / 8),
                      child: RotatedBox(
                        quarterTurns: isAndroid() ? 1 : 0,
                        child: Image.memory(
                          snapshot.requireData,
                          width: size.width / 2,
                          height: size.height / 2,
                        ),
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
  Widget _cameraPreviewWidget(double cropSize) {
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
          widget.showCroppingRect
              ? Container(
                  decoration: ShapeDecoration(
                    shape: ScannerOverlay(
                      borderColor: Theme.of(context).primaryColor,
                      overlayColor: const Color.fromRGBO(0, 0, 0, 0.5),
                      borderRadius: 1,
                      borderLength: 16,
                      borderWidth: 8,
                      cutOutSize: cropSize,
                    ),
                  ),
                )
              : Container()
        ],
      );
    }
  }
}
