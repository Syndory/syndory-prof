import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syndory_prof/features/notifications/notifications_screen.dart';

void main() {
  testWidgets('NotificationsScreen displays mock notifications when backend is not initialized', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: NotificationsScreen(),
      ),
    );

    // Verify that the title is displayed
    expect(find.text('Notifications'), findsOneWidget);

    // Verify that some mock notifications are displayed
    expect(find.text('Nouvelle séance publiée'), findsOneWidget);
    expect(find.text('Ressource partagée'), findsOneWidget);
    expect(find.text('Rappel examen'), findsOneWidget);
    
    // Verify that the "Tout lire" button is present because there are unread mock notifications
    expect(find.text('Tout lire'), findsOneWidget);
  });

  testWidgets('NotificationsScreen "Tout lire" button marks all as read in mock mode', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NotificationsScreen(),
      ),
    );

    // The button should be visible initially
    expect(find.text('Tout lire'), findsOneWidget);

    // Tap the "Tout lire" button
    await tester.tap(find.text('Tout lire'));
    await tester.pumpAndSettle(); // Wait for state to update

    // The button should disappear because there are no unread notifications left
    expect(find.text('Tout lire'), findsNothing);
  });
}
