import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/src/utils.dart';
import 'package:html/dom.dart' as dom;

/// Defines the way an anchor ('a') element is lexed and parsed.
class InteractiveElementBuiltIn extends Extension {
  const InteractiveElementBuiltIn();

  @override
  Set<String> get supportedTags => {'a'};

  @override
  StyledElement prepare(
      ExtensionContext context, List<StyledElement> children) {
    if (context.attributes.containsKey('href')) {
      return InteractiveElement(
        name: context.elementName,
        children: children,
        href: context.attributes['href'],
        style: Style(
          color: Colors.blue,
          textDecoration: TextDecoration.underline,
        ),
        node: context.node,
        elementId: context.id,
      );
    }
    // When <a> tag have no href, it must be unclickable and without decoration.
    return StyledElement(
      name: context.elementName,
      children: children,
      style: Style(),
      node: context.node,
      elementId: context.id,
    );
  }

  @override
  InlineSpan build(ExtensionContext context,
      Map<StyledElement, InlineSpan> Function() parseChildren) {
    return TextSpan(
      children: parseChildren().values.map((childSpan) {
        return _processInteractableChild(context, childSpan);
      }).toList(),
    );
  }

  InlineSpan _processInteractableChild(
    ExtensionContext context,
    InlineSpan childSpan,
  ) {
    onTap() => context.parser.internalOnAnchorTap?.call(
          (context.styledElement! as InteractiveElement).href,
          context.attributes,
          (context.node as dom.Element),
        );

    if (childSpan is TextSpan) {
      return TextSpan(
        text: childSpan.text,
        children: childSpan.children
            ?.map((e) => _processInteractableChild(context, e))
            .toList(),
        style: childSpan.style,
        semanticsLabel: childSpan.semanticsLabel,
        recognizer: TapGestureRecognizer()..onTap = onTap,
      );
    } else {
      return WidgetSpan(
        child: MultipleTapGestureDetector(
          onTap: onTap,
          child: GestureDetector(
            key: AnchorKey.of(
                context.parser.key,
                context
                    .styledElement), //TODO this replaced context.key. Does it work?
            onTap: onTap,
            child: (childSpan as WidgetSpan).child,
          ),
        ),
      );
    }
  }
}
