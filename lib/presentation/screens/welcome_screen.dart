import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/gradient_button.dart';
import 'register_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 18),
          child: Column(
            children: [
              const SizedBox(height: 100),
              Align(
                alignment: Alignment.center,
                child: Image.asset('assets/yabatech_logo.png', height: 150),
              ).animate().slideX(begin: -0.2).fadeIn(duration: 500.ms),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Welcome to', style: theme.textTheme.titleLarge?.copyWith(color: Colors.green.shade700))
                        .animate()
                        .fadeIn(delay: 150.ms),
                    const SizedBox(height: 8),
                    Text('YABATECH CGPA Calculator',
                        style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center)
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideY(begin: 0.02),
                    const SizedBox(height: 16),
                    Text(
                      'Compute your Semester GPA and keep an updated CGPA. Beautifully animated and secure.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 420.ms),
                    const SizedBox(height: 36),
                    GradientButton(
                      text: 'Create Account',
                      gradient: const LinearGradient(colors: [Color(0xFF2BB673), Color(0xFF1E8F4E)]),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
                      },
                    ).animate(delay: 500.ms).fadeIn().scale(),
                    const SizedBox(height: 14),
                    GradientButton(
                      text: 'Login',
                      gradient: const LinearGradient(colors: [Color(0xFF64D98B), Color(0xFF2BB673)]),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
                      },
                      outlined: true,
                      foreground: Colors.green.shade800,
                    ).animate(delay: 650.ms).fadeIn().scale(),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text('Built for Yaba College of Technology students', style: theme.textTheme.bodySmall)
                  .animate()
                  .fadeIn(delay: 850.ms),
            ],
          ),
        ),
      ),
    );
  }
}