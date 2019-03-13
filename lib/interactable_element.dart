import 'package:flutter_html/html_elements.dart';
import 'package:html/dom.dart' as dom;

/// An [InteractableElement] is a [StyledElement] that takes user gestures (e.g. tap).
class InteractableElement extends StyledElement {
  String href;

  InteractableElement({
    String name,
    List<StyledElement> children,
    Style style,
    this.href,
  }) : super(name: name, children: children, style: style);
}

/// A [Gesture] indicates the type of interaction by a user.
enum Gesture {
  TAP,
}

InteractableElement parseInteractableElement(dom.Element element, List<StyledElement> children) {

  InteractableElement interactableElement = InteractableElement(
    name: element.localName,
    children: children,
  );

  switch(element.localName) {
    case "a":
      interactableElement.href = element.attributes['href'];
      break;
  }

  return interactableElement;
}