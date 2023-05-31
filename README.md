# flutter_camera_processing

This Flutter plugin demonstrates how to use OpenCV and ZXing C++ libraries natively in Flutter with Dart FFI using the camera stream.

## App Features

- Uses [OpenCV v4.7.0](https://github.com/opencv/opencv) C++ library to process the camera stream
- Utilizes [ZXing v2.0.0](https://github.com/zxing-cpp/zxing-cpp) C++ library to scan more than 15 barcode types
- Implements [Dart FFI](https://pub.dev/packages/ffi) to access the native libraries.
- Utilizes [ffigen](https://pub.dev/packages/ffigen) to generate FFI bindings
- Works on Android and iOS

## Building and Running

To build and run the project, follow these steps:

1. Download the required versions of the OpenCV and ZXing libraries and install them.   
**Note**: The project uses `wget` to download the libraries from the command line.   
If you're on macOS, you can use [Homebrew](https://brew.sh) to install `wget`:
```sh
brew install wget
```

2. On macOS, run the init.sh script:   
```sh
sh init.sh
```
On Windows, run the init_windows.ps1 script:
```sh
.\init_windows.ps1
```

By following these steps, you will have the necessary dependencies installed and the project ready to be built and run on both Android and iOS devices.

## License

MIT License. See [LICENSE](https://github.com/khoren93/flutter_camera_processing/blob/master/LICENSE).
