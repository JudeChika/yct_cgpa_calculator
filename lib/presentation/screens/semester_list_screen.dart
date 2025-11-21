import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../bloc/semester/semesters_cubit.dart';
import '../../bloc/semester/semesters_state.dart';
import '../../domain/models/semester.dart';
import '../../domain/services/gpa_service.dart';
import 'semester_editor_screen.dart';

class SemestersListScreen extends StatelessWidget {
  const SemestersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Semesters')),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Add Semester'),
        icon: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const SemesterEditorScreen(loadedSemester: null),
          ));
        },
      ),
      body: BlocBuilder<SemestersCubit, SemestersState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox(),
            loading: () => const Center(child: CircularProgressIndicator()),
            unauthenticated: () => const Center(child: Text('Please login to view semesters')),
            failure: (msg) => Center(child: Text('Error: $msg')),
            loaded: (semesters) {
              if (semesters.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('No semesters added yet.'),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: semesters.length,
                itemBuilder: (ctx, i) {
                  final sem = semesters[i];
                  final metrics = GpaService.computeSemesterMetrics(sem.courses);
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => SemesterEditorScreen(loadedSemester: sem),
                        ));
                      },
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: Text('${sem.semesterNumber}'),
                      ),
                      title: Text('Semester ${sem.semesterNumber} (${sem.session})'),
                      subtitle: Text('${metrics.tcu} Units • ${sem.courses.length} Courses'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            metrics.gpa.toStringAsFixed(2),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const Text('GPA', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ).animate().slideX(delay: (i * 100).ms);
                },
              );
            },
          );
        },
      ),
    );
  }
}
