import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'presentation/screens/welcome_screen.dart';
import 'firebase_options.dart';
import 'domain/repositories/auth_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Guard Firebase initialization to avoid the core/duplicate-app error.
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // ignore: avoid_print
      print('Firebase initialized for project: ${Firebase.app().options.projectId}');
    } on FirebaseException catch (e) {
      if (e.code == 'duplicate-app') {
        // ignore: avoid_print
        print('Firebase already initialized (duplicate-app caught).');
      } else {
        rethrow;
      }
    }
  } else {
    // ignore: avoid_print
    print('Firebase already initialized. Using existing default app: ${Firebase.app().name}');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  /// Optional AuthRepository injection for tests.
  /// If null, the app can still run normally (production wiring can provide a real repository).
  final AuthRepository? authRepository;

  const MyApp({super.key, this.authRepository});

  @override
  Widget build(BuildContext context) {
    final baseText = ThemeData.light().textTheme;
    return MaterialApp(
      title: 'Yabatech CGPA Calculator',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.green.shade700,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.green),
        textTheme: GoogleFonts.poppinsTextTheme(baseText).copyWith(
          headlineLarge: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.bold),
          headlineMedium: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w600),
          titleLarge: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green.shade700,
          titleTextStyle: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1113),
        primaryColor: Colors.green.shade600,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
          headlineLarge: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green.shade800,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
