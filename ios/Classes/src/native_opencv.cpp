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

    FUNCTION_ATTRIBUTE
    void opencvProcessImage(char *input, char *output)
    {
        long long start = get_now();

        Mat src = imread(input, IMREAD_COLOR);
        Mat dst;

        // Crop 10% of the image from the bottom
        // int crop = src.rows * 0.1;
        // Rect roi(0, 0, src.cols, src.rows - crop);

        // // Crop the image
        // src
        //     .rowRange(roi.y, roi.y + roi.height)
        //     .colRange(roi.x, roi.x + roi.width)
        //     .copyTo(src);

        // // Bitwise not the image
        // bitwise_not(src, dst);

        Mat img = src;

        Mat gray;
        cvtColor(img, gray, COLOR_BGR2GRAY);
        Mat mask;
        threshold(gray, mask, 0, 255, THRESH_BINARY_INV + THRESH_OTSU);
        Mat white(img.rows, img.cols, CV_8UC3, Scalar(255, 255, 255));
        Mat result;
        white.copyTo(result, mask);

        bitwise_not(result, dst);

        // Mat img = src;

        // -----------------------------

        // threshold on orange
        // Scalar lower(0, 60, 200);
        // Scalar upper(110, 160, 255);
        
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

        // create 3-channel grayscale version
        // Mat gray;
        // cvtColor(img, gray, COLOR_BGR2GRAY);
        // cvtColor(gray, gray, COLOR_GRAY2BGR);

        // blend img with gray using mask
        Mat result2;
        bitwise_and(img, mask3, result2);
        addWeighted(result2, 1, dst, 0.5, 0, result2);

        // -----------------------------

        // // colors to threshold on
        // std::vector<Scalar> lower_bounds = {
        //     Scalar(0, 60, 200),  // orange
        //     Scalar(50, 150, 50), // green
        //     Scalar(0, 0, 255)    // red
        // };
        // std::vector<Scalar> upper_bounds = {
        //     Scalar(110, 160, 255), // orange
        //     Scalar(100, 255, 100), // green
        //     Scalar(100, 100, 255)  // red
        // };

        // // color names
        // std::vector<std::string> color_names = {"Orange", "Green", "Red"};

        // // apply morphological operations on colors
        // std::vector<Mat> masks;
        // Mat thresh, mask;
        // for (int i = 0; i < lower_bounds.size(); i++)
        // {
        //     inRange(img, lower_bounds[i], upper_bounds[i], thresh);
        //     Mat kernel = getStructuringElement(MORPH_ELLIPSE, Size(5, 5));
        //     morphologyEx(thresh, mask, MORPH_CLOSE, kernel);
        //     morphologyEx(mask, mask, MORPH_OPEN, kernel);
        //     masks.push_back(mask);
        //     std::cout << "Thresholding on " << color_names[i] << std::endl;
        // }

        // // merge masks
        // bitwise_or(masks[0], masks[1], mask);
        // for (int i = 2; i < masks.size(); i++)
        // {
        //     bitwise_or(mask, masks[i], mask);
        // }

        // // create 3-channel grayscale version
        // Mat gray;
        // cvtColor(img, gray, COLOR_BGR2GRAY);
        // cvtColor(gray, gray, COLOR_GRAY2BGR);

        // cout << "img size " << img.size() << endl;
        // cout << "mask size " << mask.size() << endl;

        // // blend img with gray using mask
        // Mat result;
        // bitwise_and(img, mask, result);
        // addWeighted(result, 1, gray, 0.5, 0, result);

        // save images
        dst = result2;

        // -----------------------------

        // write the image to a file
        imwrite(output, dst);

        int evalInMillis = static_cast<int>(get_now() - start);
        platform_log("Decode done in %dms\n", evalInMillis);
    }
}
