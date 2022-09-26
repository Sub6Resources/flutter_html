import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_test/flutter_test.dart';

import 'golden_test.dart';

void main() {
  group("asset uri matcher", () {
    CustomRenderMatcher matcher = assetUriMatcher();
    testImgSrcMatcher(
      "matches a full asset: uri",
      matcher,
      imgSrc: 'asset:some/asset.png',
      shouldMatch: true,
    );
    testImgSrcMatcher(
      "matches asset: schema without path",
      matcher,
      imgSrc: 'asset:',
      shouldMatch: true,
    );
    testImgSrcMatcher(
      "doesn't match literal host 'asset'",
      matcher,
      imgSrc: 'asset/faulty.path',
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
  group("default network source matcher", () {
    CustomRenderMatcher matcher = networkSourceMatcher();
    testImgSrcMatcher(
      "matches a full http uri",
      matcher,
      imgSrc: 'http://legacy.http/uri.png',
      shouldMatch: true,
    );
    testImgSrcMatcher(
      "matches a full https uri",
      matcher,
      imgSrc: 'https://proper.https/uri',
      shouldMatch: true,
    );
    testImgSrcMatcher(
      "matches http: schema without path",
      matcher,
      imgSrc: 'http:',
      shouldMatch: true,
    );
    testImgSrcMatcher(
      "matches https: schema without path",
      matcher,
      imgSrc: 'http:',
      shouldMatch: true,
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
  group("custom network source matcher", () {
    CustomRenderMatcher matcher = networkSourceMatcher(
      schemas: ['https'],
      domains: ['www.google.com'],
      extension: 'png',
    );
    testImgSrcMatcher(
      "matches schema, domain and extension",
      matcher,
      imgSrc:
          'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png',
      shouldMatch: true,
    );
    testImgSrcMatcher(
      "doesn't match if schema is different",
      matcher,
      imgSrc:
          'http://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png',
      shouldMatch: false,
    );
    testImgSrcMatcher(
      "doesn't match if domain is different",
      matcher,
      imgSrc:
          'https://google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png',
      shouldMatch: false,
    );
    testImgSrcMatcher(
      "doesn't match if file extension is different",
      matcher,
      imgSrc:
          'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dppng',
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
  group("default (base64) image data uri matcher", () {
    CustomRenderMatcher matcher = dataUriMatcher();
    testImgSrcMatcher(
      "matches a full png base64 data uri",
      matcher,
      imgSrc:
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==',
      shouldMatch: true,
    );
    testImgSrcMatcher(
      "matches a full jpeg base64 data uri",
      matcher,
      imgSrc:
          'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDADIiJSwlHzIsKSw4NTI7S31RS0VFS5ltc1p9tZ++u7Kfr6zI4f/zyNT/16yv+v/9////////wfD/////////////2wBDATU4OEtCS5NRUZP/zq/O////////////////////////////////////////////////////////////////////wAARCAAYAEADAREAAhEBAxEB/8QAGQAAAgMBAAAAAAAAAAAAAAAAAQMAAgQF/8QAJRABAAIBBAEEAgMAAAAAAAAAAQIRAAMSITEEEyJBgTORUWFx/8QAFAEBAAAAAAAAAAAAAAAAAAAAAP/EABQRAQAAAAAAAAAAAAAAAAAAAAD/2gAMAwEAAhEDEQA/AOgM52xQDrjvAV5Xv0vfKUALlTQfeBm0HThMNHXkL0Lw/swN5qgA8yT4MCS1OEOJV8mBz9Z05yfW8iSx7p4j+jA1aD6Wj7ZMzstsfvAas4UyRHvjrAkC9KhpLMClQntlqFc2X1gUj4viwVObKrddH9YDoHvuujAEuNV+bLwFS8XxdSr+Cq3Vf+4F5RgQl6ZR2p1eAzU/HX80YBYyJLCuexwJCO2O1bwCRidAfWBSctswbI12GAJT3yiwFR7+MBjGK2g/WAJR3FdF84E2rK5VR0YH/9k=',
      shouldMatch: true,
    );
    testImgSrcMatcher(
      "matches base64 data uri without data",
      matcher,
      imgSrc: 'data:image/png;base64,',
      shouldMatch: true,
    );
    testImgSrcMatcher(
      "doesn't match non-base64 image data uri",
      matcher,
      imgSrc:
          'data:image/png;hex,89504e470d0a1a0a0000000d49484452000000050000000508060000008d6f26e50000001c4944415408d763f8ffff3fc37f062005c3201284d031f18258cd04000ef535cbd18e0e1f0000000049454e44ae426082',
      shouldMatch: false,
    );
    testImgSrcMatcher(
      "doesn't match base64 non-image data uri",
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
      <img alt ='' src="$src" />
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
