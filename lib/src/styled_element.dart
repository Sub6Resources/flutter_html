import 'package:flutter/material.dart';
import 'package:flutter_html/style.dart';
import 'package:html/dom.dart' as dom;
//TODO(Sub6Resources) don't use the internal code of the html package as it may change unexpectedly.
import 'package:html/src/query_selector.dart';

/// A [StyledElement] applies a style to all of its children.
class StyledElement {
  final String name;
  final String elementId;
  final List<String> elementClasses;
  List<StyledElement> children;
  Style style;
  final dom.Node _node;

  StyledElement({
    this.name = "[[No name]]",
    this.elementId,
    this.elementClasses,
    this.children,
    this.style,
    dom.Element node,
  }) : this._node = node;

  bool matchesSelector(String selector) =>
      _node != null && matches(_node, selector);

  @override
  String toString() {
    String selfData =
        "$name [Children: ${children?.length ?? 0}] [Classes: ${elementClasses.toString()}] [ID: $elementId] <Style: $style>";
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
    elementId: element.id,
    elementClasses: element.classes.toList(),
    children: children,
    node: element,
  );

  switch (element.localName) {
    case "abbr":
    case "acronym":
      styledElement.style = Style(
        textDecoration: TextDecoration.underline,
        textDecorationStyle: TextDecorationStyle.dotted,
      );
      break;
    case "address":
      continue italics;
    bold:
    case "b":
      styledElement.style = Style(
        fontWeight: FontWeight.bold,
      );
      break;
    case "bdo":
      TextDirection textDirection =
          ((element.attributes["dir"] ?? "ltr") == "rtl")
              ? TextDirection.rtl
              : TextDirection.ltr;
      styledElement.style = Style(
        textDirection: textDirection,
      );
      break;
    case "big":
      styledElement.style = Style(
        fontSize: 20.0,
      );
      break;
    case "cite":
      continue italics;
    monospace:
    case "code":
      styledElement.style = Style(
        fontFamily: 'Monospace',
      );
      break;
    strikeThrough:
    case "del":
      styledElement.style = Style(
        textDecoration: TextDecoration.lineThrough,
      );
      break;
    case "dfn":
      continue italics;
    case "em":
      continue italics;
    italics:
    case "i":
      styledElement.style = Style(
        fontStyle: FontStyle.italic,
      );
      break;
    case "ins":
      continue underline;
    case "kbd":
      continue monospace;
    case "mark":
      styledElement.style = Style(
        color: Colors.black,
        backgroundColor: Colors.yellow,
      );
      break;
    case "q":
      styledElement.style = Style(
        before: "\"",
        after: "\"",
      );
      break;
    case "s":
      continue strikeThrough;
    case "samp":
      continue monospace;
    case "small":
      styledElement.style = Style(
        fontSize: 10.0,
      );
      break;
    case "strike":
      continue strikeThrough;
    case "strong":
      continue bold;
    case "sub":
      styledElement.style = Style(
        fontSize: 10.0,
        baselineOffset: -1,
      );
      break;
    case "sup":
      styledElement.style = Style(
        fontSize: 10.0,
        baselineOffset: 1,
      );
      break;
    case "tt":
      continue monospace;
    underline:
    case "u":
      styledElement.style = Style(
        textDecoration: TextDecoration.underline,
      );
      break;
    case "var":
      continue italics;
  }

  return styledElement;
}

typedef ListCharacter = String Function(int i);
