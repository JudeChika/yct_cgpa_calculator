import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/semester/semesters_cubit.dart';
import '../../bloc/semester/semesters_state.dart';
import '../../domain/services/gpa_service.dart';
import 'semester_editor_screen.dart';
import '../../bloc/semester/semester_editor_cubit.dart';
import '../../bloc/semester/semester_editor_state.dart';

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
          final semCount = context.read<SemestersCubit>().state.semesters.length;
          final next = semCount + 1;

          // Pre-initialize editor state so the editor screen is populated immediately.
          final editor = context.read<SemesterEditorCubit>();
          editor.initForNewSemester(semesterNumber: next);
          if (editor.state.semester?.courses.isEmpty ?? true) editor.addEmptyCourse();

          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const SemesterEditorScreen(),
          ));
        },
      ),
      body: BlocBuilder<SemestersCubit, SemestersState>(
        builder: (context, state) {
          // Support both union-style `when` and plain property-style implementations
          try {
            return state.when(
              initial: () => const SizedBox(),
              loading: () => const Center(child: CircularProgressIndicator()),
              unauthenticated: () => const Center(child: Text('Please login to view semesters')),
              failure: (msg) => Center(child: Text('Error: $msg')),
              loaded: (semesters) {
                final metrics = semesters.map((s) => GpaService.computeSemesterMetrics(s.courses)).toList();
                final cgpa = GpaService.computeCgpa(metrics);
                final totalTcu = metrics.fold<int>(0, (p, m) => p + m.tcu);

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

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Cumulative CGPA', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                    const SizedBox(height: 6),
                                    Text(cgpa.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                                    const SizedBox(height: 4),
                                    Text('$totalTcu units • ${semesters.length} semesters', style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final next = semesters.length + 1;
                                  final editor = context.read<SemesterEditorCubit>();
                                  editor.initForNewSemester(semesterNumber: next);
                                  editor.addEmptyCourse();
                                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SemesterEditorScreen()));
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                                child: const Text('Add', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: semesters.length,
                        itemBuilder: (ctx, i) {
                          final sem = semesters[i];
                          final m = GpaService.computeSemesterMetrics(sem.courses);
                          return GestureDetector(
                            onTap: () {
                              // Pre-load editor with selected semester for immediate display
                              final editor = context.read<SemesterEditorCubit>();
                              editor.emit(SemesterEditorState.editing(sem));
                              editor.computeMetrics();

                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => SemesterEditorScreen(loadedSemester: sem),
                              ));
                            },
                            child: Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green.shade300,
                                  child: Text('${sem.semesterNumber}'),
                                ),
                                title: Text('Semester ${sem.semesterNumber} (${sem.session})'),
                                subtitle: Text('${m.tcu} Units • ${sem.courses.length} Courses'),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      m.gpa.toStringAsFixed(2),
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
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          } catch (_) {
            // Fallback for property-based state
            if (state is SemestersState) {
              if (state.status == SemestersStatus.loading) return const Center(child: CircularProgressIndicator());
              if (state.status == SemestersStatus.unauthenticated) return const Center(child: Text('Please login to view semesters'));
              if (state.status == SemestersStatus.failure) return Center(child: Text('Error: ${state.message}'));
              final semesters = state.semesters;
              final metrics = semesters.map((s) => GpaService.computeSemesterMetrics(s.courses)).toList();
              final cgpa = GpaService.computeCgpa(metrics);
              final totalTcu = metrics.fold<int>(0, (p, m) => p + m.tcu);
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
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Cumulative CGPA', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                  const SizedBox(height: 6),
                                  Text(cgpa.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                                  const SizedBox(height: 4),
                                  Text('$totalTcu units • ${semesters.length} semesters', style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final next = semesters.length + 1;
                                final editor = context.read<SemesterEditorCubit>();
                                editor.initForNewSemester(semesterNumber: next);
                                editor.addEmptyCourse();
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SemesterEditorScreen()));
                              },
                              child: const Text('Add'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: semesters.length,
                      itemBuilder: (ctx, i) {
                        final sem = semesters[i];
                        final m = GpaService.computeSemesterMetrics(sem.courses);
                        return GestureDetector(
                          onTap: () {
                            final editor = context.read<SemesterEditorCubit>();
                            editor.emit(SemesterEditorState.editing(sem));
                            editor.computeMetrics();
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => SemesterEditorScreen(loadedSemester: sem)));
                          },
                          child: Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                child: Text('${sem.semesterNumber}'),
                              ),
                              title: Text('Semester ${sem.semesterNumber} (${sem.session})'),
                              subtitle: Text('${m.tcu} Units • ${sem.courses.length} Courses'),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    m.gpa.toStringAsFixed(2),
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
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return const Center(child: Text('Unexpected state'));
          }
        },
      ),
    );
  }
}