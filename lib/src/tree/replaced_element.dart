import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/src/processing/Node_order.dart';
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
    StyledElement? parent,
    List<StyledElement>? children,
    required super.node,
    required super.nodeToIndex,
    this.alignment = PlaceholderAlignment.aboveBaseline,
  }) : super(parent: parent, children: children ?? []);

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
    required super.nodeToIndex,
    dom.Element? element,
  }) : super(name: "[text]", style: style, node: node, elementId: "[[No ID]]");

  /// splits this [TextContentElement] at the indexes and makes any necessary changes to the
  /// tree. Returns the [TextContentElement]'s acted on.
  /// [start] inclusive, [end] exclusive
  List<TextContentElement> split(int start, [int? end]) {
    if (text == null) {
      assert(false);
      return [this];
    }
    int length = text!.length;
    if (start >= length) {
      assert(false);
      return [this];
    }
    final text1 = node.text!.substring(0, start);
    final String text2;
    final String? text3;
    if (end == null) {
      text2 = node.text!.substring(start);
      text3 = null;
    } else {
      if (end < length) {
        text2 = node.text!.substring(start, end);
        text3 = node.text!.substring(end);
      } else {
        text2 = node.text!.substring(start, end);
        text3 = null;
      }
    }
    final dom.Text newNodeBefore = dom.Text(text1);
    final TextContentElement newBeforeTextContentElement =
        _copyWithNoParent(node: newNodeBefore);
    insertBefore(newBeforeTextContentElement);
    if (text3 == null) {
      node.text = text2;
      return [newBeforeTextContentElement, this];
    } else {
      final dom.Text newNodeBefore2 = dom.Text(text2);
      final TextContentElement newBeforeTextContentElement2 =
          _copyWithNoParent(node: newNodeBefore2);
      insertBefore(newBeforeTextContentElement2);
      node.text = text3;
      return [newBeforeTextContentElement, newBeforeTextContentElement2, this];
    }
  }

  /// Inserts the element before, assumes the new element and its node have not been connected yet
  void insertBefore(StyledElement element) {
    assert(node.parent != null && element.parent == null);
    assert(parent != null && element.parent == null);
    node.parentNode!.insertBefore(element.node, node);
    parent!.children.insert(parent!.children.indexOf(this), element);
    element.parent = parent!;
    NodeOrderProcessing.reIndexNodeToIndexMapWith(nodeToIndex, element.node);
    assert(nodeToIndex[element.node]! + 1 == nodeToIndex[node]!);
  }

  /// Copies the current element, but without the parent
  TextContentElement _copyWithNoParent({
    Style? style,
    dom.Text? node,
    dom.Element? element,
  }) {
    return TextContentElement(
        style: style ?? this.style.copyWith(),
        node: node ?? this.node as dom.Text,
        nodeToIndex: nodeToIndex);
  }

  @override
  String toString() {
    return "\"${text!.replaceAll("\n", "\\n")}\"";
  }
}

class LinebreakContentElement extends ReplacedElement {
  LinebreakContentElement({
    required super.style,
    required super.node,
    required super.nodeToIndex,
  }) : super(name: 'br', elementId: "[[No ID]]");
}

class EmptyContentElement extends ReplacedElement {
  EmptyContentElement(
      {required super.node, required super.nodeToIndex, String name = "empty"})
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
    required super.nodeToIndex,
  }) : super(
            name: name,
            alignment: PlaceholderAlignment.middle,
            style: Style(),
            elementId: element.id,
            children: children);
}
