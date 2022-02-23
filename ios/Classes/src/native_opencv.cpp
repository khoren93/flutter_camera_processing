#include "common.h"
#include <opencv2/opencv.hpp>
#include "native_opencv.h"

using namespace cv;

extern "C"
{
    FUNCTION_ATTRIBUTE
    const char *opencvVersion()
    {
        return CV_VERSION;
    }

    FUNCTION_ATTRIBUTE
    unsigned int *opencvProcessStream(char *bytes, int width, int height)
    {
        long long start = get_now();

        Mat src = Mat(height, width, CV_8UC1, bytes);
        Mat dst;

        // Bitwise not the image
        bitwise_not(src, dst);

        // return the image as a pointer to the data
        long length = dst.total() * dst.elemSize();
        uint32_t *result = new uint32_t[length];
        memcpy(result, dst.data, length);

        int evalInMillis = static_cast<int>(get_now() - start);
        platform_log("Decode done in %dms\n", evalInMillis);
        return result;
    }
}
