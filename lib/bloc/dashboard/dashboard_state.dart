

import 'package:equatable/equatable.dart';

enum DashboardStatus { initial, loading, loaded, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final double cgpa;
  final int totalTcu;
  final double totalTqp;
  final List<double> gpaHistory;
  final int semestersCount;
  final String? message;

  const DashboardState._({
    this.status = DashboardStatus.initial,
    this.cgpa = 0.0,
    this.totalTcu = 0,
    this.totalTqp = 0.0,
    this.gpaHistory = const [],
    this.semestersCount = 0,
    this.message,
  });

  const DashboardState.initial() : this._();

  const DashboardState.loading() : this._(status: DashboardStatus.loading);

  const DashboardState.loaded({
    required double cgpa,
    required int totalTcu,
    required double totalTqp,
    required List<double> gpaHistory,
    required int semestersCount,
  }) : this._(
    status: DashboardStatus.loaded,
    cgpa: cgpa,
    totalTcu: totalTcu,
    totalTqp: totalTqp,
    gpaHistory: gpaHistory,
    semestersCount: semestersCount,
  );

  const DashboardState.failure(String message) : this._(status: DashboardStatus.failure, message: message);

  @override
  List<Object?> get props => [status, cgpa, totalTcu, totalTqp, gpaHistory, semestersCount, message];
}