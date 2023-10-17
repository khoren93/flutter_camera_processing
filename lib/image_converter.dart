// import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as imglib;

// https://gist.github.com/Alby-o/fe87e35bc21d534c8220aed7df028e03

// TODO: this is not working on iOS in portrait mode
Future<Uint8List> convertImage(CameraImage image) async {
  try {
    /*final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final Uint8List bytes = allBytes.done().buffer.asUint8List();
    return bytes;

    bytes = allBytes.done().buffer.asUint8List();
    return bytes;*/
    if (image.format.group == ImageFormatGroup.yuv420) {
      return convertYUV420(image).getBytes();
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      //return image.planes.first.bytes;
      return convertBGRA8888(image).getBytes(order: imglib.ChannelOrder.rgba);
    }
  } catch (e) {
    debugPrint(">>>>>>>>>>>> ERROR:$e");
  }
  return Uint8List(0);
}

// TODO: this is not working on iOS (yet) in Image v4
// Made change but don't know if its working or not. I don't have mac machine
imglib.Image convertBGRA8888(CameraImage image) {
  final plane = image.planes[0];
  return imglib.Image.fromBytes(
    width: image.width,
    height: image.height,
    bytes: plane.bytes.buffer,
    rowStride: plane.bytesPerRow,
    bytesOffset: 28,
    order: imglib.ChannelOrder.rgba,
  );
}

imglib.Image convertYUV420(CameraImage cameraImage) {
  final imageWidth = cameraImage.width;
  final imageHeight = cameraImage.height;
  final yBuffer = cameraImage.planes[0].bytes;
  final uBuffer = cameraImage.planes[1].bytes;
  final vBuffer = cameraImage.planes[2].bytes;

  final int yRowStride = cameraImage.planes[0].bytesPerRow;
  final int yPixelStride = cameraImage.planes[0].bytesPerPixel!;

  final int uvRowStride = cameraImage.planes[1].bytesPerRow;
  final int uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

  final image = imglib.Image(width: imageWidth, height: imageHeight);

  for (int h = 0; h < imageHeight; h++) {
    int uvh = (h / 2).floor();

    for (int w = 0; w < imageWidth; w++) {
      int uvw = (w / 2).floor();

      final yIndex = (h * yRowStride) + (w * yPixelStride);

      // Y plane should have positive values belonging to [0...255]
      final int y = yBuffer[yIndex];

      // U/V Values are subsampled i.e. each pixel in U/V chanel in a
      // YUV_420 image act as chroma value for 4 neighbouring pixels
      final int uvIndex = (uvh * uvRowStride) + (uvw * uvPixelStride);

      // U/V values ideally fall under [-0.5, 0.5] range. To fit them into
      // [0, 255] range they are scaled up and centered to 128.
      // Operation below brings U/V values to [-128, 127].
      final int u = uBuffer[uvIndex];
      final int v = vBuffer[uvIndex];

      // Compute RGB values per formula above.
      int r = (y + v * 1436 / 1024 - 179).round();
      int g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
      int b = (y + u * 1814 / 1024 - 227).round();

      r = r.clamp(0, 255);
      g = g.clamp(0, 255);
      b = b.clamp(0, 255);

      image.setPixelRgb(w, h, r, g, b);
    }
  }

  return image;
}
