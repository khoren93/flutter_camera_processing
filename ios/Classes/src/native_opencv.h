typedef unsigned int uint32_t;

#ifdef __cplusplus
extern "C" {
#endif

    const char *opencvVersion();
    uint32_t *opencvProcessStream(char *bytes, int width, int height);

#ifdef __cplusplus
}
#endif