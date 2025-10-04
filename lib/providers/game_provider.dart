// providers/game_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/question.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import '../services/local_data_service.dart';

// ---------- Providers ----------

final apiServiceProvider = Provider((ref) => ApiService());
final localDataServiceProvider = Provider((ref) => LocalDataService());

/// ✅ FIXED: Current user provider (simpler approach)
final currentUserProvider = StateProvider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});

/// ✅ Auth state stream provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

/// Profile data provider
final profileProvider =
    StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  return ProfileNotifier(ref);
});

// ---------- Profile Notifier ----------

class ProfileNotifier extends StateNotifier<UserProfile> {
  final Ref ref;

  ProfileNotifier(this.ref) : super(_loadProfile()) {
    _initAuthListener();
  }

  static UserProfile _loadProfile() {
    final box = Hive.box<UserProfile>('profile');
    return box.get('user') ?? UserProfile.empty();
  }

  // ✅ Listen to auth changes
  void _initAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((authState) {
      final user = authState.session?.user;
      ref.read(currentUserProvider.notifier).state = user;

      if (user != null) {
        // User logged in - load from Supabase
        loadFromSupabase();
      }
    });
  }

  // ---- Local Updates ----
  void updateUsername(String name) {
    state = state.copyWith(username: name);
    _save();
    _syncIfLoggedIn();
  }

  void updateAvatar(int index) {
    state = state.copyWith(avatarIndex: index);
    _save();
    _syncIfLoggedIn();
  }

  void addScore(String subject, String gameMode, int points) {
    final subjectScore = state.subjectScores.firstWhere(
      (s) => s.subject == subject,
      orElse: () => throw Exception('Subject not found: $subject'),
    );
    subjectScore.updateScore(gameMode, points);
    state = state.copyWith(subjectScores: [...state.subjectScores]);
    _save();
    _syncIfLoggedIn();
  }

  void _save() {
    Hive.box<UserProfile>('profile').put('user', state);
  }

  // ✅ Auto-sync if user is logged in
  void _syncIfLoggedIn() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      syncToSupabase();
    }
  }

  // ---- Guest Reset ----
  Future<void> resetToGuest() async {
    final box = Hive.box<UserProfile>('profile');
    await box.clear();
    state = UserProfile.empty();
  }

  // ---- Supabase Sync ----
  Future<void> syncToSupabase() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client.from('profiles').upsert({
        'id': user.id,
        'username': state.username,
        'avatar_index': state.avatarIndex,
        'subject_scores': state.toJson()['subjectScores'],
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Error syncing to Supabase: $e');
    }
  }

  Future<void> loadFromSupabase() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        final cloudProfile = UserProfile.fromJson({
          'username': response['username'] ?? state.username,
          'avatarIndex': response['avatar_index'] ?? state.avatarIndex,
          'subjectScores': response['subject_scores'] ?? [],
        });

        // --- Conflict Resolution: Keep higher score ---
        if (cloudProfile.totalScore() > state.totalScore()) {
          print('☁️ Cloud profile has higher score, using it');
          state = cloudProfile;
          _save();
        } else {
          print('📱 Local profile has higher score, syncing to cloud');
          await syncToSupabase();
        }
      } else {
        // First time user: push local data to cloud
        print('🆕 New user, syncing local data to cloud');
        await syncToSupabase();
      }
    } catch (e) {
      print('❌ Error loading from Supabase: $e');
    }
  }
}

// ---------- Game Question Cache ----------

final questionsProvider = FutureProvider.family<List<Question>, GameConfig>(
  (ref, config) async {
    if (config.type == QuestionType.riddle) {
      return ref.read(localDataServiceProvider).loadRiddles(config.subject);
    } else if (config.type == QuestionType.anagram) {
      return ref.read(localDataServiceProvider).loadAnagrams(config.subject);
    } else {
      try {
        final questions = await ref.read(apiServiceProvider).fetchQuestions(
              config.subject,
              config.type,
            );
        _cacheQuestions(config, questions);
        return questions;
      } catch (_) {
        return _loadCachedQuestions(config);
      }
    }
  },
);

void _cacheQuestions(GameConfig config, List<Question> questions) {
  final box = Hive.box('cached_questions');
  final key = '${config.subject}_${config.type.name}';
  box.put(
      key,
      questions
          .map((q) => {
                'question': q.question,
                'answer': q.correctAnswer,
                'options': q.options,
                'hint': q.hint,
                'type': q.type.name,
              })
          .toList());
}

List<Question> _loadCachedQuestions(GameConfig config) {
  final box = Hive.box('cached_questions');
  final key = '${config.subject}_${config.type.name}';
  final cached = box.get(key) as List?;

  if (cached == null) return [];

  return cached.map((q) {
    return Question(
      question: q['question'],
      correctAnswer: q['answer'],
      options: q['options'] != null ? List<String>.from(q['options']) : null,
      hint: q['hint'],
      type: QuestionType.values.firstWhere((t) => t.name == q['type']),
    );
  }).toList();
}

// ---------- Game Config ----------

class GameConfig {
  final String subject;
  final QuestionType type;

  GameConfig(this.subject, this.type);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameConfig &&
          runtimeType == other.runtimeType &&
          subject == other.subject &&
          type == other.type;

  @override
  int get hashCode => subject.hashCode ^ type.hashCode;
}
