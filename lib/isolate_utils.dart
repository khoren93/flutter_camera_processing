import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';

import 'flutter_camera_processing.dart';
import 'image_converter.dart';
import 'package:image/image.dart' as imglib;

// Inspired from https://github.com/am15h/object_detection_flutter

/// Bundles data to pass between Isolate
class ZxingIsolateData {
  CameraImage cameraImage;
  double cropPercent;

  SendPort? responsePort;

  ZxingIsolateData(
    this.cameraImage,
    this.cropPercent,
  );
}

class OpenCVIsolateData {
  CameraImage cameraImage;

  SendPort? responsePort;

  OpenCVIsolateData(
    this.cameraImage,
  );
}

/// Manages separate Isolate instance for inference
class IsolateUtils {
  static const String kDebugName = "IsolateProcessing";

  Isolate? _isolate;
  final _receivePort = ReceivePort();
  SendPort? _sendPort;

  SendPort? get sendPort => _sendPort;

  Future<void> startIsolateProcessing() async {
    _isolate = await Isolate.spawn<SendPort>(
      processingEntryPoint,
      _receivePort.sendPort,
      debugName: kDebugName,
    );

    _sendPort = await _receivePort.first;
  }

  void stopIsolateProcessing() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sendPort = null;
  }

  static void processingEntryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    await for (final isolateData in port) {
      if (isolateData is ZxingIsolateData) {
        final image = isolateData.cameraImage;
        final bytes = await convertImage(image);
        final cropPercent = isolateData.cropPercent;
        final cropSize = (min(image.width, image.height) * cropPercent).round();
        final result = FlutterCameraProcessing.zxingProcessStream(
            bytes, image.width, image.height, cropSize);
        isolateData.responsePort?.send(result);
      }
      if (isolateData is OpenCVIsolateData) {
        final image = isolateData.cameraImage;
        final bytes = await convertImage(image);
        final result = FlutterCameraProcessing.opencvProcessStream(
            bytes, image.width, image.height);
        final img = imglib.Image.fromBytes(
          width: image.width,
          height: image.height,
          bytes: result.buffer,
          numChannels: 4,
          // order: imglib.ChannelOrder.bgra,
        );
        final resultBytes = Uint32List.fromList(imglib.encodeJpg(img));
        isolateData.responsePort?.send(resultBytes);
      }
    }
  }
}
