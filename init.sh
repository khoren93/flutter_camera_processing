# Define the project name (the same as name: in the pubspec.yaml file)
project="flutter_camera_processing"

# Define the versions to download
opencv_version="4.7.0"
zxing_version="2.0.0"

# Define the paths to the directories where the files will be installed
projectPath="../../$project"
opencvIOSPath="$projectPath/ios"
opencvIncludePath="$projectPath/cpp/"
opencvJNIPath="$projectPath/android/src/main/jniLibs/"
zxingPath="$projectPath/cpp/zxing"

# Create the download directory
mkdir -p download
cd download

# Download the opencv source code and unzip it
wget -O "opencv-$opencv_version-android-sdk.zip" "https://github.com/opencv/opencv/releases/download/$opencv_version/opencv-$opencv_version-android-sdk.zip"
wget -O "opencv-$opencv_version-ios-framework.zip" "https://github.com/opencv/opencv/releases/download/$opencv_version/opencv-$opencv_version-ios-framework.zip"
unzip "opencv-$opencv_version-android-sdk.zip"
unzip "opencv-$opencv_version-ios-framework.zip"

# remove opencv from ios project
rm -R "$opencvIOSPath/opencv2.framework"

# remove opencv from android project
rm -R "$opencvIncludePath/include"
rm -R "$opencvJNIPath"

# copy opencv to ios project
cp -R opencv2.framework "$opencvIOSPath"

# print success message for ios
echo "OpenCV $opencv_version for iOS has been successfully installed"

# copy opencv to android project
cp -R OpenCV-android-sdk/sdk/native/jni/include "$opencvIncludePath"
mkdir -p "$opencvJNIPath"
cp -R OpenCV-android-sdk/sdk/native/libs/* "$opencvJNIPath"

# print success message for android
echo "OpenCV $opencv_version for Android has been successfully installed"

# Download the zxing source code and unzip it
wget -O "zxing-cpp-$zxing_version.zip" "https://github.com/nu-book/zxing-cpp/archive/refs/tags/v$zxing_version.zip"
unzip "zxing-cpp-$zxing_version.zip"

# remove zxing from project
rm -R "$zxingPath"

# copy zxing
cp -R "zxing-cpp-$zxing_version/" "$zxingPath"

# print success message for zxing
echo "ZXing $zxing_version has been successfully installed"

# remove the downloaded files
rm -R ../download