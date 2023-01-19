# Define the project name (the same as name: in the pubspec.yaml file)
Set-Variable project "flutter_camera_processing"

# Define the versions to download
Set-Variable opencv_version "4.7.0"
Set-Variable zxing_version "2.0.0"

# Define the paths to the directories where the files will be installed
Set-Variable projectPath "../../$project"
Set-Variable opencvIOSPath "$projectPath/ios"
Set-Variable opencvIncludePath "$projectPath/cpp/"
Set-Variable opencvJNIPath "$projectPath/android/src/main/jniLibs/"
Set-Variable zxingPath "$projectPath/cpp/zxing"

# Create the download directory
mkdir -p download
Set-Location download

# Download the opencv source code and unzip it
Invoke-WebRequest -O "opencv-$opencv_version-android-sdk.zip" "https://github.com/opencv/opencv/releases/download/$opencv_version/opencv-$opencv_version-android-sdk.zip"
Invoke-WebRequest -O "opencv-$opencv_version-ios-framework.zip" "https://github.com/opencv/opencv/releases/download/$opencv_version/opencv-$opencv_version-ios-framework.zip"
Expand-Archive "opencv-$opencv_version-android-sdk.zip"
Expand-Archive "opencv-$opencv_version-ios-framework.zip"

# remove opencv from ios project
Remove-Item -R "$opencvIOSPath/opencv2.framework"

# remove opencv from android project
Remove-Item -R "$opencvIncludePath/include"
Remove-Item -R "$opencvJNIPath"

# copy opencv to ios project
Copy-Item -R "opencv-$opencv_version-ios-framework/opencv2.framework" "$opencvIOSPath"

# print success message for ios
Write-Output "OpenCV $opencv_version for iOS has been successfully installed"

# copy opencv to android project
Copy-Item -R "opencv-$opencv_version-android-sdk/OpenCV-android-sdk/sdk/native/jni/include" "$opencvIncludePath"
mkdir -p "$opencvJNIPath"
Copy-Item -R "opencv-$opencv_version-android-sdk/OpenCV-android-sdk/sdk/native/libs/*" "$opencvJNIPath"

# print success message for android
Write-Output "OpenCV $opencv_version for Android has been successfully installed"

# Download the zxing source code and unzip it
Invoke-WebRequest -O "zxing-cpp-$zxing_version.zip" "https://github.com/nu-book/zxing-cpp/archive/refs/tags/v$zxing_version.zip"
Expand-Archive "zxing-cpp-$zxing_version.zip"

# remove zxing from project
Remove-Item -R "$zxingPath"

# copy zxing
Copy-Item -R "zxing-cpp-$zxing_version/zxing-cpp-$zxing_version/" "$zxingPath"

# print success message for zxing
Write-Output "ZXing $zxing_version has been successfully installed"

# remove the downloaded files
Set-Location ..
Remove-Item -R download