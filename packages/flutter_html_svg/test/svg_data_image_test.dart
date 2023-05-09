import 'package:flutter_html_svg/flutter_html_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import './test_utils.dart';

void main() {
  group("custom image data uri tests:", () {
    String makeImgTag({
      String? src,
      int? width,
      int? height,
    }) {
      String srcAttr = src != null ? 'src="$src"' : '';
      String widthAttr = width != null ? 'width=$width' : '';
      String heightAttr = height != null ? 'height=$height' : '';

      return """
        <img alt='dummy' $widthAttr $heightAttr $srcAttr />
        """;
    }

    // Happy path (taken from SvgPicture examples)
    testMatchAndRender(
        "matches and renders image/svg+xml with text encoding",
        makeImgTag(
            src: 'data:image/svg+xml,$svgEncoded', width: 100, height: 100),
        svgDataUriMatcher(encoding: null),
        svgDataImageRender(),
        TestResult.matchAndRenderSvgPicture);
    testMatchAndRender(
        "matches and renders image/svg+xml and base64 encoding",
        makeImgTag(src: 'data:image/svg+xml;base64,$svgBase64'),
        svgDataUriMatcher(),
        svgDataImageRender(),
        TestResult.matchAndRenderSvgPicture);

    // Failure paths
    testMatchAndRender("image tag with no attributes", makeImgTag(),
        svgDataUriMatcher(), svgDataImageRender(), TestResult.noMatch);
    testMatchAndRender(
        "does not match base64 image data uri",
        makeImgTag(
            src:
                'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg=='),
        svgDataUriMatcher(),
        svgDataImageRender(),
        TestResult.noMatch);
    testMatchAndRender(
        "does not match non-svg mime data",
        makeImgTag(src: 'data:text/plain;base64,'),
        svgDataUriMatcher(),
        svgDataImageRender(),
        TestResult.noMatch);
    testMatchAndRender(
        "does not match non-data schema",
        makeImgTag(src: 'http:'),
        svgDataUriMatcher(),
        svgDataImageRender(),
        TestResult.noMatch);
  });
}
