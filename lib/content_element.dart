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

  static List<String> parseContentSources(List<dom.Element> elements) {
    return elements
        .where((element) => element.localName == 'source')
        .map((element) {
      return element.attributes['src'];
    }).toList();
  }
}

/// [TextContentElement] is a [ContentElement] with plaintext as its content.
class TextContentElement extends ContentElement {
  String text;

  TextContentElement({
    Style style,
    this.text,
  }) : super(name: "text", style: style);

  @override
  String toString() {
    return "\"${text.replaceAll("\n", "\\n")}\"";
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

/// [AudioContentElement] is a [ContentElement] with an audio file as its content.
class AudioContentElement extends ContentElement {
  final List<String> src;
  final bool showControls;
  final bool autoplay;
  final bool loop;
  final bool muted;

  AudioContentElement({
    String name,
    Style style,
    this.src,
    this.showControls,
    this.autoplay,
    this.loop,
    this.muted,
  }) : super(name: name, style: style);
}

/// [VideoContentElement] is a [ContentElement] with a video file as its content.
class VideoContentElement extends ContentElement {
  final List<String> src;
  final String poster;
  final bool showControls;
  final bool autoplay;
  final bool loop;
  final bool muted;

  VideoContentElement({
    String name,
    Style style,
    this.src,
    this.poster,
    this.showControls,
    this.autoplay,
    this.loop,
    this.muted,
  }) : super(name: name, style: style);
}

class EmptyContentElement extends ContentElement {
  EmptyContentElement({String name = "empty"}) : super(name: name);
}

ContentElement parseContentElement(dom.Element element) {
  switch (element.localName) {
    case "audio":
      return AudioContentElement(
        name: "audio",
        src: ContentElement.parseContentSources(element.children),
        showControls: element.attributes['controls'] != null,
        loop: element.attributes['loop'] != null,
        autoplay: element.attributes['autoplay'] != null,
        muted: element.attributes['muted'] != null,
      );
    case "img":
      return ImageContentElement(
        name: "img",
        src: element.attributes['href'],
        alt: element.attributes['alt'],
      );
    case "video":
      return VideoContentElement(
        name: "video",
        src: ContentElement.parseContentSources(element.children),
        poster: element.attributes['poster'],
        showControls: element.attributes['controls'] != null,
        loop: element.attributes['loop'] != null,
        autoplay: element.attributes['autoplay'] != null,
        muted: element.attributes['muted'] != null,
      );
    default:
      return EmptyContentElement(name: element.localName);
  }
}
