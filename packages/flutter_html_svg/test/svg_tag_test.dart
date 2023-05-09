import 'package:flutter_html_svg/flutter_html_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import './test_utils.dart';

void main() {
  group("svg tag tests:", () {
    const String svgString = svgRawString;
    String makeSvgTag({
      String? content,
      int? width,
      int? height,
    }) {
      String widthAttr = width != null ? 'width=$width' : '';
      String heightAttr = height != null ? 'height=$height' : '';

      return """
        <svg $widthAttr $heightAttr>
          $content
        </svg>
        """;
    }

    // Happy path (taken from SvgPicture examples)
    testMatchAndRender(
        "matches and renders svg tag",
        makeSvgTag(content: svgRawString, width: 100, height: 100),
        svgTagMatcher(),
        svgTagRender(),
        TestResult.matchAndRenderSvgPicture);
  });
}
