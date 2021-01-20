import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/src/html_elements.dart';
import 'package:flutter_html/src/utils.dart';
import 'package:flutter_html/style.dart';
import 'package:html/dom.dart' as dom;

/// An [InteractableElement] is a [StyledElement] that takes user gestures (e.g. tap).
abstract class InteractableElement extends StyledElement {
  String href;

  InteractableElement({
    String name,
    List<StyledElement> children,
    Style style,
    this.href,
    dom.Node node,
  }) : super(name: name, children: children, style: style, node: node);

  Widget toWidget(RenderContext context, {InlineSpan childSpan});
}

/// A [Gesture] indicates the type of interaction by a user.
enum Gesture {
  TAP,
}

class LinkedContentElement extends InteractableElement {
  String href;
  Style style;

  LinkedContentElement({
    dom.Node node,
    String name,
    List<StyledElement> children,
    this.href,
    this.style,
  }) : super(name: name, node: node, children: children);

  @override
  Widget toWidget(RenderContext context, {InlineSpan childSpan}) {
    return RawGestureDetector(
      gestures: {
        MultipleTapGestureRecognizer: GestureRecognizerFactoryWithHandlers<
            MultipleTapGestureRecognizer>(
              () => MultipleTapGestureRecognizer(),
              (instance) {
            instance..onTap = () => context.parser.onLinkTap?.call(href);
          },
        ),
      },
      child: (childSpan as WidgetSpan).child,
    );
  }
}

class DetailsContentElement extends InteractableElement {
  List<dom.Element> title;

  DetailsContentElement({
    dom.Node node,
    String name,
    List<StyledElement> children,
    this.title,
  }) : super(name: name, node: node, children: children);

  @override
  Widget toWidget(RenderContext context, {InlineSpan childSpan}) {
    return ExpansionTile(
      title: title.first.localName == "summary" ? StyledText(
        textSpan: TextSpan(
          style: style.generateTextStyle(),
          children: [children
              .map((tree) => context.parser.parseTree(context, tree))
              .toList().first] ??
              [],
        ),
        style: style,
      ) : Text("Details"),
      children: [
        StyledText(
          textSpan: TextSpan(
            style: style.generateTextStyle(),
            children: children
                .map((tree) => context.parser.parseTree(context, tree))
                .toList() ??
                [],
          ),
          style: style,
        ),
      ]
    );
  }

}

class EmptyInteractableElement extends InteractableElement {
  EmptyInteractableElement({String name = "empty"}) : super(name: name);

  @override
  Widget toWidget(_, {InlineSpan childSpan}) => null;
}

InteractableElement parseInteractableElement(
    dom.Element element, List<StyledElement> children) {

  switch (element.localName) {
    case "a":
      return LinkedContentElement(
        node: element,
        name: element.localName,
        children: children,
        href: element.attributes['href'],
        style: Style(
          color: Colors.blue,
          textDecoration: TextDecoration.underline,
        )
      );
    case "details":
      return DetailsContentElement(
        node: element,
        name: element.localName,
        children: element.children.first.localName == "summary" ? children : children,
        title: element.children
      );
    default:
      return EmptyInteractableElement(name: element.localName);
  }
}
