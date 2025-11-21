import 'package:bloc/bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:yct_cgpa_calculator/bloc/semester/semester_editor_state.dart';
import '../../domain/models/course.dart';
import '../../domain/models/semester.dart';
import '../../domain/repositories/semester_repositories.dart';
import '../../domain/services/gpa_service.dart';

class SemesterEditorCubit extends Cubit<SemesterEditorState> {
  final SemesterRepository _semesterRepository;

  SemesterEditorCubit({required SemesterRepository semesterRepository})
      : _semesterRepository = semesterRepository,
        super(SemesterEditorState.initial());

  void initForNewSemester({required int semesterNumber, String session = ''}) {
    final sem = Semester(id: const Uuid().v4(), semesterNumber: semesterNumber, session: session, courses: []);
    emit(SemesterEditorState.editing(sem));
  }

  void addEmptyCourse() {
    final current = state.semester!;
    final newCourse = Course(id: const Uuid().v4(), code: '', creditUnit: 3, grade: 'A1');
    final updated = current.copyWith(courses: [...current.courses, newCourse]);
    emit(SemesterEditorState.editing(updated));
    computeMetrics();
  }

  void updateCourse(String id, {String? code, int? creditUnit, String? grade, double? score}) {
    final current = state.semester!;
    final updatedCourses = current.courses.map((c) {
      if (c.id == id) {
        return c.copyWith(code: code, creditUnit: creditUnit, grade: grade, score: score);
      }
      return c;
    }).toList();
    final updated = current.copyWith(courses: updatedCourses);
    emit(SemesterEditorState.editing(updated));
    computeMetrics();
  }

  void removeCourse(String id) {
    final current = state.semester!;
    final remaining = current.courses.where((c) => c.id != id).toList();
    final updated = current.copyWith(courses: remaining);
    emit(SemesterEditorState.editing(updated));
    computeMetrics();
  }

  void computeMetrics() {
    final current = state.semester!;
    final metrics = GpaService.computeSemesterMetrics(current.courses);
    emit(SemesterEditorState.metrics(current, metrics));
  }

  Future<void> save(String uid) async {
    if (state.semester == null) return;
    emit(SemesterEditorState.saving(state.semester!));
    try {
      await _semesterRepository.saveSemester(uid, state.semester!);
      emit(SemesterEditorState.saved(state.semester!));
    } catch (e) {
      emit(SemesterEditorState.failure('Failed to save semester: $e'));
    }
  }
}