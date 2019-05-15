import 'package:flutter_html/html_elements.dart';
import 'package:html/dom.dart' as dom;

/// A [ContentElement] is a type of [StyledElement] that renders none of its [children].
///
/// A [ContentElement] may use its children nodes to determine relevant information
/// (e.g. <video>'s <source> tags), but the children nodes will not be saved as [children].
abstract class ContentElement extends StyledElement {
  ContentElement({
    String name,
    Style style,
  }) : super(name: name, children: null, style: style);
}

/// [TextContentElement] is a [ContentElement] with plaintext as its content.
class TextContentElement extends ContentElement {
  final String text;

  TextContentElement({
    Style style,
    this.text,
  }) : super(name: "text", style: style);

  @override
  String toString() {
    return "\"${text.replaceAll("\n", "\\n").trim()}\"";
  }
}

/// [ImageContentElement] is a [ContentElement] with an image as its content.
class ImageContentElement extends ContentElement {
  final String src;
  final String alt;

  ImageContentElement({
    String name,
    Style style,
    this.src,
    this.alt,
  }) : super(name: name, style: style);
}

class EmptyContentElement extends ContentElement {
  EmptyContentElement({
    String name = "empty"
  }): super(
    name: name,
  );
}

ContentElement parseContentElement(dom.Element element) {
  switch (element.localName) {
    case "img":
      return ImageContentElement(
        name: "img",
        src: element.attributes['href'],
        alt: element.attributes['alt'],
      );
      break;
    default:
      return EmptyContentElement(name: element.localName);
  }
}
