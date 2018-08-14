library flutter_html;

import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';


class HtmlWidget extends StatelessWidget {
  HtmlWidget({Key key, @required this.data, this.padding, this.backgroundColor}): super(key: key);

  final String data;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: HtmlParser.parse(data),
      ),
    );
  }

}
