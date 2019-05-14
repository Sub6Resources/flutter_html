import 'package:flutter/widgets.dart';
import 'package:flutter_html/html_elements.dart';
import 'package:html/dom.dart' as dom;

/// A [Block] contains information about a [BlockElement] (width, height, padding, margins)
class Block {
  final EdgeInsets margin;

  final double width;
  final double height;

  const Block({
    this.margin,
    this.width,
    this.height,
  });

  @override
  String toString() {
    return "(${margin != null? "Margin: $margin": ""} ${width != null? "Width: $width": ""}, ${height != null? "Height: $height": ""})";
  }
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

  @override
  String toString() {
    String selfData = "$name [Children: ${children?.length ?? 0}] <Block: $block Style: $style>";
    children?.forEach((child) {
      selfData += ("\n${child.toString()}").replaceAll(RegExp("^", multiLine: true), "-");
    });
    return selfData;
  }
}

BlockElement parseBlockElement(dom.Element node, List<StyledElement> children) {
  BlockElement blockElement = BlockElement(
    name: node.localName,
    children: children,
    block: parseBlockElementBlock(node),
  );

  // Add styles to new block element.
  switch(node.localName) {
    case "h1":
      blockElement.style = Style(textStyle: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold));
      break;
    case "h2":
      blockElement.style = Style(textStyle: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold));
      break;
    case "h3":
      blockElement.style = Style(textStyle: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold));
      break;
    case "h4":
      blockElement.style = Style(textStyle: TextStyle(fontSize: 20.0));
      break;
    case "h5":
      blockElement.style = Style(textStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold));
      break;
    case "h6":
      blockElement.style = Style(textStyle: TextStyle(fontSize: 18.0));
      break;
    case "ol":
      blockElement.style = Style(indentChildren: true, listCharacter: (i) => "$i.");
      break;
    case "ul":
      blockElement.style = Style(indentChildren: true, listCharacter: (i) => ".");
      break;
  }

  return blockElement;
}

Block parseBlockElementBlock(dom.Element element) {
  switch (element.localName) {
    case "div":
      return const Block(
        margin: const EdgeInsets.symmetric(vertical: 14.0),
      );
      break;
    case "p":
      return const Block(
        margin: const EdgeInsets.symmetric(vertical: 14.0),
      );
    default:
      return const Block();
      break;
  }
}
