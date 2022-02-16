// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
import 'dart:ffi' as ffi;

/// Bindings to opencv and zxing.
class GeneratedBindings {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  GeneratedBindings(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  GeneratedBindings.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  ffi.Pointer<ffi.Int8> opencvVersion() {
    return _opencvVersion();
  }

  late final _opencvVersionPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Int8> Function()>>(
          'opencvVersion');
  late final _opencvVersion =
      _opencvVersionPtr.asFunction<ffi.Pointer<ffi.Int8> Function()>();

  ffi.Pointer<ffi.Uint32> opencvProcessStream(
    ffi.Pointer<ffi.Int8> bytes,
    int width,
    int height,
  ) {
    return _opencvProcessStream(
      bytes,
      width,
      height,
    );
  }

  late final _opencvProcessStreamPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Uint32> Function(ffi.Pointer<ffi.Int8>, ffi.Int32,
              ffi.Int32)>>('opencvProcessStream');
  late final _opencvProcessStream = _opencvProcessStreamPtr.asFunction<
      ffi.Pointer<ffi.Uint32> Function(ffi.Pointer<ffi.Int8>, int, int)>();

  ffi.Pointer<ffi.Int8> zxingVersion() {
    return _zxingVersion();
  }

  late final _zxingVersionPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Int8> Function()>>(
          'zxingVersion');
  late final _zxingVersion =
      _zxingVersionPtr.asFunction<ffi.Pointer<ffi.Int8> Function()>();

  CodeResult zxingProcessStream(
    ffi.Pointer<ffi.Int8> bytes,
    int width,
    int height,
    int cropSize,
  ) {
    return _zxingProcessStream(
      bytes,
      width,
      height,
      cropSize,
    );
  }

  late final _zxingProcessStreamPtr = _lookup<
      ffi.NativeFunction<
          CodeResult Function(ffi.Pointer<ffi.Int8>, ffi.Int32, ffi.Int32,
              ffi.Int32)>>('zxingProcessStream');
  late final _zxingProcessStream = _zxingProcessStreamPtr
      .asFunction<CodeResult Function(ffi.Pointer<ffi.Int8>, int, int, int)>();
}

abstract class Format {
  /// < Used as a return value if no valid barcode has been detected
  static const int None = 0;

  /// < Aztec (2D)
  static const int Aztec = 1;

  /// < Codabar (1D)
  static const int Codabar = 2;

  /// < Code39 (1D)
  static const int Code39 = 4;

  /// < Code93 (1D)
  static const int Code93 = 8;

  /// < Code128 (1D)
  static const int Code128 = 16;

  /// < GS1 DataBar, formerly known as RSS 14
  static const int DataBar = 32;

  /// < GS1 DataBar Expanded, formerly known as RSS EXPANDED
  static const int DataBarExpanded = 64;

  /// < DataMatrix (2D)
  static const int DataMatrix = 128;

  /// < EAN-8 (1D)
  static const int EAN8 = 256;

  /// < EAN-13 (1D)
  static const int EAN13 = 512;

  /// < ITF (Interleaved Two of Five) (1D)
  static const int ITF = 1024;

  /// < MaxiCode (2D)
  static const int MaxiCode = 2048;

  /// < PDF417 (1D) or (2D)
  static const int PDF417 = 4096;

  /// < QR Code (2D)
  static const int QRCode = 8192;

  /// < UPC-A (1D)
  static const int UPCA = 16384;

  /// < UPC-E (1D)
  static const int UPCE = 32768;
  static const int OneDCodes = 51070;
  static const int TwoDCodes = 14465;
  static const int Any = 65535;
}

class CodeResult extends ffi.Struct {
  @ffi.Int32()
  external int isValid;

  external ffi.Pointer<ffi.Int8> text;

  @ffi.Int32()
  external int format;
}
