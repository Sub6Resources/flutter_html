library flutter_html;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/image_render.dart';
import 'package:flutter_html/src/html_elements.dart';
import 'package:flutter_html/style.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter_html/src/navigation_delegate.dart';

//export render context api
export 'package:flutter_html/html_parser.dart';
export 'package:flutter_html/image_render.dart';
//export src for advanced custom render uses (e.g. casting context.tree)
export 'package:flutter_html/src/anchor.dart';
export 'package:flutter_html/src/interactable_element.dart';
export 'package:flutter_html/src/layout_element.dart';
export 'package:flutter_html/src/replaced_element.dart';
export 'package:flutter_html/src/styled_element.dart';
export 'package:flutter_html/src/navigation_delegate.dart';
//export style api
export 'package:flutter_html/style.dart';

class Html extends StatelessWidget {
  /// The `Html` widget takes HTML as input and displays a RichText
  /// tree of the parsed HTML content.
  ///
  /// **Attributes**
  /// **data** *required* takes in a String of HTML data (required only for `Html` constructor).
  /// **document** *required* takes in a Document of HTML data (required only for `Html.fromDom` constructor).
  ///
  /// **onLinkTap** This function is called whenever a link (`<a href>`)
  /// is tapped.
  /// **customRender** This function allows you to return your own widgets
  /// for existing or custom HTML tags.
  /// See [its wiki page](https://github.com/Sub6Resources/flutter_html/wiki/All-About-customRender) for more info.
  ///
  /// **onImageError** This is called whenever an image fails to load or
  /// display on the page.
  ///
  /// **shrinkWrap** This makes the Html widget take up only the width it
  /// needs and no more.
  ///
  /// **onImageTap** This is called whenever an image is tapped.
  ///
  /// **tagsList** Tag names in this array will be the only tags rendered. By default all supported HTML tags are rendered.
  ///
  /// **style** Pass in the style information for the Html here.
  /// See [its wiki page](https://github.com/Sub6Resources/flutter_html/wiki/Style) for more info.
  Html({
    Key? key,
    GlobalKey? anchorKey,
    required this.data,
    this.onLinkTap,
    this.onAnchorTap,
    this.customRender = const {},
    this.customImageRenders = const {},
    this.onCssParseError,
    this.onImageError,
    this.onMathError,
    this.shrinkWrap = false,
    this.onImageTap,
    this.tagsList = const [],
    this.style = const {},
    this.navigationDelegateForIframe,
  })  : document = null,
        assert(data != null),
        _anchorKey = anchorKey ?? GlobalKey(),
        super(key: key);

  Html.fromDom({
    Key? key,
    GlobalKey? anchorKey,
    @required this.document,
    this.onLinkTap,
    this.onAnchorTap,
    this.customRender = const {},
    this.customImageRenders = const {},
    this.onCssParseError,
    this.onImageError,
    this.onMathError,
    this.shrinkWrap = false,
    this.onImageTap,
    this.tagsList = const [],
    this.style = const {},
    this.navigationDelegateForIframe,
  })  : data = null,
        assert(document != null),
        _anchorKey = anchorKey ?? GlobalKey(),
        super(key: key);

  /// A unique key for this Html widget to ensure uniqueness of anchors
  final GlobalKey _anchorKey;

  /// The HTML data passed to the widget as a String
  final String? data;

  /// The HTML data passed to the widget as a pre-processed [dom.Document]
  final dom.Document? document;

  /// A function that defines what to do when a link is tapped
  final OnTap? onLinkTap;

  /// A function that defines what to do when an anchor link is tapped. When this value is set,
  /// the default anchor behaviour is overwritten.
  final OnTap? onAnchorTap;

  /// An API that allows you to customize the entire process of image rendering.
  /// See the README for more details.
  final Map<ImageSourceMatcher, ImageRender> customImageRenders;

  /// A function that defines what to do when CSS fails to parse
  final OnCssParseError? onCssParseError;

  /// A function that defines what to do when an image errors
  final ImageErrorListener? onImageError;

  /// A function that defines what to do when either <math> or <tex> fails to render
  /// You can return a widget here to override the default error widget.
  final OnMathError? onMathError;

  /// A parameter that should be set when the HTML widget is expected to be
  /// flexible
  final bool shrinkWrap;

  /// A function that defines what to do when an image is tapped
  final OnTap? onImageTap;

  /// A list of HTML tags that are the only tags that are rendered. By default, this list is empty and all supported HTML tags are rendered.
  final List<String> tagsList;

  /// Either return a custom widget for specific node types or return null to
  /// fallback to the default rendering.
  final Map<String, CustomRender> customRender;

  /// An API that allows you to override the default style for any HTML element
  final Map<String, Style> style;

  /// Decides how to handle a specific navigation request in the WebView of an
  /// Iframe. It's necessary to use the webview_flutter package inside the app
  /// to use NavigationDelegate.
  final NavigationDelegate? navigationDelegateForIframe;

  static List<String> get tags => new List<String>.from(STYLED_ELEMENTS)
    ..addAll(INTERACTABLE_ELEMENTS)
    ..addAll(REPLACED_ELEMENTS)
    ..addAll(LAYOUT_ELEMENTS)
    ..addAll(TABLE_CELL_ELEMENTS)
    ..addAll(TABLE_DEFINITION_ELEMENTS);

