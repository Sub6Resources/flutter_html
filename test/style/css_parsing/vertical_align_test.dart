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
}
