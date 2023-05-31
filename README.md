# flutter_camera_processing

This Flutter plugin created to show how to use OpenCV and ZXing C++ libraries natively in Flutter with Dart FFI using the camera stream.

## App Features

- [X] Used [OpenCV v4.7.0](https://github.com/opencv/opencv) C++ library to process the camera stream
- [X] Used [ZXing v2.0.0](https://github.com/zxing-cpp/zxing-cpp) C++ library to scan more than 15 barcode types
- [X] Used [Dart FFI](https://pub.dev/packages/ffi) to access the native libraries.
- [X] Used Dart [ffigen](https://pub.dev/packages/ffigen) to generate FFI bindings
- [X] Works on Android and iOS

## Building and Running

We need download the defined versions of the OpenCV and ZXing libraries and install them.

`wget` is essential for downloading files from the command line. It is used in this repository to fetch the OpenCV and ZXing libraries. 
To install wget on macOS, use [Homebrew](https://brew.sh):
```sh
brew install wget
```

On MacOS run [init.sh](https://github.com/khoren93/flutter_camera_processing/blob/master/init.sh)

```sh
sh init.sh
```

On Windows run [init_windows.ps1](https://github.com/khoren93/flutter_camera_processing/blob/master/init_windows.ps1) script

```sh
.\init_windows.ps1
```

If you are downloaded the zip file from github repository, then you should rename the folder from `flutter_camera_processing_master` to `flutter_camera_processing` and run the command below.
Otherwise, you should change the project name to `flutter_camera_processing_master` in the [init.sh](https://github.com/khoren93/flutter_camera_processing/blob/master/init.sh) script.

## License

MIT License. See [LICENSE](https://github.com/khoren93/flutter_camera_processing/blob/master/LICENSE).
