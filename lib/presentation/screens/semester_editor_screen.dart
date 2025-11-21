import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../bloc/semester/semester_editor_cubit.dart';
import '../../bloc/semester/semester_editor_state.dart';
import '../../domain/models/course.dart';
import '../../domain/models/semester.dart';
import '../../domain/services/gpa_service.dart';
import '../../widgets/gradient_button.dart';

class SemesterEditorScreen extends StatefulWidget {
  final Semester? loadedSemester;
  final int? initialSemesterNumber;

  const SemesterEditorScreen({super.key, this.loadedSemester, this.initialSemesterNumber});

  @override
  State<SemesterEditorScreen> createState() => _SemesterEditorScreenState();
}

class _SemesterEditorScreenState extends State<SemesterEditorScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<SemesterEditorCubit>();
    if (widget.loadedSemester != null) {
      // initialize editing loaded semester
      cubit.emit(SemesterEditorState.editing(widget.loadedSemester!));
      cubit.computeMetrics();
    } else {
      final n = widget.initialSemesterNumber ?? 1;
      cubit.initForNewSemester(semesterNumber: n);
      cubit.addEmptyCourse(); // start with one row
    }
  }

  Widget _courseRow(Course c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: TextFormField(
              initialValue: c.code,
              decoration: const InputDecoration(labelText: 'Code'),
              onChanged: (v) => context.read<SemesterEditorCubit>().updateCourse(c.id, code: v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: c.creditUnit.toString(),
              decoration: const InputDecoration(labelText: 'CU'),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                final cu = int.tryParse(v) ?? 0;
                if (cu > 0) {
                  context.read<SemesterEditorCubit>().updateCourse(c.id, creditUnit: cu);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              value: c.grade,
              items: GpaService.availableGrades.map((g) {
                return DropdownMenuItem(value: g, child: Text(g));
              }).toList(),
              onChanged: (v) {
                if (v != null) context.read<SemesterEditorCubit>().updateCourse(c.id, grade: v);
              },
              decoration: const InputDecoration(labelText: 'Grade'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => context.read<SemesterEditorCubit>().removeCourse(c.id),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semester Editor'),
      ),
      body: BlocConsumer<SemesterEditorCubit, SemesterEditorState>(
        listener: (context, state) {
          if (state.status == SemesterEditorStatus.saved) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semester saved')));
            Navigator.of(context).pop();
          }
          if (state.status == SemesterEditorStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message ?? 'Error')));
          }
        },
        builder: (context, state) {
          final sem = state.semester;
          if (sem == null) return const Center(child: CircularProgressIndicator());
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('Semester ${sem.semesterNumber}', style: Theme.of(context).textTheme.headlineSmall),
                    const Spacer(),
                    GradientButton(
                      text: 'Add Course',
                      gradient: const LinearGradient(colors: [Color(0xFF64D98B), Color(0xFF2BB673)]),
                      onTap: () => context.read<SemesterEditorCubit>().addEmptyCourse(),
                    ),
                  ],
                ).animate().fadeIn(),
                const SizedBox(height: 12),
                ...sem.courses.map(_courseRow),
                const SizedBox(height: 16),
                if (state.metrics != null)
                  Card(
                    child: ListTile(
                      title: Text('GPA: ${state.metrics!.gpa}'),
                      subtitle: Text('TCU: ${state.metrics!.tcu} • TQP: ${state.metrics!.tqp}'),
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 12),
                GradientButton(
                  text: 'Compute Metrics',
                  gradient: const LinearGradient(colors: [Color(0xFF2BB673), Color(0xFF1E8F4E)]),
                  onTap: () => context.read<SemesterEditorCubit>().computeMetrics(),
                ).animate().fadeIn(),
                const SizedBox(height: 12),
                GradientButton(
                  text: state.status == SemesterEditorStatus.saving ? 'Saving...' : 'Save Semester',
                  gradient: const LinearGradient(colors: [Color(0xFF18A85E), Color(0xFF0E9A4B)]),
                  onTap: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in first')));
                      return;
                    }
                    await context.read<SemesterEditorCubit>().save(user.uid);
                  },
                ).animate().fadeIn(),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}