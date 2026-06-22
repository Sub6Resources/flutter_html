import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('table with img', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data:
                '<table><tr><td><img src="https://example.com/img.png"></td></tr></table>',
            extensions: [const TableHtmlExtension()],
          ),
        ),
      ),
    );
  });
}
