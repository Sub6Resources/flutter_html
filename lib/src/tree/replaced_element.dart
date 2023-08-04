import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/src/style.dart';
import 'package:flutter_html/src/tree/styled_element.dart';
import 'package:html/dom.dart' as dom;

/// A [ReplacedElement] is a type of [StyledElement] that does not require its [children] to be rendered.
///
/// A [ReplacedElement] may use its children nodes to determine relevant information
/// (e.g. <video>'s <source> tags), but the children nodes will not be saved as [children].
abstract class ReplacedElement extends StyledElement {
  PlaceholderAlignment alignment;

  ReplacedElement({
    required super.name,
    required super.style,
    required super.elementId,
    List<StyledElement>? children,
    required super.node,
    this.alignment = PlaceholderAlignment.aboveBaseline,
  }) : super(children: children ?? []);

  static List<String?> parseMediaSources(List<dom.Element> elements) {
    return elements
        .where((element) => element.localName == 'source')
        .map((element) {
      return element.attributes['src'];
    }).toList();
  }
}

/// [TextContentElement] is a [ContentElement] with plaintext as its content.
class TextContentElement extends ReplacedElement {
  String? get text => node.text;

  TextContentElement({
    required Style style,
    required dom.Text node,
    dom.Element? element,
  }) : super(name: "[text]", style: style, node: node, elementId: "[[No ID]]");

  @override
  String toString() {
    return "\"${text!.replaceAll("\n", "\\n")}\"";
  }
}

class LinebreakContentElement extends ReplacedElement {
  LinebreakContentElement({
    required super.style,
    required super.node,
  }) : super(name: 'br', elementId: "[[No ID]]");
}

class EmptyContentElement extends ReplacedElement {
  EmptyContentElement({required super.node, String name = "empty"})
      : super(name: name, style: Style(), elementId: "[[No ID]]");
}

class RubyElement extends ReplacedElement {
  @override
  dom.Element element;

  RubyElement({
    required this.element,
    required List<StyledElement> children,
    String name = "ruby",
    required super.node,
  }) : super(
            name: name,
            alignment: PlaceholderAlignment.middle,
            style: Style(),
            elementId: element.id,
            children: children);
}
