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
    <td><img alt="A Screenshot of flutter_html" src="https://github.com/Sub6Resources/flutter_html/blob/master/.github/flutter_html_screenshot.png" width="250"/></td>
    <td><img alt="Another Screenshot of flutter_html" src="https://github.com/Sub6Resources/flutter_html/blob/master/.github/flutter_html_screenshot2.png" width="250"/></td>
    <td><img alt="Yet another Screenshot of flutter_html" src="https://github.com/Sub6Resources/flutter_html/blob/master/.github/flutter_html_screenshot3.png" width="250"/></td>
  </tr>
 </table>

## Table of Contents:

- [Installing](#installing)

- [Currently Supported HTML Tags](#currently-supported-html-tags)

- [Currently Supported CSS Attributes](#currently-supported-css-attributes)

- [Why flutter_html?](#why-this-package)

- [API Reference](#api-reference)

  - [Parameters Table](#parameters)

  - [Data](#data)

    - [Example](#example-usage---data)

  - [onLinkTap](#onlinktap)

    - [Example](#example-usage---onlinktap)

  - [customRender](#customrender)

    - [Example](#example-usages---customrender)

  - [onImageError](#onimageerror)

    - [Example](#example-usage---onimageerror)

  - [onImageTap](#onimagetap)

    - [Example](#example-usage---onimagetap)

  - [blacklistedElements](#blacklistedelements)

    - [Example](#example-usage---blacklistedelements)

  - [style](#style)

    - [Example](#example-usage---style)

  - [navigationDelegateForIframe](#navigationdelegateforiframe)

    - [Example](#example-usage---navigationdelegateforiframe)
    
- [Rendering Reference](#rendering-reference)

  - [Image](#image)
  
  - [Iframe](#iframe)
  
  - [Audio](#audio)
  
  - [Video](#video)
  
  - [SVG](#svg)
  
  - [Table](#table)

- [Migration Guide](#migration-guides)

- [Contribution Guide](#contribution-guide)

## Installing:

Add the following to your `pubspec.yaml` file:

    dependencies:
      flutter_html: ^1.2.0

## Currently Supported HTML Tags:
|            |           |       |             |         |         |       |      |        |        |        |
|------------|-----------|-------|-------------|---------|---------|-------|------|--------|--------|--------|
|`a`         | `abbr`    | `acronym`| `address`   | `article`| `aside` | `audio`| `b`  | `bdi`  | `bdo`  | `big`  |
|`blockquote`| `body`    | `br`  | `caption`   | `cite`  | `code`  | `data`| `dd` | `del`  | `dfn`  | `div`  |
|`dl`        | `dt`      | `em`  | `figcaption`| `figure`| `footer`| `h1`  | `h2` | `h3`   | `h4`   | `h5`   |
|`h6`        | `header`  | `hr`  | `i`         | `iframe`| `img`   | `ins` | `kbd`| `li`   | `main` | `mark` |
|`nav`       | `noscript`|`ol`   | `p`         | `pre`   | `q`     | `rp`  | `rt` | `ruby` | `s`    |`samp`  |
|`section`   | `small`   | `span`| `strike`    | `strong`| `sub`   | `sup` | `svg`| `table`| `tbody`| `td`   |
| `template` | `tfoot`   | `th`  | `thead`     |`time`   | `tr`    | `tt`  | `u`  | `ul`   | `var`  | `video`|


 
## Currently Supported CSS Attributes:
|                  |        |            |          |              |                        |            |
|------------------|--------|------------|----------|--------------|------------------------|------------|
|`background-color`| `color`| `direction`| `display`| `font-family`| `font-feature-settings`| `font-size`|
|`font-style`      | `font-weight`| `height`   | `letter-spacing`| `line-height`| `list-style-type`      | `list-style-position`|
|`padding`         | `margin`| `text-align`| `text-decoration`| `text-decoration-color`| `text-decoration-style`| `text-decoration-thickness`|
|`text-shadow`     | `vertical-align`| `white-space`| `width`  | `word-spacing`|                        |            |

Don't see a tag or attribute you need? File a feature request or contribute to the project!

## Why this package?

This package is designed with simplicity in mind. Originally created to allow basic rendering of HTML content into the Flutter widget tree,
this project has expanded to include support for basic styling as well! 
If you need something more robust and customizable, the package also provides a number of optional custom APIs for extremely granular control over widget rendering!

## API Reference:

For the full API reference, see [here](https://pub.dev/documentation/flutter_html/latest/).

For a full example, see [here](https://github.com/Sub6Resources/flutter_html/tree/master/example).

Below, you will find brief descriptions of the parameters the`Html` widget accepts and some code snippets to help you use this package.

### Parameters: 

|  Parameters  |   Description   |
|--------------|-----------------|
| `data` | The HTML data passed to the `Html` widget. This is required and cannot be null. |
| `onLinkTap` | A function that defines what the widget should do when a link is tapped. The function exposes the `src` of the link as a `String` to use in your implementation. |
| `customRender` | A powerful API that allows you to customize everything when rendering a specific HTML tag. |
| `onImageError` | A function that defines what the widget should do when an image fails to load. The function exposes the exception `Object` and `StackTrace` to use in your implementation. |
| `shrinkWrap` | A `bool` used while rendering different widgets to specify whether they should be shrink-wrapped or not, like `ContainerSpan` |
| `onImageTap` | A function that defines what the widget should do when an image is tapped. The function exposes the `src` of the image as a `String` to use in your implementation. |
| `blacklistedElements` | A list of elements the `Html` widget should not render. The list should contain the tags of the HTML elements you wish to blacklist.  |
| `style` | A powerful API that allows you to customize the style that should be used when rendering a specific HTMl tag. |
| `navigationDelegateForIframe` | Allows you to set the `NavigationDelegate` for the `WebView`s of all the iframes rendered by the `Html` widget. |

### Data:

The HTML data passed to the `Html` widget as a `String`. This is required and cannot be null.
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

### onLinkTap:

A function that defines what the widget should do when a link is tapped.

#### Example Usage - onLinkTap:

```dart
Widget html = Html(
  data: """<p>
   Linking to <a href='https://github.com'>websites</a> has never been easier.
  </p>""",
  onLinkTap: (String url) {
    //open URL in webview, or launch URL in browser, or any other logic here
  }
);
```

### customRender:

A powerful API that allows you to customize everything when rendering a specific HTML tag. This means you can add support for HTML elements that aren't supported natively. You can also make up your own custom tags in your HTML!

`customRender` accepts a `Map<String, CustomRender>`. The `CustomRender` type is a function that requires a `Widget` to be returned. It exposes `RenderContext`, the `Widget` that would have been rendered by `Html` without a `customRender` defined, the `attributes` of the HTML element as a `Map<String, String>`, and the HTML element itself as `Element`.

To use this API, set the key as the tag of the HTML element you wish to provide a custom implementation for, and create a function with the above parameters that returns a `Widget`.

#### Example Usages - customRender:
1. Simple example - rendering custom HTML tags
<details><summary>View code</summary>

```dart
Widget html = Html(
  data: """
  <h3>Display bird element and flutter element <bird></bird></h3>
  <flutter></flutter>
  <flutter horizontal></flutter>
  """,
  customRender: {
      "bird": (RenderContext context, Widget child, Map<String, String> attributes, _) {
        return TextSpan(text: "🐦");
      },
      "flutter": (RenderContext context, Widget child, Map<String, String> attributes, _) {
        return FlutterLogo(
          style: (attributes['horizontal'] != null)
              ? FlutterLogoStyle.horizontal
              : FlutterLogoStyle.markOnly,
          textColor: context.style.color,
          size: context.style.fontSize.size * 5,
        );
      },
    },
);
```
</details>

2. Complex example - rendering an `iframe` differently based on whether it is an embedded youtube video or some other embedded content

Packages used: [`data_connection_checker`](https://pub.dev/packages/data_connection_checker) and [`flutter_inappwebview`](https://pub.dev/packages/flutter_inappwebview)

<details><summary>View code</summary>

```dart
Widget html = Html(
   data: """
   <h3>Google iframe:</h3>
   <iframe src="https://google.com"></iframe>
   <h3>YouTube iframe:</h3>
   <iframe src="https://www.youtube.com/embed/tgbNymZ7vqY"></iframe>
   """,
   customRender: {
      "iframe": (RenderContext context, Widget child, Map<String, String> attributes, _) {
         if (attributes != null) {
           double width = double.tryParse(attributes['width'] ?? "");
           double height = double.tryParse(attributes['height'] ?? "");
           print(attributes['src']);
           return Container(
             width: width ?? (height ?? 150) * 2,
             height: height ?? (width ?? 300) / 2,
             child: InAppWebView(
               initialUrl: attributes['src'],
               // recommended options when using this implementation
               initialOptions: InAppWebViewGroupOptions(
                 crossPlatform: InAppWebViewOptions(
                   javaScriptEnabled: true,
                   cacheEnabled: false,
                   disableVerticalScroll: attributes['src'].contains("youtube.com/embed") ? true : false,
                   disableHorizontalScroll: attributes['src'].contains("youtube.com/embed") ? true : false,
                   useShouldOverrideUrlLoading: true,
                 ),
                 ios: IOSInAppWebViewOptions(
                   allowsLinkPreview: false,
                 ),
                 android: AndroidInAppWebViewOptions(
                   useHybridComposition: true,
                 )
               ),
               // no need for a scrolling gesture recognizer for embedded youtube videos so we only use VerticalDragGestureRecognizer when the iframe does not display embedded youtube videos
               gestureRecognizers: attributes['src'].contains("youtube.com/embed") ? null : [
                 Factory(() => VerticalDragGestureRecognizer())
               ].toSet(),
               // no need to load other urls when displaying embedded youtube videos so we block url loading requests when this is the case
               shouldOverrideUrlLoading: (controller, request) async {
                 if (attributes['src'].contains("youtube.com/embed")) {
                   if (!request.url.contains("youtube.com/embed")) {
                     return ShouldOverrideUrlLoadingAction.CANCEL;
                   } else {
                     return ShouldOverrideUrlLoadingAction.ALLOW;
                   }
                 } else {
                   return ShouldOverrideUrlLoadingAction.ALLOW;
                 }
               },
             ),
           );
         // if the src of the iframe is null then do not render anything
         } else {
           return Container(height: 0);
         }
       }
     }
 ),
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
  onImageTap: (String url) {
    //open image in webview, or launch image in browser, or any other logic here
  }
);
```

### blacklistedElements:

A list of elements the `Html` widget should not render. The list should contain the tags of the HTML elements you wish to blacklist.

#### Example Usage - blacklistedElements:
You may have instances where you can choose between two different types of HTML tags to display the same content. In the example below, the `<video>` and `<iframe>` elements are going to display the same content.

The `blacklistedElements` parameter allows you to change which element is rendered. Iframes can be advantageous because they allow parallel loading - Flutter just has to wait for the webview to be initialized before rendering the page, possibly cutting down on load time. Video can be advantageous because it provides a 100% native experience with Flutter widgets, but it may take more time to render the page. You may know that Flutter webview is a little janky in its current state on Android, so using `blacklistedElements` and a simple condition, you can get the best of both worlds - choose the video widget to render on Android and the iframe webview to render on iOS.
```dart
Widget html = Html(
  data: """
  <video controls>
    <source src="https://www.w3schools.com/html/mov_bbb.mp4" />
  </video>
  <iframe src="https://www.w3schools.com/html/mov_bbb.mp4"></iframe>""",
  blacklistedElements: [Platform.isAndroid ? "iframe" : "video"]
);
```

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
    <td rowspan='2'>Rowspan\nRowspan\nRowspan\nRowspan\nRowspan\nRowspan\nRowspan\nRowspan\nRowspan\nRowspan</td><td>Data</td><td>Data</td>
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

### navigationDelegateForIframe:

Allows you to set the `NavigationDelegate` for the `WebView`s of all the iframes rendered by the `Html` widget. You can block or allow the loading of certain URLs with the `NavigationDelegate`.

#### Example Usage - navigationDelegateForIframe:

```dart
Widget html = Html(
  data: """
   <h3>YouTube iframe:</h3>
   <iframe src="https://google.com"></iframe>
   <h3>Google iframe:</h3>
   <iframe src="https://www.youtube.com/embed/tgbNymZ7vqY"></iframe>
   """,
  navigationDelegateForIframe: (NavigationRequest request) {
    if (request.url.contains("google.com/images")) {
      return NavigationDecision.prevent;
    } else {
      return NavigationDecision.navigate;
    }
  },
);
```

## Rendering Reference

This section will describe how certain HTML elements are rendered by this package, so you can evaluate how your HTML will be rendered and structure it accordingly.

### Image

This package currently has support for base64 images, asset images, network SVGs inside an `<img>`, and network images.

The package uses the `src` of the image to determine which of the above types to render. The order is as follows:
1. If the `src` is null, render the alt text of the image, if any.
2. If the `src` starts with "data:image" and contains "base64," (this indicates the image data is indeed base64), render an `Image.memory` from the base64 data.
3. If the `src` starts with "asset:", render an `Image.asset` from the path in the `src`.
4. If the `src` ends with ".svg", render a `SvgPicture.network` (from the [`flutter_svg`](https://pub.dev/packages/flutter_svg) package)
5. Otherwise, just render an `Image.network`.

If the rendering of any of the above fails, the package will fall back to rendering the alt text of the image, if any.

Currently the package only considers the width, height, src, and alt text while rendering an image.

Note that there currently is no support for SVGs either in base64 format or asset format.

### Iframe

This package renders iframes using the [`webview_flutter`](https://pub.dev/packages/webview_flutter) plugin. 

When rendering iframes, the package considers the width, height, and sandbox attributes. 

Sandbox controls the JavaScript mode of the webview - a value of `null` or `allow-scripts` will set `javascriptMode: JavascriptMode.unrestricted`, otherwise it will set `javascriptMode: JavascriptMode.disabled`.

You can set the `navigationDelegate` of the webview with the `navigationDelegateForIframe` property - see [here](#navigationdelegateforiframe) for more details. 

### Audio

This package renders audio elements using the [`chewie_audio`](https://pub.dev/packages/chewie_audio) plugin. 

Note: Audio elements currently do not work on iOS due to a bug with `chewie_audio`. Once [#509](https://github.com/Sub6Resources/flutter_html/pull/509) is merged, it will work again.

The package considers the attributes `controls`, `loop`, `src`, `autoplay`, `width`, and `muted` when rendering the audio widget.

### Video

This package renders video elements using the [`chewie`](https://pub.dev/packages/chewie) plugin. 

The package considers the attributes `controls`, `loop`, `src`, `autoplay`, `poster`, `width`, `height`, and `muted` when rendering the video widget.

### SVG

This package renders svg elements using the [`flutter_svg`](https://pub.dev/packages/flutter_svg) plugin.

When rendering SVGs, the package takes the SVG data within the `<svg>` tag and passes it to `flutter_svg`. The `width` and `height` attributes are considered while rendering, if given.

### Table

This package renders table elements using the [`flutter_layout_grid`](https://pub.dev/packages/flutter_layout_grid) plugin.

When rendering table elements, the package tries to calculate the best fit for each element and size its cell accordingly. `Rowspan`s and `colspan`s are considered in this process, so cells that span across multiple rows and columns are rendered as expected. Heights are determined intrinsically to maintain an optimal aspect ratio for the cell.

## Migration Guides
- For Version 1.0 - [Guide](https://github.com/Sub6Resources/flutter_html/wiki/1.0.0-Migration-Guide)

## Contribution Guide
> Coming soon!
>
> Meanwhile, PRs are always welcome
