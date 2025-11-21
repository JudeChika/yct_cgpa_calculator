// Firebase-backed implementation of UserRepository using Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/profiles.dart';
import '../domain/repositories/user_repositories.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;

  FirebaseUserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> usersRef() => _firestore.collection('users');

  @override
  Future<void> createProfile(Profile profile) async {
    await usersRef().doc(profile.uid).set(profile.toMap());
  }

  @override
  Future<Profile?> getProfile(String uid) async {
    final doc = await usersRef().doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    // If your stored map does not include uid field, ensure it's present
    final mapWithUid = Map<String, dynamic>.from(data);
    mapWithUid['uid'] = uid;
    return Profile.fromMap(mapWithUid);
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    await usersRef().doc(profile.uid).update(profile.toMap());
  }
}