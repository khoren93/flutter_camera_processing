// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
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

  /// Returns the version of the opencv library.
  ///
  /// @return The version of the opencv library.
  ffi.Pointer<ffi.Char> opencvVersion() {
    return _opencvVersion();
  }

  late final _opencvVersionPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'opencvVersion');
  late final _opencvVersion =
      _opencvVersionPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  /// @brief Processes image bytes.
  /// @param bytes Image bytes.
  /// @param width Image width.
  /// @param height Image height.
  /// @return Image bytes.
  ffi.Pointer<ffi.UnsignedChar> opencvProcessStream(
    ffi.Pointer<ffi.Char> bytes,
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
          ffi.Pointer<ffi.UnsignedChar> Function(
              ffi.Pointer<ffi.Char>, ffi.Int, ffi.Int)>>('opencvProcessStream');
  late final _opencvProcessStream = _opencvProcessStreamPtr.asFunction<
      ffi.Pointer<ffi.UnsignedChar> Function(
          ffi.Pointer<ffi.Char>, int, int)>();

  void opencvProcessImage(
    ffi.Pointer<ffi.Char> input,
    ffi.Pointer<ffi.Char> output,
  ) {
    return _opencvProcessImage(
      input,
      output,
    );
  }

  late final _opencvProcessImagePtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>)>>('opencvProcessImage');
  late final _opencvProcessImage = _opencvProcessImagePtr.asFunction<
      void Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>)>();

  /// Returns the version of the zxing library.
  ///
  /// @return The version of the zxing library.
  ffi.Pointer<ffi.Char> zxingVersion() {
    return _zxingVersion();
  }

  late final _zxingVersionPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'zxingVersion');
  late final _zxingVersion =
      _zxingVersionPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  /// @brief Reads barcode from image.
  /// @param bytes Image bytes.
  /// @param width Image width.
  /// @param height Image height.
  /// @param cropSize Crop size.
  /// @return Barcode result.
  CodeResult zxingRead(
    ffi.Pointer<ffi.Char> bytes,
    int width,
    int height,
    int cropSize,
  ) {
    return _zxingRead(
      bytes,
      width,
      height,
      cropSize,
    );
  }

  late final _zxingReadPtr = _lookup<
      ffi.NativeFunction<
          CodeResult Function(
              ffi.Pointer<ffi.Char>, ffi.Int, ffi.Int, ffi.Int)>>('zxingRead');
  late final _zxingRead = _zxingReadPtr
      .asFunction<CodeResult Function(ffi.Pointer<ffi.Char>, int, int, int)>();

  /// @brief Encode a string into a barcode
  /// @param contents The string to encode
  /// @param width The width of the barcode
  /// @param height The height of the barcode
  /// @param format The format of the barcode
  /// @param margin The margin of the barcode
  /// @param eccLevel The error correction level of the barcode. Used for Aztec, PDF417, and QRCode only, [0-8].
  /// @return The barcode data
  EncodeResult zxingEncode(
    ffi.Pointer<ffi.Char> contents,
    int width,
    int height,
    int format,
    int margin,
    int eccLevel,
  ) {
    return _zxingEncode(
      contents,
      width,
      height,
      format,
      margin,
      eccLevel,
    );
  }

  late final _zxingEncodePtr = _lookup<
      ffi.NativeFunction<
          EncodeResult Function(ffi.Pointer<ffi.Char>, ffi.Int, ffi.Int,
              ffi.Int, ffi.Int, ffi.Int)>>('zxingEncode');
  late final _zxingEncode = _zxingEncodePtr.asFunction<
      EncodeResult Function(ffi.Pointer<ffi.Char>, int, int, int, int, int)>();
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

final class CodeResult extends ffi.Struct {
  @ffi.Int()
  external int isValid;

  external ffi.Pointer<ffi.Char> text;

  @ffi.Int32()
  external int format;
}

final class EncodeResult extends ffi.Struct {
  external ffi.Pointer<ffi.UnsignedInt> data;

  @ffi.Int()
  external int length;

  @ffi.Int()
  external int isValid;

  external ffi.Pointer<ffi.Char> error;
}
