import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_svg/flutter_html_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

void main() {
  group("custom image data uri matcher", () {
    CustomRenderMatcher matcher =
        svgDataUriMatcher(encoding: null, mime: 'image/svg+xml');
    testImgSrcMatcher(
      "matches an svg data uri with base64 encoding",
      matcher,
      imgSrc:
          'data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHN2ZyB2aWV3Qm94PSIwIDAgMzAgMjAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxjaXJjbGUgY3g9IjE1IiBjeT0iMTAiIHI9IjEwIiBmaWxsPSJncmVlbiIvPgo8L3N2Zz4=',
      shouldMatch: true,
    );
    testImgSrcMatcher(
      "matches an svg data uri without specified encoding",
      matcher,
      imgSrc:
          'data:image/svg+xml,%3C?xml version="1.0" encoding="UTF-8"?%3E%3Csvg viewBox="0 0 30 20" xmlns="http://www.w3.org/2000/svg"%3E%3Ccircle cx="15" cy="10" r="10" fill="green"/%3E%3C/svg%3E',
      shouldMatch: true,
    );
    testImgSrcMatcher(
      "matches base64 data uri without data",
      matcher,
      imgSrc: 'data:image/svg+xml;base64,',
      shouldMatch: true,
    );
    testImgSrcMatcher(
      "doesn't match non-base64 image data uri",
      matcher,
      imgSrc:
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==',
      shouldMatch: false,
    );
    testImgSrcMatcher(
      "doesn't match different mime data uri",
      matcher,
      imgSrc: 'data:text/plain;base64,',
      shouldMatch: false,
    );
    testImgSrcMatcher(
      "doesn't non-data schema",
      matcher,
      imgSrc: 'http:',
      shouldMatch: false,
    );
    testImgSrcMatcher(
      "doesn't match null",
      matcher,
      imgSrc: null,
      shouldMatch: false,
    );
    testImgSrcMatcher(
      "doesn't match empty",
      matcher,
      imgSrc: '',
      shouldMatch: false,
    );
  });
}

String _fakeElement(String? src) {
  return """
      <img alt='' src="$src" />
    """;
}

@isTest
void testImgSrcMatcher(
  String name,
  CustomRenderMatcher matcher, {
  required String? imgSrc,
  required bool shouldMatch,
}) {
  testWidgets(name, (WidgetTester tester) async {
    await tester.pumpWidget(
      TestApp(
        Html(
          data: _fakeElement(imgSrc),
          customRenders: {
            matcher: CustomRender.widget(
              widget: (RenderContext context, _) {
                return const Text("Success");
              },
            ),
          },
        ),
      ),
    );
    await expectLater(
        find.text("Success"), shouldMatch ? findsOneWidget : findsNothing);
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
        appBar: AppBar(title: const Text('flutter_html')),
      ),
    );
  }
}
