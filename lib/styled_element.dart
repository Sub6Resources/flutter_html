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
    this.name = "[[No name]]",
    this.children,
    this.style,
  });

  @override
  String toString() {
    String selfData =
        "$name [Children: ${children?.length ?? 0}] <Style: $style>";
    children?.forEach((child) {
      selfData += ("\n${child.toString()}")
          .replaceAll(RegExp("^", multiLine: true), "-");
    });
    return selfData;
  }
}

StyledElement parseStyledElement(
    dom.Element element, List<StyledElement> children) {
  StyledElement styledElement = StyledElement(
    name: element.localName,
    children: children,
  );

  switch (element.localName) {
    case "abbr":
    case "acronym":
      styledElement.style = Style(
        textStyle: TextStyle(
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.dotted,
        ),
      );
      break;
    case "address":
      continue italics;
    bold:
    case "b":
      styledElement.style = Style(
        textStyle: TextStyle(fontWeight: FontWeight.bold),
      );
      break;
    italics:
    case "i":
      styledElement.style = Style(
        textStyle: TextStyle(fontStyle: FontStyle.italic),
      );
      break;
    underline:
    case "u":
      styledElement.style = Style(
        textStyle: TextStyle(decoration: TextDecoration.underline),
      );
      break;
  }

  return styledElement;
}

typedef ListCharacter = String Function(int i);

class Style {
  final TextStyle textStyle;
  final bool indentChildren;
  final ListCharacter listCharacter;

  Style({this.textStyle, this.indentChildren, this.listCharacter});

  @override
  String toString() {
    return "(Text Style: ($textStyle}),)";
  }
}
