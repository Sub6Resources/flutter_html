import 'package:flutter/material.dart';
import 'package:flutter_html/src/html_elements.dart';
import 'package:flutter_html/style.dart';
import 'package:html/dom.dart' as dom;

import 'html_elements.dart';


/// An [InteractableElement] is a [StyledElement] that takes user gestures (e.g. tap).
class InteractableElement extends StyledElement {
  String href;

  InteractableElement({
    String name,
    List<StyledElement> children,
    Style style,
    this.href,
    dom.Node node,
  }) : super(name: name, children: children, style: style, node: node);
}

/// A [Gesture] indicates the type of interaction by a user.
enum Gesture {
  TAP,
}

InteractableElement parseInteractableElement(
    dom.Element element, List<StyledElement> children) {
  InteractableElement interactableElement = InteractableElement(
    name: element.localName,
    children: children,
    node: element,
  );

  switch (element.localName) {
    case "a":
      interactableElement.href = element.attributes['href'];
      if (element.children?.isEmpty ?? true) {
        interactableElement.style = Style(
          textDecoration: TextDecoration.underline,
          color: Colors.blue,
        );
      } else {
        final allWidgets = List<TextContentElement>();
        List<StyledElement> searchQueue =
            List.from(interactableElement.children);

        // recursively
        while (searchQueue.isNotEmpty) {
          final List<StyledElement> nextSearch = searchQueue
              .expand((e) => e?.children ?? List<StyledElement>())
              .toList();
          allWidgets.addAll(nextSearch
              .where((element) => element is TextContentElement)
              .map((e) => e as TextContentElement));
          searchQueue = nextSearch;
        }

        allWidgets
            .where((element) => element is TextContentElement)
            .forEach((element) {
              final style = element.style ?? Style();
          element.style = style.copyWith(
            textDecoration: TextDecoration.underline,
            color: Colors.blue,
          );
        });
      }

      break;
  }

  return interactableElement;
}
