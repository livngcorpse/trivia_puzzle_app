// models/question.dart
class Question {
  final String question;
  final String correctAnswer;
  final List<String>? options;
  final String? hint;
  final QuestionType type;

  Question({
    required this.question,
    required this.correctAnswer,
    this.options,
    this.hint,
    required this.type,
  });

  factory Question.fromApi(Map<String, dynamic> json) {
    final type =
        json['type'] == 'boolean' ? QuestionType.trueFalse : QuestionType.mcq;

    List<String> options = [];
    if (type == QuestionType.mcq) {
      options = List<String>.from(json['incorrect_answers']);
      options.add(json['correct_answer']);
      options.shuffle();
    } else {
      options = ['True', 'False'];
    }

    return Question(
      question: _decodeHtml(json['question']),
      correctAnswer: _decodeHtml(json['correct_answer']),
      options: options.map((o) => _decodeHtml(o)).toList(),
      type: type,
    );
  }

  factory Question.riddle(String q, String a) {
    return Question(
      question: q,
      correctAnswer: a,
      type: QuestionType.riddle,
    );
  }

  factory Question.anagram(String word, String hint) {
    return Question(
      question: _scrambleWord(word),
      correctAnswer: word,
      hint: hint,
      type: QuestionType.anagram,
    );
  }

  static String _decodeHtml(String text) {
    return text
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }

  static String _scrambleWord(String word) {
    final chars = word.split('')..shuffle();
    return chars.join();
  }
}

enum QuestionType { mcq, trueFalse, riddle, anagram }
