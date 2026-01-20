import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class NotesRepository {
  final _client = Supabase.instance.client;

  // Create a new note
  Future<void> createNote({
    required String content,
    String? mood,
    String? summary,
    List<String>? keywords,
    List<String>? actionItems,
    int? emotionalIntensity,
    String? subconsciousDrivers,
    List<String>? cognitiveDistortions,
    List<String>? coreValues,
    List<String>? impactAreas,
    double? sentimentScore,
    String? reflectionQuestion,
    String? voiceUrl,
    String? imageUrl,
    String? linkUrl,
    bool isScan = false,
  }) async {
    try {
      final payload = {
        'content': content,
        'mood': mood,
        'summary': summary,
        'keywords': keywords,
        'action_items': actionItems,
        'emotional_intensity': emotionalIntensity,
        'subconscious_drivers': subconsciousDrivers,
        'cognitive_distortions': cognitiveDistortions,
        'core_values': coreValues,
        'impact_areas': impactAreas,
        'sentiment_score': sentimentScore,
        'reflection_question': reflectionQuestion,
        'voice_url': voiceUrl,
        'image_url': imageUrl,
        'link_url': linkUrl,
        'is_scan': isScan,
        'user_id': _client.auth.currentUser?.id,
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

  // Upload a file to Supabase Storage
  Future<String?> uploadFile(String filePath, String bucket) async {
    try {
      final file = File(filePath);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${filePath.split('/').last}';
      
      await _client.storage.from(bucket).upload(fileName, file);
      
      final String publicUrl = _client.storage.from(bucket).getPublicUrl(fileName);
      print("✅ File uploaded to $bucket: $publicUrl");
      return publicUrl;
    } catch (e) {
      print("❌ Error uploading file: $e");
      return null;
    }
  }

  // Get real-time stream of notes
  Stream<List<Map<String, dynamic>>> getNotesStream() {
    print("📡 NotesRepository: Initializing stream for 'notes' table...");
    final userId = _client.auth.currentUser?.id;
    return _client
        .from('notes')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId ?? '')
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
      final userId = _client.auth.currentUser?.id;
      final response = await _client
          .from('notes')
          .select()
          .eq('user_id', userId ?? '')
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
