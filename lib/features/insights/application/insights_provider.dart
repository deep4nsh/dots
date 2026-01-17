import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/ai_service.dart';
import '../../home/data/notes_provider.dart';

final dailyInsightProvider = FutureProvider<String?>((ref) async {
  final repository = ref.watch(notesRepositoryProvider);
  
  // 1. Get today's notes
  final notes = await repository.getTodaysNotes();
  
  if (notes.isEmpty) return null;
  
  // 2. Extract content
  final thoughts = notes.map((n) => n['content'] as String).toList();
  
  // 3. Generate Digest
  return await AIService().generateDailyDigest(thoughts);
});
