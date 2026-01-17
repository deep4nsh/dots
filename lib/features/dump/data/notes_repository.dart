import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';

class NotesRepository {
  final SupabaseClient _client = SupabaseService().client;

  Future<void> createNote({
    required String content,
    String? mood,
    String? summary,
    List<String>? keywords,
  }) async {
    try {
      await _client.from('notes').insert({
        'content': content,
        'mood': mood,
        'summary': summary,
        'keywords': keywords,
        // 'user_id': _client.auth.currentUser?.id, // Uncomment when Auth is ready
      });
      print("✅ Note saved to Supabase!");
    } catch (e) {
      print("❌ Error saving note: $e");
      throw Exception('Failed to save note: $e');
    }
  }
}
