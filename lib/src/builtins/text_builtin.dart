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
      return LinebreakContentElement(
        style: Style(),
        node: context.node,
      );
    }

    if (context.node is dom.Text) {
      return TextContentElement(
        style: Style(),
        element: context.node.parent,
        node: context.node as dom.Text,
      );
    }

    return EmptyContentElement(node: context.node);
  }

  @override
  InlineSpan build(ExtensionContext context) {
    if (context.styledElement is LinebreakContentElement) {
      return WidgetSpan(
        child: const SizedBox.shrink(),
        style: context.styledElement!.style.generateTextStyle(),
      );
    }

    final element = context.styledElement! as TextContentElement;
    return TextSpan(
      style: element.style.generateTextStyle(),
      text: element.text!.transformed(element.style.textTransform),
    );
  }
}
