import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    "Check that widget does not fail on empty data",
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Html(
            data: "",
          ),
        ),
      );
      expect(find.text('', findRichText: true), findsOneWidget);
    },
  );

  testWidgets(
    "Check that widget displays given text",
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Html(
            data: "Text",
          ),
        ),
      );
      expect(find.text('Text', findRichText: true), findsOneWidget);
    },
  );

  testWidgets('Check that a simple element is displayed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Html(
          data: "<p>Text</p>",
        ),
      ),
    );
    expect(find.text('Text', findRichText: true), findsOneWidget);
  });

  testWidgets(
      'Check that a simple element is hidden when tagsList does not contain it',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Html(
          data: "<p>Text</p>",
          onlyRenderTheseTags: const {'html', 'body', 'div'}, //Anything but `p`
        ),
      ),
    );
    expect(find.text('Text', findRichText: true), findsNothing);
  });

  testWidgets(
      'Check that a simple element is displayed when it is included in tagsList',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Html(
          data: "<p>Text</p>",
          onlyRenderTheseTags: const {'html', 'body', 'p'},
        ),
      ),
    );
    expect(find.text('Text', findRichText: true), findsOneWidget);
  });

  testWidgets('Check that a custom element is not displayed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Html(
          data: "<custom>Text</custom>",
        ),
      ),
    );
    expect(find.text('Text', findRichText: true), findsNothing);
  });

  testWidgets('Check that a custom element is displayed when configured',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Html(
          data: "<custom>Text</custom>",
          extensions: [
            TagExtension(
              tagsToExtend: {"custom"},
              builder: (context) => Text(context.innerHtml),
            ),
          ],
        ),
      ),
    );
    expect(find.text('Text', findRichText: true), findsOneWidget);
  });
}
