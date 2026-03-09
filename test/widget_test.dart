import 'package:flutter_test/flutter_test.dart';

import 'package:film_list/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // We don't really have a counter here, but we can just test if FilmListApp builds
    await tester.pumpWidget(const FilmListApp());
  });
}
