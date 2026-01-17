import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dump/data/notes_repository.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository();
});

final notesStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repository = ref.watch(notesRepositoryProvider);
  return repository.getNotesStream();
});
