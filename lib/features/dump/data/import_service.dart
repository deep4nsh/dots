import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notes_repository.dart';

class ImportService {
  final NotesRepository _notesRepository = NotesRepository();
  final SupabaseClient _client = Supabase.instance.client;

  // Singleton pattern
  static final ImportService _instance = ImportService._internal();
  factory ImportService() => _instance;
  ImportService._internal();

  /// Listen for incoming share intents (text, images)
  void listenForShareIntent(BuildContext context, Function(Map<String, dynamic> noteData) onNoteReceived) {
    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) {
      _processSharedMedia(value, onNoteReceived);
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
      _processSharedMedia(value, onNoteReceived);
      ReceiveSharingIntent.instance.reset(); // clear to avoid reprocessing
    });
  }

  void _processSharedMedia(List<SharedMediaFile> files, Function(Map<String, dynamic> noteData) onNoteReceived) {
    if (files.isEmpty) return;

    // Use the first file/text for now as a simple implementation
    final file = files.first;
    String content = "";
    String? imageUrl;
    String? voiceUrl; // Not typically shared via "Send" intent as primary but possible

    if (file.type == SharedMediaType.text) {
        content = file.path; // For text, path contains the text
    } else if (file.type == SharedMediaType.url) {
       content = file.path; // URL is also text
    } else if (file.type == SharedMediaType.image) {
      // It's a file path to the image in the cache
      // We will need to upload this or pass the path to the UI to confirm before uploading
      // For now, let's pass the local path and let the UI handle upload or display
      imageUrl = file.path;
      content = "Shared Image";
    }

    if (content.isNotEmpty || imageUrl != null) {
      onNoteReceived({
        'content': content,
        'image_url': imageUrl, // Local path initially
        'is_shared': true,
      });
    }
  }

  /// Import notes from a file (e.g., Google Keep JSON)
  Future<void> importFromFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'txt'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
        String extension = result.files.single.extension?.toLowerCase() ?? '';

        if (extension == 'json') {
          await _parseAndImportJson(content);
        } else {
           // Treat as plain text note
           await _notesRepository.createNote(content: content);
        }
      }
    } catch (e) {
      print("Error importing file: $e");
    }
  }

  Future<void> _parseAndImportJson(String jsonContent) async {
    try {
      final decoded = jsonDecode(jsonContent);
      
      // Google Keep Takeout format usually comes as a list of notes or single files.
      // If single file represents one note:
      if (decoded is Map<String, dynamic>) {
        await _importSingleKeepNote(decoded);
      } else if (decoded is List) {
        for (var item in decoded) {
           if (item is Map<String, dynamic>) {
             await _importSingleKeepNote(item);
           }
        }
      }
    } catch (e) {
      print("Error parsing JSON: $e");
    }
  }

  Future<void> _importSingleKeepNote(Map<String, dynamic> noteData) async {
    // Mapping Logic for Google Keep JSON
    // Keep JSON structure varies, but typically:
    // { "textContent": "...", "title": "...", "labels": [...], "attachments": [...] }
    
    String content = "";
    if (noteData.containsKey('title') && noteData['title'].toString().isNotEmpty) {
      content += "${noteData['title']}\n\n";
    }
    if (noteData.containsKey('textContent')) {
      content += noteData['textContent'];
    }
    
    // Check for list items (checklist)
    if (noteData.containsKey('listContent')) {
       // Handle checklist
       var list = noteData['listContent'] as List;
       for(var item in list) {
         content += "\n- ${item['text']}"; // Simple text conversion for now
       }
    }

    if (content.trim().isEmpty) return; // Skip empty imports

    await _notesRepository.createNote(
      content: content,
      isScan: false,
      // Attempt to map timestamp if available, otherwise repo handles current time
    );
  }
}
