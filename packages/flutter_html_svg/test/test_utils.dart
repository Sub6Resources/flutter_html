import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:meta/meta.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';
import 'dart:convert';

const svgRawString = '''<rect x="5" y="5" width="10" height="10"/>''';
const svgString = '''
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" viewBox="0 0 20 20">
  $svgRawString
</svg>
''';
final String svgEncoded = Uri.encodeFull(svgString);
final svgBase64 = base64Encode(utf8.encode(svgString) as Uint8List);

class FakeAssetBundle extends Fake implements AssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return svgString;
  }

  @override
  Future<ByteData> load(String key) async {
    return Uint8List.fromList(utf8.encode(svgString)).buffer.asByteData();
  }
}

enum TestResult {
  noMatch,
  matchAndFail,
  matchAndRenderSvgPicture,
  matchAndRenderSizedBox,
}

@isTest
void testMatchAndRender(
  String testName,
  String data,
  CustomRenderMatcher matcher,
  CustomRender renderer,
  TestResult expectedResult,
) {
  testWidgets(testName, (WidgetTester tester) async {
    await tester.pumpWidget(
      TestApp(
        Html(
          data: data,
          customRenders: {
            matcher: renderer,
          },
        ),
      ),
    );

    switch (expectedResult) {
      case TestResult.noMatch:
        await expectLater(find.byType(SvgPicture), findsNothing);
        break;
      case TestResult.matchAndFail:
        await expectLater(
            tester.takeException(), anyOf(isException, isStateError));
        break;
      case TestResult.matchAndRenderSvgPicture:
        await expectLater(find.byType(SvgPicture), findsOneWidget);
        break;
      case TestResult.matchAndRenderSizedBox:
        await expectLater(find.byType(SizedBox), findsOneWidget);
        break;
    }
  });
}

class TestApp extends StatelessWidget {
  final Widget body;

  const TestApp(this.body, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: body,
        appBar: AppBar(title: const Text('flutter_html_svg')),
      ),
    );
  }
}
