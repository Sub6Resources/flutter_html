import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_html/src/css_parser.dart';
import 'package:flutter_html/style.dart';
import 'package:html/dom.dart' as dom;
//TODO(Sub6Resources): don't use the internal code of the html package as it may change unexpectedly.
//ignore: implementation_imports
import 'package:html/src/query_selector.dart';
import 'package:list_counter/list_counter.dart';

/// A [StyledElement] applies a style to all of its children.
class StyledElement {
  final String name;
  final String elementId;
  final List<String> elementClasses;
  List<StyledElement> children;
  Style style;
  final dom.Element? _node;
  final ListQueue<Counter> counters = ListQueue<Counter>();

  StyledElement({
    this.name = "[[No name]]",
    this.elementId = "[[No ID]]",
    this.elementClasses = const [],
    required this.children,
    required this.style,
    required dom.Element? node,
  }) : _node = node;

  bool matchesSelector(String selector) =>
      (_node != null && matches(_node!, selector)) || name == selector;

  Map<String, String> get attributes =>
      _node?.attributes.map((key, value) {
        return MapEntry(key.toString(), value);
      }) ??
      <String, String>{};

  dom.Element? get element => _node;

  @override
  String toString() {
    String selfData =
        "[$name] ${children.length} ${elementClasses.isNotEmpty == true ? 'C:${elementClasses.toString()}' : ''}${elementId.isNotEmpty == true ? 'ID: $elementId' : ''}";
    for (var child in children) {
      selfData += ("\n${child.toString()}")
          .replaceAll(RegExp("^", multiLine: true), "-");
    }
    return selfData;
  }
}

