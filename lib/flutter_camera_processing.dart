import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';

import 'generated_bindings.dart';
import 'isolate_utils.dart';

class FlutterCameraProcessing {
  static const MethodChannel _channel =
      MethodChannel('flutter_camera_processing');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static final bindings = GeneratedBindings(dylib);

  static IsolateUtils? isolateUtils;

  static Future<void> startCameraProcessing() async {
    isolateUtils = IsolateUtils();
    await isolateUtils?.startIsolateProcessing();
  }

  static void stopCameraProcessing() => isolateUtils?.stopIsolateProcessing();

  static String opencvVersion() =>
      bindings.opencvVersion().cast<Utf8>().toDartString();

  static Future<Uint32List?> opencvProcessCameraImage(
          CameraImage image) async =>
      await _inference(OpenCVIsolateData(image));

  static Uint32List opencvProcessStream(
          Uint8List bytes, int width, int height) =>
      Uint32List.fromList(bindings
          .opencvProcessStream(bytes.allocatePointer(), width, height)
          .cast<Int8>()
          .asTypedList(width * height));

  static String zxingVersion() =>
      bindings.zxingVersion().cast<Utf8>().toDartString();

  static CodeResult zxingProcessStream(
          Uint8List bytes, int width, int height, int cropSize) =>
      bindings.zxingRead(bytes.allocatePointer(), width, height, cropSize);

  static EncodeResult zxingEncode(String contents, int width, int height,
          int format, int margin, int eccLevel) =>
      bindings.zxingEncode(contents.toNativeUtf8().cast<Char>(), width, height,
          format, margin, eccLevel);

  static Future<CodeResult> zxingProcessCameraImage(
          CameraImage image, double cropPercent) async =>
      await _inference(ZxingIsolateData(image, cropPercent));

  /// Runs inference in another isolate
  static Future<dynamic> _inference(dynamic isolateData) async {
    final ReceivePort responsePort = ReceivePort();
    isolateUtils?.sendPort
        ?.send(isolateData..responsePort = responsePort.sendPort);
    final dynamic results = await responsePort.first;
    return results;
  }
}

// Getting a library that holds needed symbols
DynamicLibrary _openDynamicLibrary() {
  if (Platform.isAndroid) {
    return DynamicLibrary.open('libflutter_camera_processing.so');
  } else if (Platform.isWindows) {
    return DynamicLibrary.open("flutter_camera_processing_windows_plugin.dll");
  }
  return DynamicLibrary.process();
}

DynamicLibrary dylib = _openDynamicLibrary();

extension Uint8ListBlobConversion on Uint8List {
  /// Allocates a pointer filled with the Uint8List data.
  Pointer<Char> allocatePointer() {
    final Pointer<Int8> blob = calloc<Int8>(length);
    final Int8List blobBytes = blob.asTypedList(length);
    blobBytes.setAll(0, this);
    return blob.cast<Char>();
  }
}
