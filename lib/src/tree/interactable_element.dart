import 'package:flutter_html/flutter_html.dart';

/// An [InteractiveElement] is a [StyledElement] that takes user gestures (e.g. tap).
class InteractiveElement extends StyledElement {
  String? href;

  InteractiveElement({
    required super.name,
    required super.children,
    required super.style,
    required super.node,
    required super.elementId,
    required this.href,
  }) : super();
}

/// A [Gesture] indicates the type of interaction by a user.
enum Gesture {
  tap,
}
