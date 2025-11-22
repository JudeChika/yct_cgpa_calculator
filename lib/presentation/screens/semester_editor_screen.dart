import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/semester/semester_editor_cubit.dart';
import '../../bloc/semester/semester_editor_state.dart';
import '../../domain/models/course.dart';
import '../../domain/models/semester.dart';
import '../../domain/services/gpa_service.dart';
import '../../widgets/gradient_button.dart';
import '../../bloc/semester/semesters_cubit.dart';

class SemesterEditorScreen extends StatefulWidget {
  final Semester? loadedSemester;
  final int? initialSemesterNumber;

  const SemesterEditorScreen({super.key, this.loadedSemester, this.initialSemesterNumber});

  @override
  State<SemesterEditorScreen> createState() => _SemesterEditorScreenState();
}

class _SemesterEditorScreenState extends State<SemesterEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Defer initialization to ensure the bloc is available in the widget tree.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<SemesterEditorCubit>();

      if (widget.loadedSemester != null) {
        // Populate the cubit with the existing semester (editing)
        cubit.emit(SemesterEditorState.editing(widget.loadedSemester!));
        cubit.computeMetrics();
      } else {
        final n = widget.initialSemesterNumber ?? 1;
        cubit.initForNewSemester(semesterNumber: n);
        // ensure at least one course row
        if (cubit.state.semester?.courses.isEmpty ?? true) {
          cubit.addEmptyCourse();
        }
      }

      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    });
  }

  Widget _courseRow(Course c, int index) {
    final cubit = context.read<SemesterEditorCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Course code
          Expanded(
            flex: 4,
            child: TextFormField(
              initialValue: c.code,
              decoration: const InputDecoration(labelText: 'Code', hintText: 'e.g. CSC101'),
              textCapitalization: TextCapitalization.characters,
              onChanged: (v) => cubit.updateCourse(c.id, code: v.trim().toUpperCase()),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter code';
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          // Credit unit
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: c.creditUnit.toString(),
              decoration: const InputDecoration(labelText: 'CU', hintText: 'e.g. 3'),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                final cu = int.tryParse(v) ?? 0;
                cubit.updateCourse(c.id, creditUnit: cu);
              },
              validator: (v) {
                final cu = int.tryParse(v ?? '') ?? 0;
                if (cu <= 0) return 'CU > 0';
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          // Grade dropdown
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              value: c.grade,
              items: GpaService.availableGrades.map((g) {
                return DropdownMenuItem(value: g, child: Text(g));
              }).toList(),
              onChanged: (v) {
                if (v != null) cubit.updateCourse(c.id, grade: v);
              },
              decoration: const InputDecoration(labelText: 'Grade'),
            ),
          ),
          const SizedBox(width: 8),
          // Optional score input (derive grade)
          SizedBox(
            width: 84,
            child: TextFormField(
              initialValue: c.score?.toStringAsFixed(0) ?? '',
              decoration: const InputDecoration(labelText: 'Score', hintText: '0-100'),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                final s = double.tryParse(v);
                if (s != null) {
                  final grade = GpaService.scoreToGrade(s);
                  cubit.updateCourse(c.id, score: s, grade: grade);
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // prevent removing the last remaining row
              final current = cubit.state.semester;
              if (current != null && current.courses.length <= 1) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('At least one course is required')));
                return;
              }
              cubit.removeCourse(c.id);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _onSaveSuccess() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        await context.read<SemestersCubit>().loadSemesters(uid);
      } catch (_) {
        // ignore errors
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // show a small skeleton while initializing to avoid an empty screen
    if (!_initialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Semester Editor')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Semester Editor'),
      ),
      body: BlocConsumer<SemesterEditorCubit, SemesterEditorState>(
        listener: (context, state) async {
          if (state.status == SemesterEditorStatus.saved) {
            await _onSaveSuccess();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semester saved')));
            if (mounted) Navigator.of(context).pop();
          }
          if (state.status == SemesterEditorStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message ?? 'Error')));
          }
        },
        builder: (context, state) {
          final sem = state.semester;
          if (sem == null) return const Center(child: Text('No semester available'));

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Semester ${sem.semesterNumber}', style: Theme.of(context).textTheme.headlineSmall),
                      const Spacer(),
                      SizedBox(
                        width: 140, // Constrain the width of the button
                        child: GradientButton(
                          text: 'Add Course',
                          gradient: const LinearGradient(colors: [Color(0xFF64D98B), Color(0xFF2BB673)]),
                          onTap: () => context.read<SemesterEditorCubit>().addEmptyCourse(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Course rows
                  ...sem.courses.asMap().entries.map((e) => _courseRow(e.value, e.key)).toList(),

                  const SizedBox(height: 16),

                  // Metrics (live)
                  if (state.metrics != null)
                    Card(
                      child: ListTile(
                        title: Text('GPA: ${state.metrics!.gpa}'),
                        subtitle: Text('TCU: ${state.metrics!.tcu} • TQP: ${state.metrics!.tqp}'),
                      ),
                    ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: GradientButton(
                          text: 'Compute Metrics',
                          gradient: const LinearGradient(colors: [Color(0xFF2BB673), Color(0xFF1E8F4E)]),
                          onTap: () {
                            // validate before computing; still compute to surface issues
                            if (_formKey.currentState?.validate() ?? false) {
                              context.read<SemesterEditorCubit>().computeMetrics();
                            } else {
                              context.read<SemesterEditorCubit>().computeMetrics();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fix validation errors')));
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GradientButton(
                          text: state.status == SemesterEditorStatus.saving ? 'Saving...' : 'Save Semester',
                          gradient: const LinearGradient(colors: [Color(0xFF18A85E), Color(0xFF0E9A4B)]),
                          onTap: () async {
                            if (!(_formKey.currentState?.validate() ?? false)) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fix validation errors before saving')));
                              return;
                            }
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in first')));
                              return;
                            }
                            await context.read<SemesterEditorCubit>().save(user.uid);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
