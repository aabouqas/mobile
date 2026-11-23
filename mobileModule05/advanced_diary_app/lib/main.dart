import 'package:advanced_diary_app/diary_page.dart';
import 'package:advanced_diary_app/home_page.dart';
import 'package:advanced_diary_app/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),

        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.transparent,
          selectedLabelStyle: TextStyle(color: Colors.blue),
          unselectedLabelStyle: TextStyle(color: Colors.grey),
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
        ),
      ),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bg.jpg"),
              fit: .cover,
            ),
          ),
          child: child,
        );
      },
      home: StreamBuilder(
        stream: SupabaseService.supabase.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.data?.session != null) {
            return const HomePage();
          }
          return const WelcomePage();
        },
      ),
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/bg.jpg"), fit: .cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(7),
          child: Center(
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
        ),
      ),
    );
  }

  void _handleAuth() async {
    if (Supabase.instance.client.auth.currentUser == null) {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'dev.eledrissi.diary://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DiaryPage()),
      );
    }
  }
}
