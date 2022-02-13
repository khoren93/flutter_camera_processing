#include "common.cpp"

extern "C"
{
    FUNCTION_ATTRIBUTE
    const char *zxingVersion()
    {
        return "1.2.0";
    }

    FUNCTION_ATTRIBUTE
    char *zxingProcessStream(char *bytes, int width, int height, char *outputImagePath)
    {
        long long start = get_now();

        int evalInMillis = static_cast<int>(get_now() - start);
        platform_log("Decode done in %dms\n", evalInMillis);
        return bytes;
    }
}
