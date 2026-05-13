import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:dots_mobile/core/constants/media_constants.dart';
import '../../../../core/services/ai_service.dart';
import '../data/notes_repository.dart';

class DumpController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> saveDump(
    String text, {
    String? voicePath,
    String? voiceTranscription,
    String? imagePath,
    String? videoPath,
    String? linkUrl,
    bool isScan = false,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(notesRepositoryProvider);
      String? videoThumbnailPath;

      // 1. Extract video thumbnail for analysis (if video provided)
      if (videoPath != null) {
        videoThumbnailPath = await _extractVideoThumbnail(videoPath);
      }

      // 2. Analyze with AI (text + media) - on-device processing BEFORE upload
      final aiResult = await ref.read(aiServiceProvider).analyzeThought(
        text,
        imagePath: imagePath ?? videoThumbnailPath,
        voiceTranscription: voiceTranscription,
      );

      String? mood;
      String? summary;
      List<String>? keywords;
      List<String>? actionItems;
      int? emotionalIntensity;
      String? subconsciousDrivers;
      List<String>? cognitiveDistortions;
      List<String>? coreValues;
      List<String>? impactAreas;
      double? sentimentScore;
      String? reflectionQuestion;

      if (aiResult != null && aiResult.isNotEmpty) {
        mood = aiResult['mood']?.toString();
        summary = aiResult['summary']?.toString();
        keywords = (aiResult['keywords'] as List?)?.map((e) => e.toString()).toList();
        actionItems = (aiResult['action_items'] as List?)?.map((e) => e.toString()).toList();

        emotionalIntensity = aiResult['emotional_intensity'] is int
            ? aiResult['emotional_intensity']
            : int.tryParse(aiResult['emotional_intensity']?.toString() ?? '');

        subconsciousDrivers = aiResult['subconscious_drivers']?.toString();
        cognitiveDistortions = (aiResult['cognitive_distortions'] as List?)?.map((e) => e.toString()).toList();
        coreValues = (aiResult['core_values'] as List?)?.map((e) => e.toString()).toList();
        impactAreas = (aiResult['impact_areas'] as List?)?.map((e) => e.toString()).toList();

        sentimentScore = aiResult['sentiment_score'] is double
            ? aiResult['sentiment_score']
            : double.tryParse(aiResult['sentiment_score']?.toString() ?? '');

        reflectionQuestion = aiResult['reflection_question']?.toString();
      }

      // 3. Validate file sizes before upload (extra safety)
      if (voicePath != null && await File(voicePath).length() > MediaConstants.mbToBytes(MediaConstants.maxVoiceSizeMB)) {
        throw Exception("Voice recording exceeds size limit");
      }
      if (imagePath != null && await File(imagePath).length() > MediaConstants.mbToBytes(5)) { // Images are already compressed, 5MB is plenty
        throw Exception("Image exceeds size limit");
      }
      if (videoPath != null && await File(videoPath).length() > MediaConstants.mbToBytes(MediaConstants.maxVideoSizeMB)) {
        throw Exception("Video exceeds size limit");
      }

      // 4. Upload files in parallel (after analysis)
      final voiceFuture = voicePath != null ? repository.uploadFile(voicePath, 'voice_notes') : Future.value(null);
      final imageFuture = imagePath != null ? repository.uploadFile(imagePath, 'images') : Future.value(null);
      final videoFuture = videoPath != null ? repository.uploadFile(videoPath, 'videos') : Future.value(null);

      final uploadResults = await Future.wait([voiceFuture, imageFuture, videoFuture]);
      final voiceUrl = uploadResults[0];
      final imageUrl = uploadResults[1];
      final videoUrl = uploadResults[2];

      // 4. Save to Supabase
      await repository.createNote(
        content: text,
        mood: mood,
        summary: summary,
        keywords: keywords,
        actionItems: actionItems,
        emotionalIntensity: emotionalIntensity,
        subconsciousDrivers: subconsciousDrivers,
        cognitiveDistortions: cognitiveDistortions,
        coreValues: coreValues,
        impactAreas: impactAreas,
        sentimentScore: sentimentScore,
        reflectionQuestion: reflectionQuestion,
        voiceUrl: voiceUrl,
        imageUrl: imageUrl,
        videoUrl: videoUrl,
        linkUrl: linkUrl,
        isScan: isScan,
      );

      // 5. Cleanup local files after successful save
      await _cleanupLocalFiles([voicePath, imagePath, videoPath, videoThumbnailPath]);
    });
  }

  Future<String?> _extractVideoThumbnail(String videoPath) async {
    try {
      final dir = await getTemporaryDirectory();
      final thumbPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: dir.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 512,
        quality: 75,
      );
      return thumbPath;
    } catch (_) {
      return null;
    }
  }

  Future<void> _cleanupLocalFiles(List<String?> paths) async {
    for (final path in paths) {
      if (path == null) continue;
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        // Never fail a save because cleanup failed
      }
    }
  }
}

final dumpControllerProvider = AsyncNotifierProvider<DumpController, void>(DumpController.new);
