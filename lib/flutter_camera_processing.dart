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
        .opencvProcessStream(bytes.allocatePointer(), width, height).cast<Uint32>()
        .asTypedList(width * height);
  }

  static String zxingVersion() {
    return bindings.zxingVersion().cast<Utf8>().toDartString();
  }

  static CodeResult zxingProcessStream(
      Uint8List bytes, int width, int height, int cropSize) {
    return bindings.zxingRead(bytes.allocatePointer(), width, height, cropSize);
  }

  static EncodeResult zxingEncode(String contents, int width, int height,
      int format, int margin, int eccLevel) {
    var result = bindings.zxingEncode(contents.toNativeUtf8().cast<Char>(),
        width, height, format, margin, eccLevel);
    // var result2 = result.asTypedList(width * height);
    return result;
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
