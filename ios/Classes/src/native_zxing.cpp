#include "common.h"
#include "zxing/src/ReadBarcode.h"
#include <opencv2/opencv.hpp>
#include "native_zxing.h"

using namespace ZXing;
using namespace cv;

extern "C"
{
    FUNCTION_ATTRIBUTE
    char *zxingVersion()
    {
        return "1.2.0";
    }

    FUNCTION_ATTRIBUTE
    struct CodeResult zxingProcessStream(char *bytes, int width, int height, int cropSize)
    {
        long long start = get_now();

        Mat src = Mat(height, width, CV_8UC1, bytes);

        long length = src.total() * src.elemSize();
        uint8_t *data = new uint8_t[length];
        memcpy(data, src.data, length);
        
        BarcodeFormats formats = BarcodeFormat::Any;
        // BarcodeFormats formats = BarcodeFormat::TwoDCodes;
        DecodeHints hints = DecodeHints().setTryHarder(false).setTryRotate(true).setFormats(formats);
        ImageView image{data, width, height, ImageFormat::Lum};
        ImageView cropped = image.cropped(width / 2 - cropSize / 2, height / 2 - cropSize / 2, cropSize, cropSize);
        Result result = ReadBarcode(cropped, hints);
        
        struct CodeResult code = {false, nullptr};
        if (result.isValid()) {
            code.isValid = result.isValid();
            code.text = new char[result.text().length() + 1];
            std::string text = std::string(result.text().begin(), result.text().end());
            strcpy(code.text, text.c_str());
            code.format = Format(static_cast<int>(result.format()));
        }
        
        int evalInMillis = static_cast<int>(get_now() - start);
        platform_log("Decode done in %dms\n", evalInMillis);
        return code;
    }
}
