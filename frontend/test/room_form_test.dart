import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:room_rental_system/views/room/room_form_view.dart';

void main() {
  testWidgets('renders room form fields', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: RoomFormView(isEditing: false, onSubmit: (_) async {}),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(Form), findsOneWidget);
  });

  testWidgets('rejects non-positive price and ward values', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: RoomFormView(isEditing: false, onSubmit: (_) async {}),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Test room');
    await tester.enterText(find.byType(TextFormField).at(1), 'A nice room');
    await tester.enterText(find.byType(TextFormField).at(2), '0');
    await tester.enterText(find.byType(TextFormField).at(3), 'Bagmati');
    await tester.enterText(find.byType(TextFormField).at(4), 'Kathmandu');
    await tester.enterText(find.byType(TextFormField).at(5), '0');

    final formState = tester.state<FormState>(find.byType(Form));
    expect(formState.validate(), isFalse);
  });
}
