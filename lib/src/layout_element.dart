import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/src/styled_element.dart';
import 'package:flutter_html/style.dart';
import 'package:html/dom.dart' as dom;

/// A [LayoutElement] is an element that breaks the normal Inline flow of
/// an html document with a more complex layout. LayoutElements handle
abstract class LayoutElement extends StyledElement {
  LayoutElement({
    String name,
    List<StyledElement> children,
    Style style,
    dom.Element node,
  }) : super(name: name, children: children, style: style, node: node);

  Widget toWidget(RenderContext context);
}

class TableLayoutElement extends LayoutElement {
  TableLayoutElement({
    @required List<StyledElement> children,
  }) : super(children: children);

  @override
  Widget toWidget(RenderContext context) {
    return Table(
//      children: children.where((e) => e.name == 'tr').map(),
    );
  }
}

class TableRowLayoutElement extends LayoutElement {
  TableRowLayoutElement({
    @required List<StyledElement> children,
}) : super(children: children);

  @override
  Widget toWidget(RenderContext context) {
    return Container(child: Text("TABLE ROW"));
  }

  TableRow toTableRow(RenderContext context) {

  }
}

LayoutElement parseLayoutElement(dom.Element element, List<StyledElement> children) {
  switch (element.localName) {
    case "table":
      return TableLayoutElement(
        children: children,
      );
      break;
    case "tr":
      return TableLayoutElement(
        children: children,
      );
      break;
    default:
      return TableLayoutElement(
        children: children
      );
  }
}