StyledElement parseStyledElement(
  dom.Element element,
  List<StyledElement> children,
) {
  StyledElement styledElement = StyledElement(
    name: element.localName!,
    elementId: element.id,
    elementClasses: element.classes.toList(),
    children: children,
    node: element,
    style: Style(),
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
    case "article":
      styledElement.style = Style(
        display: Display.block,
      );
      break;
    case "aside":
      styledElement.style = Style(
        display: Display.block,
      );
      break;
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
        direction: textDirection,
      );
      break;
    case "big":
      styledElement.style = Style(
        fontSize: FontSize.larger,
      );
      break;
    case "blockquote":
      //TODO(Sub6Resources) this is a workaround for collapsing margins. Remove.
      if (element.parent!.localName == "blockquote") {
        styledElement.style = Style(
          margin: Margins.only(left: 40.0, right: 40.0, bottom: 14.0),
          display: Display.block,
        );
      } else {
        styledElement.style = Style(
          margin: Margins.symmetric(horizontal: 40.0, vertical: 14.0),
          display: Display.block,
        );
      }
      break;
    case "body":
      styledElement.style = Style(
        margin: Margins.all(8.0),
        display: Display.block,
      );
      break;
    case "center":
      styledElement.style = Style(
        alignment: Alignment.center,
        display: Display.block,
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
    case "dd":
      styledElement.style = Style(
        margin: Margins.only(left: 40.0),
        display: Display.block,
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
    case "div":
      styledElement.style = Style(
        margin: Margins.all(0),
        display: Display.block,
      );
      break;
    case "dl":
      styledElement.style = Style(
        margin: Margins.symmetric(vertical: 14.0),
        display: Display.block,
      );
      break;
    case "dt":
      styledElement.style = Style(
        display: Display.block,
      );
      break;
    case "em":
      continue italics;
    case "figcaption":
      styledElement.style = Style(
        display: Display.block,
      );
      break;
    case "figure":
      styledElement.style = Style(
        margin: Margins.symmetric(vertical: 14.0, horizontal: 40.0),
        display: Display.block,
      );
      break;
    case "footer":
      styledElement.style = Style(
        display: Display.block,
      );
      break;
    case "font":
      styledElement.style = Style(
        color: element.attributes['color'] != null
            ? element.attributes['color']!.startsWith("#")
                ? ExpressionMapping.stringToColor(element.attributes['color']!)
                : ExpressionMapping.namedColorToColor(
                    element.attributes['color']!)
            : null,
        fontFamily: element.attributes['face']?.split(",").first,
        fontSize: element.attributes['size'] != null
            ? numberToFontSize(element.attributes['size']!)
            : null,
      );
      break;
    case "h1":
      styledElement.style = Style(
        fontSize: FontSize(2, Unit.em),
        fontWeight: FontWeight.bold,
        margin: Margins.symmetric(vertical: 0.67, unit: Unit.em),
        display: Display.block,
      );
      break;
    case "h2":
      styledElement.style = Style(
        fontSize: FontSize(1.5, Unit.em),
        fontWeight: FontWeight.bold,
        margin: Margins.symmetric(vertical: 0.83, unit: Unit.em),
        display: Display.block,
      );
      break;
    case "h3":
      styledElement.style = Style(
        fontSize: FontSize(1.17, Unit.em),
        fontWeight: FontWeight.bold,
        margin: Margins.symmetric(vertical: 1, unit: Unit.em),
        display: Display.block,
      );
      break;
    case "h4":
      styledElement.style = Style(
        fontWeight: FontWeight.bold,
        margin: Margins.symmetric(vertical: 1.33, unit: Unit.em),
        display: Display.block,
      );
      break;
    case "h5":
      styledElement.style = Style(
        fontSize: FontSize(0.83, Unit.em),
        fontWeight: FontWeight.bold,
        margin: Margins.symmetric(vertical: 1.67, unit: Unit.em),
        display: Display.block,
      );
      break;
    case "h6":
      styledElement.style = Style(
        fontSize: FontSize(0.67, Unit.em),
        fontWeight: FontWeight.bold,
        margin: Margins.symmetric(vertical: 2.33, unit: Unit.em),
        display: Display.block,
      );
      break;
    case "header":
      styledElement.style = Style(
        display: Display.block,
      );
      break;
    case "hr":
      styledElement.style = Style(
        margin: Margins(
          top: Margin(0.5, Unit.em),
          bottom: Margin(0.5, Unit.em),
          left: Margin.auto(),
          right: Margin.auto(),
        ),
        border: Border.all(),
        display: Display.block,
      );
      break;
    case "html":
      styledElement.style = Style(
        display: Display.block,
      );
      break;
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
    case "li":
      styledElement.style = Style(
        display: Display.listItem,
      );
      break;
    case "main":
      styledElement.style = Style(
        display: Display.block,
      );
      break;
    case "mark":
      styledElement.style = Style(
        color: Colors.black,
        backgroundColor: Colors.yellow,
      );
      break;
    case "nav":
      styledElement.style = Style(
        display: Display.block,
      );
      break;
    case "noscript":
      styledElement.style = Style(
        display: Display.block,
      );
      break;
    case "ol":
    case "ul":
      styledElement.style = Style(
        display: Display.block,
        listStyleType: element.localName == "ol"
            ? ListStyleType.decimal
            : ListStyleType.disc,
        padding: const EdgeInsets.only(left: 40),
      );
      break;
    case "p":
      styledElement.style = Style(
        margin: Margins.symmetric(vertical: 1, unit: Unit.em),
        display: Display.block,
      );
      break;
    case "pre":
      styledElement.style = Style(
        fontFamily: 'monospace',
        margin: Margins.symmetric(vertical: 14.0),
        whiteSpace: WhiteSpace.pre,
        display: Display.block,
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
    case "section":
      styledElement.style = Style(
        display: Display.block,
      );
      break;
    case "small":
      styledElement.style = Style(
        fontSize: FontSize.smaller,
      );
      break;
    case "strike":
      continue strikeThrough;
    case "strong":
      continue bold;
    case "sub":
      styledElement.style = Style(
        fontSize: FontSize.smaller,
        verticalAlign: VerticalAlign.sub,
      );
      break;
    case "sup":
      styledElement.style = Style(
        fontSize: FontSize.smaller,
        verticalAlign: VerticalAlign.sup,
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

FontSize numberToFontSize(String num) {
  switch (num) {
    case "1":
      return FontSize.xxSmall;
    case "2":
      return FontSize.xSmall;
    case "3":
      return FontSize.small;
    case "4":
      return FontSize.medium;
    case "5":
      return FontSize.large;
    case "6":
      return FontSize.xLarge;
    case "7":
      return FontSize.xxLarge;
  }
  if (num.startsWith("+")) {
    final relativeNum = double.tryParse(num.substring(1)) ?? 0;
    return numberToFontSize((3 + relativeNum).toString());
  }
  if (num.startsWith("-")) {
    final relativeNum = double.tryParse(num.substring(1)) ?? 0;
    return numberToFontSize((3 - relativeNum).toString());
  }
  return FontSize.medium;
}

extension DeepCopy on ListQueue<Counter> {
  ListQueue<Counter> deepCopy() {
    return ListQueue<Counter>.from(map((counter) {
      return Counter(counter.name, counter.value);
    }));
  }
}
