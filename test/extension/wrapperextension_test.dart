import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    "Check that widget renders a div normally",
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Html(
            data: "<div>Lorem ipsum dolor sit amet</div>",
          ),
        ),
      );
      expect(find.text('Lorem ipsum dolor sit amet', findRichText: true), findsOneWidget);
    },
  );

  const finderKey = Key("find-me");

  testWidgets(
    "Check that WrapperExtension doesn't match anything when given an empty set",
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Html(
            data: "<div>Lorem ipsum dolor sit amet</div>",
            extensions: [
              WrapperExtension(
                tagsToWrap: {},
                builder: (child) => Container(key: finderKey, child: child),
              ),
            ],
          ),
        ),
      );
      expect(find.text('Lorem ipsum dolor sit amet', findRichText: true), findsOneWidget);
      expect(find.byKey(finderKey), findsNothing);
    },
  );

  testWidgets(
    "Check that WrapperExtension doesn't match anything when told to wrap a tag that isn't there",
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Html(
            data: "<div>Lorem ipsum dolor sit amet</div>",
            extensions: [
              WrapperExtension(
                tagsToWrap: {"p"},
                builder: (child) => Container(key: finderKey, child: child),
              ),
            ],
          ),
        ),
      );
      expect(find.text('Lorem ipsum dolor sit amet', findRichText: true), findsOneWidget);
      expect(find.byKey(finderKey), findsNothing);
    },
  );

  testWidgets(
    "Check that WrapperExtension matches a normal div",
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Html(
            data: "<div>Lorem ipsum dolor sit amet</div>",
            extensions: [
              WrapperExtension(
                tagsToWrap: {"div"},
                builder: (child) => Container(key: finderKey, child: child),
              ),
            ],
          ),
        ),
      );
      expect(find.text('Lorem ipsum dolor sit amet', findRichText: true), findsOneWidget);
      expect(find.byKey(finderKey), findsOneWidget);
    },
  );

  testWidgets(
    "Check that WrapperExtension doesn't render children unnecessarily",
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Html(
            data: "<div>Lorem ipsum dolor sit amet</div>",
            extensions: [
              WrapperExtension(
                tagsToWrap: {"div"},
                builder: (child) => Container(key: finderKey),
              ),
            ],
          ),
        ),
      );
      expect(find.text('Lorem ipsum dolor sit amet', findRichText: true), findsNothing);
      expect(find.byKey(finderKey), findsOneWidget);
    },
  );
}