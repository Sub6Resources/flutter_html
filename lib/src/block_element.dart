import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/src/html_elements.dart';
import 'package:flutter_html/style.dart';
import 'package:html/dom.dart' as dom;

/// A [Block] contains information about a [Display.BLOCK] element (width, height, padding, margins)
class Block {
  double width;
  double height;
  Border border;
  Alignment alignment;

  Block({
    this.width,
    this.height,
    this.border,
    this.alignment = Alignment.centerLeft,
  });

  @override
  String toString() {
    return "(${width != null ? "Width: $width" : ""}, ${height != null ? "Height: $height" : ""})";
  }

  Block merge(Block other) {
    if (other == null) return this;

    return copyWith(
      width: other.width,
      height: other.height,
      border: other.border,
      alignment: other.alignment,
    );
  }

  Block copyWith({
    double width,
    double height,
    Border border,
    Alignment alignment,
  }) {
    return Block(
      width: width ?? this.width,
      height: height ?? this.height,
      border: border ?? this.border,
      alignment: alignment ?? this.alignment,
    );
  }
}

StyledElement parseBlockElement(
    dom.Element node, List<StyledElement> children) {
  StyledElement blockElement = StyledElement(
    name: node.localName,
    children: children,
    node: node,
  );

  // Add styles to new block element.
  switch (node.localName) {
    case "blockquote":
      //TODO(Sub6Resources) this is a workaround for collapsing margins. Remove.
      if (node.parent.localName == "blockquote") {
        blockElement.style = Style(
          margin: const EdgeInsets.only(left: 40.0, right: 40.0, bottom: 14.0),
        );
      } else {
        blockElement.style = Style(
          margin: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 14.0),
        );
      }
      break;
    case "body":
      blockElement.style = Style(margin: EdgeInsets.all(8.0));
      break;
    case "dd":
      blockElement.style = Style(margin: EdgeInsets.only(left: 40.0));
      break;
    case "div":
      blockElement.style = Style(margin: EdgeInsets.all(0));
      break;
    case "dl":
      blockElement.style = Style(margin: EdgeInsets.symmetric(vertical: 14.0));
      break;
    case "figure":
      blockElement.style =
          Style(margin: EdgeInsets.symmetric(vertical: 14.0, horizontal: 40.0));
      break;
    case "h1":
      blockElement.style = Style(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
        margin: EdgeInsets.symmetric(vertical: 18.67),
      );
      break;
    case "h2":
      blockElement.style = Style(
        fontSize: 21.0,
        fontWeight: FontWeight.bold,
        margin: EdgeInsets.symmetric(vertical: 17.5),
      );
      break;
    case "h3":
      blockElement.style = Style(
        fontSize: 16.5,
        fontWeight: FontWeight.bold,
        margin: EdgeInsets.symmetric(vertical: 16.5),
      );
      break;
    case "h4":
      blockElement.style = Style(
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
        margin: EdgeInsets.symmetric(vertical: 18.5),
      );
      break;
    case "h5":
      blockElement.style = Style(
        fontSize: 11.5,
        fontWeight: FontWeight.bold,
        margin: EdgeInsets.symmetric(vertical: 19.25),
      );
      break;
    case "h6":
      blockElement.style = Style(
        fontSize: 9.5,
        fontWeight: FontWeight.bold,
        margin: EdgeInsets.symmetric(vertical: 22),
      );
      break;
    case "hr":
      blockElement.style = Style(
        margin: EdgeInsets.symmetric(vertical: 7.0),
      );
      break;
    case "ol":
    case "ul":
      if (node.parent.localName == "li") {
        blockElement.style = Style(margin: EdgeInsets.only(left: 30.0));
      } else {
        blockElement.style =
            Style(margin: EdgeInsets.only(left: 30.0, top: 14.0, bottom: 14.0));
      }
      break;
    case "p":
      blockElement.style = Style(margin: EdgeInsets.symmetric(vertical: 14.0));
      break;
    case "pre":
      blockElement.style = Style(
        fontFamily: 'Monospace',
        margin: EdgeInsets.symmetric(vertical: 14.0),
        preserveWhitespace: true,
      );
      break;
    default:
      blockElement.style = Style();
  }

  blockElement.style.block = parseBlockElementBlock(node);
  blockElement.style.display = Display.BLOCK;

  return blockElement;
}

Block parseBlockElementBlock(dom.Element element) {
  switch (element.localName) {
    case "center":
      return Block(
        alignment: Alignment.center,
      );
    case "hr":
      return Block(
        width: double.infinity,
        border: Border(bottom: BorderSide(width: 1.0)),
      );
    default:
      return Block();
  }
}
