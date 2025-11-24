// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'services/seed_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Seed only if collections are empty
  await ensureSeedDataLoaded();
  runApp(const ChessClubApp());
}

class ChessClubApp extends StatelessWidget {
  const ChessClubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSS Chess Club',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Logged in → go to HomeScreen
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Not logged in → show sign in
        return const SignInScreen();
      },
    );
  }
}
