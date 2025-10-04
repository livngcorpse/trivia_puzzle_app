// widgets/sync_choice_dialog.dart
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../providers/game_provider.dart';

class SyncChoiceDialog extends StatelessWidget {
  final UserProfile localProfile;
  final UserProfile cloudProfile;
  final int localTotal;
  final int cloudTotal;

  const SyncChoiceDialog({
    super.key,
    required this.localProfile,
    required this.cloudProfile,
    required this.localTotal,
    required this.cloudTotal,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.sync, color: Colors.blue),
          SizedBox(width: 8),
          Text('Sync Profile Data'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'We found existing data in your account and on this device. How would you like to proceed?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Local Profile Card
            _ProfileCard(
              title: '📱 This Device',
              username: localProfile.username,
              avatarIndex: localProfile.avatarIndex,
              totalScore: localTotal,
              color: Colors.orange,
            ),

            const SizedBox(height: 12),

            // Cloud Profile Card
            _ProfileCard(
              title: '☁️ Cloud Account',
              username: cloudProfile.username,
              avatarIndex: cloudProfile.avatarIndex,
              totalScore: cloudTotal,
              color: Colors.blue,
            ),

            const SizedBox(height: 24),

            const Text(
              'Choose an option:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Merge Button
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context, SyncStrategy.merge),
          icon: const Icon(Icons.merge),
          label: const Text('Smart Merge'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),

        // Keep Cloud Button
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context, SyncStrategy.keepCloud),
          icon: const Icon(Icons.cloud_download),
          label: const Text('Use Cloud'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue,
          ),
        ),

        // Keep Local Button
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context, SyncStrategy.keepLocal),
          icon: const Icon(Icons.phone_android),
          label: const Text('Use This Device'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.orange,
          ),
        ),
      ],
      actionsAlignment: MainAxisAlignment.spaceEvenly,
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String title;
  final String username;
  final int avatarIndex;
  final int totalScore;
  final Color color;

  const _ProfileCard({
    required this.title,
    required this.username,
    required this.avatarIndex,
    required this.totalScore,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage(
              'assets/avatars/avatar_$avatarIndex.png',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Score: $totalScore',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
