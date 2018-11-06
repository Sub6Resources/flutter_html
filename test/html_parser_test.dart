import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_html/flutter_html.dart';

void main() {
  test('Checks that `parse` does not throw an exception', () {
    final elementList = HtmlOldParser(width: 42.0).parse("<b>Bold Text</b>");
    expect(elementList, isNotNull);
  });

  testWidgets('Tests some plain old text', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
      body: Html(data: "This is some plain text"),
    )));

    expect(find.text("This is some plain text"), findsOneWidget);
  });

  testWidgets('Tests that a <b> element gets rendered correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Html(
          data: "<b>Bold Text</b>",
        ),
      ),
    ));

    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets(
      'Tests that a combination of elements and text nodes gets rendered',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Html(
          data: "<b>Bold Text</b> and plain text",
        ),
      ),
    ));

    expect(find.byType(RichText), findsNWidgets(2));
    expect(find.text(" and plain text"), findsOneWidget);
  });

  testWidgets('Tests that a <i> element gets rendered correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Html(
          data: "<b>Bold Text</b>, <i>Italic Text</i> and plain text",
        ),
      ),
    ));

    expect(find.byType(RichText), findsNWidgets(4));
    expect(find.text(", "), findsOneWidget);
    expect(find.text(" and plain text"), findsOneWidget);
  });

  testWidgets('Tests that nested elements get rendered correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Html(
          data:
              "<b>Bold Text and <i>Italic bold text and <u>Underlined italic bold text</u></i></b>",
        ),
      ),
    ));

    expect(find.byType(RichText), findsNWidgets(3));
  });

  testWidgets('Tests that the header elements (h1-h6) get rendered correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Html(
          data:
              "<h1>H1</h1><h2>H2</h2><h3>H3</h3><h4>H4</h4><h5>H5</h5><h6>H6</h6>",
        ),
      ),
    ));

    expect(find.byType(RichText), findsNWidgets(6));
  });
}
