cmake_minimum_required(VERSION 3.10)

project(flutter_camera_processing LANGUAGES C CXX)

include_directories(include)
add_library(lib_opencv SHARED IMPORTED)
set_target_properties(lib_opencv PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/../android/src/main/jniLibs/${ANDROID_ABI}/libopencv_java4.so)

add_library(
    flutter_camera_processing
    SHARED
    common.cpp
    native_opencv.cpp
    native_zxing.cpp
)

set (BUILD_WRITERS ON)

add_subdirectory(zxing/core)

find_library(log-lib log)
target_link_libraries(flutter_camera_processing ZXing lib_opencv ${log-lib})