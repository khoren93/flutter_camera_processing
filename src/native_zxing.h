#ifdef __cplusplus
extern "C"
{
#endif

    enum Format
    {
        None = 0,                   ///< Used as a return value if no valid barcode has been detected
        Aztec = (1 << 0),           ///< Aztec (2D)
        Codabar = (1 << 1),         ///< Codabar (1D)
        Code39 = (1 << 2),          ///< Code39 (1D)
        Code93 = (1 << 3),          ///< Code93 (1D)
        Code128 = (1 << 4),         ///< Code128 (1D)
        DataBar = (1 << 5),         ///< GS1 DataBar, formerly known as RSS 14
        DataBarExpanded = (1 << 6), ///< GS1 DataBar Expanded, formerly known as RSS EXPANDED
        DataMatrix = (1 << 7),      ///< DataMatrix (2D)
        EAN8 = (1 << 8),            ///< EAN-8 (1D)
        EAN13 = (1 << 9),           ///< EAN-13 (1D)
        ITF = (1 << 10),            ///< ITF (Interleaved Two of Five) (1D)
        MaxiCode = (1 << 11),       ///< MaxiCode (2D)
        PDF417 = (1 << 12),         ///< PDF417 (1D) or (2D)
        QRCode = (1 << 13),         ///< QR Code (2D)
        UPCA = (1 << 14),           ///< UPC-A (1D)
        UPCE = (1 << 15),           ///< UPC-E (1D)

        OneDCodes = Codabar | Code39 | Code93 | Code128 | EAN8 | EAN13 | ITF | DataBar | DataBarExpanded | UPCA | UPCE,
        TwoDCodes = Aztec | DataMatrix | MaxiCode | PDF417 | QRCode,
        Any = OneDCodes | TwoDCodes,
    };

    struct CodeResult
    {
        int isValid;
        char *text;
        enum Format format;
    };

    struct EncodeResult
    {
        const unsigned int *data;
        int length;
        int isValid;
        char *error;
    };

    /**
     * Returns the version of the zxing library.
     *
     * @return The version of the zxing library.
     */
    char *zxingVersion();

    /**
     * @brief Reads barcode from image.
     * @param bytes Image bytes.
     * @param width Image width.
     * @param height Image height.
     * @param cropSize Crop size.
     * @return Barcode result.
     */
    struct CodeResult zxingRead(char *bytes, int width, int height, int cropSize);

    /**
     * @brief Encode a string into a barcode
     * @param contents The string to encode
     * @param width The width of the barcode
     * @param height The height of the barcode
     * @param format The format of the barcode
     * @param margin The margin of the barcode
     * @param eccLevel The error correction level of the barcode. Used for Aztec, PDF417, and QRCode only, [0-8].
     * @return The barcode data
     */
    struct EncodeResult zxingEncode(char *contents, int width, int height, int format, int margin, int eccLevel);

#ifdef __cplusplus
}
#endif