import 'package:equatable/equatable.dart';
import '../../domain/models/semester.dart';

enum SemestersStatus { initial, loading, loaded, failure, unauthenticated }

class SemestersState extends Equatable {
  final SemestersStatus status;
  final List<Semester> semesters;
  final String? message;

  const SemestersState._({this.status = SemestersStatus.initial, this.semesters = const [], this.message});

  const SemestersState.initial() : this._();

  const SemestersState.loading() : this._(status: SemestersStatus.loading);

  const SemestersState.loaded(List<Semester> semesters) : this._(status: SemestersStatus.loaded, semesters: semesters);

  const SemestersState.failure(String message) : this._(status: SemestersStatus.failure, message: message);

  const SemestersState.unauthenticated() : this._(status: SemestersStatus.unauthenticated);

  @override
  List<Object?> get props => [status, semesters, message];

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<Semester> semesters) loaded,
    required T Function(String message) failure,
    required T Function() unauthenticated,
  }) {
    switch (status) {
      case SemestersStatus.initial:
        return initial();
      case SemestersStatus.loading:
        return loading();
      case SemestersStatus.loaded:
        return loaded(semesters);
      case SemestersStatus.failure:
        return failure(message ?? 'Unknown error');
      case SemestersStatus.unauthenticated:
        return unauthenticated();
    }
  }
}
