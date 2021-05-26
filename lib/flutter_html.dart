library flutter_html;

import 'package:flutter/material.dart';
import 'package:flutter_html/custom_render.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/src/html_elements.dart';
import 'package:flutter_html/style.dart';
import 'package:html/dom.dart' as dom;

//export render context api
export 'package:flutter_html/html_parser.dart';
//export render context api
export 'package:flutter_html/html_parser.dart';
export 'package:flutter_html/custom_render.dart';
export 'package:flutter_html/src/anchor.dart';
export 'package:flutter_html/src/anchor.dart';
export 'package:flutter_html/src/interactable_element.dart';
export 'package:flutter_html/src/interactable_element.dart';
//export src for advanced custom render uses (e.g. casting context.tree)
export 'package:flutter_html/src/layout_element.dart';
//export src for advanced custom render uses (e.g. casting context.tree)
export 'package:flutter_html/src/layout_element.dart';
export 'package:flutter_html/src/replaced_element.dart';
export 'package:flutter_html/src/replaced_element.dart';
export 'package:flutter_html/src/styled_element.dart';
export 'package:flutter_html/src/styled_element.dart';
//export style api
export 'package:flutter_html/style.dart';
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
  /// **tagsList** Tag names in this array will be the only tags rendered. By default all tags are rendered.
  ///
  /// **style** Pass in the style information for the Html here.
  /// See [its wiki page](https://github.com/Sub6Resources/flutter_html/wiki/Style) for more info.
  Html({
    Key? key,
    GlobalKey? anchorKey,
    required this.data,
    this.onLinkTap,
    this.customRenders = const {},
    this.onCssParseError,
    this.onImageError,
    this.shrinkWrap = false,
    this.onImageTap,
    this.tagsList = const [],
    this.style = const {},
  }) : document = null,
        assert (data != null),
        _anchorKey = anchorKey ?? GlobalKey(),
        super(key: key);

  Html.fromDom({
    Key? key,
    GlobalKey? anchorKey,
    @required this.document,
    this.onLinkTap,
    this.customRenders = const {},
    this.onCssParseError,
    this.onImageError,
    this.shrinkWrap = false,
    this.onImageTap,
    this.tagsList = const [],
    this.style = const {},
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

  /// A function that defines what to do when CSS fails to parse
  final OnCssParseError? onCssParseError;

  /// A function that defines what to do when an image errors
  final ImageErrorListener? onImageError;

  /// A parameter that should be set when the HTML widget is expected to be
  /// flexible
  final bool shrinkWrap;

  /// A function that defines what to do when an image is tapped
  final OnTap? onImageTap;

  /// A list of HTML tags that defines what elements are not rendered
  final List<String> tagsList;

  /// Either return a custom widget for specific node types or return null to
  /// fallback to the default rendering.
  final Map<CustomRenderMatcher, CustomRender> customRenders;

  /// An API that allows you to override the default style for any HTML element
  final Map<String, Style> style;

  static List<String> get tags => new List<String>.from(STYLED_ELEMENTS)
    ..addAll(INTERACTABLE_ELEMENTS)
    ..addAll(REPLACED_ELEMENTS)
    ..addAll(LAYOUT_ELEMENTS)
    ..addAll(TABLE_CELL_ELEMENTS)
    ..addAll(TABLE_DEFINITION_ELEMENTS)
    ..addAll(EXTERNAL_ELEMENTS);

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
        onImageTap: onImageTap,
        onCssParseError: onCssParseError,
        onImageError: onImageError,
        shrinkWrap: shrinkWrap,
        style: style,
        customRenders: {}
          ..addAll(customRenders)
          ..addAll(defaultRenders),
        tagsList: tagsList.isEmpty ? Html.tags : tagsList,
      ),
    );
  }
}
