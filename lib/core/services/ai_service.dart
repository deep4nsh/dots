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
    
    _model = GenerativeModel(
      model: 'gemini-pro', 
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7, // Creative but grounded
        responseMimeType: 'application/json', // Force JSON output
      ),
    );
    print("✅ AIService Initialized with Gemini");
  }

  // Analyze a raw thought using Gemini
  Future<Map<String, dynamic>?> analyzeThought(String thought) async {
    if (_model == null) {
      print("❌ AIService not initialized. Check API Key.");
      return null;
    }

    if (thought.trim().isEmpty) return null;

    final prompt = '''
    You are an AI assistant for a minimalist thought capture app called 'dots'. 
    Analyze the following user thought and extract structured data.
    
    User Thought: "$thought"
    
    Return a STRICT JSON object with these fields:
    - "mood": (String) The inferred mood/tone (e.g., "Anxious", "Excited", "Neutral").
    - "summary": (String) A concise 1-sentence summary of the thought.
    - "action_items": (List<String>) Any tasks, to-dos, or actionable steps implied. If none, return empty list.
    - "keywords": (List<String>) 3-5 key topics.
    
    JSON:
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      final responseText = response.text;
      if (responseText == null) return null;

      // Clean markdown code blocks if present (e.g. ```json ... ```)
      String cleanJson = responseText.replaceAll(RegExp(r'^```json\s*|\s*```$'), '');
      
      return jsonDecode(cleanJson);
    } catch (e) {
      print("❌ Error analyzing thought: $e");
      return null;
    }
  }
}
