// Modified to register repository providers and bloc providers for the new features.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'domain/repositories/semester_repositories.dart';
import 'domain/repositories/user_repositories.dart';
import 'presentation/screens/welcome_screen.dart';
import 'firebase_options.dart';
import 'domain/repositories/auth_repository.dart';
import 'infrastructure/firebase_user_repository.dart';
import 'infrastructure/firebase_semester_repository.dart';
import 'domain/repositories/firebase_auth_repository.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/profile/profile_cubit.dart';
import 'bloc/semester/semesters_cubit.dart';
import 'bloc/semester/semester_editor_cubit.dart';
import 'bloc/dashboard/dashboard_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      print('Firebase already initialized (apps list not empty).');
    }
  } catch (e) {
    // Catching all exceptions to be safe, checking message for duplicate
    if (e.toString().contains('duplicate') || (e is FirebaseException && e.code == 'duplicate-app')) {
      print('Firebase already initialized (caught exception: $e).');
    } else {
      // rethrow other errors
      rethrow;
    }
  }

  // Infrastructure instances
  final authRepository = FirebaseAuthRepository();
  final userRepository = FirebaseUserRepository();
  final semesterRepository = FirebaseSemesterRepository();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<UserRepository>.value(value: userRepository),
        RepositoryProvider<SemesterRepository>.value(value: semesterRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => AuthBloc(authRepository: authRepository)),
          BlocProvider<ProfileCubit>(
            create: (ctx) => ProfileCubit(userRepository: userRepository, authStream: authRepository.user),
          ),
          BlocProvider<SemestersCubit>(
            create: (ctx) => SemestersCubit(semesterRepository: semesterRepository, authStream: authRepository.user),
          ),
          BlocProvider<SemesterEditorCubit>(
            create: (ctx) => SemesterEditorCubit(semesterRepository: semesterRepository),
          ),
          BlocProvider<DashboardCubit>(
            create: (ctx) => DashboardCubit(semestersCubit: ctx.read<SemestersCubit>()),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      ),
      home: const WelcomeScreen(),
    );
  }
}
