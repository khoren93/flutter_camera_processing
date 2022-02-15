import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_camera_processing/flutter_camera_processing.dart';
import 'package:flutter_camera_processing/opencv_page.dart';
import 'package:flutter_camera_processing/zxing_page.dart';

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _opencvVersion = 'Unknown';
  String _zxingVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await FlutterCameraProcessing.platformVersion ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    try {
      _opencvVersion = FlutterCameraProcessing.opencvVersion();
      _zxingVersion = FlutterCameraProcessing.zxingVersion();
    } on Exception catch (e) {
      debugPrint(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Processing Demo'),
      ),
      body: Column(
        children: [
          Card(
            child: ListTile(
              title: const Text('OpenCV Demo'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OpencvPage(),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('ZXing Demo'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ZxingPage(onScan: (result) {
                      debugPrint('Scan result: $result');
                    }),
                  ),
                );
              },
            ),
          ),
          const Spacer(flex: 5),
          Center(
            child: Text(
              'Running on: $_platformVersion\n\nOpenCV: $_opencvVersion\n\nZXing: $_zxingVersion\n',
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
