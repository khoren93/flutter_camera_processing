#include "common.h"
#include "ReadBarcode.h"
#include "MultiFormatWriter.h"
#include "TextUtfEncoding.h"
#include "BitMatrix.h"
#include "native_zxing.h"

#include <locale>
#include <codecvt>
#include <stdarg.h>

using namespace ZXing;

extern "C"
{
    FUNCTION_ATTRIBUTE
    char *zxingVersion()
    {
        return "1.4.0";
    }

    FUNCTION_ATTRIBUTE
    struct CodeResult zxingRead(char *bytes, int width, int height, int cropSize)
    {
        long long start = get_now();

        long length = width * height;
        uint8_t *data = new uint8_t[length];
        memcpy(data, bytes, length);

        BarcodeFormats formats = BarcodeFormat::Any;
        DecodeHints hints = DecodeHints().setTryHarder(false).setTryRotate(true).setFormats(formats);
        ImageView image{data, width, height, ImageFormat::Lum};
        ImageView cropped = image.cropped(width / 2 - cropSize / 2, height / 2 - cropSize / 2, cropSize, cropSize);
        Result result = ReadBarcode(cropped, hints);

        struct CodeResult code = {false, nullptr};
        if (result.isValid())
        {
            code.isValid = result.isValid();

            std::wstring_convert<std::codecvt_utf8<wchar_t>> converter;
            std::string text = converter.to_bytes(result.text());
            code.text = new char[text.length() + 1];
            strcpy(code.text, text.c_str());

            code.format = Format(static_cast<int>(result.format()));
        }

        int evalInMillis = static_cast<int>(get_now() - start);
        platform_log("Decode done in %dms\n", evalInMillis);
        return code;
    }

    FUNCTION_ATTRIBUTE
    struct EncodeResult zxingEncode(char *contents, int width, int height, int format, int margin, int eccLevel)
    {
        long long start = get_now();

        struct EncodeResult result = {nullptr, 0, false, nullptr};
        try
        {
            auto writer = MultiFormatWriter(BarcodeFormat(format)).setMargin(margin).setEccLevel(eccLevel);
            auto bitMatrix = writer.encode(TextUtfEncoding::FromUtf8(std::string(contents)), width, height);
            result.data = ToMatrix<uint32_t>(bitMatrix).data();
            result.length = bitMatrix.width() * bitMatrix.height();
            result.isValid = true;
        }
        catch (const std::exception &e)
        {
            platform_log("Can't encode text: %s\nError: %s\n", contents, e.what());
            result.error = new char[strlen(e.what()) + 1];
            strcpy(result.error, e.what());
        }

        int evalInMillis = static_cast<int>(get_now() - start);
        platform_log("Encode done in %dms\n", evalInMillis);
        return result;
    }
}
