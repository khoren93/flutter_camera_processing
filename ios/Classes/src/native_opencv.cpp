#include <opencv2/opencv.hpp>
#include <chrono>

#if defined(WIN32) || defined(_WIN32) || defined(__WIN32)
#define IS_WIN32
#endif

#ifdef __ANDROID__
#include <android/log.h>
#endif

#ifdef IS_WIN32
#include <windows.h>
#endif

#if defined(__GNUC__)
// Attributes to prevent 'unused' function from being removed and to make it visible
#define FUNCTION_ATTRIBUTE __attribute__((visibility("default"))) __attribute__((used))
#elif defined(_MSC_VER)
// Marking a function for export
#define FUNCTION_ATTRIBUTE __declspec(dllexport)
#endif

using namespace cv;
using namespace std;

long long int get_now()
{
    return chrono::duration_cast<std::chrono::milliseconds>(
               chrono::system_clock::now().time_since_epoch())
        .count();
}

void platform_log(const char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);
#ifdef __ANDROID__
    __android_log_vprint(ANDROID_LOG_VERBOSE, "ndk", fmt, args);
#elif defined(IS_WIN32)
    char *buf = new char[4096];
    std::fill_n(buf, 4096, '\0');
    _vsprintf_p(buf, 4096, fmt, args);
    OutputDebugStringA(buf);
    delete[] buf;
#else
    vprintf(fmt, args);
#endif
    va_end(args);
}

// Avoiding name mangling
extern "C"
{
    FUNCTION_ATTRIBUTE
    const char *version()
    {
        return CV_VERSION;
    }

    FUNCTION_ATTRIBUTE
    char *process_camera_stream(char *bytes, int width, int height, char *outputImagePath)
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
