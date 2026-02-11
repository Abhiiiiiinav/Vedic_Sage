import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKeys {
  /// Gemini API Key — loaded from .env file
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
}
