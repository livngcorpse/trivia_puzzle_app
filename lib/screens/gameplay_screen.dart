// screens/gameplay_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import '../providers/game_provider.dart';

class GameplayScreen extends ConsumerStatefulWidget {
  final String subject;
  final QuestionType type;

  const GameplayScreen({
    super.key,
    required this.subject,
    required this.type,
  });

  @override
  ConsumerState<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends ConsumerState<GameplayScreen> {
  int currentIndex = 0;
  int totalScore = 0;
  String? selectedAnswer;
  bool showFeedback = false;
  bool hintUsed = false;
  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(
      questionsProvider(GameConfig(widget.subject, widget.type)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject} - ${_getGameModeName()}'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Score: $totalScore',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: questionsAsync.when(
        data: (questions) {
          if (questions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No questions available',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please check your internet connection',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          if (currentIndex >= questions.length) {
            return _buildResultScreen();
          }

          final question = questions[currentIndex];
          return _buildQuestionView(question);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Offline Mode',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('Loading cached questions...'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionView(Question question) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: (currentIndex + 1) / 10,
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Question ${currentIndex + 1}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                question.question,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (widget.type == QuestionType.mcq ||
              widget.type == QuestionType.trueFalse)
            ..._buildOptions(question),
          if (widget.type == QuestionType.riddle ||
              widget.type == QuestionType.anagram)
            ..._buildTextInput(question),
          const SizedBox(height: 24),
          if (showFeedback) _buildFeedback(question),
        ],
      ),
    );
  }

  List<Widget> _buildOptions(Question question) {
    return question.options!.map((option) {
      final isSelected = selectedAnswer == option;
      final isCorrect = option == question.correctAnswer;
      final showCorrect = showFeedback && isCorrect;
      final showWrong = showFeedback && isSelected && !isCorrect;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: showCorrect
                ? Colors.green
                : showWrong
                    ? Colors.red
                    : isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white,
            foregroundColor:
                isSelected || showFeedback ? Colors.white : Colors.black,
            padding: const EdgeInsets.all(16),
            elevation: isSelected ? 8 : 2,
          ),
          onPressed: showFeedback ? null : () => _selectAnswer(option),
          child: Text(
            option,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildTextInput(Question question) {
    return [
      if (question.hint != null && !hintUsed)
        ElevatedButton.icon(
          onPressed: () {
            setState(() => hintUsed = true);
          },
          icon: const Icon(Icons.help),
          label: const Text('Show Hint'),
        ),
      if (hintUsed && question.hint != null) ...[
        const SizedBox(height: 12),
        Card(
          color: Colors.amber[100],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.hint!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      const SizedBox(height: 16),
      TextField(
        controller: textController,
        decoration: const InputDecoration(
          labelText: 'Your Answer',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.edit),
        ),
        textCapitalization: TextCapitalization.none,
        enabled: !showFeedback,
      ),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: showFeedback ? null : () => _submitTextAnswer(question),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
        ),
        child: const Text('Submit Answer', style: TextStyle(fontSize: 16)),
      ),
    ];
  }

  Widget _buildFeedback(Question question) {
    final isCorrect = selectedAnswer == question.correctAnswer ||
        (textController.text.trim().toLowerCase() ==
            question.correctAnswer.toLowerCase());

    return Card(
      color: isCorrect ? Colors.green[100] : Colors.red[100],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isCorrect ? 'Correct!' : 'Incorrect',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.green[900] : Colors.red[900],
                    ),
                  ),
                ),
              ],
            ),
            if (!isCorrect) ...[
              const SizedBox(height: 8),
              Text(
                'Correct answer: ${question.correctAnswer}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _nextQuestion,
              child: const Text('Next Question'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_events,
            size: 100,
            color: Colors.amber,
          ),
          const SizedBox(height: 24),
          Text(
            'Quiz Complete!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Final Score: $totalScore',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Subject Selection'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  void _selectAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
    });
    _submitAnswer();
  }

  void _submitTextAnswer(Question question) {
    final answer = textController.text.trim();
    if (answer.isEmpty) return;

    final isCorrect =
        answer.toLowerCase() == question.correctAnswer.toLowerCase();

    if (isCorrect) {
      setState(() {
        selectedAnswer = question.correctAnswer;
        showFeedback = true;
      });
      _updateScore(question);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Try again!'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _submitAnswer() {
    final question = ref
        .read(questionsProvider(GameConfig(widget.subject, widget.type)))
        .value![currentIndex];

    setState(() {
      showFeedback = true;
    });

    _updateScore(question);
  }

  void _updateScore(Question question) {
    final isCorrect = selectedAnswer == question.correctAnswer ||
        (textController.text.trim().toLowerCase() ==
            question.correctAnswer.toLowerCase());

    int points = 0;
    if (widget.type == QuestionType.mcq ||
        widget.type == QuestionType.trueFalse) {
      points = isCorrect ? 10 : -5;
    } else if (widget.type == QuestionType.riddle ||
        widget.type == QuestionType.anagram) {
      if (isCorrect) {
        points = hintUsed ? 10 : 20;
      }
    }

    setState(() {
      totalScore += points;
    });

    ref
        .read(profileProvider.notifier)
        .addScore(widget.subject, _getGameModeName(), points);
  }

  void _nextQuestion() {
    setState(() {
      currentIndex++;
      selectedAnswer = null;
      showFeedback = false;
      hintUsed = false;
      textController.clear();
    });
  }

  String _getGameModeName() {
    switch (widget.type) {
      case QuestionType.mcq:
        return 'Multiple Choice';
      case QuestionType.trueFalse:
        return 'True/False';
      case QuestionType.riddle:
        return 'Riddles';
      case QuestionType.anagram:
        return 'Anagrams';
    }
  }
}
