# Define the project name (the same as name: in the pubspec.yaml file)
project="flutter_camera_processing"

# Define the versions to download
opencv_version="4.5.5"
zxing_version="1.2.0"

# Define the paths to the directories where the files will be installed
projectPath="../../$project"
opencvIOSPath="$projectPath/ios"
opencvIncludePath="$projectPath"
opencvJNIPath="$projectPath/android/src/main/jniLibs/"

# Create the download directory
mkdir -p download
cd download

# Download the opencv source code and unzip it
wget -O "opencv-$opencv_version-android-sdk.zip" "https://github.com/opencv/opencv/releases/download/$opencv_version/opencv-$opencv_version-android-sdk.zip"
wget -O "opencv-$opencv_version-ios-framework.zip" "https://github.com/opencv/opencv/releases/download/$opencv_version/opencv-$opencv_version-ios-framework.zip"
unzip "opencv-$opencv_version-android-sdk.zip"
unzip "opencv-$opencv_version-ios-framework.zip"

# remove opencv from ios
rm -R "$opencvIOSPath/opencv2.framework"

# remove opencv from android
rm -R "$opencvIncludePath/include"
rm -R "$opencvJNIPath"

# copy opencv to ios
cp -R opencv2.framework "$opencvIOSPath"

# copy opencv to android
cp -R OpenCV-android-sdk/sdk/native/jni/include "$opencvIncludePath"
mkdir -p "$opencvJNIPath"
cp -R OpenCV-android-sdk/sdk/native/libs/* "$opencvJNIPath"

# Download the zxing source code and unzip it
wget -O "zxing-$zxing_version.zip" "https://github.com/nu-book/zxing-cpp/archive/refs/tags/v$zxing_version.zip"
unzip "zxing-$zxing_version.zip"

# remove the downloaded files
# rm -R ../download

# print success message
echo "OpenCV $opencv_version has been successfully installed"
echo "ZXing $zxing_version has been successfully installed"