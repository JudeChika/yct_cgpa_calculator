import 'package:firebase_auth/firebase_auth.dart';

// This is the "interface". It describes WHAT we can do, not HOW.
abstract class AuthRepository {
  // A stream to listen to the user's auth state (logged in or out)
  Stream<User?> get user;

  Future<UserCredential> signUp({required String email, required String password});

  Future<void> signIn({required String email, required String password});

  Future<void> signOut();
}