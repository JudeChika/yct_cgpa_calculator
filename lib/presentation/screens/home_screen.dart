import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> profile;
  const HomeScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fullName = profile['fullName'] ?? 'Student';
    final matric = profile['matric'] ?? profile['matricNumber'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text('Welcome', style: theme.textTheme.titleLarge?.copyWith(color: Colors.green.shade700))
                  .animate()
                  .fadeIn(delay: 200.ms),
              const SizedBox(height: 6),
              Text(fullName, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold))
                  .animate()
                  .slideY(begin: 0.04, delay: 320.ms),
              const SizedBox(height: 4),
              Text(matric, style: theme.textTheme.titleLarge).animate().fadeIn(delay: 420.ms),
              const SizedBox(height: 24),
              // Placeholder: GPA/CGPA UI will be added in next iteration
              Expanded(
                child: Center(
                  child: Text(
                    'Semester GPA & CGPA calculator will be here',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}