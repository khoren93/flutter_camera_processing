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
    unsigned int *opencvProcessStream(char *bytes, int width, int height);

#ifdef __cplusplus
}
#endif