import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/src/anchor.dart';
import 'package:flutter_html/src/html_elements.dart';
import 'package:flutter_html/src/utils.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:html/dom.dart' as dom;

/// A [ReplacedElement] is a type of [StyledElement] that does not require its [children] to be rendered.
///
/// A [ReplacedElement] may use its children nodes to determine relevant information
/// (e.g. <video>'s <source> tags), but the children nodes will not be saved as [children].
abstract class ReplacedElement extends StyledElement {
  PlaceholderAlignment alignment;

  ReplacedElement({
    required String name,
    required Style style,
    required String elementId,
    dom.Element? node,
    this.alignment = PlaceholderAlignment.aboveBaseline,
  }) : super(
            name: name,
            children: [],
            style: style,
            node: node,
            elementId: elementId);

  static List<String?> parseMediaSources(List<dom.Element> elements) {
    return elements
        .where((element) => element.localName == 'source')
        .map((element) {
      return element.attributes['src'];
    }).toList();
  }

  Widget? toWidget(RenderContext context);
}

/// [TextContentElement] is a [ContentElement] with plaintext as its content.
class TextContentElement extends ReplacedElement {
  String? text;
  dom.Node? node;

  TextContentElement({
    required Style style,
    required this.text,
    this.node,
    dom.Element? element,
  }) : super(
            name: "[text]",
            style: style,
            node: element,
            elementId: "[[No ID]]");

  @override
  String toString() {
    return "\"${text!.replaceAll("\n", "\\n")}\"";
  }

  @override
  Widget? toWidget(_) => null;
}

/// [ImageContentElement] is a [ReplacedElement] with an image as its content.
/// https://developer.mozilla.org/en-US/docs/Web/HTML/Element/img
class ImageContentElement extends ReplacedElement {
  final String? src;
  final String? alt;

  ImageContentElement({
    required String name,
    required this.src,
    required this.alt,
    required dom.Element node,
  }) : super(
            name: name,
            style: Style(),
            node: node,
            alignment: PlaceholderAlignment.middle,
            elementId: node.id);

  @override
  Widget toWidget(RenderContext context) {
    for (final entry in context.parser.imageRenders.entries) {
      if (entry.key.call(attributes, element)) {
        final widget = entry.value.call(context, attributes, element);
        return Builder(builder: (buildContext) {
          return GestureDetector(
            key: AnchorKey.of(context.parser.key, this),
            child: widget,
            onTap: () {
              if (MultipleTapGestureDetector.of(buildContext) != null) {
                MultipleTapGestureDetector.of(buildContext)!.onTap?.call();
              }
              context.parser.onImageTap
                  ?.call(src, context, attributes, element);
            },
          );
        });
      }
    }
    return SizedBox(width: 0, height: 0);
  }
}

/// [SvgContentElement] is a [ReplacedElement] with an SVG as its contents.
class SvgContentElement extends ReplacedElement {
  final String data;
  final double? width;
  final double? height;

  SvgContentElement({
    required String name,
    required this.data,
    required this.width,
    required this.height,
    required dom.Element node,
  }) : super(
            name: name,
            style: Style(),
            node: node,
            elementId: node.id,
            alignment: PlaceholderAlignment.middle);

  @override
  Widget toWidget(RenderContext context) {
    return SvgPicture.string(
      data,
      key: AnchorKey.of(context.parser.key, this),
      width: width,
      height: height,
    );
  }
}

class EmptyContentElement extends ReplacedElement {
  EmptyContentElement({String name = "empty"})
      : super(name: name, style: Style(), elementId: "[[No ID]]");

  @override
  Widget? toWidget(_) => null;
}

class RubyElement extends ReplacedElement {
  dom.Element element;

  RubyElement({required this.element, String name = "ruby"})
      : super(
            name: name,
            alignment: PlaceholderAlignment.middle,
            style: Style(),
            elementId: element.id);

  @override
  Widget toWidget(RenderContext context) {
    dom.Node? textNode;
    List<Widget> widgets = <Widget>[];
    //TODO calculate based off of parent font size.
    final rubySize = max(9.0, context.style.fontSize!.size! / 2);
    final rubyYPos = rubySize + rubySize / 2;
    element.nodes.forEach((c) {
      if (c.nodeType == dom.Node.TEXT_NODE) {
        textNode = c;
      }
      if (c is dom.Element) {
        if (c.localName == "rt" && textNode != null) {
          final widget = Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                  alignment: Alignment.bottomCenter,
                  child: Center(
                      child: Transform(
                          transform:
                              Matrix4.translationValues(0, -(rubyYPos), 0),
                          child: Text(c.innerHtml,
                              style: context.style
                                  .generateTextStyle()
                                  .copyWith(fontSize: rubySize))))),
              Container(
                  child: Text(textNode!.text!.trim(),
                      style: context.style.generateTextStyle())),
            ],
          );
          widgets.add(widget);
        }
      }
    });
    return Row(
      key: AnchorKey.of(context.parser.key, this),
      crossAxisAlignment: CrossAxisAlignment.end,
      textBaseline: TextBaseline.alphabetic,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }
}

