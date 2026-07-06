import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:room_rental_system/widgets/settings_tile.dart';

void main() {
  testWidgets('SettingsTile renders title and subtitle', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsTile(
            icon: Icons.person,
            iconColor: Colors.blue,
            title: 'My Profile',
            subtitle: 'View and edit profile details',
            onTap: () {},
          ),
        ),
      ),
    );

    // Verify that title and subtitle are present
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('View and edit profile details'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });
}
