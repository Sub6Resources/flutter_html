library flutter_html;

import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/rich_text_parser.dart';
import 'package:flutter_html/style.dart';
import 'image_properties.dart';

class Html extends StatelessWidget {
  /// The `Html` widget takes HTML as input and displays a RichText
  /// tree of the parsed HTML content.
  ///
  /// **Attributes**
  /// **data** *required* takes in a String of HTML data.
  ///
  /// **css** currently does nothing
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
  /// **blacklistedElements** Tag names in this array are ignored during parsing and rendering.
  ///
  /// **style** Pass in the style information for the Html here.
  /// See [its wiki page](https://github.com/Sub6Resources/flutter_html/wiki/Style) for more info.
  Html({
    Key key,
    @required this.data,
    this.css = "",
    @deprecated this.padding,
    @deprecated this.backgroundColor,
    @deprecated this.defaultTextStyle,
    this.onLinkTap,
    @deprecated this.renderNewlines = false,
    this.customRender,
    @deprecated this.customEdgeInsets,
    @deprecated this.customTextStyle,
    @deprecated this.blockSpacing = 14.0,
    @deprecated this.useRichText = false,
    @deprecated this.customTextAlign, //TODO Add alternative for this
    this.onImageError,
    @deprecated this.linkStyle = const TextStyle(
        decoration: TextDecoration.underline,
        color: Colors.blueAccent,
        decorationColor: Colors.blueAccent),
    this.shrinkWrap = false,
    @deprecated this.imageProperties,
    this.onImageTap,
    @deprecated this.showImages = true,
    this.blacklistedElements = const [],
    this.style,
  }) : super(key: key);

  final String data;
  final String css;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final TextStyle defaultTextStyle;
  final OnTap onLinkTap;
  final bool renderNewlines;
  final double blockSpacing;
  final bool useRichText;
  final ImageErrorListener onImageError;
  final TextStyle linkStyle;
  final bool shrinkWrap;

  /// Properties for the Image widget that gets rendered by the rich text parser
  final ImageProperties imageProperties;
  final OnTap onImageTap;
  final bool showImages;

  final List<String> blacklistedElements;

  /// Either return a custom widget for specific node types or return null to
  /// fallback to the default rendering.
  final Map<String, CustomRender> customRender;
  final CustomEdgeInsets customEdgeInsets;
  final CustomTextStyle customTextStyle;
  final CustomTextAlign customTextAlign;

  /// Fancy New Parser parameters
  final Map<String, Style> style;

  @override
  Widget build(BuildContext context) {
    final double width = shrinkWrap ? null : MediaQuery.of(context).size.width;

    if (useRichText) {
      return Container(
        padding: padding,
        color: backgroundColor,
        width: width,
        child: DefaultTextStyle.merge(
          style: defaultTextStyle ?? Theme.of(context).textTheme.body1,
          child: HtmlRichTextParser(
            shrinkToFit: shrinkWrap,
            onLinkTap: onLinkTap,
            renderNewlines: renderNewlines,
            customEdgeInsets: customEdgeInsets,
            customTextStyle: customTextStyle,
            customTextAlign: customTextAlign,
            html: data,
            onImageError: onImageError,
            linkStyle: linkStyle,
            imageProperties: imageProperties,
            onImageTap: onImageTap,
            showImages: showImages,
          ),
        ),
      );
    }

    return Container(
      color: backgroundColor,
      width: width,
      child: HtmlParser(
        htmlData: data,
        cssData: css,
        onLinkTap: onLinkTap,
        onImageTap: onImageTap,
        onImageError: onImageError,
        shrinkWrap: shrinkWrap,
        style: style,
        customRender: customRender,
        blacklistedElements: blacklistedElements,
      ),
    );
  }
}
