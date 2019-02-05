import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_html/flutter_html.dart';

void main() {

  testWidgets("Check that default parser does not fail on empty data", (tester) async {
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

  testWidgets("Check that RichText parser does not fail on empty data", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: "",
            useRichText: true,
          ),
        ),
      ),
    );
  });

  testWidgets("Check that `a` tag is rendered by both parsers", (tester) async {
    String html = "<a href='https://github.com'>Test link</a>";
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );
  });

  testWidgets("Check that tapping on the `a` tag calls the callback", (tester) async {
    String html = "<a href='https://github.com'>Test link</a>";
    String urlTapped;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            onLinkTap: (url) {
              urlTapped = url;
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text("Test link"));
    expect(urlTapped, "https://github.com");
  });

}
