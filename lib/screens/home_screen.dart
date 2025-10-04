// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import 'subject_selection_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trivia Puzzle'),
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(
                "assets/avatars/avatar_${profile.avatarIndex}.png",
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
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
              Icon(
                Icons.quiz,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Select a Subject',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 48),
              _SubjectButton(
                icon: Icons.calculate,
                label: 'Math',
                color: Colors.blue,
                onTap: () => _navigateToSubject(context, 'Math'),
              ),
              const SizedBox(height: 16),
              _SubjectButton(
                icon: Icons.science,
                label: 'Physics',
                color: Colors.green,
                onTap: () => _navigateToSubject(context, 'Physics'),
              ),
              const SizedBox(height: 16),
              _SubjectButton(
                icon: Icons.computer,
                label: 'Computers',
                color: Colors.orange,
                onTap: () => _navigateToSubject(context, 'Computers'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSubject(BuildContext context, String subject) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubjectSelectionScreen(subject: subject),
      ),
    );
  }
}

class _SubjectButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SubjectButton({
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 24,
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
