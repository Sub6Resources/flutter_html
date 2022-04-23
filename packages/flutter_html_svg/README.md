# flutter_html_svg

SVG widget for flutter_html

This package renders svg elements using the [`flutter_svg`](https://pub.dev/packages/flutter_svg) plugin.

When rendering SVGs, the package takes the SVG data within the `<svg>` tag and passes it to `flutter_svg`. The `width` and `height` attributes are considered while rendering, if given.

The package also exposes a few ways to render SVGs within an `<img>` tag, specifically base64 SVGs, asset SVGs, and network SVGs.

#### Registering the `CustomRender`:

```dart
Widget html = Html(
  customRenders: {
    svgTagMatcher(): svgTagRender(),
    svgDataUriMatcher(): svgDataImageRender(),
    svgAssetUriMatcher(): svgAssetImageRender(),
    svgNetworkSourceMatcher(): svgNetworkImageRender(),
  }
);
```
