"""// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yct_cgpa_calculator/domain/repositories/auth_repository.dart';
import 'package:yct_cgpa_calculator/domain/repositories/firebase_auth_repository.dart';

import 'package:yct_cgpa_calculator/main.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Stream<dynamic> get user => Stream.value(null);

  @override
  Future<void> signIn({required String email, required String password}) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<dynamic> signUp(
      {required String email, required String password}) async {}
}

void main() {
  testWidgets('App shows loading indicator on startup',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester
        .pumpWidget(MyApp(authRepository: FirebaseAuthRepository()));

    // Expect to see a loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
""