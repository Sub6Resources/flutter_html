import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_data.dart';

class TestApp extends StatelessWidget {
  final Widget body;

  TestApp(this.body);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: body,
        appBar: AppBar(title: Text('flutter_html')),
      ),
    );
  }
}

void testHtml(String name, String htmlData) {
  testWidgets('$name golden test', (WidgetTester tester) async {
    await tester.pumpWidget(
      TestApp(
        Html(
          data: htmlData,
        ),
      ),
    );
    await expectLater(find.byType(Html), matchesGoldenFile('./goldens/$name.png'));
  });
}

void main() {
  testData.forEach((key, value) {
    testHtml(key, value);
  });
}
