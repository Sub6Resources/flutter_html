import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/html_elements.dart';
import 'package:flutter_html/style.dart';
import 'package:html/dom.dart' as dom;

/// A [Block] contains information about a [BlockElement] (width, height, padding, margins)
class Block {
  EdgeInsets margin;
  double width;
  double height;
  Border border;
  Alignment alignment;
  Color backgroundColor;

  Block({
    this.margin,
    this.width,
    this.height,
    this.border,
    this.alignment = Alignment.centerLeft,
    this.backgroundColor,
  });

  @override
  String toString() {
    return "(${margin != null ? "Margin: $margin" : ""} ${width != null ? "Width: $width" : ""}, ${height != null ? "Height: $height" : ""})";
  }

  Block merge(Block other) {
    if (other == null) return this;

    return copyWith(
      margin: other.margin,
      width: other.width,
      height: other.height,
      border: other.border,
      alignment: other.alignment,
      backgroundColor: other.backgroundColor,
    );
  }

  Block copyWith({
    EdgeInsets margin,
    double width,
    double height,
    Border border,
    Alignment alignment,
    Color backgroundColor,
  }) {
    return Block(
      margin: margin ?? this.margin,
      width: width ?? this.width,
      height: height ?? this.height,
      border: border ?? this.border,
      alignment: alignment ?? this.alignment,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }
}

/// A [BlockElement] is a [StyledElement] that wraps before and after the its [children].
///
/// A [BlockElement] may have a margin/padding or be a set width/height.
class BlockElement extends StyledElement {
  BlockElement({
    String name,
    List<StyledElement> children,
    Style style,
  }) : super(name: name, children: children, style: style);

}

BlockElement parseBlockElement(dom.Element node, List<StyledElement> children) {
  BlockElement blockElement = BlockElement(
    name: node.localName,
    children: children,
  );

  // Add styles to new block element.
  switch (node.localName) {
    case "h1":
      blockElement.style = Style(
          textStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold));
      break;
    case "h2":
      blockElement.style = Style(
          textStyle: TextStyle(fontSize: 21.0, fontWeight: FontWeight.bold));
      break;
    case "h3":
      blockElement.style = Style(
          textStyle: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold));
      break;
    case "h4":
      blockElement.style = Style(
          textStyle: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold));
      break;
    case "h5":
      blockElement.style = Style(
          textStyle: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold));
      break;
    case "h6":
      blockElement.style = Style(
          textStyle: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold));
      break;
    case "pre":
      blockElement.style = Style(
          textStyle: TextStyle(fontFamily: 'Monospace'),
          preserveWhitespace: true);
      break;
    default:
      blockElement.style = Style();
  }

  blockElement.style.block = parseBlockElementBlock(node);

  return blockElement;
}

Block parseBlockElementBlock(dom.Element element) {
  switch (element.localName) {
    case "blockquote":
      if (element.parent.localName == "blockquote") {
        return Block(
          margin: const EdgeInsets.only(left: 40.0, right: 40.0, bottom: 14.0),
        );
      }
      return Block(
        margin: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 14.0),
      );
    case "body":
      return Block(
        margin: const EdgeInsets.all(8.0),
      );
    case "center":
      return Block(
        alignment: Alignment.center,
      );
    case "dd":
      return Block(
        margin: const EdgeInsets.only(left: 40.0),
      );
    case "div":
      return Block(
        margin: const EdgeInsets.all(0),
      );
    case "dl":
      return Block(
        margin: const EdgeInsets.symmetric(vertical: 14.0),
      );
    case "figure":
      return Block(
        margin: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 40.0),
      );
    case "h1":
      return Block(
        margin: const EdgeInsets.symmetric(vertical: 18.67),
      );
    case "h2":
      return Block(
        margin: const EdgeInsets.symmetric(vertical: 17.5),
      );
    case "h3":
      return Block(
        margin: const EdgeInsets.symmetric(vertical: 16.5),
      );
    case "h4":
      return Block(
        margin: const EdgeInsets.symmetric(vertical: 18.5),
      );
    case "h5":
      return Block(
        margin: const EdgeInsets.symmetric(vertical: 19.25),
      );
    case "h6":
      return Block(
        margin: const EdgeInsets.symmetric(vertical: 22),
      );
    case "hr":
      return Block(
        margin: const EdgeInsets.symmetric(vertical: 7.0),
        width: double.infinity,
        border: Border(bottom: BorderSide(width: 1.0)),
      );
    case "ol":
    case "ul":
      if (element.parent.localName == "li") {
        return Block(
          margin: const EdgeInsets.only(left: 30.0),
        );
      }
      return Block(
        margin: const EdgeInsets.only(left: 30.0, top: 14.0, bottom: 14.0),
      );
    case "p":
      return Block(
        margin: const EdgeInsets.symmetric(vertical: 14.0),
      );
    case "pre":
      return Block(
        margin: const EdgeInsets.symmetric(vertical: 14.0),
      );
    default:
      return Block();
  }
}
