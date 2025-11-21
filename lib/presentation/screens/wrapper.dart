import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_screen.dart';
import 'welcome_screen.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/profile/profile_cubit.dart';

/// Wrapper uses the AuthBloc state to decide the app's landing screen.
/// - Authenticated => HomeScreen (which contains the dashboard and CTA to compute GPA)
/// - Unauthenticated => WelcomeScreen (public landing)
/// - Unknown/initializing => progress indicator
class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.authenticated:
          // Grab profile from ProfileCubit if available and pass a simple map to HomeScreen
            final profileState = context.watch<ProfileCubit>().state;
            final profile = profileState.profile;
            final profileMap = {
              'fullName': profile?.fullName,
              'matric': profile?.matric,
              'department': profile?.department,
              'program': profile?.program,
              'phone': profile?.phone,
              'email': profile?.email,
            };
            return HomeScreen(profile: profileMap);
          case AuthStatus.unauthenticated:
          // Public landing for guests
            return const WelcomeScreen();
          case AuthStatus.unknown:
          default:
          // While auth is initializing show a spinner
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
        }
      },
    );
  }
}