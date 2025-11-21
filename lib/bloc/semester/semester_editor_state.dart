import 'package:equatable/equatable.dart';

import '../../domain/models/semester.dart';
import '../../domain/services/gpa_service.dart';

enum SemesterEditorStatus { initial, editing, metricsComputed, saving, saved, failure }

class SemesterEditorState extends Equatable {
  final SemesterEditorStatus status;
  final Semester? semester;
  final SemesterMetrics? metrics;
  final String? message;

  const SemesterEditorState._({this.status = SemesterEditorStatus.initial, this.semester, this.metrics, this.message});

  const SemesterEditorState.initial() : this._();

  const SemesterEditorState.editing(Semester semester) : this._(status: SemesterEditorStatus.editing, semester: semester);

  const SemesterEditorState.metrics(Semester semester, SemesterMetrics metrics)
      : this._(status: SemesterEditorStatus.metricsComputed, semester: semester, metrics: metrics);

  const SemesterEditorState.saving(Semester semester) : this._(status: SemesterEditorStatus.saving, semester: semester);

  const SemesterEditorState.saved(Semester semester) : this._(status: SemesterEditorStatus.saved, semester: semester);

  const SemesterEditorState.failure(String message) : this._(status: SemesterEditorStatus.failure, message: message);

  @override
  List<Object?> get props => [status, semester, metrics, message];
}