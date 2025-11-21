import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yct_cgpa_calculator/domain/repositories/auth_repository.dart';
import 'package:yct_cgpa_calculator/main.dart';

// A simple MockAuthRepository that matches the AuthRepository interface.
// We keep implementations minimal because the widget test only needs
// a repository object to construct the app widget; we do not call signUp.
class MockAuthRepository implements AuthRepository {
  @override
  Stream<User?> get user => Stream<User?>.value(null);

  @override
  Future<UserCredential> signUp({required String email, required String password}) async {
    // Not used in this test. Throwing is fine (or return a fake if you prefer).
    throw UnimplementedError('signUp not needed for this test');
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    // Minimal implementation; do nothing
    return;
  }

  @override
  Future<void> signOut() async {
    // Minimal implementation; do nothing
    return;
  }
}

void main() {
  testWidgets('App shows loading indicator on startup', (WidgetTester tester) async {
    // Build our app using the MockAuthRepository to avoid touching real Firebase.
    final mockAuth = MockAuthRepository();

    await tester.pumpWidget(MyApp(authRepository: mockAuth));

    // Let the first frame build
    await tester.pump();

    // Expect to see a CircularProgressIndicator on initial frame,
    // matching the original test's intent (app shows a loading indicator).
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}