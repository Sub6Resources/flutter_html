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

- [Currently Supported Inline CSS Attributes](#currently-supported-inline-css-attributes)

- [Why flutter_html?](#why-this-package)

- [API Reference](#api-reference)

  - [Parameters Table](#parameters)

  - [Data](#data)

  - [onLinkTap](#onlinktap)

  - [customRender](#customrender)

  - [onImageError](#onimageerror)
  
  - [onMathError](#onmatherror)

  - [onImageTap](#onimagetap)

  - [blacklistedElements](#blacklistedelements)

  - [style](#style)

  - [navigationDelegateForIframe](#navigationdelegateforiframe)

  - [customImageRender](#customimagerender)
  
    - [typedef ImageSourceMatcher (with examples)](#typedef-imagesourcematcher)
    
    - [typedef ImageRender (with examples)](#typedef-imagerender)
    
    - [Extended examples](#example-usages---customimagerender)
    
- [Rendering Reference](#rendering-reference)

  - [Image](#image)
  
  - [Iframe](#iframe)
  
  - [Audio](#audio)
  
  - [Video](#video)
  
  - [SVG](#svg)
  
  - [MathML](#mathml)
  
  - [Table](#table)
  
- [Notes](#notes)

- [Migration Guide](#migration-guides)

- [Contribution Guide](#contribution-guide)

## Installing:

Add the following to your `pubspec.yaml` file:

    dependencies:
      flutter_html: ^1.3.0

## Currently Supported HTML Tags:
|            |           |       |             |         |         |       |      |        |        |        |
|------------|-----------|-------|-------------|---------|---------|-------|------|--------|--------|--------|
|`a`         | `abbr`    | `acronym`| `address`   | `article`| `aside` | `audio`| `b`  | `bdi`  | `bdo`  | `big`  |
|`blockquote`| `body`    | `br`  | `caption`   | `cite`  | `code`  | `data`| `dd` | `del`  | `details`  | `dfn`  |
| `div` | `dl`        | `dt`      | `em`  | `figcaption`| `figure`| `footer`| `h1`  | `h2` | `h3`   | `h4`   |
| `h5` |`h6`        | `header`  | `hr`  | `i`         | `iframe`| `img`   | `ins` | `kbd`| `li`   | `main` | 
| `mark` | `nav`       | `noscript`|`ol`   | `p`         | `pre`   | `q`     | `rp`  | `rt` | `ruby` | `s`  |
| `samp` | `section`   | `small`   | `span`| `strike`    | `strong`| `sub`   | `sup` | `summary` | `svg`| `table`| 
| `tbody` | `td` | `template` | `tfoot`   | `th`  | `thead`     |`time`   | `tr`    | `tt`  | `u`  | `ul` |
| `var` | `video` |  `math`:  |  `mrow`  |  `msup`    | `msub`  |  `mover`   | `munder`  | `msubsup`  | `moverunder`   | `mfrac`  | 
| `mlongdiv` | `msqrt` |  `mroot`  |  `mi`  |  `mn`    | `mo`  | `tex` (custom tag for this package)  |   |   |    |   | 

 
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
|`background-color`| `border` | `color`| `direction`| `display`| `font-family`| `font-feature-settings` |
| `font-size`|`font-style`      | `font-weight`| `line-height` | `list-style-type`  | `list-style-position`|`padding`     |
| `margin`| `text-align`| `text-decoration`| `text-decoration-color`| `text-decoration-style`| `text-shadow` | |

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
| `omMathError` | A function that defines what the widget should do when a math fails to render. The function exposes the parsed Tex `String`, as well as the error and error with type from `flutter_math` as a `String`. |
| `shrinkWrap` | A `bool` used while rendering different widgets to specify whether they should be shrink-wrapped or not, like `ContainerSpan` |
| `onImageTap` | A function that defines what the widget should do when an image is tapped. The function exposes the `src` of the image as a `String` to use in your implementation. |
| `blacklistedElements` | A list of elements the `Html` widget should not render. The list should contain the tags of the HTML elements you wish to blacklist.  |
| `style` | A powerful API that allows you to customize the style that should be used when rendering a specific HTMl tag. |
| `navigationDelegateForIframe` | Allows you to set the `NavigationDelegate` for the `WebView`s of all the iframes rendered by the `Html` widget. |
| `customImageRender` | A powerful API that allows you to fully customize how images are loaded. |

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
  onLinkTap: (String? url, RenderContext context, Map<String, String> attributes, dom.Element? element) {
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
      "bird": (RenderContext context, Widget child, Map<String, String> attributes, dom.Element? element) {
        return TextSpan(text: "🐦");
      },
      "flutter": (RenderContext context, Widget child, Map<String, String> attributes, dom.Element? element) {
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
      "iframe": (RenderContext context, Widget child, Map<String, String> attributes, dom.Element? element) {
         if (attributes != null) {
           double width = double.tryParse(attributes['width'] ?? "");
           double height = double.tryParse(attributes['height'] ?? "");
           return Container(
             width: width ?? (height ?? 150) * 2,
             height: height ?? (width ?? 300) / 2,
             child: WebView(
                initialUrl: attributes['src'] ?? "about:blank",
                javascriptMode: JavascriptMode.unrestricted,
                //no need for scrolling gesture recognizers on embedded youtube, so set gestureRecognizers null
                //on other iframe content scrolling might be necessary, so use VerticalDragGestureRecognizer
                gestureRecognizers: attributes['src'] != null && attributes['src']!.contains("youtube.com/embed") ? null : [
                  Factory(() => VerticalDragGestureRecognizer())
                ].toSet(),
                navigationDelegate: (NavigationRequest request) async {
                //no need to load any url besides the embedded youtube url when displaying embedded youtube, so prevent url loading
                //on other iframe content allow all url loading
                  if (attributes['src'] != null && attributes['src']!.contains("youtube.com/embed")) {
                    if (!request.url.contains("youtube.com/embed")) {
                      return NavigationDecision.prevent;
                    } else {
                      return NavigationDecision.navigate;
                    }
                  } else {
                    return NavigationDecision.navigate;
                  }
                },
              ),
            );
         } else {
           return Container(height: 0);
         }
       }
     }
 );
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

### onMathError:

A function that defines what the widget should do when a math fails to render. The function exposes the parsed Tex `String`, as well as the error and error with type from `flutter_math` as a `String`.

#### Example Usage - onMathError:

```dart
Widget html = Html(
  data: """<!-- Some MathML string that fails to parse -->""",
  onMathError: (String parsedTex, String error, String errorWithType) {
    //your logic here. A Widget must be returned from this function:
    return Text(error);
    //you can also try and fix the parsing yourself:
    return Math.tex(correctedParsedTex);
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

### customImageRender:

A powerful API that allows you to customize what the `Html` widget does when rendering an image, down to the most minute detail.

`customImageRender` accepts a `Map<ImageSourceMatcher, ImageRender>`. `ImageSourceMatcher` provides the matching function, while `ImageRender` provides the widget to be rendered.

The default image renders are:

```dart
final Map<ImageSourceMatcher, ImageRender> defaultImageRenders = {
  base64UriMatcher(): base64ImageRender(),
  assetUriMatcher(): assetImageRender(),
  networkSourceMatcher(extension: "svg"): svgNetworkImageRender(),
  networkSourceMatcher(): networkImageRender(),
};
```

See [the source code](https://github.com/Sub6Resources/flutter_html/blob/master/lib/image_render.dart) for details on how these are implemented.

When setting `customImageRenders`, the package will prioritize the custom renders first, while the default ones are used as a fallback.

Note: Order is very important when you set `customImageRenders`. The more specific your `ImageSourceMatcher`, the higher up in the `customImageRender` list it should be.

#### typedef ImageSourceMatcher

This is type defined as a function that passes the attributes as a `Map<String, String>` and the DOM element as `dom.Element`. This type is used to define how an image should be matched i.e. whether the package should override the default rendering method and instead use your custom implementation.

A typical usage would look something like this:

```dart
ImageSourceMatcher base64UriMatcher() => (attributes, element) =>
    attributes["src"] != null &&
    attributes["src"]!.startsWith("data:image") &&
    attributes["src"]!.contains("base64,");
```

In the above example, the matcher checks whether the image's `src` either starts with "data:image" or contains "base64,", since these indicate an image in base64 format.

You can also declare your own variables in the function itself, which would look like this:

```dart
ImageSourceMatcher networkSourceMatcher({
/// all three are optional, you don't need to have these in the function
  List<String> schemas: const ["https", "http"],
  List<String> domains: const ["your domain 1", "your domain 2"],
  String extension: "your extension",
}) =>
    (attributes, element) {
      final src = Uri.parse(attributes["src"] ?? "about:blank");
      return schemas.contains(src.scheme) &&
          domains.contains(src.host) &&
          src.path.endsWith(".$extension");
    };
```

In the above example, the possible schemas are checked against the scheme of the `src`, and optionally the domains and extensions are also checked. This implementation allows for extremely granular control over what images are matched, and could even be changed on the fly with a variable.

#### typedef ImageRender

This is a type defined as a function that passes the attributes of the image as a `Map<String, String>`, the current [`RenderContext`](https://github.com/Sub6Resources/flutter_html/wiki/All-About-customRender#rendercontext-context), and the DOM element as `dom.Element`. This type is used to define the widget that should be rendered when used in conjunction with an `ImageSourceMatcher`.

A typical usage might look like this:

```dart
ImageRender base64ImageRender() => (context, attributes, element) {
      final decodedImage = base64.decode(attributes["src"] != null ?
          attributes["src"].split("base64,")[1].trim() : "about:blank");
      return Image.memory(
        decodedImage,
      );
    };
```

The above example should be used with the `base64UriMatcher()` in the examples for `ImageSourceMatcher`.

Just like functions for `ImageSourceMatcher`, you can declare your own variables in the function itself:

```dart
ImageRender networkImageRender({
  Map<String, String> headers,
  double width,
  double height,
  Widget Function(String) altWidget,
}) =>
    (context, attributes, element) {
      return Image.network(
        attributes["src"] ?? "about:blank",
        headers: headers,
        width: width,
        height: height,
        frameBuilder: (ctx, child, frame, _) {
          if (frame == null) {
            return altWidget.call(attributes["alt"]) ??
                Text(attributes["alt"] ?? "",
                    style: context.style.generateTextStyle());
          }
          return child;
        },
      );
    };
```

Implementing these variables allows you to customize every last detail of how the widget is rendered.

#### Example Usages - customImageRender:

`customImageRender` can be used in two different ways:

1. Overriding a default render:
```dart
Widget html = Html(
  data: """
  <img alt='Flutter' src='https://flutter.dev/assets/flutter-lockup-1caf6476beed76adec3c477586da54de6b552b2f42108ec5bc68dc63bae2df75.png' /><br />
  <img alt='Google' src='https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png' /><br />
  """,
  customImageRenders: {
    networkSourceMatcher(domains: ["flutter.dev"]):
        (context, attributes, element) {
      return FlutterLogo(size: 36);
    },
    networkSourceMatcher(): networkImageRender(
      headers: {"Custom-Header": "some-value"},
      altWidget: (alt) => Text(alt ?? ""),
      loadingWidget: () => Text("Loading..."),
    ),
            (attr, _) => attr["src"] != null && attr["src"]!.startsWith("/wiki"):
    networkImageRender(
            mapUrl: (url) => "https://upload.wikimedia.org" + url),
  },
);
```

Above, there are three custom `networkSourceMatcher`s, which will be applied - in order - before the default implementations. 

When an image with URL `flutter.dev` is detected, rather than displaying the image, the render will display the flutter logo. If the image is any other image, it keeps the default widget, but just sets the headers and the alt text in case that image happens to be broken. The final render handles relative paths by rewriting them, specifically prefixing them with a base url. Note that the customizations of the previous custom renders do not apply. For example, the headers that the second render would apply are not applied in this third render.  

2. Creating your own renders:
```dart
ImageSourceMatcher classAndIdMatcher({String classToMatch, String idToMatch}) => (attributes, element) =>
    attributes["class"] != null && attributes["id"] != null &&
    (attributes["class"]!.contains(classToMatch) ||
    attributes["id"]!.contains(idToMatch));

ImageRender classAndIdRender({String classToMatch, String idToMatch}) => (context, attributes, element) {
  if (attributes["class"] != null && attributes["class"]!.contains(classToMatch)) {
    return Image.asset(attributes["src"] ?? "about:blank");
  } else {
    return Image.network(
      attributes["src"] ?? "about:blank",
      semanticLabel: attributes["longdesc"] ?? "",
      width: attributes["width"],
      height: attributes["height"],
      color: context.style.color,
      frameBuilder: (ctx, child, frame, _) {
          if (frame == null) {
            return Text(attributes["alt"] ?? "", style: context.style.generateTextStyle());
          }
          return child;
        },
    ); 
  }
};

Widget html = Html(
  data: """
  <img alt='alt text' class='class1-class2' src='assets/flutter.png' /><br />
  <img alt='alt text 2' id='imageId' src='https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png' /><br />
  """,
  customImageRenders: {
    classAndIdMatcher(classToMatch: "class1", idToMatch: "imageId"): classAndIdRender(classToMatch: "class1", idToMatch: "imageId")
  },
);
```

The above example has a matcher that checks for either a class or an id, and then returns two different widgets based on whether a class was matched or an id was matched. 

The sky is the limit when using the custom image renders. You can make it as granular as you want, or as all-encompassing as you want, and you have full control of everything. Plus you get the package's style parsing to use in your custom widgets, so your code looks neat and readable!

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

The package considers the attributes `controls`, `loop`, `src`, `autoplay`, `width`, and `muted` when rendering the audio widget.

### Video

This package renders video elements using the [`chewie`](https://pub.dev/packages/chewie) plugin. 

The package considers the attributes `controls`, `loop`, `src`, `autoplay`, `poster`, `width`, `height`, and `muted` when rendering the video widget.

### SVG

This package renders svg elements using the [`flutter_svg`](https://pub.dev/packages/flutter_svg) plugin.

When rendering SVGs, the package takes the SVG data within the `<svg>` tag and passes it to `flutter_svg`. The `width` and `height` attributes are considered while rendering, if given.

### MathML

This package renders MathML elements using the [`flutter_math`](https://pub.dev/packages/flutter_math) plugin.

When rendering MathML, the package takes the MathML data within the `<math>` tag and tries to parse it to Tex. Then, it will pass the parsed string to `flutter_math`.

Because this package is parsing MathML to Tex, it may not support some functionalities. The current list of supported tags can be found [above](#currently-supported-html-tags), but some of these only have partial support at the moment.

If the parsing errors, you can use the [onMathError](#onmatherror) API to catch the error and potentially fix it on your end - you can analyze the error and the parsed string, and finally return a new instance of `Math.tex()` with the corrected Tex string.

If you'd like to see more MathML features, feel free to create a PR or file a feature request!

### Tex

If you have a Tex string you'd like to render inside your HTML you can do that!

Use the custom `<tex>` tag inside your HTML, and place your **raw** Tex string inside. The package uses the same logic as MathML rendering above, but doesn't need to parse the string, of course.
 
 The rendering error will also be called if your Tex string fails to render.

### Table

This package renders table elements using the [`flutter_layout_grid`](https://pub.dev/packages/flutter_layout_grid) plugin.

When rendering table elements, the package tries to calculate the best fit for each element and size its cell accordingly. `Rowspan`s and `colspan`s are considered in this process, so cells that span across multiple rows and columns are rendered as expected. Heights are determined intrinsically to maintain an optimal aspect ratio for the cell.

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
- For Version 1.0 - [Guide](https://github.com/Sub6Resources/flutter_html/wiki/1.0.0-Migration-Guide)

## Contribution Guide
> Coming soon!
>
> Meanwhile, PRs are always welcome
