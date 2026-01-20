import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    String? imagePath,
    String? linkUrl,
    bool isScan = false,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = NotesRepository();
      
      // 1. Upload files if any
      String? voiceUrl;
      String? imageUrl;
      
      if (voicePath != null) {
        voiceUrl = await repository.uploadFile(voicePath, 'voice_notes');
      }
      if (imagePath != null) {
        imageUrl = await repository.uploadFile(imagePath, 'images');
      }

      // 2. Analyze with AI
      final aiResult = await AIService().analyzeThought(text);
      
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
        print('🧠 DumpController: AI Analysis Result (parsed JSON): $aiResult');
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

        print('🧠 DumpController: Mapped granular values success');
      } else {
        print('❌ DumpController: AI Analysis Failed or empty. aiResult: $aiResult');
      }

      // 3. Save to Supabase (Cloud)
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
        linkUrl: linkUrl,
        isScan: isScan,
      );
    });
  }
}

final dumpControllerProvider = AsyncNotifierProvider<DumpController, void>(DumpController.new);
