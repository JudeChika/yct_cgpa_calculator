// Firebase-backed implementation of SemesterRepository using Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/semester.dart';
import '../domain/repositories/semester_repositories.dart';

class FirebaseSemesterRepository implements SemesterRepository {
  final FirebaseFirestore _firestore;

  FirebaseSemesterRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> userSemesters(String uid) {
    return _firestore.collection('users').doc(uid).collection('semesters');
  }

  @override
  Future<void> saveSemester(String uid, Semester semester) async {
    await userSemesters(uid).doc(semester.id).set(semester.toMap());
  }

  @override
  Future<List<Semester>> getSemesters(String uid) async {
    final query = await userSemesters(uid).orderBy('timestamp', descending: true).get();
    return query.docs.map((doc) {
      // Ensure the ID is part of the model if not stored in the map
      final data = doc.data();
      // Assuming toMap() / fromMap() handles 'id' appropriately or we inject it
      return Semester.fromMap(data); 
    }).toList();
  }

  @override
  Future<void> deleteSemester(String uid, String semesterId) async {
    await userSemesters(uid).doc(semesterId).delete();
  }
}