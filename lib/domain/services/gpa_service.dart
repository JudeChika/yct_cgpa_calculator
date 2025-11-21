import '../models/course.dart';

/// Results returned when computing a semester's metrics.
class SemesterMetrics {
  final int tcu; // total credit units
  final double tqp; // total quality points
  final double gpa; // semester GPA (rounded to 2 decimals)

  SemesterMetrics({required this.tcu, required this.tqp, required this.gpa});

  Map<String, dynamic> toMap() => {
    'tcu': tcu,
    'tqp': tqp,
    'gpa': gpa,
  };

  @override
  String toString() => 'SemesterMetrics(tcu: $tcu, tqp: $tqp, gpa: $gpa)';
}

/// Pure Dart service that implements the Yabatech grading scale and
/// provides GPA and CGPA calculations. No Firebase or I/O here so it's easy to unit test.
class GpaService {
  // Grade label -> Grade Point map according to provided grading scale
  static const Map<String, double> gradePointMap = {
    'A1': 4.00, // 75 - 100
    'A2': 3.50, // 70 - 74
    'B1': 3.25, // 65 - 69
    'B2': 3.00, // 60 - 64
    'C1': 2.75, // 55 - 59
    'C2': 2.50, // 50 - 54
    'D1': 2.25, // 45 - 49
    'D2': 2.00, // 40 - 44
    'F': 0.00,  // 0 - 39
  };

  /// Returns a list of available grade labels, in display order.
  static List<String> get availableGrades => gradePointMap.keys.toList();

  /// Convert grade label (e.g. 'A1') to grade point (e.g. 4.0).
  /// Returns 0.0 for unknown labels.
  static double gradeToPoint(String grade) {
    return gradePointMap[grade.toUpperCase()] ?? 0.0;
  }

  /// Convert numeric score (0-100) to a grade label according to the Yabatech scale.
  /// Scores outside 0-100 will be clamped into valid ranges before conversion.
  static String scoreToGrade(double score) {
    final s = score.clamp(0.0, 100.0).round();
    if (s >= 75) return 'A1';
    if (s >= 70) return 'A2';
    if (s >= 65) return 'B1';
    if (s >= 60) return 'B2';
    if (s >= 55) return 'C1';
    if (s >= 50) return 'C2';
    if (s >= 45) return 'D1';
    if (s >= 40) return 'D2';
    return 'F';
  }

  /// Compute quality point for a single course: CU * GP
  static double qualityPoint(int creditUnit, String grade) {
    final gp = gradeToPoint(grade);
    return creditUnit * gp;
  }

  /// Compute semester metrics (tcu, tqp, gpa) for a list of courses.
  /// Uses the Course model as input.
  static SemesterMetrics computeSemesterMetrics(List<Course> courses) {
    double tqp = 0.0;
    int tcu = 0;

    for (final c in courses) {
      final cu = c.creditUnit;
      final grade = c.grade;
      tcu += cu;
      tqp += qualityPoint(cu, grade);
    }

    final gpa = tcu == 0 ? 0.0 : tqp / tcu;
    // round to 2 decimal places for display
    final rounded = double.parse(gpa.toStringAsFixed(2));

    return SemesterMetrics(tcu: tcu, tqp: double.parse(tqp.toStringAsFixed(2)), gpa: rounded);
  }

  /// Compute cumulative CGPA given a list of semester metrics.
  /// Returns 0.0 if cumulative TCU is zero.
  static double computeCgpa(List<SemesterMetrics> semesters) {
    double totalTqp = 0.0;
    int totalTcu = 0;
    for (final s in semesters) {
      totalTqp += s.tqp;
      totalTcu += s.tcu;
    }
    if (totalTcu == 0) return 0.0;
    final cgpa = totalTqp / totalTcu;
    return double.parse(cgpa.toStringAsFixed(2));
  }
}
