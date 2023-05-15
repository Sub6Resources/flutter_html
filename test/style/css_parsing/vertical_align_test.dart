import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils.dart';

void main() {
  testWidgets(
    'Tag with vertical align set inline should receive that style',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <span style="vertical-align: super;">Text</span>
          """,
          ),
        ),
      );
      expect(find.text("Text", findRichText: true), findsOneWidget);
      expect(
          findCssBox(find.text("Text", findRichText: true))!
              .style
              .verticalAlign,
          equals(VerticalAlign.sup));
    },
  );

  testWidgets(
    'Tag with vertical align set in style tag should receive that style',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <style>span {vertical-align: sub;}</style>
            <span>Text</span>
          """,
          ),
        ),
      );
      expect(find.text("Text", findRichText: true), findsOneWidget);
      expect(
          findCssBox(find.text("Text", findRichText: true))!
              .style
              .verticalAlign,
          equals(VerticalAlign.sub));
    },
  );

  testWidgets(
    'Tag with no vertical align set should have default',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <span>Text</span>
          """,
          ),
        ),
      );
      expect(find.text("Text", findRichText: true), findsOneWidget);
      expect(
          findCssBox(find.text("Text", findRichText: true))!
              .style
              .verticalAlign,
          equals(VerticalAlign.baseline));
    },
  );

  testWidgets(
    'Tag with vertical align bottom set should have that value',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <div style="vertical-align: bottom;">Text</div>
          """,
          ),
        ),
      );
      expect(find.text("Text", findRichText: true), findsOneWidget);
      expect(
          findCssBox(find.text("Text", findRichText: true))!
              .style
              .verticalAlign,
          equals(VerticalAlign.bottom));
    },
  );

  testWidgets(
    'Tag with vertical align middle set should have that value',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <div style="vertical-align: middle;">Text</div>
          """,
          ),
        ),
      );
      expect(find.text("Text", findRichText: true), findsOneWidget);
      expect(
          findCssBox(find.text("Text", findRichText: true))!
              .style
              .verticalAlign,
          equals(VerticalAlign.middle));
    },
  );

  testWidgets(
    'Tag with vertical align top set should have that value',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Html(
            data: """
            <div style="vertical-align: top;">Text</div>
          """,
          ),
        ),
      );
      expect(find.text("Text", findRichText: true), findsOneWidget);
      expect(
          findCssBox(find.text("Text", findRichText: true))!
              .style
              .verticalAlign,
          equals(VerticalAlign.top));
    },
  );
}
