import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/ai_service.dart';
import '../../home/data/notes_provider.dart';

final dailyInsightProvider = FutureProvider<String?>((ref) async {
  // Watch the stream provider so this re-runs whenever the timeline changes
  final notesAsync = ref.watch(notesStreamProvider);
  
  return notesAsync.when(
    data: (notes) async {
      if (notes.isEmpty) return null;

      // Filter for today's notes only
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      
      final todaysNotes = notes.where((n) {
        final createdAt = DateTime.parse(n['created_at']);
        return createdAt.isAfter(startOfToday);
      }).toList();

      if (todaysNotes.isEmpty) return null;

      // Extract content
      final thoughts = todaysNotes.map((n) => n['content'] as String).toList();

      // Generate Digest
      return await AIService().generateDailyDigest(thoughts);
    },
    loading: () => null,
    error: (err, stack) => null,
  );
});
