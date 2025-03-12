# flutter_html
[![pub package](https://img.shields.io/pub/v/flutter_html.svg)](https://pub.dev/packages/flutter_html)
[![codecov](https://codecov.io/gh/Sub6Resources/flutter_html/branch/master/graph/badge.svg)](https://codecov.io/gh/Sub6Resources/flutter_html)
[![GitHub Actions](https://github.com/Sub6Resources/flutter_html/actions/workflows/test.yml/badge.svg)](https://github.com/Sub6Resources/flutter_html/actions)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/Sub6Resources/flutter_html/blob/master/LICENSE)

A Flutter widget for rendering HTML and CSS as Flutter widgets.

```dart
Widget build(context) {
  return Html(
    data: """
        <h1>Hello, World!</h1>
        <p><span style="font-style:italic;">flutter_html</span> supports a variety of HTML and CSS tags and attributes.</p>
        <p>Over a hundred static tags are supported out of the box.</p>
        <p>Or you can even define your own using an <code>Extension</code>: <flutter></flutter></p>
        <p>Its easy to add custom styles to your Html as well using the <code>Style</code> class:</p>
        <p class="fancy">Here's a fancy &lt;p&gt; element!</p>
        """,
    extensions: [
      TagExtension(
        tagsToExtend: {"flutter"},
        child: const FlutterLogo(),
      ),
    ],
    style: {
      "p.fancy": Style(
        textAlign: TextAlign.center,
        padding: const EdgeInsets.all(16),
        backgroundColor: Colors.grey,
        margin: Margins(left: Margin(50, Unit.px), right: Margin.auto()),
        width: Width(300, Unit.px),
        fontWeight: FontWeight.bold,
      ),
    },
  );
}
```

becomes...

<img src="https://raw.githubusercontent.com/Sub6Resources/flutter_html/master/example/screenshots/flutter_html_readme_screenshot.png" alt="A screenshot showing the above code snippet rendered using flutter_html" />

## Table of Contents:

- [Supported HTML Tags](https://github.com/Sub6Resources/flutter_html/wiki/Supported-HTML-Elements)

- [Supported CSS Attributes](https://github.com/Sub6Resources/flutter_html/wiki/Supported-CSS-Attributes)

- [Why flutter_html?](#why-this-package)

- [Migration Guide](#migration-guides)

- [API Reference](#api-reference)

  - [Constructors](#constructors)

  - [Parameters Table](#parameters)
  
- [External Packages](#external-packages)
  
  - [`flutter_html_all`](#flutter_html_all)
  
  - [`flutter_html_audio`](#flutter_html_audio)
  
  - [`flutter_html_iframe`](#flutter_html_iframe)
  
  - [`flutter_html_math`](#flutter_html_math)
  
  - [`flutter_html_svg`](#flutter_html_svg)
  
  - [`flutter_html_table`](#flutter_html_table)

  - [`flutter_html_video`](#flutter_html_video)
  
- [Frequently Asked Questions](#faq)

- [Example](#example)


## Why this package?

This package is designed with simplicity in mind. Originally created to allow basic rendering of HTML content into the Flutter widget tree,
this project has expanded to include support for basic styling as well! 

If you need something more robust and customizable, the package also provides a number of extension APIs for extremely granular control over widget rendering!

## Migration Guides

[3.0.0 Migration Guide](https://github.com/Sub6Resources/flutter_html/wiki/Migration-Guides#300)

## API Reference:

For the full API reference, see [here](https://pub.dev/documentation/flutter_html/latest/).

For a full example, see [here](https://github.com/Sub6Resources/flutter_html/tree/master/example).

Below, you will find brief descriptions of the parameters the`Html` widget accepts and some code snippets to help you use this package.

### Constructors:

The package currently has two different constructors - `Html()` and `Html.fromDom()`. 

The `Html()` constructor is for those who would like to directly pass HTML from the source to the package to be rendered. 

If you would like to modify or sanitize the HTML before rendering it, then `Html.fromDom()` is for you - you can convert the HTML string to a `Document` and use its methods to modify the HTML as you wish. Then, you can directly pass the modified `Document` to the package. This eliminates the need to parse the modified `Document` back to a string, pass to `Html()`, and convert back to a `Document`, thus cutting down on load times.

### Parameters:

| Parameters             | Description                                                                                                                                                                                         |
|------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `data`                 | The HTML data passed to the `Html` widget. This is required and cannot be null when using `Html()`.                                                                                                 |
| `document`             | The DOM document passed to the `Html` widget. This is required and cannot be null when using `Html.fromDom()`.                                                                                      |
| `onLinkTap`            | Optional. A function that defines what the widget should do when a link is tapped. The function exposes the `src` of the link as a `String` to use in your implementation.                          |
| `extensions`           | Optional. A powerful API that allows you to customize everything when rendering a specific HTML tag.                                                                                                |
| `shrinkWrap`           | Optional. A `bool` used while rendering different widgets to specify whether they should be shrink-wrapped or not, like `ContainerSpan`                                                             |
| `onlyRenderTheseTags`  | Optional. An exclusive set of elements the `Html` widget should render. Note that your html will be wrapped in `<body>` and `<html>` if it isn't already, so you should include those in this list. |
| `doNotRenderTheseTags` | Optional. A set of tags that should not be rendered by the `Html` widget.                                                                                                                           |
| `style`                | Optional. A powerful API that allows you to customize the style that should be used when rendering a specific HTMl tag.                                                                             |


More examples and in-depth details are available:

 - [Style](https://github.com/Sub6Resources/flutter_html/wiki/How-To-Use-Style).
 - [HtmlExtension](https://github.com/Sub6Resources/flutter_html/wiki/How-To-Use-Extensions)

## External Packages

### `flutter_html_all`

This package is simply a convenience package that exports all the other external packages below. You should use this if you plan to render all the tags that require external dependencies.

### `flutter_html_audio`

This package renders audio elements using the [`chewie_audio`](https://pub.dev/packages/chewie_audio) and the [`video_player`](https://pub.dev/packages/video_player) plugin.

The package considers the attributes `controls`, `loop`, `src`, `autoplay`, `width`, and `muted` when rendering the audio widget.

#### Adding the `AudioHtmlExtension`:

Add the dependency to your pubspec.yaml:

    flutter pub add flutter_html_audio

```dart
import 'package:flutter_html_audio/flutter_html_audio.dart';

Widget html = Html(
  data: myHtml,
  extensions: [
    AudioHtmlExtension(),
  ],
);
```

### `flutter_html_iframe`

This package renders iframes using the [`webview_flutter`](https://pub.dev/packages/webview_flutter) plugin. 

When rendering iframes, the package considers the width, height, and sandbox attributes. 

Sandbox controls the JavaScript mode of the webview - a value of `null` or `allow-scripts` will set `javascriptMode: JavascriptMode.unrestricted`, otherwise it will set `javascriptMode: JavascriptMode.disabled`.

#### Adding the `IframeHtmlExtension`:

Add the dependency to your pubspec.yaml:

    flutter pub add flutter_html_iframe

```dart
import 'package:flutter_html_iframe/flutter_html_iframe.dart';

Widget html = Html(
  data: myHtml,
  extensions: [
    IframeHtmlExtension(),
  ],
);
```

You can set the `navigationDelegate` of the webview with the `navigationDelegate` property on `IframeHtmlExtension`. This allows you to block or allow the loading of certain URLs.

### `flutter_html_math`

This package renders MathML elements using the [`flutter_math_fork`](https://pub.dev/packages/flutter_math_fork) plugin.

When rendering MathML, the package takes the MathML data within the `<math>` tag and tries to parse it to Tex. Then, it will pass the parsed string to `flutter_math_fork`.

Because this package is parsing MathML to Tex, it may not support some functionalities. The current list of supported tags can be found [on the Wiki](https://github.com/Sub6Resources/flutter_html/wiki/First-Party-Extensions#flutter_html_math), but some of these only have partial support at the moment.

#### Adding the `MathHtmlExtension`:

Add the dependency to your pubspec.yaml:

    flutter pub add flutter_html_math

```dart
import 'package:flutter_html_math/flutter_html_math.dart';

Widget html = Html(
  data: myHtml,
  extensions: [
    MathHtmlExtension(),
  ],
);
```

If the parsing errors, you can use the `onMathErrorBuilder` property of `MathHtmlException` to catch the error and potentially fix it on your end.

The function exposes the parsed Tex `String`, as well as the error and error with type from `flutter_math_fork` as a `String`.

You can analyze the error and the parsed string, and finally return a new instance of `Math.tex()` with the corrected Tex string.

#### Tex

If you have a Tex string you'd like to render inside your HTML you can do that using the same [`flutter_math_fork`](https://pub.dev/packages/flutter_math_fork) plugin.

Use a custom tag inside your HTML (an example could be `<tex>`), and place your **raw** Tex string inside.
 
Then, use the `extensions` parameter to add the widget to render Tex. It could look like this:

```dart
Widget htmlWidget = Html(
  data: r"""<tex>i\hbar\frac{\partial}{\partial t}\Psi(\vec x,t) = -\frac{\hbar}{2m}\nabla^2\Psi(\vec x,t)+ V(\vec x)\Psi(\vec x,t)</tex>""",
  extensions: [
    TagExtension(
      tagsToExtend: {"tex"},
      builder: (extensionContext) {
        return Math.tex(
          extensionContext.innerHtml,
          mathStyle: MathStyle.display,
          textStyle: extensionContext.styledElement?.style.generateTextStyle(),
          onErrorFallback: (FlutterMathException e) {
            //optionally try and correct the Tex string here
            return Text(e.message);
          },
        );
      }
    ),
  ],
);
```

### `flutter_html_svg`

This package renders svg elements using the [`flutter_svg`](https://pub.dev/packages/flutter_svg) plugin.

When rendering SVGs, the package takes the SVG data within the `<svg>` tag and passes it to `flutter_svg`. The `width` and `height` attributes are considered while rendering, if given.

The package also exposes a few ways to render SVGs within an `<img>` tag, specifically base64 SVGs, asset SVGs, and network SVGs.

#### Adding the `SvgHtmlExtension`:

Add the dependency to your pubspec.yaml:

    flutter pub add flutter_html_svg

```dart
import 'package:flutter_html_svg/flutter_html_svg.dart';

Widget html = Html(
  data: myHtml,
  extensions: [
    SvgHtmlExtension(),
  ],
);
```

### `flutter_html_table`

This package renders table elements using the [`flutter_layout_grid`](https://pub.dev/packages/flutter_layout_grid) plugin.

When rendering table elements, the package tries to calculate the best fit for each element and size its cell accordingly. `Rowspan`s and `colspan`s are considered in this process, so cells that span across multiple rows and columns are rendered as expected. Heights are determined intrinsically to maintain an optimal aspect ratio for the cell.

#### Adding the `TableHtmlExtension`:

Add the dependency to your pubspec.yaml:

    flutter pub add flutter_html_table

```dart
import 'package:flutter_html_table/flutter_html_table.dart';

Widget html = Html(
  data: myHtml,
  extensions: [
    TableHtmlExtension(),
  ],
);
```

### `flutter_html_video`

This package renders video elements using the [`chewie`](https://pub.dev/packages/chewie) and the [`video_player`](https://pub.dev/packages/video_player) plugin.

The package considers the attributes `controls`, `loop`, `src`, `autoplay`, `poster`, `width`, `height`, and `muted` when rendering the video widget.

#### Adding the `VideoHtmlExtension`:

Add the dependency to your pubspec.yaml:

    flutter pub add flutter_html_video

```dart
import 'package:flutter_html_video/flutter_html_video.dart';

Widget html = Html(
  data: myHtml,
  extensions: [
    VideoHtmlExtension(),
  ],
);
```

## FAQ

### Why can't I get `<audio>`/`<iframe>`/`<math>`/`<svg>`/`<table>`/<video>` to show up?

Have you followed the instructions as described [above](#external-packages)?

If so, feel free to file an issue or start a discussion for some extra help.

### How can I render `LaTex` in my HTML?

See the [above example](#tex).

### How do I use this inside of a `Row()`?

If you'd like to use this widget inside of a `Row()`, make sure to set `shrinkWrap: true` and place your widget inside expanded:

```dart
Widget row = Row(
   children: [
        Expanded(
            child: Html(
              shrinkWrap: true,
              //other params
            )
        ),
	    //whatever other widgets
   ]
);
```

## Example

Here's what the example in example/lib/main.dart looks like after being run (in Chrome):

<table>
<tr>
<td><img src="https://raw.githubusercontent.com/Sub6Resources/flutter_html/master/example/screenshots/flutter_html_screenshot.png" alt="A screenshot showing the result of running the example" /></td>
<td><img src="https://raw.githubusercontent.com/Sub6Resources/flutter_html/master/example/screenshots/flutter_html_screenshot1.png" alt="A second screenshot showing the result of running the example" /></td>
<td><img src="https://raw.githubusercontent.com/Sub6Resources/flutter_html/master/example/screenshots/flutter_html_screenshot2.png" alt="A third screenshot showing the result of running the example" /></td>
<td><img src="https://raw.githubusercontent.com/Sub6Resources/flutter_html/master/example/screenshots/flutter_html_screenshot3.png" alt="A fourth screenshot showing the result of running the example" /></td>
</tr>
</table>

