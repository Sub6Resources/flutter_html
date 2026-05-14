import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_utils.dart';

void main() {
  group('Ordered List Start Attribute', () {
    testWidgets('Default start value is 1 (offset 0)', (WidgetTester tester) async {
      final tree = await generateStyledElementTreeFromHtml(
        tester,
        html: '<ol><li>Item</li></ol>',
      );

      final ol = tree.children.first.children.first; // html -> body -> ol
      expect(ol.name, 'ol');
      expect(ol.style.counterIncrement!['list-item'], 0);
    });

    testWidgets('Explicit start value is respected', (WidgetTester tester) async {
      final tree = await generateStyledElementTreeFromHtml(
        tester,
        html: '<ol start="5"><li>Item</li></ol>',
      );

      final ol = tree.children.first.children.first; // html -> body -> ol
      expect(ol.name, 'ol');
      expect(ol.style.counterIncrement!['list-item'], 4);
    });

    testWidgets('Invalid start value defaults to 1 (offset 0)', (WidgetTester tester) async {
      final tree = await generateStyledElementTreeFromHtml(
        tester,
        html: '<ol start="abc"><li>Item</li></ol>',
      );

      final ol = tree.children.first.children.first; // html -> body -> ol
      expect(ol.name, 'ol');
      expect(ol.style.counterIncrement!['list-item'], 0);
    });
  });
}
