library flutter_html;

import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';

class Html extends StatelessWidget {
  Html(
      {Key key,
      @required this.data,
      this.padding,
      this.backgroundColor,
      this.defaultTextStyle = const TextStyle(color: Colors.black)})
      : super(key: key);

  final String data;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final TextStyle defaultTextStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: HtmlParser(defaultTextStyle: defaultTextStyle).parse(data),
      ),
    );
  }
}
