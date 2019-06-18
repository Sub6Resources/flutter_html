library flutter_html;

import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/rich_text_parser.dart';
import 'package:flutter_html/style.dart';
import 'image_properties.dart';

class Html extends StatelessWidget {
  Html({
    Key key,
    @required this.data,
    this.css = "",
    @deprecated this.padding,
    this.backgroundColor,
    @deprecated this.defaultTextStyle,
    this.onLinkTap,
    this.renderNewlines = false,
    this.customRender,
    @deprecated this.customEdgeInsets,
    @deprecated this.customTextStyle,
    @deprecated this.blockSpacing = 14.0,
    @deprecated this.useRichText = false,
    this.onImageError,
    @deprecated this.linkStyle = const TextStyle(
        decoration: TextDecoration.underline,
        color: Colors.blueAccent,
        decorationColor: Colors.blueAccent),
    this.imageProperties,
    this.onImageTap,
    this.showImages = true,
    this.style,
  }) : super(key: key);

  final String data;
  final String css;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final TextStyle defaultTextStyle;
  final OnLinkTap onLinkTap;
  final bool renderNewlines;
  final double blockSpacing;
  final bool useRichText;
  final ImageErrorListener onImageError;
  final TextStyle linkStyle;

  /// Properties for the Image widget that gets rendered by the rich text parser
  final ImageProperties imageProperties;
  final OnImageTap onImageTap;
  final bool showImages;

  /// Either return a custom widget for specific node types or return null to
  /// fallback to the default rendering.
  final CustomRender customRender;
  final CustomEdgeInsets customEdgeInsets;
  final CustomTextStyle customTextStyle;

  /// Fancy New Parser parameters
  final Map<String, Style> style;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    if(useRichText) {
      return Container(
//      padding: padding,
        color: backgroundColor,
        width: width,
        child: DefaultTextStyle.merge(
          style: defaultTextStyle ?? Theme.of(context).textTheme.body1,
          child:  HtmlRichTextParser(
            width: width,
            onLinkTap: onLinkTap,
            renderNewlines: renderNewlines,
            customEdgeInsets: customEdgeInsets,
            customTextStyle: customTextStyle,
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
        style: style,
      )
    );

  }
}
