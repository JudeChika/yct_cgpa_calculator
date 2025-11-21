import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:yct_cgpa_calculator/presentation/screens/semester_editor_screen.dart';
import '../../bloc/semester/semesters_cubit.dart';
import '../../bloc/semester/semesters_state.dart';
import '../../widgets/gradient_button.dart';

class SemestersListScreen extends StatefulWidget {
  const SemestersListScreen({super.key});

  @override
  State<SemestersListScreen> createState() => _SemestersListScreenState();
}

class _SemestersListScreenState extends State<SemestersListScreen> {
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<SemestersCubit>().loadSemesters(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semesters'),
        actions: [
          IconButton(
            onPressed: () {
              // start new semester editor (default semesterNumber = current count + 1)
              final user = FirebaseAuth.instance.currentUser;
              final semCount = context.read<SemestersCubit>().state.semesters.length;
              final next = semCount + 1;
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => SemesterEditorScreen(initialSemesterNumber: next)));
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: BlocBuilder<SemestersCubit, SemestersState>(
        builder: (context, state) {
          if (state.status == SemestersStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == SemestersStatus.unauthenticated) {
            return const Center(child: Text('Sign in to view semesters'));
          }
          if (state.semesters.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No semesters yet'),
                  const SizedBox(height: 12),
                  GradientButton(
                    text: 'Add Semester',
                    gradient: const LinearGradient(colors: [Color(0xFF2BB673), Color(0xFF1E8F4E)]),
                    onTap: () {
                      final semCount = context.read<SemestersCubit>().state.semesters.length;
                      final next = semCount + 1;
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => SemesterEditorScreen(initialSemesterNumber: next)));
                    },
                  ).animate().fadeIn(),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: state.semesters.length,
            itemBuilder: (context, i) {
              final sem = state.semesters[i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text('Semester ${sem.semesterNumber} • ${sem.session}'),
                  subtitle: Text('${sem.courses.length} courses'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete semester?'),
                          content: const Text('This action cannot be undone.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await context.read<SemestersCubit>().deleteSemester(user.uid, sem.id);
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => SemesterEditorScreen(loadedSemester: sem)));
                  },
                ),
              ).animate().fadeIn(delay: (i * 80).ms);
            },
          );
        },
      ),
    );
  }
}