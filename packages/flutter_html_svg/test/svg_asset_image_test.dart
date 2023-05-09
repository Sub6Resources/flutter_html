import 'package:flutter_html_svg/flutter_html_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import './test_utils.dart';

void main() {
  group("custom image asset tests:", () {
    const String svgString = svgRawString;
    String makeImgTag({
      String? src,
      int? width,
      int? height,
    }) {
      String srcAttr = src != null ? 'src="$src"' : '';
      String widthAttr = width != null ? 'width=$width' : '';
      String heightAttr = height != null ? 'height=$height' : '';

      return """
        <img $widthAttr $heightAttr $srcAttr />
        """;
    }

    // Happy path (taken from SvgPicture examples)
    testMatchAndRender(
        "matches and renders img with asset",
        makeImgTag(src: "asset:fake.svg", width: 100, height: 100),
        svgAssetUriMatcher(),
        svgAssetImageRender(bundle: FakeAssetBundle()),
        TestResult.matchAndRenderSvgPicture);

    // Failure paths
    testMatchAndRender(
        "does not match",
        makeImgTag(src: "fake.svg"),
        svgAssetUriMatcher(),
        svgAssetImageRender(bundle: FakeAssetBundle()),
        TestResult.noMatch);
  });
}
