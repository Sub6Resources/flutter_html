# flutter_html
[![pub package](https://img.shields.io/pub/v/flutter_html.svg)](https://pub.dev/packages/flutter_html)
[![codecov](https://codecov.io/gh/Sub6Resources/flutter_html/branch/master/graph/badge.svg)](https://codecov.io/gh/Sub6Resources/flutter_html)
[![CircleCI](https://circleci.com/gh/Sub6Resources/flutter_html.svg?style=svg)](https://circleci.com/gh/Sub6Resources/flutter_html)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/Sub6Resources/flutter_html/blob/master/LICENSE)

A Flutter widget for rendering HTML and CSS as Flutter widgets.

<table>
  <tr>
    <td align="center">Screenshot 1</td>
    <td align="center">Screenshot 2</td>
    <td align="center">Screenshot 3</td>
  </tr>
  <tr>
    <td><img alt="A Screenshot of flutter_html" src="https://raw.githubusercontent.com/Sub6Resources/flutter_html/master/.github/flutter_html_screenshot.png" width="250"/></td>
    <td><img alt="Another Screenshot of flutter_html" src="https://raw.githubusercontent.com/Sub6Resources/flutter_html/master/.github/flutter_html_screenshot2.png" width="250"/></td>
    <td><img alt="Yet another Screenshot of flutter_html" src="https://raw.githubusercontent.com/Sub6Resources/flutter_html/master/.github/flutter_html_screenshot3.png" width="250"/></td>
  </tr>
 </table>

## Table of Contents:

- [Installing](#installing)

- [Currently Supported HTML Tags](#currently-supported-html-tags)

- [Currently Supported CSS Attributes](#currently-supported-css-attributes)

- [Currently Supported Inline CSS Attributes](#currently-supported-inline-css-attributes)

- [Why flutter_html?](#why-this-package)

- [API Reference](#api-reference)

  - [Constructors](#constructors)

    - [Selectable Text](#selectable-text)

  - [Parameters Table](#parameters)
  
  - [Methods](#methods)
  
  - [Getters](#getters)

  - [Data](#data)
    
  - [Document](#document)

  - [onLinkTap](#onlinktap)

  - [customRender](#customrender)

  - [onImageError](#onimageerror)

  - [onImageTap](#onimagetap)

  - [tagsList](#tagslist)

  - [style](#style)

- [Rendering Reference](#rendering-reference)

  - [Image](#image)
  
- [External Packages](#external-packages)
  
  - [`flutter_html_all`](#flutter_html_all)
  
  - [`flutter_html_audio`](#flutter_html_audio)
  
  - [`flutter_html_iframe`](#flutter_html_iframe)
  
  - [`flutter_html_math`](#flutter_html_math)
  
  - [`flutter_html_svg`](#flutter_html_svg)
  
  - [`flutter_html_table`](#flutter_html_table)

  - [`flutter_html_video`](#flutter_html_video)
  
- [Notes](#notes)

- [Migration Guide](#migration-guides)

- [Contribution Guide](#contribution-guide)

## Installing:

Add the following to your `pubspec.yaml` file:

    dependencies:
      flutter_html: ^3.0.0-alpha.5
      // Or flutter_html_all: ^3.0.0-alpha.5 to include table, video, audio, iframe...

## Currently Supported HTML Tags:
|            |           |       |             |         |         |       |      |        |        |        |
|------------|-----------|-------|-------------|---------|---------|-------|------|--------|--------|--------|
|`a`         | `abbr`    | `acronym`| `address`   | `article`| `aside` | `audio`| `b`  | `bdi`  | `bdo`  | `big`  |
|`blockquote`| `body`    | `br`  | `caption`   | `cite`  | `code`  | `data`| `dd` | `del`  | `details`  | `dfn`  |
| `div` | `dl`        | `dt`      | `em`  | `figcaption`| `figure`| `footer`| `font` | `h1`  | `h2` | `h3`   |
| `h4` | `h5` |`h6`        | `header`  | `hr`  | `i`         | `iframe`| `img`   | `ins` | `kbd`| `li`   |
| `main` | `mark` | `nav`       | `noscript`|`ol`   | `p`         | `pre`   | `q`     | `rp`  | `rt` | `ruby` |
| `s` | `samp` | `section`   | `small`   | `span`| `strike`    | `strong`| `sub`   | `sup` | `summary` | `svg`|
| `table` | `tbody` | `td` | `template` | `tfoot`   | `th`  | `thead`     |`time`   | `tr`    | `tt`  | `u`  |
| `ul` | `var` | `video` |  `math`:  |  `mrow`  |  `msup`    | `msub`  |  `mover`   | `munder`  | `msubsup`  | `moverunder` |
| `mfrac` | `mlongdiv` | `msqrt` |  `mroot`  |  `mi`  |  `mn`    | `mo`  |  |   |   |    | 

 
## Currently Supported CSS Attributes:
|                  |        |            |          |              |                        |            |
|------------------|--------|------------|----------|--------------|------------------------|------------|
|`background-color`| `color`| `direction`| `display`| `font-family`| `font-feature-settings`| `font-size`|
|`font-style`      | `font-weight`| `height`   | `letter-spacing`| `line-height`| `list-style-type`      | `list-style-position`|
|`padding`         | `margin`| `text-align`| `text-decoration`| `text-decoration-color`| `text-decoration-style`| `text-decoration-thickness`|
|`text-shadow`     | `vertical-align`| `white-space`| `width`  | `word-spacing`|                        |            |

## Currently Supported Inline CSS Attributes:
|                  |        |            |          |              |                        |            |
|------------------|--------|------------|----------|--------------|------------------------|------------|
|`background-color`| `border` (including specific directions) | `color`| `direction`| `display`| `font-family`| `font-feature-settings` |
| `font-size`|`font-style`      | `font-weight`| `line-height` | `list-style-type`  | `list-style-position`|`padding`  (including specific directions)   |
| `margin` (including specific directions) | `text-align`| `text-decoration`| `text-decoration-color`| `text-decoration-style`| `text-shadow` | |

Don't see a tag or attribute you need? File a feature request or contribute to the project!

## Why this package?

This package is designed with simplicity in mind. Originally created to allow basic rendering of HTML content into the Flutter widget tree,
this project has expanded to include support for basic styling as well! 
If you need something more robust and customizable, the package also provides a number of optional custom APIs for extremely granular control over widget rendering!

## API Reference:

For the full API reference, see [here](https://pub.dev/documentation/flutter_html/latest/).

For a full example, see [here](https://github.com/Sub6Resources/flutter_html/tree/master/example).

Below, you will find brief descriptions of the parameters the`Html` widget accepts and some code snippets to help you use this package.

### Constructors:

The package currently has two different constructors - `Html()` and `Html.fromDom()`. 

The `Html()` constructor is for those who would like to directly pass HTML from the source to the package to be rendered. 

If you would like to modify or sanitize the HTML before rendering it, then `Html.fromDom()` is for you - you can convert the HTML string to a `Document` and use its methods to modify the HTML as you wish. Then, you can directly pass the modified `Document` to the package. This eliminates the need to parse the modified `Document` back to a string, pass to `Html()`, and convert back to a `Document`, thus cutting down on load times.

#### Selectable Text

The package also has two constructors for selectable text support - `SelectableHtml()` and `SelectableHtml.fromDom()`.

The difference between the two is the same as noted above.

Please note: Due to Flutter [#38474](https://github.com/flutter/flutter/issues/38474), selectable text support is significantly watered down compared to the standard non-selectable version of the widget. The changes are as follows:

1. The list of tags that can be rendered is significantly reduced. Key omissions include no support for images/video/audio, table, and ul/ol.

2. No support for `customRender`, `customImageRender`, `onImageError`, `onImageTap`, `onMathError`, and `navigationDelegateForIframe`. (Support for `customRender` may be added in the future).

3. Styling support is significantly reduced. Only text-related styling works (e.g. bold or italic), while container related styling (e.g. borders or padding/margin) do not work.

Once the above issue is resolved, the aforementioned compromises will go away. Currently the `SelectableText.rich()` constructor does not support `WidgetSpan`s, resulting in the feature losses above.

### Parameters:

|  Parameters  |   Description   |
|--------------|-----------------|
| `data` | The HTML data passed to the `Html` widget. This is required and cannot be null when using `Html()`. |
| `document` | The DOM document passed to the `Html` widget. This is required and cannot be null when using `Html.fromDom()`. |
| `onLinkTap` | A function that defines what the widget should do when a link is tapped. The function exposes the `src` of the link as a `String` to use in your implementation. |
| `customRenders` | A powerful API that allows you to customize everything when rendering a specific HTML tag. |
| `onImageError` | A function that defines what the widget should do when an image fails to load. The function exposes the exception `Object` and `StackTrace` to use in your implementation. |
| `shrinkWrap` | A `bool` used while rendering different widgets to specify whether they should be shrink-wrapped or not, like `ContainerSpan` |
| `onImageTap` | A function that defines what the widget should do when an image is tapped. The function exposes the `src` of the image as a `String` to use in your implementation. |
| `tagsList` | A list of elements the `Html` widget should render. The list should contain the tags of the HTML elements you wish to include.  |
| `style` | A powerful API that allows you to customize the style that should be used when rendering a specific HTMl tag. |
| `selectionControls` |  A custom text selection controls that allow you to override default toolbar and build toolbar with custom text selection options. See an [example](https://github.com/justinmc/flutter-text-selection-menu-examples/blob/master/lib/custom_menu_page.dart). |

### Methods:

|  Methods  |   Description   |
|--------------|-----------------|
| `disposeAll()` | Disposes all `ChewieController`s, `ChewieAudioController`s, and `VideoPlayerController`s being used by every `Html` widget. (Note: `Html` widgets automatically dispose their controllers, this method is only provided in case you need other behavior) |

### Getters:

1. `Html.tags`. This provides a list of all the tags the package renders. The main use case is to assist in excluding elements using `tagsList`. See an [example](#example-usage---tagslist---excluding-tags) below.

2. `SelectableHtml.tags`. This provides a list of all the tags that can be rendered in selectable mode.

3. `Html.chewieAudioControllers`. This provides a list of all `ChewieAudioController`s being used by `Html` widgets.

4. `Html.chewieControllers`. This provides a list of all `ChewieController`s being used by `Html` widgets.

5. `Html.videoPlayerControllers`. This provides a list of all `VideoPlayerController`s being used for video widgets by `Html` widgets.

6. `Html.audioPlayerControllers`. This provides a list of all `VideoPlayerController`s being used for audio widgets by `Html` widgets.

### Data:

The HTML data passed to the `Html` widget as a `String`. This is required and cannot be null when using `Html`.
Any HTML tags in the `String` that are not supported by the package will not be rendered.

#### Example Usage - Data: 

```dart
Widget html = Html(
  data: """<div>
        <h1>Demo Page</h1>
        <p>This is a fantastic product that you should buy!</p>
        <h3>Features</h3>
        <ul>
          <li>It actually works</li>
          <li>It exists</li>
          <li>It doesn't cost much!</li>
        </ul>
        <!--You can pretty much put any html in here!-->
      </div>""",
);
```

### Document:

The DOM document passed to the `Html` widget as a `Document`. This is required and cannot be null when using `Html.fromDom()`.
Any HTML tags in the document that are not supported by the package will not be rendered.
Using the `Html.fromDom()` constructor can be useful when you would like to sanitize the HTML string yourself before passing it to the package.

#### Example Usage - Document: 

```dart 
import 'package:html/parser.dart' as htmlparser;
import 'package:html/dom.dart' as dom;
...
String htmlData = """<div>
  <h1>Demo Page</h1>
  <p>This is a fantastic product that you should buy!</p>
  <h3>Features</h3>
  <ul>
    <li>It actually works</li>
    <li>It exists</li>
    <li>It doesn't cost much!</li>
  </ul>
  <!--You can pretty much put any html in here!-->
</div>""";
dom.Document document = htmlparser.parse(htmlData);
/// sanitize or query document here
Widget html = Html(
  document: document,
);
```

### onLinkTap:

A function that defines what the widget should do when a link is tapped.

#### Example Usage - onLinkTap:

```dart
Widget html = Html(
  data: """<p>
   Linking to <a href='https://github.com'>websites</a> has never been easier.
  </p>""",
  onLinkTap: (String? url, RenderContext context, Map<String, String> attributes, dom.Element? element) {
    //open URL in webview, or launch URL in browser, or any other logic here
  }
);
```

Inner links (such as `<a href="#top">Back to the top</a>` will work out of the box by scrolling the viewport, as long as your `Html` widget is wrapped in a scroll container such as a `SingleChildScrollView`.

### customRenders:

A powerful API that allows you to customize everything when rendering a specific HTML tag. This means you can change the default behaviour or add support for HTML elements that aren't supported natively. You can also make up your own custom tags in your HTML!

`customRender` accepts a `Map<CustomRenderMatcher, CustomRender>`.

`CustomRenderMatcher` is a function that requires a `bool` to be returned. It exposes the `RenderContext` which provides `BuildContext` and access to the HTML tree.

The `CustomRender` class has two constructors: `CustomRender.widget()` and `CustomRender.inlineSpan()`. Both require a `<Widget/InlineSpan> Function(RenderContext, Function())`. The `Function()` argument is a function that will provide you with the element's children when needed.

To use this API, create a matching function and an instance of `CustomRender`.

#### Example Usages - customRenders:
Note: If you add any custom tags, you must add these tags to the [`tagsList`](#tagslist) parameter, otherwise they will not be rendered. See below for an example.

1. Simple example - rendering custom HTML tags

```dart
Widget html = Html(
  data: """
  <h3>Display bird element and flutter element <bird></bird></h3>
  <flutter></flutter>
  <flutter horizontal></flutter>
  """,
  customRenders: {
      birdMatcher(): CustomRender.inlineSpan(inlineSpan: (context, buildChildren) => TextSpan(text: "🐦")),
      flutterMatcher(): CustomRender.widget(widget: (context, buildChildren) => FlutterLogo(
        style: (context.tree.element!.attributes['horizontal'] != null)
            ? FlutterLogoStyle.horizontal
            : FlutterLogoStyle.markOnly,
        textColor: context.style.color!,
        size: context.style.fontSize!.size! * 5,
      )),
    },
  tagsList: Html.tags..addAll(["bird", "flutter"]),
);

CustomRenderMatcher birdMatcher() => (context) => context.tree.element?.localName == 'bird';

CustomRenderMatcher flutterMatcher() => (context) => context.tree.element?.localName == 'flutter';
```

2. Complex example - wrapping the default widget with your own, in this case placing a horizontal scroll around a (potentially too wide) table.

Note: Requires the [`flutter_html_table`](#flutter_html_table) package.

<details><summary>View code</summary>

```dart
Widget html = Html(
  data: """
  <table style="width:100%">
    <caption>Monthly savings</caption>
    <tr> <th>January</th> <th>February</th> <th>March</th> <th>April</th> <th>May</th> <th>June</th> <th>July</th> <th>August</th> <th>September</th> <th>October</th> <th>November</th> <th>December</th> </tr>
    <tr> <td>\$100</td> <td>\$50</td> <td>\$80</td> <td>\$60</td> <td>\$90</td> <td>\$140</td> <td>\$110</td> <td>\$80</td> <td>\$90</td> <td>\$60</td> <td>\$40</td> <td>\$70</td> </tr>
    <tr> <td>\90</td> <td>\$60</td> <td>\$80</td> <td>\$80</td> <td>\$100</td> <td>\$160</td> <td>\$150</td> <td>\$110</td> <td>\$100</td> <td>\$60</td> <td>\$30</td> <td>\$80</td> </tr>
  </table>
  """,
  customRenders: {
    tableMatcher(): CustomRender.widget(widget: (context, child) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        // this calls the table CustomRender to render a table as normal (it uses a widget so we know widget is not null)
        child: tableRender.call().widget!.call(context, buildChildren),
      );
    }),
  },
);

CustomRenderMatcher tableMatcher() => (context) => context.tree.element?.localName == "table";
```

</details>

3. Complex example - rendering an `iframe` differently based on whether it is an embedded youtube video or some other embedded content.

<details><summary>View code</summary>

```dart
Widget html = Html(
   data: """
   <h3>Google iframe:</h3>
   <iframe src="https://google.com"></iframe>
   <h3>YouTube iframe:</h3>
   <iframe src="https://www.youtube.com/embed/tgbNymZ7vqY"></iframe>
   """,
   customRenders: {
      iframeYT(): CustomRender.widget(widget: (context, buildChildren) {
        double? width = double.tryParse(context.tree.attributes['width'] ?? "");
        double? height = double.tryParse(context.tree.attributes['height'] ?? "");
        return Container(
          width: width ?? (height ?? 150) * 2,
          height: height ?? (width ?? 300) / 2,
          child: WebView(
            initialUrl: context.tree.attributes['src']!,
            javascriptMode: JavascriptMode.unrestricted,
            navigationDelegate: (NavigationRequest request) async {
              //no need to load any url besides the embedded youtube url when displaying embedded youtube, so prevent url loading
              if (!request.url.contains("youtube.com/embed")) {
                return NavigationDecision.prevent;
              } else {
                return NavigationDecision.navigate;
              }
            },
          ),
        );
      }),
      iframeOther(): CustomRender.widget(widget: (context, buildChildren) {
        double? width = double.tryParse(context.tree.attributes['width'] ?? "");
        double? height = double.tryParse(context.tree.attributes['height'] ?? "");
        return Container(
          width: width ?? (height ?? 150) * 2,
          height: height ?? (width ?? 300) / 2,
          child: WebView(
            initialUrl: context.tree.attributes['src'],
            javascriptMode: JavascriptMode.unrestricted,
            //on other iframe content scrolling might be necessary, so use VerticalDragGestureRecognizer
            gestureRecognizers: [
              Factory(() => VerticalDragGestureRecognizer())
            ].toSet(),
          ),
        );
      }),
      iframeNull(): CustomRender.widget(widget: (context, buildChildren) => Container(height: 0, width: 0)),
   }
 );

CustomRenderMatcher iframeYT() => (context) => context.tree.element?.attributes['src']?.contains("youtube.com/embed") ?? false;

CustomRenderMatcher iframeOther() => (context) => !(context.tree.element?.attributes['src']?.contains("youtube.com/embed")
  ?? context.tree.element?.attributes['src'] == null);

CustomRenderMatcher iframeNull() => (context) => context.tree.element?.attributes['src'] == null;
```
</details>

More example usages and in-depth details available [here](https://github.com/Sub6Resources/flutter_html/wiki/All-About-customRender).

### onImageError:

A function that defines what the widget should do when an image fails to load. The function exposes the exception `Object` and `StackTrace` to use in your implementation.

#### Example Usage - onImageError:

```dart
Widget html = Html(
  data: """<img alt='Alt Text of an intentionally broken image' src='https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30d'/>""",
  onImageError: (Exception exception, StackTrace stackTrace) {
    FirebaseCrashlytics.instance.recordError(exception, stackTrace);
  },
);
```

### onImageTap:

A function that defines what the widget should do when an image is tapped.

#### Example Usage - onImageTap:

```dart
Widget html = Html(
  data: """<img alt='Google' src='https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png' />""",
  onImageTap: (String? url, RenderContext context, Map<String, String> attributes, dom.Element? element) {
    //open image in webview, or launch image in browser, or any other logic here
  }
);
```

### tagsList:

A list of elements the `Html` widget should render. The list should contain the tags of the HTML elements you wish to whitelist.

#### Example Usage - tagsList - Excluding Tags:
You may have instances where you can choose between two different types of HTML tags to display the same content. In the example below, the `<video>` and `<iframe>` elements are going to display the same content.

The `tagsList` parameter allows you to change which element is rendered. Iframes can be advantageous because they allow parallel loading - Flutter just has to wait for the webview to be initialized before rendering the page, possibly cutting down on load time. Video can be advantageous because it provides a 100% native experience with Flutter widgets, but it may take more time to render the page. You may know that Flutter webview is a little janky in its current state on Android, so using `tagsList` and a simple condition, you can get the best of both worlds - choose the video widget to render on Android and the iframe webview to render on iOS.

```dart
Widget html = Html(
  data: """
  <video controls>
    <source src="https://www.w3schools.com/html/mov_bbb.mp4" />
  </video>
  <iframe src="https://www.w3schools.com/html/mov_bbb.mp4"></iframe>""",
  tagsList: Html.tags..remove(Platform.isAndroid ? "iframe" : "video")
);
```

`Html.tags` provides easy access to a list of all the tags the package can render, and you can remove specific tags from this list to blacklist them.

#### Example Usage - tagsList - Allowing Tags:
You may also have instances where you would only like the package to render a handful of html tags. You can do that like so:
```dart
Widget html = Html(
  data: """
    <p>Render this item</p>
    <span>Do not render this item or any other item</span>
    <img src='https://flutter.dev/images/flutter-mono-81x100.png'/>
  """,
  tagsList: ['p']
);
```

Here, the package will only ever render `<p>` and ignore all other tags.

### style:

A powerful API that allows you to customize the style that should be used when rendering a specific HTMl tag.

`style` accepts a `Map<String, Style>`. The `Style` type is a class that allows you to set all the CSS styling the package currently supports. See [here](https://pub.dev/documentation/flutter_html/latest/style/Style-class.html) for the full list.

To use this API, set the key as the tag of the HTML element you wish to provide a custom implementation for, and set the value to be a `Style` with your customizations.

#### Example Usage - style:

```dart
Widget html = Html(
  data: """
    <h1>Table support:</h1>
    <table>
    <colgroup>
    <col width="50%" />
    <col span="2" width="25%" />
    </colgroup>
    <thead>
    <tr><th>One</th><th>Two</th><th>Three</th></tr>
    </thead>
    <tbody>
    <tr>
    <td rowspan='2'>Rowspan<br>Rowspan<br>Rowspan<br>Rowspan<br>Rowspan<br>Rowspan<br>Rowspan<br>Rowspan<br>Rowspan<br>Rowspan</td><td>Data</td><td>Data</td>
    </tr>
    <tr>
    <td colspan="2"><img alt='Google' src='https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png' /></td>
    </tr>
    </tbody>
    <tfoot>
    <tr><td>fData</td><td>fData</td><td>fData</td></tr>
    </tfoot>
    </table>""",
  style: {
    // tables will have the below background color
    "table": Style(
      backgroundColor: Color.fromARGB(0x50, 0xee, 0xee, 0xee),
    ),
    // some other granular customizations are also possible
    "tr": Style(
      border: Border(bottom: BorderSide(color: Colors.grey)),
    ),
    "th": Style(
      padding: EdgeInsets.all(6),
      backgroundColor: Colors.grey,
    ),
    "td": Style(
      padding: EdgeInsets.all(6),
      alignment: Alignment.topLeft,
    ),
    // text that renders h1 elements will be red
    "h1": Style(color: Colors.red),
  }
);
```

More examples and in-depth details available [here](https://github.com/Sub6Resources/flutter_html/wiki/Style).

## Rendering Reference

This section will describe how certain HTML elements are rendered by this package, so you can evaluate how your HTML will be rendered and structure it accordingly.

### Image

This package currently has support for base64 images, asset images, and network images.

The package uses the `src` of the image to determine which of the above types to render. The order is as follows:
1. If the `src` is null, render the alt text of the image, if any.
2. If the `src` starts with "data:image" and contains "base64," (this indicates the image data is indeed base64), render an `Image.memory` from the base64 data.
3. If the `src` starts with "asset:", render an `Image.asset` from the path in the `src`.
4. Otherwise, just render an `Image.network`.

If the rendering of any of the above fails, the package will fall back to rendering the alt text of the image, if any.

Currently the package only considers the width, height, src, and alt text while rendering an image.

If you would like to support SVGs in an `<img>`, you should use the [`flutter_html_svg`](#flutter_html_svg) package which provides support for base64, asset, and network SVGs.

## External Packages

### `flutter_html_all`

This package is simply a convenience package that exports all the other external packages below. You should use this if you plan to activate all the renders that require external dependencies.

### `flutter_html_audio`

This package renders audio elements using the [`chewie_audio`](https://pub.dev/packages/chewie_audio) and the [`video_player`](https://pub.dev/packages/video_player) plugin.

The package considers the attributes `controls`, `loop`, `src`, `autoplay`, `width`, and `muted` when rendering the audio widget.

#### Registering the `CustomRender`:

Add the dependency to your pubspec.yaml:

    dependencies:
      flutter_html_audio: ^3.0.0-alpha.3

```dart
Widget html = Html(
  customRenders: {
    audioMatcher(): audioRender(),
  }
);
```

### `flutter_html_iframe`

This package renders iframes using the [`webview_flutter`](https://pub.dev/packages/webview_flutter) plugin. 

When rendering iframes, the package considers the width, height, and sandbox attributes. 

Sandbox controls the JavaScript mode of the webview - a value of `null` or `allow-scripts` will set `javascriptMode: JavascriptMode.unrestricted`, otherwise it will set `javascriptMode: JavascriptMode.disabled`.

#### Registering the `CustomRender`:

Add the dependency to your pubspec.yaml:

    dependencies:
      flutter_html_iframe: ^3.0.0-alpha.3

```dart
Widget html = Html(
  customRenders: {
    iframeMatcher(): iframeRender(),
  }
);
```

You can set the `navigationDelegate` of the webview with the `navigationDelegate` property on `iframeRender`. This allows you to block or allow the loading of certain URLs.

#### `NavigationDelegate` example:

```dart
Widget html = Html(
  customRenders: {
    iframeMatcher(): iframeRender(navigationDelegate: (NavigationRequest request) {
      if (request.url.contains("google.com/images")) {
        return NavigationDecision.prevent;
      } else {
        return NavigationDecision.navigate;
      }
    }),
  }
);
```

### `flutter_html_math`

This package renders MathML elements using the [`flutter_math_fork`](https://pub.dev/packages/flutter_math_fork) plugin.

When rendering MathML, the package takes the MathML data within the `<math>` tag and tries to parse it to Tex. Then, it will pass the parsed string to `flutter_math_fork`.

Because this package is parsing MathML to Tex, it may not support some functionalities. The current list of supported tags can be found [above](#currently-supported-html-tags), but some of these only have partial support at the moment.

#### Registering the `CustomRender`:

Add the dependency to your pubspec.yaml:

    dependencies:
      flutter_html_math: ^3.0.0-alpha.3

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

If you'd like to see more MathML features, feel free to create a PR or file a feature request!

#### Tex

If you have a Tex string you'd like to render inside your HTML you can do that using the same [`flutter_math_fork`](https://pub.dev/packages/flutter_math_fork) plugin.

Use a custom tag inside your HTML (an example could be `<tex>`), and place your **raw** Tex string inside.
 
Then, use the `customRender` parameter to add the widget to render Tex. It could look like this:

```dart
Widget htmlWidget = Html(
  data: r"""<tex>i\hbar\frac{\partial}{\partial t}\Psi(\vec x,t) = -\frac{\hbar}{2m}\nabla^2\Psi(\vec x,t)+ V(\vec x)\Psi(\vec x,t)</tex>""",
  customRenders: {
    texMatcher(): CustomRender.widget(widget: (context, buildChildren) => Math.tex(
      context.tree.element?.innerHtml ?? '',
      mathStyle: MathStyle.display,
      textStyle: context.style.generateTextStyle(),
      onErrorFallback: (FlutterMathException e) {
        //optionally try and correct the Tex string here
        return Text(e.message);
      },
    )),
  },
  tagsList: Html.tags..add('tex'),
);

CustomRenderMatcher texMatcher() => (context) => context.tree.element?.localName == 'tex';
```

### `flutter_html_svg`

This package renders svg elements using the [`flutter_svg`](https://pub.dev/packages/flutter_svg) plugin.

When rendering SVGs, the package takes the SVG data within the `<svg>` tag and passes it to `flutter_svg`. The `width` and `height` attributes are considered while rendering, if given.

The package also exposes a few ways to render SVGs within an `<img>` tag, specifically base64 SVGs, asset SVGs, and network SVGs.

#### Registering the `CustomRender`:

Add the dependency to your pubspec.yaml:

    dependencies:
      flutter_html_svg: ^3.0.0-alpha.3

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

### `flutter_html_table`

This package renders table elements using the [`flutter_layout_grid`](https://pub.dev/packages/flutter_layout_grid) plugin.

When rendering table elements, the package tries to calculate the best fit for each element and size its cell accordingly. `Rowspan`s and `colspan`s are considered in this process, so cells that span across multiple rows and columns are rendered as expected. Heights are determined intrinsically to maintain an optimal aspect ratio for the cell.

#### Registering the `CustomRender`:

Add the dependency to your pubspec.yaml:

    dependencies:
      flutter_html_table: ^3.0.0-alpha.3

```dart
Widget html = Html(
  customRenders: {
    tableMatcher(): tableRender(),
  }
);
```

### `flutter_html_video`

This package renders video elements using the [`chewie`](https://pub.dev/packages/chewie) and the [`video_player`](https://pub.dev/packages/video_player) plugin.

The package considers the attributes `controls`, `loop`, `src`, `autoplay`, `poster`, `width`, `height`, and `muted` when rendering the video widget.

#### Registering the `CustomRender`:

Add the dependency to your pubspec.yaml:

    dependencies:
      flutter_html_video: ^3.0.0-alpha.3

```dart
Widget html = Html(
  customRenders: {
    videoMatcher(): videoRender(),
  }
);
```

## Notes

1. If you'd like to use this widget inside of a `Row()`, make sure to set `shrinkWrap: true` and place your widget inside expanded:

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

## Migration Guides
- For Version 1.0/2.0 - [Guide](https://github.com/Sub6Resources/flutter_html/wiki/1.0.0-Migration-Guide)
- For Version 3.0 - **TODO**

## Contribution Guide
> Coming soon!
>
> Meanwhile, PRs are always welcome
