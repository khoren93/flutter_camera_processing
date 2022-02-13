#include "common.cpp"
#include <opencv2/opencv.hpp>

using namespace cv;

extern "C"
{
    FUNCTION_ATTRIBUTE
    const char *opencvVersion()
    {
        return CV_VERSION;
    }

    FUNCTION_ATTRIBUTE
    char *opencvProcessStream(char *bytes, int width, int height, char *outputImagePath)
    {
        long long start = get_now();

        Mat src = Mat(height, width, CV_8UC1, bytes);
        Mat dst;

        // Blur the image with 3x3 Gaussian kernel
        //  GaussianBlur(src, dst, Size(3, 3), 0);

        // Blur the image with 5x5 Gaussian kernel
        //  GaussianBlur(src, dst, Size(5, 5), 0);

        // Bitwise not the image
        bitwise_not(src, dst);

        // imwrite(outputImagePath, dst);

        int evalInMillis = static_cast<int>(get_now() - start);
        platform_log("Decode done in %dms\n", evalInMillis);

        // return the image as a pointer to the data
        int length = dst.total() * dst.elemSize();
        char *result = new char[length];
        memcpy(result, dst.data, length);
        return result;
        // return bytes; //src.data;
    }
}
