import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/user_profile.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(SubjectScoreAdapter());
  Hive.registerAdapter(GameModeScoreAdapter());

  // Open Boxes
  await Hive.openBox<UserProfile>('profile');
  await Hive.openBox('cached_questions');

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://sasltwsrwfnjakyjfbhn.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNhc2x0d3Nyd2ZuamFreWpmYmhuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk1MTE5ODAsImV4cCI6MjA3NTA4Nzk4MH0.7kPe0h05xIfV7ErZGwXyTOsJeggb6IqqZOLn0SG7SsU',
  );

  runApp(const ProviderScope(child: TriviaApp()));
}

class TriviaApp extends StatelessWidget {
  const TriviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trivia Puzzle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
