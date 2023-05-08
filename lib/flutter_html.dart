library flutter_html;

import 'package:flutter/material.dart';
import 'package:flutter_html/src/html_parser.dart';
import 'package:flutter_html/src/extension/extension.dart';
import 'package:flutter_html/src/html_elements.dart';
import 'package:flutter_html/src/style.dart';
import 'package:html/dom.dart' as dom;

//export render context api
export 'package:flutter_html/src/html_parser.dart';
//export src for advanced custom render uses (e.g. casting context.tree)
export 'package:flutter_html/src/anchor.dart';
export 'package:flutter_html/src/tree/interactable_element.dart';
export 'package:flutter_html/src/tree/replaced_element.dart';
export 'package:flutter_html/src/tree/styled_element.dart';
//export css_box_widget for use in extensions.
export 'package:flutter_html/src/css_box_widget.dart';
//export style api
export 'package:flutter_html/src/style.dart';
//export extension api
export 'package:flutter_html/src/extension/extension.dart';

class Html extends StatefulWidget {
  /// The `Html` widget takes HTML as input and displays a RichText
  /// tree of the parsed HTML content.
  ///
  /// **Attributes**
  /// **data** *required* takes in a String of HTML data (required only for `Html` constructor).
  /// **document** *required* takes in a Document of HTML data (required only for `Html.fromDom` constructor).
  ///
  /// **onLinkTap** This function is called whenever a link (`<a href>`)
  /// is tapped.
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
    this.extensions = const [],
    this.onCssParseError,
    this.onImageError,
    this.shrinkWrap = false,
    this.onImageTap,
    this.tagsList = const [],
    this.style = const {},
  })  : documentElement = null,
        assert(data != null),
        _anchorKey = anchorKey ?? GlobalKey(),
        super(key: key);

  Html.fromDom({
    Key? key,
    GlobalKey? anchorKey,
    @required dom.Document? document,
    this.onLinkTap,
    this.onAnchorTap,
    this.extensions = const [],
    this.onCssParseError,
    this.onImageError,
    this.shrinkWrap = false,
    this.onImageTap,
    this.tagsList = const [],
    this.style = const {},
  })  : data = null,
        assert(document != null),
        documentElement = document!.documentElement,
        _anchorKey = anchorKey ?? GlobalKey(),
        super(key: key);

  Html.fromElement({
    Key? key,
    GlobalKey? anchorKey,
    @required this.documentElement,
    this.onLinkTap,
    this.onAnchorTap,
    this.extensions = const [],
    this.onCssParseError,
    this.onImageError,
    this.shrinkWrap = false,
    this.onImageTap,
    this.tagsList = const [],
    this.style = const {},
  })  : data = null,
        assert(documentElement != null),
        _anchorKey = anchorKey ?? GlobalKey(),
        super(key: key);

  /// A unique key for this Html widget to ensure uniqueness of anchors
  final GlobalKey _anchorKey;

  /// The HTML data passed to the widget as a String
  final String? data;

  /// The HTML data passed to the widget as a pre-processed [dom.Element]
  final dom.Element? documentElement;

  /// A function that defines what to do when a link is tapped
  final OnTap? onLinkTap;

  /// A function that defines what to do when an anchor link is tapped. When this value is set,
  /// the default anchor behaviour is overwritten.
  final OnTap? onAnchorTap;

  /// A function that defines what to do when CSS fails to parse
  final OnCssParseError? onCssParseError;

  /// A function that defines what to do when an image errors
  final ImageErrorListener? onImageError;

  /// A parameter that should be set when the HTML widget is expected to be
  /// flexible
  final bool shrinkWrap;

  /// A function that defines what to do when an image is tapped
  final OnTap? onImageTap;

  /// A list of HTML tags that are the only tags that are rendered. By default, this list is empty and all supported HTML tags are rendered.
  final List<String> tagsList;

  /// A list of [Extension]s that add additional capabilities to flutter_html
  /// See the [Extension] class for more details.
  final List<Extension> extensions;

  /// An API that allows you to override the default style for any HTML element
  final Map<String, Style> style;

  static List<String> get tags => List<String>.from(HtmlElements.styledElements)
    ..addAll(HtmlElements.interactableElements)
    ..addAll(HtmlElements.replacedElements)
    ..addAll(HtmlElements.layoutElements)
    ..addAll(HtmlElements.externalElements);

  @override
  State<StatefulWidget> createState() => _HtmlState();
}

class _HtmlState extends State<Html> {
  late dom.Element documentElement;

  @override
  void initState() {
    super.initState();
    documentElement = widget.data != null
        ? HtmlParser.parseHTML(widget.data!)
        : widget.documentElement!;
  }

  @override
  void didUpdateWidget(Html oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.data != null && oldWidget.data != widget.data) ||
        oldWidget.documentElement != widget.documentElement) {
      documentElement = widget.data != null
          ? HtmlParser.parseHTML(widget.data!)
          : widget.documentElement!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlParser(
      key: widget._anchorKey,
      htmlData: documentElement,
      onLinkTap: widget.onLinkTap,
      onAnchorTap: widget.onAnchorTap,
      onImageTap: widget.onImageTap,
      onCssParseError: widget.onCssParseError,
      onImageError: widget.onImageError,
      shrinkWrap: widget.shrinkWrap,
      style: widget.style,
      extensions: widget.extensions,
      tagsList: widget.tagsList.isEmpty ? Html.tags : widget.tagsList,
    );
  }
}
