# flutter_html_math

Math widget for flutter_html.

his package renders MathML elements using the [`flutter_math_fork`](https://pub.dev/packages/flutter_math_fork) plugin.

When rendering MathML, the package takes the MathML data within the `<math>` tag and tries to parse it to Tex. Then, it will pass the parsed string to `flutter_math_fork`.

Because this package is parsing MathML to Tex, it may not support some functionalities. The current list of supported tags can be found [above](#currently-supported-html-tags), but some of these only have partial support at the moment.

#### Registering the `CustomRender`:

```dart
Widget html = Html(
  customRenders: {
    mathMatcher(): mathRender(),
  }
);
```

If the parsing errors, you can use the `onMathError` property of `mathRender` to catch the error and potentially fix it on your end.

The function exposes the parsed Tex `String`, as well as the error and error with type from `flutter_math_fork` as a `String`.

You can analyze the error and the parsed string, and finally return a new instance of `Math.tex()` with the corrected Tex string.

#### `onMathError` example:

```dart
Widget html = Html(
  customRenders: {
    mathMatcher(): mathRender(onMathError: (tex, exception, exceptionWithType) {
      print(exception);
      //optionally try and correct the Tex string here
      return Text(exception);
    }),
  }
);
```