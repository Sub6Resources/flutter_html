import 'package:flutter_html/image_render.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart' as dom;

void main() {
  group("asset uri matcher", () {
    ImageSourceMatcher matcher = assetUriMatcher();
    test("matches a full asset: uri", () {
      expect(_match(matcher, 'asset:some/asset.png'), isTrue);
    });
    test("matches asset: schema without path", () {
      expect(_match(matcher, 'asset:'), isTrue);
    });
    test("doesn't match literal host 'asset'", () {
      expect(_match(matcher, 'asset/faulty.path'), isFalse);
    });
    test("doesn't match null", () {
      expect(_match(matcher, null), isFalse);
    });
    test("doesn't match empty", () {
      expect(_match(matcher, ''), isFalse);
    });
  });
  group("default network source matcher", () {
    ImageSourceMatcher matcher = networkSourceMatcher();
    test("matches a full http uri", () {
      expect(_match(matcher, 'http://legacy.http/uri.png'), isTrue);
    });
    test("matches a full https uri", () {
      expect(_match(matcher, 'https://proper.https/uri'), isTrue);
    });
    test("matches http: schema without path", () {
      expect(_match(matcher, 'http:'), isTrue);
    });
    test("matches https: schema without path", () {
      expect(_match(matcher, 'http:'), isTrue);
    });
    test("doesn't match null", () {
      expect(_match(matcher, null), isFalse);
    });
    test("doesn't match empty", () {
      expect(_match(matcher, ''), isFalse);
    });
  });
  group("custom network source matcher", () {
    ImageSourceMatcher matcher = networkSourceMatcher(
      schemas: ['https'],
      domains: ['www.google.com'],
      extension: 'png',
    );
    test("matches schema, domain and extension", () {
      expect(
          _match(matcher,
              'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png'),
          isTrue);
    });
    test("doesn't match if schema is different", () {
      expect(
          _match(matcher,
              'http://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png'),
          isFalse);
    });
    test("doesn't match if domain is different", () {
      expect(
          _match(matcher,
              'https://google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png'),
          isFalse);
    });
    test("doesn't match if file extension is different", () {
      expect(
          _match(matcher,
              'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dppng'),
          isFalse);
    });
    test("doesn't match null", () {
      expect(_match(matcher, null), isFalse);
    });
    test("doesn't match empty", () {
      expect(_match(matcher, ''), isFalse);
    });
  });
  group("default (base64) image data uri matcher", () {
    ImageSourceMatcher matcher = dataUriMatcher();
    test("matches a full png base64 data uri", () {
      expect(
          _match(matcher,
              'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg=='),
          isTrue);
    });
    test("matches a full jpeg base64 data uri", () {
      expect(
          _match(matcher,
              'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDADIiJSwlHzIsKSw4NTI7S31RS0VFS5ltc1p9tZ++u7Kfr6zI4f/zyNT/16yv+v/9////////wfD/////////////2wBDATU4OEtCS5NRUZP/zq/O////////////////////////////////////////////////////////////////////wAARCAAYAEADAREAAhEBAxEB/8QAGQAAAgMBAAAAAAAAAAAAAAAAAQMAAgQF/8QAJRABAAIBBAEEAgMAAAAAAAAAAQIRAAMSITEEEyJBgTORUWFx/8QAFAEBAAAAAAAAAAAAAAAAAAAAAP/EABQRAQAAAAAAAAAAAAAAAAAAAAD/2gAMAwEAAhEDEQA/AOgM52xQDrjvAV5Xv0vfKUALlTQfeBm0HThMNHXkL0Lw/swN5qgA8yT4MCS1OEOJV8mBz9Z05yfW8iSx7p4j+jA1aD6Wj7ZMzstsfvAas4UyRHvjrAkC9KhpLMClQntlqFc2X1gUj4viwVObKrddH9YDoHvuujAEuNV+bLwFS8XxdSr+Cq3Vf+4F5RgQl6ZR2p1eAzU/HX80YBYyJLCuexwJCO2O1bwCRidAfWBSctswbI12GAJT3yiwFR7+MBjGK2g/WAJR3FdF84E2rK5VR0YH/9k='),
          isTrue);
    });
    test("matches base64 data uri without data", () {
      expect(_match(matcher, 'data:image/png;base64,'), isTrue);
    });
    test("doesn't match non-base64 image data uri", () {
      expect(
          _match(matcher,
              'data:image/png;hex,89504e470d0a1a0a0000000d49484452000000050000000508060000008d6f26e50000001c4944415408d763f8ffff3fc37f062005c3201284d031f18258cd04000ef535cbd18e0e1f0000000049454e44ae426082'),
          isFalse);
    });
    test("doesn't match base64 non-image data uri", () {
      expect(_match(matcher, 'data:text/plain;base64,'), isFalse);
    });
    test("doesn't non-data schema", () {
      expect(_match(matcher, 'http:'), isFalse);
    });
    test("doesn't match null", () {
      expect(_match(matcher, null), isFalse);
    });
    test("doesn't match empty", () {
      expect(_match(matcher, ''), isFalse);
    });
  });
  group("custom image data uri matcher", () {
    ImageSourceMatcher matcher =
        dataUriMatcher(encoding: null, mime: 'image/svg+xml');
    test("matches an svg data uri with base64 encoding", () {
      expect(
          _match(matcher,
              'data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHN2ZyB2aWV3Qm94PSIwIDAgMzAgMjAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxjaXJjbGUgY3g9IjE1IiBjeT0iMTAiIHI9IjEwIiBmaWxsPSJncmVlbiIvPgo8L3N2Zz4='),
          isTrue);
    });
    test("matches an svg data uri without specified encoding", () {
      expect(
          _match(matcher,
              'data:image/svg+xml,%3C?xml version="1.0" encoding="UTF-8"?%3E%3Csvg viewBox="0 0 30 20" xmlns="http://www.w3.org/2000/svg"%3E%3Ccircle cx="15" cy="10" r="10" fill="green"/%3E%3C/svg%3E'),
          isTrue);
    });
    test("matches base64 data uri without data", () {
      expect(_match(matcher, 'data:image/svg+xml;base64,'), isTrue);
    });
    test("doesn't match non-base64 image data uri", () {
      expect(
          _match(matcher,
              'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg=='),
          isFalse);
    });
    test("doesn't match different mime data uri", () {
      expect(_match(matcher, 'data:text/plain;base64,'), isFalse);
    });
    test("doesn't non-data schema", () {
      expect(_match(matcher, 'http:'), isFalse);
    });
    test("doesn't match null", () {
      expect(_match(matcher, null), isFalse);
    });
    test("doesn't match empty", () {
      expect(_match(matcher, ''), isFalse);
    });
  });
}

dom.Element _fakeElement(String? src) {
  return dom.Element.html("""
      <img src="$src" />
    """);
}

bool _match(ImageSourceMatcher matcher, String? src) {
  final element = _fakeElement(src);
  return matcher.call(
      element.attributes.map((key, value) => MapEntry(key.toString(), value)),
      element);
}
