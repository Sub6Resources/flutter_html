import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/src/html_elements.dart';
import 'package:flutter_html/style.dart';
import 'package:html/dom.dart' as dom;

/// A [ReplacedElement] is a type of [StyledElement] that renders none of its [children].
///
/// A [ContentElement] may use its children nodes to determine relevant information
/// (e.g. <video>'s <source> tags), but the children nodes will not be saved as [children].
abstract class ReplacedElement extends StyledElement {
  ReplacedElement({
    String name,
    Style style,
    dom.Element node,
  }) : super(name: name, children: null, style: style, node: node);

  static List<String> parseContentSources(List<dom.Element> elements) {
    return elements
        .where((element) => element.localName == 'source')
        .map((element) {
      return element.attributes['src'];
    }).toList();
  }

  Widget toWidget();
}

/// [TextContentElement] is a [ContentElement] with plaintext as its content.
class TextContentElement extends ReplacedElement {
  String text;

  TextContentElement({
    Style style,
    this.text,
  }) : super(name: "text", style: style);

  @override
  String toString() {
    return "\"${text.replaceAll("\n", "\\n")}\"";
  }

  @override
  Widget toWidget() => null;
}

/// [ImageContentElement] is a [ReplacedElement] with an image as its content.
/// https://developer.mozilla.org/en-US/docs/Web/HTML/Element/img
class ImageContentElement extends ReplacedElement {
  final String src;
  final String alt;

  ImageContentElement({
    String name,
    Style style,
    this.src,
    this.alt,
    dom.Element node,
  }) : super(name: name, style: style, node: node);

  @override
  Widget toWidget() {
    if (src == null) return Text(alt ?? "");
    if (src.startsWith("data:image") && src.contains("base64,")) {
      return Image.memory(base64.decode(src.split("base64,")[1].trim()));
    } else {
      return Image.network(src);
    }
    //TODO(Sub6Resources): alt text
    //TODO(Sub6Resources): precacheImage
  }
}

/// [AudioContentElement] is a [ContentElement] with an audio file as its content.
class AudioContentElement extends ReplacedElement {
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
    dom.Element node,
  }) : super(name: name, style: style, node: node);

  @override
  Widget toWidget() {
    //TODO(Sub6Resources)
    return Container(padding: const EdgeInsets.all(24), child: Text("AUDIO"));
  }
}

/// [VideoContentElement] is a [ContentElement] with a video file as its content.
class VideoContentElement extends ReplacedElement {
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
    dom.Element node,
  }) : super(name: name, style: style, node: node);

  @override
  Widget toWidget() {
    //TODO(Sub6Resources)
    return Container(padding: const EdgeInsets.all(24), child: Text("AUDIO"));
  }
}

class EmptyContentElement extends ReplacedElement {
  EmptyContentElement({String name = "empty"}) : super(name: name);

  @override
  Widget toWidget() => null;
}

ReplacedElement parseReplacedElement(dom.Element element) {
  switch (element.localName) {
    case "audio":
      return AudioContentElement(
        name: "audio",
        src: ReplacedElement.parseContentSources(element.children),
        showControls: element.attributes['controls'] != null,
        loop: element.attributes['loop'] != null,
        autoplay: element.attributes['autoplay'] != null,
        muted: element.attributes['muted'] != null,
        node: element,
      );
    case "br":
      return TextContentElement(
        text: "\n",
        style: Style(preserveWhitespace: true),
      );
    case "img":
      return ImageContentElement(
        name: "img",
        src: element.attributes['src'],
        alt: element.attributes['alt'],
        node: element,
      );
    case "video":
      return VideoContentElement(
        name: "video",
        src: ReplacedElement.parseContentSources(element.children),
        poster: element.attributes['poster'],
        showControls: element.attributes['controls'] != null,
        loop: element.attributes['loop'] != null,
        autoplay: element.attributes['autoplay'] != null,
        muted: element.attributes['muted'] != null,
        node: element,
      );
    default:
      return EmptyContentElement(name: element.localName);
  }
}
