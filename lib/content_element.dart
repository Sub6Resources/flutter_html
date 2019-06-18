import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/html_elements.dart';
import 'package:flutter_html/style.dart';
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

  Widget toWidget();
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

  @override
  Widget toWidget() => null;
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

  @override
  Widget toWidget() {
    if(src == null) return Text(alt ?? "");
    if(src.startsWith("data:image") && src.contains("base64,")) {
      return Image.memory(base64.decode(src.split("base64,")[1].trim()));
    } else {
      return Image.network(src);
    }
    //TODO(Sub6Resources): alt text
    //TODO(Sub6Resources): precacheImage
  }
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

  @override
  Widget toWidget() {
    //TODO(Sub6Resources)
    return Container(padding: const EdgeInsets.all(24), child: Text("AUDIO"));
  }
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

  @override
  Widget toWidget() {
    //TODO(Sub6Resources)
    return Container(padding: const EdgeInsets.all(24), child: Text("AUDIO"));
  }
}

class EmptyContentElement extends ContentElement {
  EmptyContentElement({String name = "empty"}) : super(name: name);

  @override
  Widget toWidget() => null;
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
