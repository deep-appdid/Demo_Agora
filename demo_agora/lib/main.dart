import 'package:demo_agora/firebase_options.dart';
import 'package:demo_agora/screens/homepage.dart';
import 'package:demo_agora/screens/loginscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agora Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // If the connection state is waiting, show a loading screen
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            // Check if the user is authenticated or not
            final isUserLoggedIn = snapshot.hasData;

            // Show the appropriate screen based on user authentication status
            if (isUserLoggedIn) {
              return const HomePage();
            } else {
              return const LoginScreen();
            }
          }
        },
      ),
    );
  }
}
