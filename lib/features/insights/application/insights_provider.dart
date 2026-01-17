import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/ai_service.dart';
import '../../home/data/notes_provider.dart';

final dailyInsightProvider = FutureProvider<String?>((ref) async {
  // 1. Await the latest notes from the stream
  final notes = await ref.watch(notesStreamProvider.future);
  
  if (notes.isEmpty) {
    print("ℹ️ Synthesis: No notes found in stream.");
    return null;
  }

  // 2. Filter for today's notes (resilient to UTC/Local mismatch)
  // We'll broaden the definition of 'today' to the last 24 hours to be safe
  final now = DateTime.now();
  final last24Hours = now.subtract(const Duration(hours: 24)).toUtc();
  
  final todaysNotes = notes.where((n) {
    final createdAt = DateTime.parse(n['created_at']).toUtc();
    return createdAt.isAfter(last24Hours);
  }).toList();

  print("ℹ️ Synthesis: Total notes: ${notes.length}");
  print("ℹ️ Synthesis: Found ${todaysNotes.length} notes in last 24h.");

  if (todaysNotes.isEmpty) {
    // If absolutely nothing in 24h, take the latest 5 regardless of time
    print("ℹ️ Synthesis: Falling back to latest 5 notes overall.");
    final fallbackNotes = notes.take(5).toList();
    final thoughts = fallbackNotes.map((n) => n['content'] as String).toList();
    return await AIService().generateDailyDigest(thoughts);
  }

  // 3. Extract content
  final thoughts = todaysNotes.map((n) => n['content'] as String).toList();

  // 4. Generate Digest
  return await AIService().generateDailyDigest(thoughts);
});
