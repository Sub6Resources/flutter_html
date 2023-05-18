import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils.dart';

void main() {
  testWidgets(
    'Test that a normal div has no padding',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: "<div>Test</div>",
          ),
        ),
      );
      expect(_getPadding("Test"), isNull);
    },
  );

  testWidgets(
    'Test that a div with inline styled padding has padding',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """<div style="padding: 8px;">Test</div>""",
          ),
        ),
      );
      expect(_getPadding("Test"), equals(HtmlPaddings.all(8, Unit.px)));
    },
  );

  testWidgets(
    'Test that a div with styled padding has padding',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <style>div {padding: 8px;}</style>
            <div>Test</div>
            """,
          ),
        ),
      );
      expect(_getPadding("Test"), equals(HtmlPaddings.all(8, Unit.px)));
    },
  );

  testWidgets(
    'Test padding-left in <style>',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <style>div {padding-left: 8px;}</style>
            <div>Test</div>
            """,
          ),
        ),
      );
      expect(_getPadding("Test"),
          equals(HtmlPaddings.only(left: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test padding-top in <style>',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <style>div {padding-top: 8px;}</style>
            <div>Test</div>
            """,
          ),
        ),
      );
      expect(_getPadding("Test"),
          equals(HtmlPaddings.only(top: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test padding-right in <style>',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <style>div {padding-right: 8px;}</style>
            <div>Test</div>
            """,
          ),
        ),
      );
      expect(_getPadding("Test"),
          equals(HtmlPaddings.only(right: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test padding-bottom in <style>',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <style>div {padding-bottom: 8px;}</style>
            <div>Test</div>
            """,
          ),
        ),
      );
      expect(_getPadding("Test"),
          equals(HtmlPaddings.only(bottom: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test padding-block-start in <style>',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <style>div {padding-block-start: 8px;}</style>
            <div>Test</div>
            """,
          ),
        ),
      );
      expect(_getPadding("Test"),
          equals(HtmlPaddings.only(blockStart: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test padding-block-end in <style>',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <style>div {padding-block-end: 8px;}</style>
            <div>Test</div>
            """,
          ),
        ),
      );
      expect(_getPadding("Test"),
          equals(HtmlPaddings.only(blockEnd: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test padding-inline-start in <style>',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <style>div {padding-inline-start: 8px;}</style>
            <div>Test</div>
            """,
          ),
        ),
      );
      expect(_getPadding("Test"),
          equals(HtmlPaddings.only(inlineStart: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test padding-inline-end in <style>',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <style>div {padding-inline-end: 8px;}</style>
            <div>Test</div>
            """,
          ),
        ),
      );
      expect(_getPadding("Test"),
          equals(HtmlPaddings.only(inlineEnd: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test padding-left inline',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <div style="padding-left: 8px;">Test</div>
            """,
          ),
        ),
      );
      expect(_getPadding("Test"),
          equals(HtmlPaddings.only(left: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test padding-top inline',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <div style="padding-top: 8px;">Test</div>
            """,
          ),
        ),
      );
      expect(_getPadding("Test"),
          equals(HtmlPaddings.only(top: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test padding-right inline',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <div style="padding-right: 8px;">Test</div>
            """,
          ),
        ),
      );
      expect(_getPadding("Test"),
          equals(HtmlPaddings.only(right: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test padding-bottom inline',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <div style="padding-bottom: 8px;">Test</div>
            """,
          ),
        ),
      );
      expect(_getPadding("Test"),
          equals(HtmlPaddings.only(bottom: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test padding-block-start inline',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <div style="padding-block-start: 8px;">Test</div>
            """,
          ),
        ),
      );
      expect(_getPadding("Test"),
          equals(HtmlPaddings.only(blockStart: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test padding-block-end inline',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <div style="padding-block-end: 8px;">Test</div>
            """,
          ),
        ),
      );
      expect(_getPadding("Test"),
          equals(HtmlPaddings.only(blockEnd: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test padding-inline-start inline',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <div style="padding-inline-start: 8px;">Test</div>
            """,
          ),
        ),
      );
      expect(_getPadding("Test"),
          equals(HtmlPaddings.only(inlineStart: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test padding-inline-end inline',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <div style="padding-inline-end: 8px;">Test</div>
            """,
          ),
        ),
      );
      expect(_getPadding("Test"),
          equals(HtmlPaddings.only(inlineEnd: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test that padding actually applies to visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <div style="padding: 8px;">Test</div>
            """,
          ),
        ),
      );

      expect(_getDivContainer("Test").padding, equals(const EdgeInsets.all(8)));
    },
  );

  testWidgets(
    'Test that two-argument padding actually applies to visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <div style="padding: 4px 8px;">Test</div>
            """,
          ),
        ),
      );

      expect(
          _getDivContainer("Test").padding,
          equals(const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 8,
          )));
    },
  );

  testWidgets(
    'Test that three-argument padding applies correctly to visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <div style="padding: 4px 6px 8px;">Test</div>
            """,
          ),
        ),
      );

      expect(
          _getDivContainer("Test").padding,
          equals(const EdgeInsets.only(
            top: 4,
            right: 6,
            left: 6,
            bottom: 8,
          )));
    },
  );

  testWidgets(
    'Test that four-argument padding applies correctly to visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <div style="padding: 2px 4px 6px 8px;">Test</div>
            """,
          ),
        ),
      );

      expect(
          _getDivContainer("Test").padding,
          equals(const EdgeInsets.only(
            top: 2,
            right: 4,
            bottom: 6,
            left: 8,
          )));
    },
  );

  testWidgets(
    'Test that padding-block-start applies correctly to visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <div style="padding-block-start: 2px;">Test</div>
            """,
          ),
        ),
      );

      expect(
          _getDivContainer("Test").padding,
          equals(const EdgeInsets.only(
            top: 2,
          )));
    },
  );

  testWidgets(
    'Test that padding-block-end applies correctly to visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <div style="padding-block-end: 2px;">Test</div>
            """,
          ),
        ),
      );

      expect(
          _getDivContainer("Test").padding,
          equals(const EdgeInsets.only(
            bottom: 2,
          )));
    },
  );

  testWidgets(
    'Test that two-argument padding-block applies correctly to visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <div style="padding-block: 2px 4px;">Test</div>
            """,
          ),
        ),
      );

      expect(
          _getDivContainer("Test").padding,
          equals(const EdgeInsets.only(
            top: 2,
            bottom: 4,
          )));
    },
  );

  testWidgets(
    'Test that padding-inline-start applies correctly to ltr visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Html(
              data: """
              <div style="padding-inline-start: 2px;">Test</div>
              """,
            ),
          ),
        ),
      );

      expect(
          _getDivContainer("Test").padding,
          equals(const EdgeInsets.only(
            left: 2,
          )));
    },
  );

  testWidgets(
    'Test that padding-inline-end applies correctly to ltr visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Html(
              data: """
              <div style="padding-inline-end: 2px;">Test</div>
              """,
            ),
          ),
        ),
      );

      expect(
          _getDivContainer("Test").padding,
          equals(const EdgeInsets.only(
            right: 2,
          )));
    },
  );

  testWidgets(
    'Test that two-argument padding-inline applies correctly to ltr visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Html(
              data: """
              <div style="padding-inline: 2px 4px;">Test</div>
              """,
            ),
          ),
        ),
      );

      expect(
          _getDivContainer("Test").padding,
          equals(const EdgeInsets.only(
            left: 2,
            right: 4,
          )));
    },
  );

  testWidgets(
    'Test that padding-inline-start applies correctly to rtl visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Html(
              data: """
              <div style="padding-inline-start: 2px;">Test</div>
              """,
            ),
          ),
        ),
      );

      expect(
          _getDivContainer("Test").padding,
          equals(const EdgeInsets.only(
            right: 2,
          )));
    },
  );

  testWidgets(
    'Test that padding-inline-end applies correctly to rtl visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Html(
              data: """
              <div style="padding-inline-end: 2px;">Test</div>
              """,
            ),
          ),
        ),
      );

      expect(
          _getDivContainer("Test").padding,
          equals(const EdgeInsets.only(
            left: 2,
          )));
    },
  );

  testWidgets(
    'Test that two-argument padding-inline applies correctly to rtl visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Html(
              data: """
              <div style="padding-inline: 2px 4px;">Test</div>
              """,
            ),
          ),
        ),
      );

      expect(
          _getDivContainer("Test").padding,
          equals(const EdgeInsets.only(
            right: 2,
            left: 4,
          )));
    },
  );
}

HtmlPaddings? _getPadding(String textToFind) {
  return findCssBox(find.text(textToFind, findRichText: true))!.style.padding;
}

Container _getDivContainer(String textToFind) {
  final containers = List<StatelessElement>.from(find
      .ancestor(
        of: find.text("Test", findRichText: true),
        matching: find.byType(Container),
      )
      .evaluate());
  expect(containers.length, greaterThanOrEqualTo(1));

  return containers.first.widget as Container;
}
