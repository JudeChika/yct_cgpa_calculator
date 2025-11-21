// Interface for semester storage per user.
import '../models/semester.dart';

abstract class SemesterRepository {
  Future<void> saveSemester(String uid, Semester semester);
  Future<List<Semester>> getSemesters(String uid);
  Future<void> deleteSemester(String uid, String semesterId);
}