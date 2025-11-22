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
    try {
      // Changed orderBy 'timestamp' to 'createdAt' because the Semester model uses 'createdAt'.
      // If your Firestore documents don't have 'createdAt', this query will fail or return nothing.
      // Ensure your saveSemester stores 'createdAt'.
      final query = await userSemesters(uid).orderBy('createdAt', descending: true).get();
      
      return query.docs.map((doc) {
        final data = doc.data();
        // Explicitly put the document ID into the map if not present, 
        // though Semester.fromMap usually expects 'id' to be in the map.
        // Our model's toMap includes 'id', so it should be there.
        return Semester.fromMap(data); 
      }).toList();
    } catch (e) {
      // Fallback: If indexing is missing or field name is wrong, try fetching without order
      // and sort locally, or just log error.
      // For now, let's try a simple get() to see if data exists at all.
      print('Error fetching sorted semesters: $e');
      final query = await userSemesters(uid).get();
      return query.docs.map((doc) => Semester.fromMap(doc.data())).toList();
    }
  }

  @override
  Future<void> deleteSemester(String uid, String semesterId) async {
    await userSemesters(uid).doc(semesterId).delete();
  }
}