  @override
  Widget build(BuildContext context) {
    final dom.Document doc =
        data != null ? HtmlParser.parseHTML(data!) : document!;
    final double? width = shrinkWrap ? null : MediaQuery.of(context).size.width;

    return Container(
      width: width,
      child: HtmlParser(
        key: _anchorKey,
        htmlData: doc,
        onLinkTap: onLinkTap,
        onAnchorTap: onAnchorTap,
        onImageTap: onImageTap,
        onCssParseError: onCssParseError,
        onImageError: onImageError,
        onMathError: onMathError,
        shrinkWrap: shrinkWrap,
        selectable: false,
        style: style,
        customRender: customRender,
        imageRenders: {}
          ..addAll(customImageRenders)
          ..addAll(defaultImageRenders),
        tagsList: tagsList.isEmpty ? Html.tags : tagsList,
        navigationDelegateForIframe: navigationDelegateForIframe,
      ),
    );
  }
}

class SelectableHtml extends StatelessWidget {
  /// The `SelectableHtml` widget takes HTML as input and displays a RichText
  /// tree of the parsed HTML content (which is selectable)
  ///
  /// **Attributes**
  /// **data** *required* takes in a String of HTML data (required only for `Html` constructor).
  /// **document** *required* takes in a Document of HTML data (required only for `Html.fromDom` constructor).
  ///
  /// **onLinkTap** This function is called whenever a link (`<a href>`)
  /// is tapped.
  ///
  /// **onAnchorTap** This function is called whenever an anchor (#anchor-id)
  /// is tapped.
  ///
  /// **tagsList** Tag names in this array will be the only tags rendered. By default, all tags that support selectable content are rendered.
  ///
  /// **style** Pass in the style information for the Html here.
  /// See [its wiki page](https://github.com/Sub6Resources/flutter_html/wiki/Style) for more info.
  ///
  /// **PLEASE NOTE**
  ///
  /// There are a few caveats due to Flutter [#38474](https://github.com/flutter/flutter/issues/38474):
  ///
  /// 1. The list of tags that can be rendered is significantly reduced.
  /// Key omissions include no support for images/video/audio, table, and ul/ol because they all require widgets and `WidgetSpan`s.
  ///
  /// 2. No support for `customRender`, `customImageRender`, `onImageError`, `onImageTap`, `onMathError`, and `navigationDelegateForIframe`.
  ///
  /// 3. Styling support is significantly reduced. Only text-related styling works
  /// (e.g. bold or italic), while container related styling (e.g. borders or padding/margin)
  /// do not work because we can't use the `ContainerSpan` class (it needs an enclosing `WidgetSpan`).

  SelectableHtml({
    Key? key,
    GlobalKey? anchorKey,
    required this.data,
    this.onLinkTap,
    this.onAnchorTap,
    this.onCssParseError,
    this.shrinkWrap = false,
    this.style = const {},
    this.tagsList = const [],
    this.selectionControls,
    this.scrollPhysics,
  }) : document = null,
        assert(data != null),
        _anchorKey = anchorKey ?? GlobalKey(),
        super(key: key);

  SelectableHtml.fromDom({
    Key? key,
    GlobalKey? anchorKey,
    required this.document,
    this.onLinkTap,
    this.onAnchorTap,
    this.onCssParseError,
    this.shrinkWrap = false,
    this.style = const {},
    this.tagsList = const [],
    this.selectionControls,
    this.scrollPhysics,
  }) : data = null,
        assert(document != null),
        _anchorKey = anchorKey ?? GlobalKey(),
        super(key: key);

  /// A unique key for this Html widget to ensure uniqueness of anchors
  final GlobalKey _anchorKey;

  /// The HTML data passed to the widget as a String
  final String? data;

  /// The HTML data passed to the widget as a pre-processed [dom.Document]
  final dom.Document? document;

  /// A function that defines what to do when a link is tapped
  final OnTap? onLinkTap;

  /// A function that defines what to do when an anchor link is tapped. When this value is set,
  /// the default anchor behaviour is overwritten.
  final OnTap? onAnchorTap;

  /// A function that defines what to do when CSS fails to parse
  final OnCssParseError? onCssParseError;

  /// A parameter that should be set when the HTML widget is expected to be
  /// flexible
  final bool shrinkWrap;

  /// A list of HTML tags that are the only tags that are rendered. By default, this list is empty and all supported HTML tags are rendered.
  final List<String> tagsList;

  /// An API that allows you to override the default style for any HTML element
  final Map<String, Style> style;

  /// Custom Selection controls allows you to override default toolbar and build custom toolbar
  /// options
  final TextSelectionControls? selectionControls;

  /// Allows you to override the default scrollPhysics for [SelectableText.rich]
  final ScrollPhysics? scrollPhysics;

  static List<String> get tags => new List<String>.from(SELECTABLE_ELEMENTS);

  @override
  Widget build(BuildContext context) {
    final dom.Document doc = data != null ? HtmlParser.parseHTML(data!) : document!;
    final double? width = shrinkWrap ? null : MediaQuery.of(context).size.width;

    return Container(
      width: width,
      child: HtmlParser(
        key: _anchorKey,
        htmlData: doc,
        onLinkTap: onLinkTap,
        onAnchorTap: onAnchorTap,
        onImageTap: null,
        onCssParseError: onCssParseError,
        onImageError: null,
        onMathError: null,
        shrinkWrap: shrinkWrap,
        selectable: true,
        style: style,
        customRender: {},
        imageRenders: defaultImageRenders,
        tagsList: tagsList.isEmpty ? SelectableHtml.tags : tagsList,
        navigationDelegateForIframe: null,
        selectionControls: selectionControls,
        scrollPhysics: scrollPhysics,
      ),
    );
  }
}
