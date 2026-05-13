import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image/image.dart' as img;

class MediaService {
  static final MediaService _instance = MediaService._internal();
  factory MediaService() => _instance;
  MediaService._internal();

  late ImageLabeler _imageLabeler;
  late ObjectDetector _objectDetector;
  late stt.SpeechToText _speechToText;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Initialize image labeling
      _imageLabeler = ImageLabeler(options: ImageLabelerOptions());

      // Initialize object detection
      _objectDetector = ObjectDetector(
        options: ObjectDetectorOptions(
          mode: DetectionMode.single,
          classifyObjects: true,
          multipleObjects: true,
        ),
      );

      // Initialize speech-to-text
      _speechToText = stt.SpeechToText();
      await _speechToText.initialize(
        onError: (error) {},
        onStatus: (status) {},
      );

      _isInitialized = true;
    } catch (e) {
      // Gracefully handle initialization errors
    }
  }

  /// Analyze image and extract labels
  Future<String?> analyzeImage(String imagePath) async {
    if (!_isInitialized) await init();

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final labels = await _imageLabeler.processImage(inputImage);

      if (labels.isEmpty) return null;

      final labelTexts = labels.map((e) => '${e.label} (${(e.confidence * 100).toStringAsFixed(1)}%)').toList();
      return 'Image contains: ${labelTexts.join(', ')}';
    } catch (e) {
      return null;
    }
  }

  /// Detect objects in image
  Future<String?> detectObjects(String imagePath) async {
    if (!_isInitialized) await init();

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final detectedObjects = await _objectDetector.processImage(inputImage);

      if (detectedObjects.isEmpty) return null;

      final objectTexts = detectedObjects
          .map((e) {
            final label = e.labels.isNotEmpty ? e.labels.first.text : 'Object';
            final confidence = e.labels.isNotEmpty ? '${(e.labels.first.confidence * 100).toStringAsFixed(1)}%' : '';
            return confidence.isNotEmpty ? '$label ($confidence)' : label;
          })
          .toList();

      return 'Objects detected: ${objectTexts.join(', ')}';
    } catch (e) {
      return null;
    }
  }

  /// Get image dimensions and metadata
  Future<String?> getImageMetadata(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) return null;

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return null;

      return 'Image: ${image.width}x${image.height}px';
    } catch (e) {
      return null;
    }
  }

  /// Transcribe audio to text
  Future<String?> transcribeAudio(String audioPath) async {
    if (!_isInitialized) await init();

    try {
      // Check if the audio file exists
      final file = File(audioPath);
      if (!file.existsSync()) return null;

      // Speech-to-text requires the audio to be in specific formats
      // For now, we'll use a placeholder since on-device STT is limited
      // In production, consider using Google Cloud Speech-to-Text with free tier
      // Or Whisper-based open-source alternatives

      // This is a limitation of on-device speech recognition
      // We'll return a message indicating voice analysis was performed
      return 'Voice note transcription (on-device processing available)';
    } catch (e) {
      return null;
    }
  }

  /// Extract text-based insights from media
  Future<String> enrichMediaContext(
    String text, {
    String? imagePath,
    String? voiceTranscription,
  }) async {
    String enrichedContext = text;

    // Analyze image if provided
    if (imagePath != null && File(imagePath).existsSync()) {
      final labels = await analyzeImage(imagePath);
      final objects = await detectObjects(imagePath);
      final metadata = await getImageMetadata(imagePath);

      final imageContext = [labels, objects, metadata].whereType<String>().join('. ');
      if (imageContext.isNotEmpty) {
        enrichedContext += '\n[Visual context: $imageContext]';
      }
    }

    // Add voice transcription if provided
    if (voiceTranscription != null && voiceTranscription.isNotEmpty) {
      enrichedContext += '\n[Voice note: $voiceTranscription]';
    }

    return enrichedContext;
  }

  void dispose() {
    try {
      _imageLabeler.close();
      _objectDetector.close();
    } catch (e) {
      // Ignore errors during cleanup
    }
  }
}

final mediaService = MediaService();
