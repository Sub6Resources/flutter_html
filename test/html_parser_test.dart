import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("Check that default parser does not fail on empty data",
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: "",
          ),
        ),
      ),
    );
  });
  testWidgets('Test new parser (hacky workaround to get BuildContext)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Builder(
        builder: (BuildContext context) {
          testNewParser(context);

          // The builder function must return a widget.
          return const Placeholder();
        },
      ),
    );
  });
}

void testNewParser(BuildContext context) {
  HtmlParser.parseHTML("<b>Hello, World!</b>");

  Style style1 = Style(
    display: Display.block,
    fontWeight: FontWeight.bold,
  );

  Style style2 = Style(
    before: "* ",
    direction: TextDirection.rtl,
    fontStyle: FontStyle.italic,
  );

  Style finalStyle = style1.merge(style2);

  expect(finalStyle.display, equals(Display.block));
  expect(finalStyle.before, equals("* "));
  expect(finalStyle.direction, equals(TextDirection.rtl));
  expect(finalStyle.fontStyle, equals(FontStyle.italic));
  expect(finalStyle.fontWeight, equals(FontWeight.bold));
}
