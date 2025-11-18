import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yct_cgpa_calculator/presentation/screens/wrapper.dart';

import 'bloc/auth/auth_bloc.dart';
import 'domain/repositories/firebase_auth_repository.dart';
import 'firebase_options.dart'; // We will create this

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize our Auth Repository
  final authRepository = FirebaseAuthRepository();

  runApp(MyApp(authRepository: authRepository));
}

class MyApp extends StatelessWidget {
  final FirebaseAuthRepository _authRepository;

  const MyApp({super.key, required FirebaseAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Widget build(BuildContext context) {
    // Provide the Auth Repository to the entire app
    return RepositoryProvider.value(
      value: _authRepository,
      child: BlocProvider(
        create: (_) => AuthBloc(authRepository: _authRepository),
        child: MaterialApp(
          title: 'Yabatech CGPA Calculator',
          debugShowCheckedModeBanner: false,

          // --- Dark Mode & Theming ---

          // Use system theme by default
          themeMode: ThemeMode.system,

          // Light Theme (Green & Cream)
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFFFFBEA), // Cream
            primarySwatch: Colors.green,
            fontFamily: GoogleFonts.poppins().fontFamily,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.green,
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.green,
            ),
          ),

          // Dark Theme (Green & Dark Grey/Black)
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212), // Dark grey
            primarySwatch: Colors.green,
            fontFamily: GoogleFonts.poppins().fontFamily,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.green[800],
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Colors.green[700],
            ),
          ),

          // --- End Theming ---

          // The Wrapper decides which screen to show
          home: const Wrapper(),
        ),
      ),
    );
  }
}