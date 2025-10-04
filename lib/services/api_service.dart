// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class ApiService {
  static const String baseUrl = 'https://opentdb.com/api.php';

  static final Map<String, int> categoryIds = {
    'Math': 19,
    'Physics': 17,
    'Computers': 18,
  };

  Future<List<Question>> fetchQuestions(
    String subject,
    QuestionType type, {
    int amount = 10,
  }) async {
    try {
      final categoryId = categoryIds[subject] ?? 18;
      final typeParam = type == QuestionType.mcq ? 'multiple' : 'boolean';

      final url = Uri.parse(
          '$baseUrl?amount=$amount&category=$categoryId&type=$typeParam');

      final response = await http.get(url).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((q) => Question.fromApi(q)).toList();
      }
      throw Exception('Failed to load questions');
    } catch (e) {
      rethrow;
    }
  }
}
