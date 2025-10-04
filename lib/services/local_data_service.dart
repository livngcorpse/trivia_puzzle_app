// services/local_data_service.dart
import 'package:flutter/services.dart';
import '../models/question.dart';

class LocalDataService {
  Future<List<Question>> loadRiddles(String subject) async {
    try {
      final content = await rootBundle
          .loadString('assets/riddles/${subject.toLowerCase()}.txt');
      return _parseRiddles(content);
    } catch (e) {
      return [];
    }
  }

  Future<List<Question>> loadAnagrams(String subject) async {
    try {
      final content = await rootBundle
          .loadString('assets/anagrams/${subject.toLowerCase()}.txt');
      return _parseAnagrams(content);
    } catch (e) {
      return [];
    }
  }

  List<Question> _parseRiddles(String content) {
    final questions = <Question>[];
    final lines = content.split('\n');

    for (int i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('Question:')) {
        final q = lines[i].substring(9).trim();
        if (i + 1 < lines.length && lines[i + 1].startsWith('Answer:')) {
          final a = lines[i + 1].substring(7).trim();
          questions.add(Question.riddle(q, a));
          i++;
        }
      }
    }
    return questions;
  }

  List<Question> _parseAnagrams(String content) {
    final questions = <Question>[];
    final lines = content.split('\n');

    for (int i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('Word:')) {
        final word = lines[i].substring(5).trim();
        if (i + 1 < lines.length && lines[i + 1].startsWith('Hint:')) {
          final hint = lines[i + 1].substring(5).trim();
          questions.add(Question.anagram(word, hint));
          i++;
        }
      }
    }
    return questions;
  }
}
