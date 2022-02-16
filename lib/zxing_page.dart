import 'dart:async';
// import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:flutter_camera_processing/flutter_camera_processing.dart';
import 'package:flutter_camera_processing/generated_bindings.dart';
import 'package:flutter_camera_processing/image_converter.dart';

import 'scanner_overlay.dart';

extension Code on CodeResult {
  bool get isValidBool => isValid == 1;
  String get textString => text.cast<Utf8>().toDartString();

  String get formatString {
    return _formatValues[format] ?? 'Unknown';
  }

  static final _formatValues = {
    Format.None: 'None',
    Format.Aztec: 'Aztec',
    Format.Codabar: 'CodaBar',
    Format.Code39: 'Code39',
    Format.Code93: 'Code93',
    Format.Code128: 'Code128',
    Format.DataBar: 'DataBar',
    Format.DataBarExpanded: 'DataBarExpanded',
    Format.DataMatrix: 'DataMatrix',
    Format.EAN8: 'EAN8',
    Format.EAN13: 'EAN13',
    Format.ITF: 'ITF',
    Format.MaxiCode: 'MaxiCode',
    Format.PDF417: 'PDF417',
    Format.QRCode: 'QR Code',
    Format.UPCA: 'UPCA',
    Format.UPCE: 'UPCE',
    Format.OneDCodes: 'OneD',
    Format.TwoDCodes: 'TwoD',
    Format.Any: 'Any',
  };
}

class ZxingPage extends StatefulWidget {
  const ZxingPage({
    Key? key,
    required this.onScan,
    this.onControllerCreated,
    this.beep = true,
    this.showCroppingRect = true,
    this.scanFps = const Duration(milliseconds: 500),
    this.cropPercent = 0.2, // 20%
    this.resolution = ResolutionPreset.high,
  }) : super(key: key);

  final Function(CodeResult) onScan;
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
  bool isAndroid() => Theme.of(context).platform == TargetPlatform.android;

  // Result queue
  final _resultQueue = <CodeResult>[];

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
        final result = FlutterCameraProcessing.zxingProcessStream(
            bytes, image.width, image.height, cropSize);
        if (result.isValidBool) {
          FlutterBeep.beep();
          _resultQueue.add(result);
          widget.onScan(result);
          setState(() {});
        }
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Zxing Demo'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Scanner'),
              Tab(text: 'Result'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Scanner
            Stack(
              children: [
                // Camera preview
                Center(child: _cameraPreviewWidget(cropSize)),
              ],
            ),
            // Result
            ListView.builder(
              itemCount: _resultQueue.length,
              itemBuilder: (context, index) {
                final result = _resultQueue[index];
                return ListTile(
                  title: Text(result.textString),
                  subtitle: Text(result.formatString),
                  trailing: ButtonBar(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Copy button
                      TextButton(
                        child: const Text('Copy'),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: result.textString));
                        },
                      ),
                      // Remove button
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _resultQueue.removeAt(index);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Display the preview from the camera.
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
