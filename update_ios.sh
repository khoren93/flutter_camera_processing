# Description: This script is used to copy the source files from the src directory to the ios/Classes/src directory.

# Define the paths to the directories where the files will be installed
srcPath="../cpp" 
zxingPath="$srcPath/zxing/core/src"
iosSrcPath="../ios/Classes/src"
iosZxingSrcPath="$iosSrcPath/zxing"

# Remove the source files if they exist
rm -rf $iosZxingSrcPath

# create the source directories
mkdir -p $iosZxingSrcPath

# Copy the source files
rsync -av "$zxingPath/" "$iosZxingSrcPath/"