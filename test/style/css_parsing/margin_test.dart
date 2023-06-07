import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils.dart';

// Note that in these tests we add <span>...</span> before and after
// the `div` to prevent its margins from collapsing into its parent's margins.

void main() {
  testWidgets(
    'Test that a normal div has no margin',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: "<div>Test</div>",
          ),
        ),
      );
      expect(_getMargin("Test"), equals(Margins.zero));
    },
  );

  testWidgets(
    'Test that a div with inline styled margin has margin',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data:
                """<span>...</span><div style="margin: 8px;">Test</div><span>...</span>""",
          ),
        ),
      );

      // Top and bottom margins will be merged with parent margins due to margin collapsing
      expect(_getMargin("Test"), equals(Margins.all(8, Unit.px)));
    },
  );

  testWidgets(
    'Test that a div with styled margin has margin',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <style>div {margin: 8px;}</style>
            <span>...</span><div>Test</div><span>...</span>
            """,
          ),
        ),
      );
      expect(_getMargin("Test"), equals(Margins.all(8, Unit.px)));
    },
  );

  testWidgets(
    'Test margin-left in <style>',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <style>div {margin-left: 8px;}</style>
            <span>...</span><div>Test</div><span>...</span>
            """,
          ),
        ),
      );
      expect(_getMargin("Test"), equals(Margins.only(left: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test margin-top in <style>',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <style>div {margin-top: 8px;}</style>
            <span>...</span><div>Test</div><span>...</span>
            """,
          ),
        ),
      );
      expect(_getMargin("Test"), equals(Margins.only(top: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test margin-right in <style>',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <style>div {margin-right: 8px;}</style>
            <span>...</span><div>Test</div><span>...</span>
            """,
          ),
        ),
      );
      expect(_getMargin("Test"), equals(Margins.only(right: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test margin-bottom in <style>',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <style>div {margin-bottom: 8px;}</style>
            <span>...</span><div>Test</div><span>...</span>
            """,
          ),
        ),
      );
      expect(
          _getMargin("Test"), equals(Margins.only(bottom: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test margin-block-start in <style>',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <style>div {margin-block-start: 8px;}</style>
            <span>...</span><div>Test</div><span>...</span>
            """,
          ),
        ),
      );
      expect(_getMargin("Test"),
          equals(Margins.only(top: 8, blockStart: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test margin-block-end in <style>',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <style>div {margin-block-end: 8px;}</style>
            <span>...</span><div>Test</div><span>...</span>
            """,
          ),
        ),
      );
      expect(
          _getMargin("Test"), equals(Margins.only(blockEnd: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test margin-inline-start in <style>',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <style>div {margin-inline-start: 8px;}</style>
            <span>...</span><div>Test</div><span>...</span>
            """,
          ),
        ),
      );
      expect(_getMargin("Test"),
          equals(Margins.only(inlineStart: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test margin-inline-end in <style>',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <style>div {margin-inline-end: 8px;}</style>
            <span>...</span><div>Test</div><span>...</span>
            """,
          ),
        ),
      );
      expect(_getMargin("Test"),
          equals(Margins.only(inlineEnd: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test margin-left inline',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <span>...</span><div style="margin-left: 8px;">Test</div><span>...</span>
            """,
          ),
        ),
      );
      expect(_getMargin("Test"), equals(Margins.only(left: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test margin-top inline',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <span>...</span><div style="margin-top: 8px;">Test</div><span>...</span>
            """,
          ),
        ),
      );
      expect(_getMargin("Test"), equals(Margins.only(top: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test margin-right inline',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <span>...</span><div style="margin-right: 8px;">Test</div><span>...</span>
            """,
          ),
        ),
      );
      expect(_getMargin("Test"), equals(Margins.only(right: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test margin-bottom inline',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <span>...</span><div style="margin-bottom: 8px;">Test</div><span>...</span>
            """,
          ),
        ),
      );
      expect(
          _getMargin("Test"), equals(Margins.only(bottom: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test margin-block-start inline',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <span>...</span><div style="margin-block-start: 8px;">Test</div><span>...</span>
            """,
          ),
        ),
      );
      expect(_getMargin("Test"),
          equals(Margins.only(top: 8, blockStart: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test margin-block-end inline',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <span>...</span><div style="margin-block-end: 8px;">Test</div><span>...</span>
            """,
          ),
        ),
      );
      expect(
          _getMargin("Test"), equals(Margins.only(blockEnd: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test margin-inline-start inline',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <span>...</span><div style="margin-inline-start: 8px;">Test</div><span>...</span>
            """,
          ),
        ),
      );
      expect(_getMargin("Test"),
          equals(Margins.only(inlineStart: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test margin-inline-end inline',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <span>...</span><div style="margin-inline-end: 8px;">Test</div><span>...</span>
            """,
          ),
        ),
      );
      expect(_getMargin("Test"),
          equals(Margins.only(inlineEnd: 8, unit: Unit.px)));
    },
  );

  testWidgets(
    'Test that margin actually applies to visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <span>...</span><div style="margin: 8px;">Test</div><span>...</span>
            """,
          ),
        ),
      );

      expect(_getDeepestRenderCSSBox("Test", tester).margins,
          equals(Margins.all(8)));
    },
  );

  testWidgets(
    'Test that two-argument margin actually applies to visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <span>...</span><div style="margin: 4px 8px;">Test</div><span>...</span>
            """,
          ),
        ),
      );

      expect(
          _getDeepestRenderCSSBox("Test", tester).margins,
          equals(Margins.symmetric(
            vertical: 4,
            horizontal: 8,
          )));
    },
  );

  testWidgets(
    'Test that three-argument margin applies correctly to visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <span>...</span><div style="margin: 4px 6px 8px;">Test</div><span>...</span>
            """,
          ),
        ),
      );

      expect(
          _getDeepestRenderCSSBox("Test", tester).margins,
          equals(Margins.only(
            top: 4,
            right: 6,
            left: 6,
            bottom: 8,
          )));
    },
  );

  testWidgets(
    'Test that four-argument margin applies correctly to visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <span>...</span><div style="margin: 2px 4px 6px 8px;">Test</div><span>...</span>
            """,
          ),
        ),
      );

      expect(
          _getDeepestRenderCSSBox("Test", tester).margins,
          equals(Margins.only(
            top: 2,
            right: 4,
            bottom: 6,
            left: 8,
          )));
    },
  );

  testWidgets(
    'Test that margin-block-start applies correctly to visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <span>...</span><div style="margin-block-start: 2px;">Test</div><span>...</span>
            """,
          ),
        ),
      );

      expect(
          _getDeepestRenderCSSBox("Test", tester).margins,
          equals(Margins.only(
            top: 2,
          )));
    },
  );

  testWidgets(
    'Test that margin-block-end applies correctly to visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <span>...</span><div style="margin-block-end: 2px;">Test</div><span>...</span>
            """,
          ),
        ),
      );

      expect(
          _getDeepestRenderCSSBox("Test", tester).margins,
          equals(Margins.only(
            bottom: 2,
          )));
    },
  );

  testWidgets(
    'Test that two-argument margin-block applies correctly to visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <span>...</span><div style="margin-block: 2px 4px;">Test</div><span>...</span>
            """,
          ),
        ),
      );

      expect(
          _getDeepestRenderCSSBox("Test", tester).margins,
          equals(Margins.only(
            top: 2,
            bottom: 4,
          )));
    },
  );

  testWidgets(
    'Test that margin-inline-start applies correctly to ltr visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Html(
              data: """
              <span>...</span><div style="margin-inline-start: 2px;">Test</div><span>...</span>
              """,
            ),
          ),
        ),
      );

      expect(
          _getDeepestRenderCSSBox("Test", tester).margins,
          equals(Margins.only(
            left: 2,
          )));
    },
  );

  testWidgets(
    'Test that margin-inline-end applies correctly to ltr visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Html(
              data: """
              <span>...</span><div style="margin-inline-end: 2px;">Test</div><span>...</span>
              """,
            ),
          ),
        ),
      );

      expect(
          _getDeepestRenderCSSBox("Test", tester).margins,
          equals(Margins.only(
            right: 2,
          )));
    },
  );

  testWidgets(
    'Test that two-argument margin-inline applies correctly to ltr visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Html(
              data: """
              <span>...</span><div style="margin-inline: 2px 4px;">Test</div><span>...</span>
              """,
            ),
          ),
        ),
      );

      expect(
          _getDeepestRenderCSSBox("Test", tester).margins,
          equals(Margins.only(
            left: 2,
            right: 4,
          )));
    },
  );

  testWidgets(
    'Test that margin-inline-start applies correctly to rtl visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Html(
              data: """
              <span>...</span><div style="margin-inline-start: 2px;">Test</div><span>...</span>
              """,
            ),
          ),
        ),
      );

      expect(
          _getDeepestRenderCSSBox("Test", tester).margins,
          equals(Margins.only(
            right: 2,
          )));
    },
  );

  testWidgets(
    'Test that margin-inline-end applies correctly to rtl visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Html(
              data: """
              <span>...</span><div style="margin-inline-end: 2px;">Test</div><span>...</span>
              """,
            ),
          ),
        ),
      );

      expect(
          _getDeepestRenderCSSBox("Test", tester).margins,
          equals(Margins.only(
            left: 2,
          )));
    },
  );

  testWidgets(
    'Test that two-argument margin-inline applies correctly to rtl visual layout',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Html(
              data: """
              <span>...</span><div style="margin-inline: 2px 4px;">Test</div><span>...</span>
              """,
            ),
          ),
        ),
      );

      expect(
          _getDeepestRenderCSSBox("Test", tester).margins,
          equals(Margins.only(
            right: 2,
            left: 4,
          )));
    },
  );

  testWidgets(
    'Test that em margin applies correctly',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 14),
            child: Html(
              data: """
              <span>...</span><div style="margin: 1em 2em; font-size: 14px;">Test</div><span>...</span>
              """,
            ),
          ),
        ),
      );

      expect(
          _getDeepestRenderCSSBox("Test", tester).margins,
          equals(Margins.symmetric(
            vertical: 14,
            horizontal: 28,
          )));
    },
  );

  testWidgets(
    'Test that rem margin applies correctly',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 14),
            child: Html(
              data: """
              <span>...</span><div style="margin-left: 2rem;">Test</div><span>...</span>
              """,
            ),
          ),
        ),
      );

      expect(
        _getDeepestRenderCSSBox("Test", tester).margins,
        equals(Margins.only(left: 28)),
      );
    },
  );

  testWidgets(
    'Test that dimensionless margin applies correctly',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <span>...</span><div style="margin-right: 12;">Test</div><span>...</span>
            """,
          ),
        ),
      );

      expect(
        _getDeepestRenderCSSBox("Test", tester).margins,
        equals(Margins.only(right: 12)),
      );
    },
  );
}

Margins? _getMargin(String textToFind) {
  return findCssBox(find.text(textToFind, findRichText: true))!.style.margin;
}

RenderCSSBox _getDeepestRenderCSSBox(String textToFind, WidgetTester tester) {
  final objects = tester.renderObjectList(
    find.byElementType(MultiChildRenderObjectElement),
  );

  return objects.lastWhere((e) {
    return e is RenderCSSBox;
  }) as RenderCSSBox;
}
