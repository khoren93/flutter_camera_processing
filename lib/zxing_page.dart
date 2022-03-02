import 'dart:async';
// import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ffi';

import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:flutter_camera_processing/flutter_camera_processing.dart';
import 'package:flutter_camera_processing/generated_bindings.dart';
import 'package:image/image.dart' as imglib;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'isolate_utils.dart';
import 'scanner_overlay.dart';

late Directory tempDir;
String get tempPath => '${tempDir.path}/zxing.jpg';

extension Encode on EncodeResult {
  bool get isValidBool => isValid == 1;
  Uint32List get bytes => data.asTypedList(length);
  String get errorMessage => error.cast<Utf8>().toDartString();
}

extension Code on CodeResult {
  bool get isValidBool => isValid == 1;
  String get textString => text.cast<Utf8>().toDartString();

  String get formatString {
    return CodeFormat.formatName(format);
  }
}

extension CodeFormat on Format {
  static String formatName(int format) => formatNames[format] ?? 'Unknown';
  String get name => formatNames[this] ?? 'Unknown';

  static final formatNames = {
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

  static final writerFormats = [
    Format.QRCode,
    Format.DataMatrix,
    Format.Aztec,
    Format.PDF417,
    Format.Codabar,
    Format.Code39,
    Format.Code93,
    Format.Code128,
    Format.EAN8,
    Format.EAN13,
    Format.ITF,
    Format.UPCA,
    Format.UPCE,
    // Format.DataBar,
    // Format.DataBarExpanded,
    // Format.MaxiCode,
  ];
}

class ZxingPage extends StatefulWidget {
  const ZxingPage({
    Key? key,
    required this.onScan,
    this.onControllerCreated,
    this.beep = true,
    this.showCroppingRect = true,
    this.scanDelay = const Duration(milliseconds: 500), // 500ms delay
    this.cropPercent = 0.5, // 50% of the screen
    this.resolution = ResolutionPreset.high,
  }) : super(key: key);

  final Function(CodeResult) onScan;
  final Function(CameraController?)? onControllerCreated;
  final bool beep;
  final bool showCroppingRect;
  final Duration scanDelay;
  final double cropPercent;
  final ResolutionPreset resolution;

  @override
  State<ZxingPage> createState() => _ZxingPageState();
}

class _ZxingPageState extends State<ZxingPage> with TickerProviderStateMixin {
  late List<CameraDescription> cameras;
  CameraController? controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  TabController? _tabController;

  bool isAndroid() => Theme.of(context).platform == TargetPlatform.android;

  // Result queue
  final _resultQueue = <CodeResult>[];

  // Result stream
  final _resultStream = StreamController<Uint8List>.broadcast();

  // true when code detecting is ongoing
  bool _isProcessing = false;

  // true when the camera is active
  bool _isScanning = true;

  final _maxTextLength = 2000;
  final _supportedFormats = CodeFormat.writerFormats;
  var _codeFormat = Format.QRCode;

  /// Instance of [IsolateUtils]
  IsolateUtils? isolateUtils;

  @override
  void initState() {
    super.initState();

    initStateAsync();
  }

  void initStateAsync() async {
    _tabController = TabController(length: 3, vsync: this);
    _tabController?.addListener(() {
      _isScanning = _tabController?.index == 0;
      if (_isScanning) {
        controller?.resumePreview();
      } else {
        controller?.pausePreview();
      }
    });

    // Spawn a new isolate
    isolateUtils = IsolateUtils();
    await isolateUtils?.start();

    getTemporaryDirectory().then((value) {
      tempDir = value;
    });

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
      controller?.startImageStream(processCameraImage);
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
        var isolateData = IsolateData(image, widget.cropPercent);

        /// perform inference in separate isolate
        CodeResult result = await inference(isolateData);
        if (result.isValidBool) {
          FlutterBeep.beep();
          _resultQueue.add(result);
          widget.onScan(result);
          setState(() {});
          await Future.delayed(const Duration(seconds: 1));
        }
      } on FileSystemException catch (e) {
        debugPrint(e.message);
      } catch (e) {
        debugPrint(e.toString());
      }
      await Future.delayed(widget.scanDelay);
      _isProcessing = false;
    }

    return null;
  }

  /// Runs inference in another isolate
  Future<CodeResult> inference(IsolateData isolateData) async {
    ReceivePort responsePort = ReceivePort();
    isolateUtils?.sendPort
        ?.send(isolateData..responsePort = responsePort.sendPort);
    var results = await responsePort.first;
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cropSize = min(size.width, size.height) * widget.cropPercent;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zxing Demo'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Scanner'),
            Tab(text: 'Result'),
            Tab(text: 'Writer'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Scanner
          Stack(
            children: [
              // Camera preview
              Center(child: _cameraPreviewWidget(cropSize)),
            ],
          ),
          // Result
          _resultQueue.isEmpty
              ? const Center(
                  child: Text(
                  'No Results',
                  style: TextStyle(fontSize: 24),
                ))
              : ListView.builder(
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
          // Writer
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(height: 20),
                    // Format DropDown button
                    DropdownButtonFormField<int>(
                      value: _codeFormat,
                      items: _supportedFormats
                          .map((format) => DropdownMenuItem(
                                value: format,
                                child: Text(CodeFormat.formatName(format)),
                              ))
                          .toList(),
                      onChanged: (format) {
                        setState(() {
                          _codeFormat = format ?? Format.QRCode;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    // Input multiline text
                    TextFormField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      maxLength: _maxTextLength,
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        filled: true,
                        hintText: 'Enter text to encode',
                        counterText:
                            '${_textController.value.text.length} / $_maxTextLength',
                      ),
                    ),
                    // Write button
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _formKey.currentState?.save();
                          FocusScope.of(context).unfocus();

                          final text = _textController.value.text;
                          const width = 300;
                          const height = 300;
                          final result = FlutterCameraProcessing.zxingEncode(
                              text, width, height, _codeFormat, 5, 0);
                          String? error;
                          if (result.isValidBool) {
                            try {
                              final img = imglib.Image.fromBytes(
                                  width, height, result.bytes);
                              final resultBytes =
                                  Uint8List.fromList(imglib.encodeJpg(img));
                              _resultStream.add(resultBytes);
                            } on Exception catch (e) {
                              error = e.toString();
                            }
                          } else {
                            error = result.errorMessage;
                          }
                          if (error != null) {
                            _resultStream.addError(error);
                            debugPrint(result.errorMessage);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result.errorMessage,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Encode'),
                    ),
                    const SizedBox(height: 20),
                    StreamBuilder<Uint8List>(
                      stream: _resultStream.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                            children: [
                              // Barcode image
                              Image.memory(snapshot.requireData),
                              // Share button
                              ElevatedButton(
                                onPressed: () {
                                  // Save image to device
                                  final file = File(tempPath);
                                  file.writeAsBytesSync(snapshot.requireData);
                                  final path = file.path;
                                  // Share image
                                  Share.shareFiles([path]);
                                },
                                child: const Text('Share'),
                              ),
                            ],
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
