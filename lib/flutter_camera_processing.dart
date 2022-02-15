import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';

import 'generated_bindings.dart';

class FlutterCameraProcessing {
  static const MethodChannel _channel =
      MethodChannel('flutter_camera_processing');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static final bindings = GeneratedBindings(dylib);

  static String opencvVersion() {
    return bindings.opencvVersion().cast<Utf8>().toDartString();
  }

  static Uint32List opencvProcessStream(
      Uint8List bytes, int width, int height) {
    return bindings
        .opencvProcessStream(bytes.allocatePointer(), width, height)
        .asTypedList(width * height);
  }

  static String zxingVersion() {
    return bindings.zxingVersion().cast<Utf8>().toDartString();
  }

  static void zxingProcessStream(
      Uint8List bytes, int width, int height, int cropSize) {
    bindings.zxingProcessStream(
        bytes.allocatePointer(), width, height, cropSize);
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
  Pointer<Int8> allocatePointer() {
    final blob = calloc<Int8>(length);
    final blobBytes = blob.asTypedList(length);
    blobBytes.setAll(0, this);
    return blob;
  }
}
