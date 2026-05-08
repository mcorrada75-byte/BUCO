import 'package:flutter_test/flutter_test.dart';

import 'package:buco/main.dart';

void main() {
  testWidgets('App si avvia e mostra la home', (tester) async {
    await tester.pumpWidget(const BucoApp());
    await tester.pump();
    expect(find.text('Buco'), findsWidgets);
    expect(find.text('Nuovo buco'), findsOneWidget);
    expect(find.text('Elenco buchi'), findsOneWidget);
  });
}
