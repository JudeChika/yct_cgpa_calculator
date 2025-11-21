// Domain model representing a single course taken in a semester.
class Course {
  final String id; // unique id (could be UUID or index)
  final String code; // course code e.g. 'CSC101'
  final int creditUnit; // credit units (CU)
  final String grade; // grade label e.g. 'A1', 'B2'
  final double? score; // optional raw numeric score (0 - 100)

  Course({
    required this.id,
    required this.code,
    required this.creditUnit,
    required this.grade,
    this.score,
  });

  Course copyWith({
    String? id,
    String? code,
    int? creditUnit,
    String? grade,
    double? score,
  }) {
    return Course(
      id: id ?? this.id,
      code: code ?? this.code,
      creditUnit: creditUnit ?? this.creditUnit,
      grade: grade ?? this.grade,
      score: score ?? this.score,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'creditUnit': creditUnit,
      'grade': grade,
      'score': score,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] as String,
      code: map['code'] as String,
      creditUnit: (map['creditUnit'] as num).toInt(),
      grade: map['grade'] as String,
      score: map['score'] != null ? (map['score'] as num).toDouble() : null,
    );
  }

  @override
  String toString() {
    return 'Course(id: $id, code: $code, cu: $creditUnit, grade: $grade, score: $score)';
  }
}