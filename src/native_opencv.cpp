#include "common.h"
#include <opencv2/opencv.hpp>
#include "native_opencv.h"
#include <vector>

using namespace cv;
using namespace std;

extern "C"
{
    FUNCTION_ATTRIBUTE
    const char *opencvVersion()
    {
        return CV_VERSION;
    }

    FUNCTION_ATTRIBUTE
    const uint8_t *opencvProcessStream(char *bytes, int width, int height)
    {
        long long start = get_now();

        //    int rotation = 0;

        Mat src = Mat(height, width, CV_8UC3, bytes);
        Mat dst = src;

        // handle rotation
        //        if (rotation == 90)
        //        {
        //    transpose(src, dst);
        //    flip(dst, dst, 1);
        //        }
        //        else if (rotation == 180)
        //        {
        //            flip(src, dst, -1);
        //        }
        //        else if (rotation == 270)
        //        {
        //            transpose(src, dst);
        //            flip(dst, dst, 0);
        //        }

        // Bitwise not the image
        // bitwise_not(src, dst);
        // bitwise_not(dst, dst);

        // return the image as a pointer to the data
        long length = dst.total() * dst.elemSize();
        uint8_t *result = new uint8_t[length];
        memcpy(result, dst.data, length);

        delete[] bytes;

        int evalInMillis = static_cast<int>(get_now() - start);
        platform_log("Decode done in %dms\n", evalInMillis);
        return result;
    }

    FUNCTION_ATTRIBUTE
    void opencvProcessImage(char *input, char *output)
    {
        long long start = get_now();

        Mat src = imread(input, IMREAD_COLOR);
        Mat dst;

        Mat img = src;

        Mat gray;
        cvtColor(img, gray, COLOR_BGR2GRAY);
        Mat mask;
        threshold(gray, mask, 0, 255, THRESH_BINARY_INV + THRESH_OTSU);
        Mat white(img.rows, img.cols, CV_8UC3, Scalar(255, 255, 255));
        Mat result;
        white.copyTo(result, mask);

        bitwise_not(result, dst);

        Scalar lower(10, 10, 10);
        Scalar upper(256, 256, 256);

        Mat thresh;
        inRange(img, lower, upper, thresh);

        // apply morphology and make 3 channels as mask
        Mat kernel = getStructuringElement(MORPH_ELLIPSE, Size(5, 5));
        Mat mask1;
        morphologyEx(thresh, mask1, MORPH_CLOSE, kernel);
        morphologyEx(mask1, mask1, MORPH_OPEN, kernel);
        Mat mask3;
        merge(std::vector<Mat>{mask1, mask1, mask1}, mask3);

        // blend img with gray using mask
        Mat result2;
        bitwise_and(img, mask3, result2);
        addWeighted(result2, 1, dst, 0.5, 0, result2);

        dst = result2;

        // write the image to a file
        imwrite(output, dst);

        int evalInMillis = static_cast<int>(get_now() - start);
        platform_log("Decode done in %dms\n", evalInMillis);
    }
}
