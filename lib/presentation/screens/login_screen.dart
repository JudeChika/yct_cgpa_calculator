import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yct_cgpa_calculator/presentation/screens/register_screen.dart';

import '../../bloc/login/login_cubit.dart';
import '../../domain/repositories/auth_repository.dart'; // We'll create this

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Key to manage the form's state for validation
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Provides the LoginCubit to all widgets below it
    return BlocProvider(
      create: (context) => LoginCubit(context.read<AuthRepository>()),
      child: Scaffold(
        body: BlocListener<LoginCubit, LoginState>(
          // Listens for state changes to show errors
          listener: (context, state) {
            if (state.status == LoginStatus.failure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage ?? 'Login Failed'),
                    backgroundColor: Colors.red,
                  ),
                );
            }
          },
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Logo with Animation ---
                  Image.asset(
                    'assets/yabatech_logo.png', // Make sure you added this to pubspec.yaml
                    height: 100,
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(delay: 200.ms, duration: 400.ms),

                  const SizedBox(height: 16),

                  Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

                  Text(
                    'Sign in to your account',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ).animate().fadeIn(delay: 400.ms, duration: 500.ms),

                  const SizedBox(height: 32),

                  // --- Form ---
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _EmailInputField(),
                        const SizedBox(height: 16),
                        _PasswordInputField(),
                        const SizedBox(height: 24),
                        _LoginButton(formKey: _formKey),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

                  const SizedBox(height: 24),

                  // --- To Register Screen ---
                  _SignUpButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Helper Widgets for Cleaner Code ---

class _EmailInputField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Rebuilds when the Cubit's state changes
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextFormField(
          onChanged: (email) {
            // Notifies the cubit of the change
            context.read<LoginCubit>().emailChanged(email);
          },
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          // --- Form Validation ---
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        );
      },
    );
  }
}

class _PasswordInputField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextFormField(
          onChanged: (password) {
            context.read<LoginCubit>().passwordChanged(password);
          },
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          obscureText: true,
          // --- Form Validation ---
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  const _LoginButton({required this.formKey});

  @override
  Widget build(BuildContext context) {
    // Rebuilds only when the status changes
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        // Show loading spinner if status is loading
        return state.status == LoginStatus.loading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            // Use gradient from your theme
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            // --- Form Validation Trigger ---
            if (formKey.currentState!.validate()) {
              // Form is valid, tell Cubit to log in
              context.read<LoginCubit>().logInWithCredentials();
            }
          },
          child: const Text('Login', style: TextStyle(fontSize: 16)),
        ).animate().scale(duration: 200.ms); // Click animation
      },
    );
  }
}

class _SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?"),
        TextButton(
          onPressed: () {
            // Navigate to the Register screen
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const RegisterScreen(), // Placeholder
            ));
          },
          child: const Text('Sign Up'),
        ),
      ],
    ).animate().fadeIn(delay: 800.ms);
  }
}