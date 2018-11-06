library flutter_html;

import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';

class Html extends StatelessWidget {
  Html({
    Key key,
    @required this.data,
    this.padding,
    this.backgroundColor,
    this.defaultTextStyle = const TextStyle(color: Colors.black),
    this.onLinkTap,
    this.renderNewlines = false,
    this.customRender,
    this.useRichText = false,
  }) : super(key: key);

  final String data;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final TextStyle defaultTextStyle;
  final OnLinkTap onLinkTap;
  final bool renderNewlines;
  final bool useRichText;

  /// Either return a custom widget for specific node types or return null to
  /// fallback to the default rendering.
  final CustomRender customRender;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Container(
      padding: padding,
      color: backgroundColor,
      width: width,
      child: DefaultTextStyle.merge(
        style: defaultTextStyle,
        child: Wrap(
          alignment: WrapAlignment.start,
          children: (useRichText)
          ? HtmlRichTextParser(
            width: width,
            onLinkTap: onLinkTap,
            renderNewlines: renderNewlines,
            customRender: customRender,
          ).parse(data)
          : HtmlOldParser(
            width: width,
            onLinkTap: onLinkTap,
            renderNewlines: renderNewlines,
            customRender: customRender,
          ).parse(data),
        ),
      ),
    );
  }
}
