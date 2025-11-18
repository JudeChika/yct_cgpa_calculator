import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart'; // Create this next

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocBuilder rebuilds the UI based on the AuthState
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          // User is logged in
          return DashboardScreen(); // Placeholder
        }
        if (state.status == AuthStatus.unauthenticated) {
          // User is logged out
          return LoginScreen(); // Placeholder
        }
        // Auth state is unknown (e.g., app just started)
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

// --- Create these placeholder files for now ---
// lib/presentation/screens/dashboard_screen.dart
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard"), actions: [
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            // Trigger the SignOut event
            context.read<AuthBloc>().add(AuthSignOutRequested());
          },
        )
      ]),
      body: Center(child: Text("Welcome!")),
    );
  }
}

// lib/presentation/screens/login_screen.dart
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Center(
        child: ElevatedButton(
          child: Text("Sign In (Test)"),
          onPressed: () {
            // This is just for testing. We will build a real form.
            // You can't call signIn directly on the BLoC because
            // it's not the BLoC's job. We'll build a LoginCubit for that.
            print("Login button pressed");
          },
        ),
      ),
    );
  }
}