# flutter_camera_processing

This Flutter plugin created to show how to use OpenCV and ZXing C++ libraries natively in Flutter with Dart FFI using the camera stream.

## App Features

- [X] Used [OpenCV](https://github.com/opencv/opencv) C++ library to process the camera stream
- [X] Used [ZXing](https://github.com/nu-book/zxing-cpp) C++ library to scan more than 30 barcode types
- [X] Used [Dart FFI](https://pub.dev/packages/ffi) to access the native libraries.
- [X] Used Dart [ffigen](https://pub.dev/packages/ffigen) to generate FFI bindings
- [X] Works on Android and iOS

## Building and Running

Run [init.sh](https://github.com/khoren93/flutter_camera_processing/blob/master/init.sh) script to download the defined versions of the OpenCV and ZXing libraries and install them.

```sh
sh init.sh
```

## License

MIT License. See [LICENSE](https://github.com/khoren93/flutter_camera_processing/blob/master/LICENSE).
