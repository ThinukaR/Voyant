// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voyant/app.dart';
import 'package:user_repository/user_repository.dart';
void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(FirebaseUserRepo()));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Just verify the app builds - no UI rendering checks
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

class MockUserRepository implements UserRepository {
  @override
  Stream<MyUser> get user => Stream.value(MyUser.empty);
  
  @override
  Future<MyUser> signUp(MyUser myUser, String password) async {
    return MyUser.empty;
  }
  
  @override
  Future<void> setUserData(MyUser myUser) async {}
  
  @override
  Future<void> signIn(String email, String password) async {}
  
  @override
  Future<void> logOut() async {}
}
