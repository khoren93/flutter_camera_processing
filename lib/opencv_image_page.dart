import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_camera_processing/flutter_camera_processing.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

late Directory tempDir;
String get tempPath => '${tempDir.path}/processed.jpg';

class OpencvImagePage extends StatefulWidget {
  const OpencvImagePage({
    Key? key,
  }) : super(key: key);

  @override
  State<OpencvImagePage> createState() => _OpencvImagePageState();
}

class _OpencvImagePageState extends State<OpencvImagePage> {
  String inputImagePath = '';
  String outputImagePath = '';

  @override
  void initState() {
    super.initState();

    getTemporaryDirectory().then((value) {
      tempDir = value;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showInSnackBar(String message) {}

  void logError(String code, String? message) {
    if (message != null) {
      debugPrint('Error: $code\nError Message: $message');
    } else {
      debugPrint('Error: $code');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenCV Image Processing'),
        actions: [
          IconButton(
            onPressed: _onChooseImage,
            icon: const Icon(Icons.photo_album),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: inputImagePath.isEmpty
              ? Container()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FutureBuilder<Uint8List>(
                        future: File(inputImagePath).readAsBytes(),
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            return Image.memory(snapshot.data!);
                          }
                          return Container();
                        }),
                    FutureBuilder<Uint8List>(
                        future: File(outputImagePath).readAsBytes(),
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            return Image.memory(snapshot.data!);
                          }
                          return Container();
                        }),
                  ],
                ),
        ),
      ),
    );
  }

  _onChooseImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await FlutterCameraProcessing.opencvProcessImage(
        pickedFile.path,
        tempPath,
      );
      setState(() {
        inputImagePath = pickedFile.path;
        outputImagePath = tempPath;
      });
    }
  }
}
