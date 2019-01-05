library flutter_html;

import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:html/dom.dart' as dom;

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
  })  : this.nodeList = null,
        super(key: key);

  Html.fromNodeList({
    Key key,
    @required this.nodeList,
    this.padding,
    this.backgroundColor,
    this.defaultTextStyle = const TextStyle(color: Colors.black),
    this.onLinkTap,
    this.renderNewlines = false,
    this.customRender,
  })  : this.data = null,
        super(key: key);

  final String data;
  final List<dom.Node> nodeList;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final TextStyle defaultTextStyle;
  final OnLinkTap onLinkTap;
  final bool renderNewlines;

  /// Either return a custom widget for specific node types or return null to
  /// fallback to the default rendering.
  final CustomRender customRender;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    ///ONLY ONE OF data or node list MUST be not null!
    assert((data == null) ^ (nodeList == null));

    HtmlParser parser = HtmlParser(
      width: width,
      onLinkTap: onLinkTap,
      renderNewlines: renderNewlines,
      customRender: customRender,
    );

    return Container(
      padding: padding,
      color: backgroundColor,
      width: width,
      child: DefaultTextStyle.merge(
        style: defaultTextStyle,
        child: Wrap(
          alignment: WrapAlignment.start,
          children:
              data != null ? parser.parse(data) : parser.parseNodeList(nodeList),
        ),
      ),
    );
  }
}
