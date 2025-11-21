import 'course.dart';

/// Represents a semester with a list of courses.
/// The class intentionally keeps computed metrics out of the core model.
/// Use GpaService to compute tcu/tqp/gpa to keep separation of concerns.
class Semester {
  final String id;
  final int semesterNumber;
  final String session; // e.g., "2023/2024"
  final List<Course> courses;
  final DateTime createdAt;

  Semester({
    required this.id,
    required this.semesterNumber,
    this.session = '',
    this.courses = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Semester copyWith({
    String? id,
    int? semesterNumber,
    String? session,
    List<Course>? courses,
    DateTime? createdAt,
  }) {
    return Semester(
      id: id ?? this.id,
      semesterNumber: semesterNumber ?? this.semesterNumber,
      session: session ?? this.session,
      courses: courses ?? this.courses,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'semesterNumber': semesterNumber,
      'session': session,
      'courses': courses.map((c) => c.toMap()).toList(),
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  factory Semester.fromMap(Map<String, dynamic> map) {
    return Semester(
      id: map['id'] as String,
      semesterNumber: (map['semesterNumber'] as num).toInt(),
      session: map['session'] as String? ?? '',
      courses: (map['courses'] as List<dynamic>? ?? [])
          .map((m) => Course.fromMap(Map<String, dynamic>.from(m as Map)))
          .toList(),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String).toLocal()
          : null,
    );
  }

  @override
  String toString() {
    return 'Semester(id: $id, sem: $semesterNumber, session: $session, courses: ${courses.length})';
  }
}