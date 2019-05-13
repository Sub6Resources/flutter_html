import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/html_elements.dart';
import 'package:html/dom.dart' as dom;

/// A [StyledElement] applies a style to all of its children.
class StyledElement {
  final String name;
  List<StyledElement> children;
  Style style;

  StyledElement({
    this.name = "[[[No name]]]",
    this.children,
    this.style,
  });

  @override
  String toString() {
    String selfData = "$name [Children: ${children?.length ?? 0}] <Style: $style>";
    children?.forEach((child) {
      selfData += "\n - ${child.toString()}";
    });
    return selfData;
  }
}

StyledElement parseStyledElement(dom.Element element,
    List<StyledElement> children) {
  StyledElement styledElement = StyledElement(
    name: element.localName,
    children: children,
  );

  switch (element.localName) {
    case "b":
      styledElement.style = Style(textStyle: TextStyle(fontWeight: FontWeight.bold));
      break;
    case "i":
      styledElement.style = Style(textStyle: TextStyle(fontStyle: FontStyle.italic));
      break;
  }

  return styledElement;
}

class Style {
  final TextStyle textStyle;

  Style({
    this.textStyle
  });

  @override
  String toString() {
    return "(Text Style: ($textStyle),)";
  }
}