import 'package:flutter_test/flutter_test.dart';
import 'package:yct_cgpa_calculator/domain/models/course.dart';

import '../services/gpa_service.dart';

void main() {
  group('GpaService.gradeToPoint', () {
    test('maps grades to correct grade points', () {
      expect(GpaService.gradeToPoint('A1'), 4.00);
      expect(GpaService.gradeToPoint('A2'), 3.50);
      expect(GpaService.gradeToPoint('B1'), 3.25);
      expect(GpaService.gradeToPoint('B2'), 3.00);
      expect(GpaService.gradeToPoint('C1'), 2.75);
      expect(GpaService.gradeToPoint('C2'), 2.50);
      expect(GpaService.gradeToPoint('D1'), 2.25);
      expect(GpaService.gradeToPoint('D2'), 2.00);
      expect(GpaService.gradeToPoint('F'), 0.00);
      expect(GpaService.gradeToPoint('unknown'), 0.00);
    });
  });

  group('GpaService.scoreToGrade', () {
    test('converts numeric scores into correct grade labels', () {
      expect(GpaService.scoreToGrade(95), 'A1');
      expect(GpaService.scoreToGrade(75), 'A1');
      expect(GpaService.scoreToGrade(74), 'A2');
      expect(GpaService.scoreToGrade(70), 'A2');
      expect(GpaService.scoreToGrade(69), 'B1');
      expect(GpaService.scoreToGrade(65), 'B1');
      expect(GpaService.scoreToGrade(64), 'B2');
      expect(GpaService.scoreToGrade(60), 'B2');
      expect(GpaService.scoreToGrade(59), 'C1');
      expect(GpaService.scoreToGrade(55), 'C1');
      expect(GpaService.scoreToGrade(54), 'C2');
      expect(GpaService.scoreToGrade(50), 'C2');
      expect(GpaService.scoreToGrade(49), 'D1');
      expect(GpaService.scoreToGrade(45), 'D1');
      expect(GpaService.scoreToGrade(44), 'D2');
      expect(GpaService.scoreToGrade(40), 'D2');
      expect(GpaService.scoreToGrade(39), 'F');
      expect(GpaService.scoreToGrade(-10), 'F');
      expect(GpaService.scoreToGrade(200), 'A1');
    });
  });

  group('GpaService.computeSemesterMetrics', () {
    test('computes TCU, TQP and GPA correctly', () {
      final courses = [
        Course(id: '1', code: 'CSC101', creditUnit: 3, grade: 'A1'),
        Course(id: '2', code: 'MTH101', creditUnit: 4, grade: 'B2'),
      ];

      // A1 -> 4.0 ; B2 -> 3.0
      // TQP = (3*4.0) + (4*3.0) = 12 + 12 = 24
      // TCU = 3 + 4 = 7
      // GPA = 24 / 7 = 3.428571... -> rounded to 3.43
      final metrics = GpaService.computeSemesterMetrics(courses);
      expect(metrics.tcu, 7);
      expect(metrics.tqp, closeTo(24.00, 0.001));
      expect(metrics.gpa, closeTo(3.43, 0.001));
    });

    test('returns zeros when there are no courses', () {
      final metrics = GpaService.computeSemesterMetrics([]);
      expect(metrics.tcu, 0);
      expect(metrics.tqp, closeTo(0.0, 0.001));
      expect(metrics.gpa, closeTo(0.0, 0.001));
    });
  });

  group('GpaService.computeCgpa', () {
    test('computes cumulative CGPA across semesters', () {
      // sem1: tcu=7, tqp=24 -> gpa ~3.43
      // sem2: tcu=5, tqp=20 -> gpa = 4.00
      final sem1 = SemesterMetrics(tcu: 7, tqp: 24.0, gpa: 3.43);
      final sem2 = SemesterMetrics(tcu: 5, tqp: 20.0, gpa: 4.00);

      // cumulative: total tqp=44, total tcu=12 => cgpa = 44/12 = 3.666666 -> 3.67
      final cgpa = GpaService.computeCgpa([sem1, sem2]);
      expect(cgpa, closeTo(3.67, 0.001));
    });

    test('returns 0.0 when no semesters provided', () {
      final cgpa = GpaService.computeCgpa([]);
      expect(cgpa, 0.0);
    });
  });
}