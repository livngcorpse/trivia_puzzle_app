// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_screen.dart';
import '../providers/game_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _usernameController = TextEditingController();
  bool _isEditingUsername = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildAvatarSection(profile),
            const SizedBox(height: 24),
            _buildUsernameSection(profile),
            const SizedBox(height: 32),

            // ✅ FIXED: Simpler login/logout UI
            if (currentUser == null)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text("Login with Email"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              )
            else
              Column(
                children: [
                  Text(
                    '✅ Logged in as: ${currentUser.email}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                      await ref.read(profileProvider.notifier).resetToGuest();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Logged out successfully'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Scores by Subject',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...profile.subjectScores.map((subjectScore) {
              return _buildSubjectCard(subjectScore);
            }),
          ],
        ),
      ),
    );
  }

  // Avatar section with image assets
  Widget _buildAvatarSection(profile) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.transparent,
          backgroundImage:
              AssetImage('assets/avatars/avatar_${profile.avatarIndex}.png'),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => _showAvatarPicker(profile.avatarIndex),
          icon: const Icon(Icons.edit),
          label: const Text('Change Avatar'),
        ),
      ],
    );
  }

  Widget _buildUsernameSection(profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.person),
            const SizedBox(width: 16),
            Expanded(
              child: _isEditingUsername
                  ? TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                      autofocus: true,
                    )
                  : Text(
                      profile.username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(_isEditingUsername ? Icons.check : Icons.edit),
              onPressed: () {
                if (_isEditingUsername) {
                  final newName = _usernameController.text.trim();
                  if (newName.isNotEmpty) {
                    ref.read(profileProvider.notifier).updateUsername(newName);
                  }
                } else {
                  _usernameController.text = profile.username;
                }
                setState(() {
                  _isEditingUsername = !_isEditingUsername;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(subjectScore) {
    final totalScore = subjectScore.getTotalScore();
    IconData icon;
    Color color;

    switch (subjectScore.subject) {
      case 'Math':
        icon = Icons.calculate;
        color = Colors.blue;
        break;
      case 'Physics':
        icon = Icons.science;
        color = Colors.green;
        break;
      case 'Computers':
        icon = Icons.computer;
        color = Colors.orange;
        break;
      default:
        icon = Icons.quiz;
        color = Colors.purple;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(
          subjectScore.subject,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('Total Score: $totalScore'),
        children: [
          if (subjectScore.gameModeScores.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No games played yet'),
            )
          else
            ...subjectScore.gameModeScores.map((gameMode) {
              return ListTile(
                leading: _getGameModeIcon(gameMode.gameMode),
                title: Text(gameMode.gameMode),
                trailing: Text(
                  '${gameMode.score} pts',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Icon _getGameModeIcon(String gameMode) {
    switch (gameMode) {
      case 'Multiple Choice':
        return const Icon(Icons.list, color: Colors.purple);
      case 'True/False':
        return const Icon(Icons.check_circle, color: Colors.teal);
      case 'Riddles':
        return const Icon(Icons.lightbulb, color: Colors.amber);
      case 'Anagrams':
        return const Icon(Icons.shuffle, color: Colors.red);
      default:
        return const Icon(Icons.quiz);
    }
  }

  // ✅ FIXED: Avatar picker with avatar images
  void _showAvatarPicker(int currentIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Avatar'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 20,
            itemBuilder: (context, index) {
              final isSelected = currentIndex == index;

              return InkWell(
                onTap: () {
                  ref.read(profileProvider.notifier).updateAvatar(index);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3,
                          )
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/avatars/avatar_$index.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
