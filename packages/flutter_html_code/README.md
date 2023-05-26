# flutter_html_code

Code widget for flutter_html. Uses the [flutter_highlighter](https://pub.dev/packages/flutter_highlighter) package
to render `<code>` blocks. Detects the language from the attribute or uses the `defaultLanguage`.

#### Registering the `CodeExtension`:

```dart
Widget html = Html(
    extensions: [
        CodeExtension(
            style: TextStyle(fontSize: 16),
            theme: shadesOfPurpleTheme,
            borderRadius: BorderRadius.circular(4),
            defaultLanguage: html,
        ),
    ],
);
```