class MathElement extends ReplacedElement {
  dom.Element element;
  String? texStr;

  MathElement({
    required this.element,
    this.texStr,
    String name = "math",
  }) : super(
            name: name,
            alignment: PlaceholderAlignment.middle,
            style: Style(display: Display.BLOCK),
            elementId: element.id);

  @override
  Widget toWidget(RenderContext context) {
    texStr = parseMathRecursive(element, r'');
    return Container(
        width: context.parser.shrinkWrap
            ? null
            : MediaQuery.of(context.buildContext).size.width,
        child: Math.tex(
          texStr ?? '',
          mathStyle: MathStyle.display,
          textStyle: context.style.generateTextStyle(),
          onErrorFallback: (FlutterMathException e) {
            if (context.parser.onMathError != null) {
              return context.parser.onMathError!
                  .call(texStr ?? '', e.message, e.messageWithType);
            } else {
              return Text(e.message);
            }
          },
        ));
  }

  String parseMathRecursive(dom.Node node, String parsed) {
    if (node is dom.Element) {
      List<dom.Element> nodeList = node.nodes.whereType<dom.Element>().toList();
      if (node.localName == "math" || node.localName == "mrow") {
        nodeList.forEach((element) {
          parsed = parseMathRecursive(element, parsed);
        });
      }
      // note: munder, mover, and munderover do not support placing braces and other
      // markings above/below elements, instead they are treated as super/subscripts for now.
      if ((node.localName == "msup" ||
              node.localName == "msub" ||
              node.localName == "munder" ||
              node.localName == "mover") &&
          nodeList.length == 2) {
        parsed = parseMathRecursive(nodeList[0], parsed);
        parsed = parseMathRecursive(
                nodeList[1],
                parsed +
                    "${node.localName == "msup" || node.localName == "mover" ? "^" : "_"}{") +
            "}";
      }
      if ((node.localName == "msubsup" || node.localName == "munderover") &&
          nodeList.length == 3) {
        parsed = parseMathRecursive(nodeList[0], parsed);
        parsed = parseMathRecursive(nodeList[1], parsed + "_{") + "}";
        parsed = parseMathRecursive(nodeList[2], parsed + "^{") + "}";
      }
      if (node.localName == "mfrac" && nodeList.length == 2) {
        parsed = parseMathRecursive(nodeList[0], parsed + r"\frac{") + "}";
        parsed = parseMathRecursive(nodeList[1], parsed + "{") + "}";
      }
      // note: doesn't support answer & intermediate steps
      if (node.localName == "mlongdiv" && nodeList.length == 4) {
        parsed = parseMathRecursive(nodeList[0], parsed);
        parsed = parseMathRecursive(nodeList[2], parsed + r"\overline{)") + "}";
      }
      if (node.localName == "msqrt" && nodeList.length == 1) {
        parsed = parseMathRecursive(nodeList[0], parsed + r"\sqrt{") + "}";
      }
      if (node.localName == "mroot" && nodeList.length == 2) {
        parsed = parseMathRecursive(nodeList[1], parsed + r"\sqrt[") + "]";
        parsed = parseMathRecursive(nodeList[0], parsed + "{") + "}";
      }
      if (node.localName == "mi" ||
          node.localName == "mn" ||
          node.localName == "mo") {
        if (mathML2Tex.keys.contains(node.text.trim())) {
          parsed = parsed +
              mathML2Tex[
                  mathML2Tex.keys.firstWhere((e) => e == node.text.trim())]!;
        } else if (node.text.startsWith("&") && node.text.endsWith(";")) {
          parsed = parsed +
              node.text
                  .trim()
                  .replaceFirst("&", r"\")
                  .substring(0, node.text.trim().length - 1);
        } else {
          parsed = parsed + node.text.trim();
        }
      }
    }
    return parsed;
  }
}

ReplacedElement parseReplacedElement(
  dom.Element element,
) {
  switch (element.localName) {
    case "br":
      return TextContentElement(
        text: "\n",
        style: Style(whiteSpace: WhiteSpace.PRE),
        element: element,
        node: element,
      );
    case "svg":
      return SvgContentElement(
        name: "svg",
        data: element.outerHtml,
        width: double.tryParse(element.attributes['width'] ?? ""),
        height: double.tryParse(element.attributes['height'] ?? ""),
        node: element,
      );
    case "ruby":
      return RubyElement(
        element: element,
      );
    case "math":
      return MathElement(
        element: element,
      );
    default:
      return EmptyContentElement(
          name: element.localName == null ? "[[No Name]]" : element.localName!);
  }
}
