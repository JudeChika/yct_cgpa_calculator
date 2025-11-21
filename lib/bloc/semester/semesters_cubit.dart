import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yct_cgpa_calculator/bloc/semester/semesters_state.dart';
import '../../domain/repositories/semester_repositories.dart';

class SemestersCubit extends Cubit<SemestersState> {
  final SemesterRepository _semesterRepository;
  late final StreamSubscription<User?> _authSub;

  SemestersCubit({required SemesterRepository semesterRepository, required Stream<User?> authStream})
      : _semesterRepository = semesterRepository,
        super(const SemestersState.initial()) {
    // load when auth state changes
    _authSub = authStream.listen((user) {
      if (user != null) {
        loadSemesters(user.uid);
      } else {
        emit(const SemestersState.unauthenticated());
      }
    });
  }

  Future<void> loadSemesters(String uid) async {
    emit(const SemestersState.loading());
    try {
      final items = await _semesterRepository.getSemesters(uid);
      emit(SemestersState.loaded(items));
    } catch (e) {
      emit(SemestersState.failure('Failed to load semesters: $e'));
    }
  }

  Future<void> deleteSemester(String uid, String semesterId) async {
    try {
      await _semesterRepository.deleteSemester(uid, semesterId);
      await loadSemesters(uid);
    } catch (e) {
      emit(SemestersState.failure('Failed to delete semester: $e'));
    }
  }

  @override
  Future<void> close() {
    _authSub.cancel();
    return super.close();
  }
}