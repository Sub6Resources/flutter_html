import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/src/utils.dart';
import 'package:html/dom.dart' as dom;

/// Defines the way an anchor ('a') element is lexed and parsed.
///
/// An `<a>` element with no `href` attribute is not interactive and is thus
/// not handled by this BuiltIn.
class InteractiveElementBuiltIn extends HtmlExtension {
  const InteractiveElementBuiltIn();

  @override
  Set<String> get supportedTags => {'a'};

  @override
  bool matches(ExtensionContext context) {
    return supportedTags.contains(context.elementName) &&
        context.attributes.containsKey("href");
  }

  @override
  StyledElement prepare(
      ExtensionContext context, List<StyledElement> children) {
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

  @override
  InlineSpan build(ExtensionContext context) {
    return TextSpan(
      children: context.inlineSpanChildren!.map((childSpan) {
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
        recognizer: TapGestureRecognizer()..onTap = onTap,
        style: childSpan.style,
        semanticsLabel: childSpan.semanticsLabel,
        locale: childSpan.locale,
        mouseCursor: childSpan.mouseCursor,
        onEnter: childSpan.onEnter,
        onExit: childSpan.onExit,
        spellOut: childSpan.spellOut,
      );
    } else {
      return WidgetSpan(
        alignment: context.style!.verticalAlign
            .toPlaceholderAlignment(context.style!.display),
        baseline: TextBaseline.alphabetic,
        child: MultipleTapGestureDetector(
          onTap: onTap,
          child: GestureDetector(
            key: AnchorKey.of(context.parser.key, context.styledElement),
            onTap: onTap,
            child: (childSpan as WidgetSpan).child,
          ),
        ),
      );
    }
  }
}
