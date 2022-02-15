#ifdef __cplusplus
extern "C" {
#endif

    struct CodeResult
    {
        int isValid;
        char *text;
    };

    char *zxingVersion();
    char *zxingProcessStream(char *bytes, int width, int height, int cropSize);

#ifdef __cplusplus
}
#endif