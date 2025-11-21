// DashboardCubit — listens to SemestersCubit and produces dashboard metrics.
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:yct_cgpa_calculator/domain/services/gpa_service.dart';
import 'package:yct_cgpa_calculator/bloc/semester/semesters_cubit.dart';

import '../semester/semesters_state.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final SemestersCubit _semestersCubit;
  late final StreamSubscription _semSub;

  DashboardCubit({required SemestersCubit semestersCubit})
      : _semestersCubit = semestersCubit,
        super(const DashboardState.initial()) {
    // Subscribe to semesters changes
    _semSub = _semestersCubit.stream.listen((state) {
      _recompute();
    });

    // initial compute in case semesters already loaded
    _recompute();
  }

  void _recompute() {
    final state = _semestersCubit.state;
    if (state.status != SemestersStatus.loaded) {
      emit(const DashboardState.loading());
      return;
    }

    final semesters = state.semesters;

    // compute per-semester metrics then aggregate
    final metrics = semesters.map((s) => GpaService.computeSemesterMetrics(s.courses)).toList();

    final totalTcu = metrics.fold<int>(0, (p, m) => p + m.tcu);
    final totalTqp = metrics.fold<double>(0.0, (p, m) => p + m.tqp);
    final cgpa = GpaService.computeCgpa(metrics);

    final gpaHistory = metrics.map((m) => m.gpa).toList();

    emit(DashboardState.loaded(
      cgpa: cgpa,
      totalTcu: totalTcu,
      totalTqp: totalTqp,
      gpaHistory: gpaHistory,
      semestersCount: semesters.length,
    ));
  }

  @override
  Future<void> close() {
    _semSub.cancel();
    return super.close();
  }
}