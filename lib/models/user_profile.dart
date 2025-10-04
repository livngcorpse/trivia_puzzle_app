// models/user_profile.dart
import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  int avatarIndex;

  @HiveField(2)
  List<SubjectScore> subjectScores;

  UserProfile({
    required this.username,
    required this.avatarIndex,
    required this.subjectScores,
  });

  factory UserProfile.empty() {
    return UserProfile(
      username: 'Player',
      avatarIndex: 0,
      subjectScores: [
        SubjectScore(subject: 'Math', gameModeScores: []),
        SubjectScore(subject: 'Physics', gameModeScores: []),
        SubjectScore(subject: 'Computers', gameModeScores: []),
      ],
    );
  }

  // ✅ Added copyWith method
  UserProfile copyWith({
    String? username,
    int? avatarIndex,
    List<SubjectScore>? subjectScores,
  }) {
    return UserProfile(
      username: username ?? this.username,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      subjectScores: subjectScores ?? this.subjectScores,
    );
  }

  // ✅ Added toJson method
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'avatarIndex': avatarIndex,
      'subjectScores': subjectScores.map((s) => s.toJson()).toList(),
    };
  }

  // ✅ Added fromJson factory
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'] ?? 'Player',
      avatarIndex: json['avatarIndex'] ?? 0,
      subjectScores: (json['subjectScores'] as List?)
              ?.map((s) => SubjectScore.fromJson(s))
              .toList() ??
          [
            SubjectScore(subject: 'Math', gameModeScores: []),
            SubjectScore(subject: 'Physics', gameModeScores: []),
            SubjectScore(subject: 'Computers', gameModeScores: []),
          ],
    );
  }

  // ✅ Added totalScore method
  int totalScore() {
    return subjectScores.fold(0, (sum, s) => sum + s.getTotalScore());
  }
}

@HiveType(typeId: 1)
class SubjectScore {
  @HiveField(0)
  String subject;

  @HiveField(1)
  List<GameModeScore> gameModeScores;

  SubjectScore({required this.subject, required this.gameModeScores});

  int getTotalScore() {
    return gameModeScores.fold(0, (sum, gms) => sum + gms.score);
  }

  void updateScore(String gameMode, int points) {
    final existing = gameModeScores.firstWhere(
      (gms) => gms.gameMode == gameMode,
      orElse: () {
        final newScore = GameModeScore(gameMode: gameMode, score: 0);
        gameModeScores.add(newScore);
        return newScore;
      },
    );
    existing.score += points;
  }

  // ✅ Added toJson method
  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'gameModeScores': gameModeScores.map((g) => g.toJson()).toList(),
    };
  }

  // ✅ Added fromJson factory
  factory SubjectScore.fromJson(Map<String, dynamic> json) {
    return SubjectScore(
      subject: json['subject'] ?? '',
      gameModeScores: (json['gameModeScores'] as List?)
              ?.map((g) => GameModeScore.fromJson(g))
              .toList() ??
          [],
    );
  }
}

@HiveType(typeId: 2)
class GameModeScore {
  @HiveField(0)
  String gameMode;

  @HiveField(1)
  int score;

  GameModeScore({required this.gameMode, required this.score});

  // ✅ Added toJson method
  Map<String, dynamic> toJson() {
    return {
      'gameMode': gameMode,
      'score': score,
    };
  }

  // ✅ Added fromJson factory
  factory GameModeScore.fromJson(Map<String, dynamic> json) {
    return GameModeScore(
      gameMode: json['gameMode'] ?? '',
      score: json['score'] ?? 0,
    );
  }
}
