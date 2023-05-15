import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/src/utils.dart';
import 'package:html/dom.dart' as dom;

/// Handles rendering of text nodes and <br> tags.
class TextBuiltIn extends HtmlExtension {
  const TextBuiltIn();

  @override
  bool matches(ExtensionContext context) {
    return supportedTags.contains(context.elementName) ||
        context.node is dom.Text;
  }

  @override
  Set<String> get supportedTags => {
        "br",
      };

  @override
  StyledElement prepare(
      ExtensionContext context, List<StyledElement> children) {
    if (context.elementName == "br") {
      return TextContentElement(
        text: '\n',
        style: Style(whiteSpace: WhiteSpace.pre),
        element: context.node as dom.Element?,
        node: context.node,
      );
    }

    if (context.node is dom.Text) {
      return TextContentElement(
        text: context.node.text,
        style: Style(),
        element: context.node.parent,
        node: context.node,
      );
    }

    return EmptyContentElement(node: context.node);
  }

  @override
  InlineSpan build(ExtensionContext context,
      Map<StyledElement, InlineSpan> Function() buildChildren) {
    final element = context.styledElement! as TextContentElement;
    return TextSpan(
      style: element.style.generateTextStyle(),
      text: element.text!.transformed(element.style.textTransform),
    );
  }
}
