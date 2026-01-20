import 'package:supabase_flutter/supabase_flutter.dart';

class NotesRepository {
  final _client = Supabase.instance.client;

  // Create a new note
  Future<void> createNote({
    required String content,
    String? mood,
    String? summary,
    List<String>? keywords,
    List<String>? actionItems,
  }) async {
    try {
      final payload = {
        'content': content,
        'mood': mood,
        'summary': summary,
        'keywords': keywords,
        'action_items': actionItems,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      };
      print("📤 Saving to Supabase Payload: $payload");
      await _client.from('notes').insert(payload);
      print("✅ Note saved to Supabase");
    } catch (e) {
      print("❌ Error saving note: $e");
      rethrow;
    }
  }

  // Get real-time stream of notes
  Stream<List<Map<String, dynamic>>> getNotesStream() {
    print("📡 NotesRepository: Initializing stream for 'notes' table...");
    return _client
        .from('notes')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(50)
        .map((data) {
          print("📡 NotesRepository: Stream received ${data.length} notes");
          if (data.isNotEmpty) {
            print("📡 NotesRepository: First note preview: ${data.first['content']}");
          }
          return List<Map<String, dynamic>>.from(data);
        });
  }

  // Fetch all notes from today
  Future<List<Map<String, dynamic>>> getTodaysNotes() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toUtc().toIso8601String();
    
    try {
      final response = await _client
          .from('notes')
          .select()
          .gte('created_at', startOfDay)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("❌ Error fetching today's notes: $e");
      return [];
    }
  }

  // Simple fetch for testing connectivity
  Future<List<Map<String, dynamic>>> testFetch() async {
    try {
      print("🧪 NotesRepository: Running testFetch()...");
      final response = await _client.from('notes').select().limit(10);
      print("🧪 NotesRepository: testFetch found ${response.length} items");
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("❌ NotesRepository: testFetch FAILED: $e");
      return [];
    }
  }
}
