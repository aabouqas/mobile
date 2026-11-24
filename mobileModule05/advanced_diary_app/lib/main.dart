import 'package:advanced_diary_app/diary_page.dart';
import 'package:advanced_diary_app/home_page.dart';
import 'package:advanced_diary_app/supabase_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

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
          centerTitle: true,
          scrolledUnderElevation: 0,
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
          elevation: 0,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.blue),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeForwardsPageTransitionsBuilder(
              backgroundColor: Colors.transparent,
            ),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      builder: (context, child) {
        return Stack(
          fit: .expand,
          children: [
            Image.asset(
              'assets/bg.jpg',
              fit: .cover,
              cacheWidth: 1080,
              // opacity: const AlwaysStoppedAnimation(0.25),
            ),
            BackdropFilter(
              filter: .blur(sigmaX: 3, sigmaY: 3),
              child: Container(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child ?? SizedBox.shrink(),
          ],
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
    return Scaffold(
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
    );
  }

  void _handleAuth() async {
    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'dev.eledrissi.diary://login-callback/',
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }
}
