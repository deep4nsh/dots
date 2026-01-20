import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dump/data/notes_repository.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository();
});

final notesStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repository = ref.watch(notesRepositoryProvider);
  return repository.getNotesStream();
});

final todaysNotesStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repository = ref.watch(notesRepositoryProvider);
  
  return repository.getNotesStream().map((notes) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    
    return notes.where((note) {
      final createdAt = DateTime.parse(note['created_at']).toLocal();
      return createdAt.isAfter(startOfToday);
    }).toList();
  });
});
