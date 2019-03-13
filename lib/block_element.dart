import 'package:flutter_html/html_elements.dart';
import 'package:html/dom.dart' as dom;

/// A [Block] contains information about a [BlockElement] (width, height, padding, margins)
class Block {
  final double marginLeft;
  final double marginTop;
  final double marginRight;
  final double marginBottom;

  final double width;
  final double height;

  Block({
    this.marginLeft,
    this.marginTop,
    this.marginRight,
    this.marginBottom,
    this.width,
    this.height,
  });
}

/// A [BlockElement] is a [StyledElement] that wraps before and after the its [children].
///
/// A [BlockElement] may have a margin/padding or be a set width/height.
class BlockElement extends StyledElement {
  final Block block;

  BlockElement({
    String name,
    List<StyledElement> children,
    Style style,
    this.block,
  }) : super(name: name, children: children, style: style);
}

Block parseBlockElementBlock(dom.Element element) {
  switch (element.localName) {
    case "div":
      return Block(
        marginTop: 14,
        marginBottom: 14,
      );
      break;
    default:
      return Block();
      break;
  }
}
