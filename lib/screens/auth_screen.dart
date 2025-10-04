import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/game_provider.dart';
import '../widgets/sync_choice_dialog.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  Future<void> _loginOrCreateAccount() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final supabase = Supabase.instance.client;

    try {
      // Try login
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // ✅ Check if cloud profile exists and show dialog
      await _handlePostLogin();

      if (mounted) Navigator.pop(context);
    } on AuthException catch (e) {
      // Try signup if login fails
      if (e.message.contains("Invalid login credentials") ||
          e.message.contains("User not found")) {
        try {
          await supabase.auth.signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          // New user - just sync local data to cloud
          await ref.read(profileProvider.notifier).loadFromSupabase(
                strategy: SyncStrategy.keepLocal,
              );

          if (mounted) Navigator.pop(context);
        } catch (signupError) {
          setState(() {
            _errorMessage = "Signup failed: ${signupError.toString()}";
          });
        }
      } else {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Unexpected error: $e";
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handlePostLogin() async {
    final comparison =
        await ref.read(profileProvider.notifier).getCloudProfileComparison();

    if (comparison == null) {
      // No cloud profile exists - first time login, use local
      await ref.read(profileProvider.notifier).loadFromSupabase(
            strategy: SyncStrategy.keepLocal,
          );
      return;
    }

    // Show dialog to let user choose
    if (!mounted) return;

    final strategy = await showDialog<SyncStrategy>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SyncChoiceDialog(
        localProfile: comparison['localProfile'],
        cloudProfile: comparison['cloudProfile'],
        localTotal: comparison['localTotal'],
        cloudTotal: comparison['cloudTotal'],
      ),
    );

    if (strategy != null) {
      await ref.read(profileProvider.notifier).loadFromSupabase(
            strategy: strategy,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: Container(
          width: maxWidth > 600 ? 400 : double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Login to your account",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _loginOrCreateAccount,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
