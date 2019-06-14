import 'package:flutter/material.dart';
import 'package:flutter_html/style.dart';
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
        textStyle: TextStyle(fontSize: 20.0),
      );
      break;
    case "cite":
      continue italics;
    monospace:
    case "code":
      styledElement.style = Style(
        textStyle: TextStyle(fontFamily: 'Monospace'),
      );
      break;
    strikeThrough:
    case "del":
      styledElement.style = Style(
        textStyle: TextStyle(
          decoration: TextDecoration.lineThrough,
        ),
      );
      break;
    case "dfn":
      continue italics;
    case "em":
      continue italics;
    italics:
    case "i":
      styledElement.style = Style(
        textStyle: TextStyle(fontStyle: FontStyle.italic),
      );
      break;
    case "ins":
      continue underline;
    case "kbd":
      continue monospace;
    case "mark":
      styledElement.style = Style(
        textStyle: TextStyle(
          color: Colors.black,
          backgroundColor: Colors.yellow,
        ),
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
        textStyle: TextStyle(fontSize: 10.0),
      );
      break;
    case "strike":
      continue strikeThrough;
    case "strong":
      continue bold;
    case "sub":
      styledElement.style = Style(
        textStyle: TextStyle(fontSize: 10.0),
        baselineOffset: -1,
      );
      break;
    case "sup":
      styledElement.style = Style(
        textStyle: TextStyle(fontSize: 10.0),
        baselineOffset: 1,
      );
      break;
    case "tt":
      continue monospace;
    underline:
    case "u":
      styledElement.style = Style(
        textStyle: TextStyle(decoration: TextDecoration.underline),
      );
      break;
    case "var":
      continue italics;
  }

  return styledElement;
}

typedef ListCharacter = String Function(int i);