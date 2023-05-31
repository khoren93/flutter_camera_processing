#ifdef __cplusplus
extern "C"
{
#endif

    /**
     * Returns the version of the opencv library.
     *
     * @return The version of the opencv library.
     */
    const char *opencvVersion();

    /**
     * @brief Processes image bytes.
     * @param bytes Image bytes.
     * @param width Image width.
     * @param height Image height.
     * @return Image bytes.
     */
    const unsigned char *opencvProcessStream(char *bytes, int width, int height);

    void opencvProcessImage(char *input, char* output);

#ifdef __cplusplus
}
#endif