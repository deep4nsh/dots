import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  late final GenerativeModel _model;

  AIService() {
    final apiKey = dotenv.env['GOOGLE_GENERATIVE_AI_API_KEY'];
    if (apiKey == null) {
      throw Exception('GOOGLE_GENERATIVE_AI_API_KEY not found in .env');
    }
    
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  Future<String?> generateInsight(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text;
    } catch (e) {
      print('AI Service Error: $e');
      return null;
    }
  }

  // Future expansion: embeddings, chat, etc.
}
