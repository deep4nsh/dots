import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/ai_service.dart';
import '../data/notes_repository.dart';

class DumpController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> saveDump(String text) async {
    if (text.trim().isEmpty) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // 1. Analyze with AI
      final aiResult = await AIService().analyzeThought(text);
      
      String? mood;
      String? summary;
      List<String>? keywords;
      List<String>? actionItems;

      if (aiResult != null) {
        print('🧠 AI Analysis Result: $aiResult');
        mood = aiResult['mood']?.toString();
        summary = aiResult['summary']?.toString();
        keywords = (aiResult['keywords'] as List?)?.map((e) => e.toString()).toList();
        actionItems = (aiResult['action_items'] as List?)?.map((e) => e.toString()).toList();
      } else {
        print('❌ AI Analysis Failed or returned null');
      }

      // 2. Save to Supabase (Cloud)
      await NotesRepository().createNote(
        content: text,
        mood: mood,
        summary: summary,
        keywords: keywords,
        actionItems: actionItems,
      );
    });
  }
}

final dumpControllerProvider = AsyncNotifierProvider<DumpController, void>(DumpController.new);
