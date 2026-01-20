import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  GenerativeModel? _model;
  
  // Initialize the model with API key
  void init() {
    final apiKey = dotenv.env['GOOGLE_GENERATIVE_AI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print("⚠️ WARNING: GOOGLE_GENERATIVE_AI_API_KEY not found in .env");
      return;
    }
    
    // Initialize with relaxed safety settings for a private journal
    _model = GenerativeModel(
      model: 'gemini-pro', 
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7, 
        responseMimeType: 'application/json',
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
      ],
    );
    print("✅ AIService Initialized with model: gemini-pro (Safety relaxed)");
  }

  // Analyze a raw thought using Gemini
  Future<Map<String, dynamic>?> analyzeThought(String thought) async {
    if (_model == null) {
      print("❌ AIService: Model not initialized.");
      return null;
    }

    if (thought.trim().isEmpty) return null;

    print("🧠 AIService: Analyzing thought: '$thought'");

    // Define Schema for structured JSON output
    final responseSchema = Schema.object(
      properties: {
        'mood': Schema.string(description: 'The inferred mood of the user'),
        'summary': Schema.string(description: 'A concise 1-sentence summary'),
        'action_items': Schema.array(items: Schema.string(description: 'Actionable steps')),
        'keywords': Schema.array(items: Schema.string(description: '3-5 key topics')),
      },
      requiredProperties: ['mood', 'summary', 'action_items', 'keywords'],
    );

    final prompt = '''
    Analyze the following user thought for a minimalist journal.
    Extract the mood, a summary, action items (to-dos), and key topics.
    
    User Thought: "$thought"
    ''';

    try {
      final content = [Content.text(prompt)];
      
      final response = await _model!.generateContent(
        content,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: responseSchema,
          temperature: 0.4, 
        ),
      );
      
      // Log safety candidate if available
      if (response.candidates.isNotEmpty) {
        final finishReason = response.candidates.first.finishReason;
        if (finishReason != null && finishReason != FinishReason.stop) {
          print("⚠️ AIService: Content blocked or unfinished. Reason: $finishReason");
        }
      }

      final responseText = response.text;
      print("🧠 AIService: Raw response: $responseText");

      if (responseText == null || responseText.isEmpty) {
        print("⚠️ AIService: Gemini returned null or empty text.");
        return null;
      }

      // Sanitize response: Remove Markdown code blocks if present
      String cleanText = responseText;
      if (cleanText.contains('```json')) {
        cleanText = cleanText.replaceAll('```json', '').replaceAll('```', '');
      } else if (cleanText.contains('```')) {
        cleanText = cleanText.replaceAll('```', '');
      }
      
      cleanText = cleanText.trim();

      try {
        final Map<String, dynamic> decoded = jsonDecode(cleanText);
        print("✅ AIService: Successfully decoded JSON: $decoded");
        return decoded;
      } catch (e) {
        print("❌ AIService JSON Decode Error: $e");
        print("❌ Failed raw text: $cleanText");
        return null;
      }
    } catch (e, stack) {
      print("❌ AIService analyzeThought Error: $e");
      return null;
    }
  }

  // Synthesize multiple thoughts into a coherent Daily Digest
  Future<String?> generateDailyDigest(List<String> thoughts) async {
    if (_model == null) {
      print("❌ AIService: Model is null.");
      return null;
    }
    if (thoughts.isEmpty) {
      print("ℹ️ AIService: No thoughts to synthesize.");
      return null;
    }

    print("🧠 AIService: Synthesizing ${thoughts.length} thoughts...");
    
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

    Return the insight as PLAIN TEXT.
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(
        content,
        generationConfig: GenerationConfig(
          responseMimeType: 'text/plain',
          temperature: 0.7,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
        ],
      );
      
      final text = response.text;
      if (text == null || text.isEmpty) {
        print("⚠️ AIService: Gemini returned empty text.");
        return null;
      }
      return text;
    } catch (e, stack) {
      print("❌ AIService Error: $e");
      return null;
    }
  }
}
