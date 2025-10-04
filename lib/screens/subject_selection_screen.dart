// screens/subject_selection_screen.dart
import 'package:flutter/material.dart';
import '../models/question.dart';
import 'gameplay_screen.dart';

class SubjectSelectionScreen extends StatelessWidget {
  final String subject;

  const SubjectSelectionScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subject),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Select Game Mode',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 48),
              _GameModeButton(
                icon: Icons.list,
                label: 'Multiple Choice',
                color: Colors.purple,
                onTap: () => _navigateToGame(context, QuestionType.mcq),
              ),
              const SizedBox(height: 16),
              _GameModeButton(
                icon: Icons.check_circle,
                label: 'True/False',
                color: Colors.teal,
                onTap: () => _navigateToGame(context, QuestionType.trueFalse),
              ),
              const SizedBox(height: 16),
              _GameModeButton(
                icon: Icons.lightbulb,
                label: 'Riddles',
                color: Colors.amber,
                onTap: () => _navigateToGame(context, QuestionType.riddle),
              ),
              const SizedBox(height: 16),
              _GameModeButton(
                icon: Icons.shuffle,
                label: 'Anagrams',
                color: Colors.red,
                onTap: () => _navigateToGame(context, QuestionType.anagram),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToGame(BuildContext context, QuestionType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameplayScreen(subject: subject, type: type),
      ),
    );
  }
}

class _GameModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _GameModeButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
