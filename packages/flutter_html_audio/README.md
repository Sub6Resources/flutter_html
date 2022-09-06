# flutter_html_audio

Audio extension for flutter_html.

This package renders audio elements using the [`chewie_audio`](https://pub.dev/packages/chewie_audio) and the [`video_player`](https://pub.dev/packages/video_player) plugin.

The package considers the attributes `controls`, `loop`, `src`, `autoplay`, `width`, and `muted` when rendering the audio widget.

#### Registering the `CustomRender`:

```dart
Widget html = Html(
  customRenders: {
    audioMatcher(): audioRender(),
  }
);
```