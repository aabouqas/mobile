import 'package:diary_app/DiaryScreen.dart';
import 'package:diary_app/SupabaseService.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.blue)),
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          spacing: 12,
          children: [
            Text.rich(
              TextSpan(
                text: "Welcome to your ",
                children: [
                  TextSpan(
                    text: "Diary",
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
              textAlign: .center,
              style: TextStyle(fontSize: 50, fontWeight: .w600),
            ),
            FilledButton(
              onPressed: () => _handleAuth(),
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.blue),
                foregroundColor: WidgetStatePropertyAll(Colors.white),
              ),
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAuth() async {
    if (Supabase.instance.client.auth.currentUser == null) {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'dev.eledrissi.diary://login-callback/',
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DiaryScreen()),
      );
    }
  }
}
