import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'media_service.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  String? _groqApiKey;

  static const String _groqBaseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _groqModel = 'llama-3.3-70b-versatile';

  // Initialize with API key from .env
  void init() {
    _groqApiKey = dotenv.env['GROQ_API_KEY'];
    mediaService.init();

    if (_groqApiKey == null || _groqApiKey!.isEmpty) {
      // debugPrint("⚠️ WARNING: GROQ_API_KEY not found in .env");
    }
  }

  // Analyze thought with optional media (images, audio, video)
  // On-device processing for media + Groq for psychological analysis
  Future<Map<String, dynamic>?> analyzeThought(
    String thought, {
    String? imagePath,
    String? voiceTranscription,
    String? videoPath,
  }) async {
    String enrichedThought = thought;

    // On-device analysis of media (no API costs)
    if (imagePath != null || voiceTranscription != null) {
      enrichedThought = await mediaService.enrichMediaContext(
        thought,
        imagePath: imagePath,
        voiceTranscription: voiceTranscription,
      );
    }

    // Send enriched text to Groq for psychological analysis
    return _analyzeWithGroq(enrichedThought);
  }

  // Analyze using Groq (text-only, cheaper)
  Future<Map<String, dynamic>?> _analyzeWithGroq(String thought) async {
    if (_groqApiKey == null) {
      return null;
    }

    if (thought.trim().isEmpty) return null;

    final prompt = '''
    Deeply analyze the following user thought for a minimalist psychological journal.
    Extract the following minute details to help find real, non-generic patterns:

    - mood: The core emotion.
    - summary: 1 concise sentence.
    - emotional_intensity: Scale of 1-10.
    - subconscious_drivers: The "why" behind the thought (e.g., perfectionism, fear of loss, need for validation).
    - cognitive_distortions: List types if present (e.g., All-or-Nothing, Overgeneralization, Mind Reading).
    - core_values: What values are being honored or violated (e.g., Freedom, Integrity, Security).
    - impact_areas: Which life areas (e.g., Career, Health, Relationships).
    - sentiment_score: -1.0 to 1.0.
    - reflection_question: A deep, personalized follow-up for the user.
    - keywords: 3-5 key topics.

    User Thought: "$thought"

    Respond ONLY with a JSON object in this format:
    {
      "mood": "string",
      "summary": "string",
      "emotional_intensity": integer,
      "subconscious_drivers": "string",
      "cognitive_distortions": ["string"],
      "core_values": ["string"],
      "impact_areas": ["string"],
      "sentiment_score": float,
      "reflection_question": "string",
      "action_items": ["string"],
      "keywords": ["string"]
    }
    ''';

    try {
      final response = await http.post(
        Uri.parse(_groqBaseUrl),
        headers: {
          'Authorization': 'Bearer $_groqApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _groqModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful assistant that outputs structured JSON journal metadata.'
            },
            {'role': 'user', 'content': prompt}
          ],
          'response_format': {'type': 'json_object'},
          'temperature': 0.1,
        }),
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);
      final String content = data['choices'][0]['message']['content'];

      final Map<String, dynamic> decoded = jsonDecode(content);
      return decoded;
    } catch (e) {
      return null;
    }
  }


  // Synthesize multiple thoughts into a coherent Daily Digest
  Future<String?> generateDailyDigest(List<String> thoughts) async {
    if (_groqApiKey == null) {
      return null;
    }
    if (thoughts.isEmpty) return null;

    final thoughtsList = thoughts.map((t) => "- $t").join("\n");

    final prompt = '''
    You are an AI assistant for 'dots', a minimalist thought journal.
    Below are the user's raw thoughts captured today:

    $thoughtsList

    TASK:
    1. Identify common themes or repeating patterns.
    2. Synthesize these into a single, cohesive "Daily Insight".
    3. Keep it to 1-2 paragraphs max, high-quality, and reflective.
    4. Focus on "connecting the dots" between scattered ideas.
    ''';

    try {
      final response = await http.post(
        Uri.parse(_groqBaseUrl),
        headers: {
          'Authorization': 'Bearer $_groqApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _groqModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a thoughtful observer who finds patterns in scattered ideas.'
            },
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String;
    } catch (e) {
      return null;
    }
  }
}

final aiServiceProvider = Provider((ref) => AIService());
