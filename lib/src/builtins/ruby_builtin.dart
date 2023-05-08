import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;

/// Handles the rendering of rp, rt, and ruby tags.
class RubyBuiltIn extends Extension {
  const RubyBuiltIn();

  @override
  Set<String> get supportedTags => {
    "rp",
    "rt",
    "ruby",
  };

  @override
  StyledElement lex(ExtensionContext context, List<StyledElement> children) {
    if(context.elementName == "ruby") {
      return RubyElement(
        element: context.node as dom.Element,
        children: children,
        node: context.node,
      );
    }

    //TODO we'll probably need specific styling for rp and rt
    return StyledElement(
      children: children,
      elementId: context.id,
      elementClasses: context.classes.toList(),
      name: context.elementName,
      node: context.node,
      style: Style(),
    );
  }

  @override
  InlineSpan parse(ExtensionContext context, Map<StyledElement, InlineSpan> Function() parseChildren) {
    StyledElement? node;
    List<Widget> widgets = <Widget>[];
    final rubySize = context.parser.style['rt']?.fontSize?.value ??
        max(9.0, context.styledElement!.style.fontSize!.value / 2);
    final rubyYPos = rubySize + rubySize / 2;
    List<StyledElement> children = [];
    context.styledElement!.children.forEachIndexed((index, element) {
      if (!((element is TextContentElement) &&
          (element.text ?? "").trim().isEmpty &&
          index > 0 &&
          index + 1 < context.styledElement!.children.length &&
          context.styledElement!.children[index - 1] is! TextContentElement &&
          context.styledElement!.children[index + 1] is! TextContentElement)) {
        children.add(element);
      }
    });
    for (var c in children) {
      if (c.name == "rt" && node != null) {
        final widget = Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.bottomCenter,
              child: Center(
                child: Transform(
                  transform: Matrix4.translationValues(0, -(rubyYPos), 0),
                  child: CssBoxWidget(
                    style: c.style,
                    child: Text(
                      c.element!.innerHtml,
                      style: c.style
                          .generateTextStyle()
                          .copyWith(fontSize: rubySize),
                    ),
                  ),
                ),
              ),
            ),
            CssBoxWidget(
              style: context.styledElement!.style,
              child: node is TextContentElement
                  ? Text(
                node.text?.trim() ?? "",
                style: context.styledElement!.style.generateTextStyle(),
              )
                  : RichText(text: const TextSpan(text: '!rc!')),// TODO was context.parser.parseTree(context, node)),
            ),
          ],
        );
        widgets.add(widget);
      } else {
        node = c;
      }
    }

    return WidgetSpan(
      alignment: (context.styledElement! as ReplacedElement).alignment,
      baseline: TextBaseline.alphabetic,
      child: Padding(
        padding: EdgeInsets.only(top: rubySize),
        child: Wrap(
          key: AnchorKey.of(context.parser.key, context.styledElement),
          runSpacing: rubySize,
          children: widgets
              .map((e) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  textBaseline: TextBaseline.alphabetic,
                  mainAxisSize: MainAxisSize.min,
                  children: [e],
                );
              }).toList(),
        ),
      ),
    );
  }

}