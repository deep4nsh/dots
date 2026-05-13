class MediaConstants {
  /// Maximum dimension for images (width or height) in pixels.
  static const double maxImageDimension = 2048;

  /// Quality for image compression (0-100).
  static const int imageQuality = 80;

  /// Maximum video file size in Megabytes.
  static const int maxVideoSizeMB = 50;

  /// Maximum voice recording file size in Megabytes.
  static const int maxVoiceSizeMB = 10;

  /// Maximum generic file size for imports in Megabytes.
  static const int maxFileSizeMB = 20;

  /// Maximum video duration for capture/selection.
  static const Duration maxVideoDuration = Duration(minutes: 1);
  
  /// Helper to convert MB to Bytes.
  static int mbToBytes(int mb) => mb * 1024 * 1024;
}
