// import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as imglib;

// https://gist.github.com/Alby-o/fe87e35bc21d534c8220aed7df028e03

// TODO: this is not working on iOS in portrait mode
Future<Uint8List> convertImage(CameraImage image) async {
  try {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final Uint8List bytes = allBytes.done().buffer.asUint8List();
    return bytes;

    // if (image.format.group == ImageFormatGroup.yuv420) {
    //   return image.planes.first.bytes;
    // } else if (image.format.group == ImageFormatGroup.bgra8888) {
    //   // return image.planes.first.bytes;
    //   return convertBGRA8888(image).getBytes(order: imglib.ChannelOrder.bgra);
    // }
  } catch (e) {
    debugPrint(">>>>>>>>>>>> ERROR:$e");
  }
  return Uint8List(0);
}

// TODO: this is not working on iOS (yet) in Image v4
imglib.Image convertBGRA8888(CameraImage image) {
  final plane = image.planes.first;
  return imglib.Image.fromBytes(
    width: image.width,
    height: image.height,
    bytes: image.planes.first.bytes.buffer,
    rowStride: plane.bytesPerRow,
    bytesOffset: 28,
    order: imglib.ChannelOrder.bgra,
  );
}

imglib.Image convertYUV420(CameraImage image) {
  var img = imglib.Image(
    width: image.width,
    height: image.height,
  ); // Create Image buffer

  Plane plane = image.planes[0];
  const int shift = (0xFF << 24);

  // Fill image buffer with plane[0] from YUV420_888
  for (int x = 0; x < image.width; x++) {
    for (int planeOffset = 0;
        planeOffset < image.height * image.width;
        planeOffset += image.width) {
      final pixelColor = plane.bytes[planeOffset + x];
      // color: 0x FF  FF  FF  FF
      //           A   B   G   R
      // Calculate pixel color
      var newVal = shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;

      img.data
          ?.setPixel(x, planeOffset ~/ image.width, imglib.ColorInt8(newVal));
    }
  }

  return img;
}
