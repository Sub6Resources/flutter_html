# flutter_html_video

Video extension for flutter_html.

This package renders video elements using the [`chewie`](https://pub.dev/packages/chewie) and the [`video_player`](https://pub.dev/packages/video_player) plugin. 

The package considers the attributes `controls`, `loop`, `src`, `autoplay`, `poster`, `width`, `height`, and `muted` when rendering the video widget.

#### Registering the `CustomRender`:

```dart
Widget html = Html(
  customRenders: {
    videoMatcher(): videoRender(),
  }
);
```