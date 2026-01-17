import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/ai_service.dart';

class DumpController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> saveDump(String text) async {
    if (text.trim().isEmpty) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Use the new Singleton Service
      final result = await AIService().analyzeThought(text);
      
      if (result != null) {
        print('🧠 AI Analysis Result:');
        print('Mood: ${result['mood']}');
        print('Summary: ${result['summary']}');
        print('Keywords: ${result['keywords']}');
        print('Actions: ${result['action_items']}');
      } else {
        print('❌ AI Analysis Failed or returned null');
      }
    });
  }
}

final dumpControllerProvider = AsyncNotifierProvider<DumpController, void>(DumpController.new);
