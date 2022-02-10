
import 'dart:async';

import 'package:flutter/services.dart';

class FlutterCameraProcessing {
  static const MethodChannel _channel = MethodChannel('flutter_camera_processing');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
