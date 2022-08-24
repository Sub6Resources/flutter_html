import 'package:flutter/material.dart';
import 'package:flutter_html/src/html_elements.dart';
import 'package:flutter_html/style.dart';
import 'package:html/dom.dart' as dom;

/// An [InteractableElement] is a [StyledElement] that takes user gestures (e.g. tap).
class InteractableElement extends StyledElement {
  String? href;

  InteractableElement({
    required super.name,
    required super.children,
    required super.style,
    required this.href,
    required dom.Node node,
    required super.elementId,
    required super.containingBlockSize,
  }) : super(node: node as dom.Element?);
}

/// A [Gesture] indicates the type of interaction by a user.
enum Gesture {
  TAP,
}

StyledElement parseInteractableElement(
    dom.Element element,
    List<StyledElement> children,
    Size containingBlockSize,
    ) {
  switch (element.localName) {
    case "a":
      if (element.attributes.containsKey('href')) {
        return InteractableElement(
            name: element.localName!,
            children: children,
            href: element.attributes['href'],
            style: Style(
              color: Colors.blue,
              textDecoration: TextDecoration.underline,
            ),
            node: element,
            elementId: element.id,
          containingBlockSize: containingBlockSize,
        );
      }
      // When <a> tag have no href, it must be non clickable and without decoration.
      return StyledElement(
        name: element.localName!,
        children: children,
        style: Style(),
        node: element,
        elementId: element.id,
        containingBlockSize: containingBlockSize,
      );
    /// will never be called, just to suppress missing return warning
    default:
      return InteractableElement(
        name: element.localName!,
        children: children,
        node: element,
        href: '',
        style: Style(),
        elementId: "[[No ID]]",
        containingBlockSize: containingBlockSize,
      );
  }
}
