import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/ai_provider.dart';

class DumpController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state is null/void
    return null;
  }

  Future<void> saveDump(String text) async {
    if (text.trim().isEmpty) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final aiService = ref.read(aiServiceProvider);
      // For now, just print the response. In real app, save to DB.
      final response = await aiService.generateInsight('Analyze this thought: "$text"');
      print('AI Insight: $response');
    });
  }
}

final dumpControllerProvider = AsyncNotifierProvider<DumpController, void>(DumpController.new);
