const STYLED_ELEMENTS = [
  "b",
];

const INTERACTABLE_ELEMENTS = [
  "a",
];

const BLOCK_ELEMENTS = [
  "div",

];

const CONTENT_ELEMENTS = [
  "img",
];

/// A [StyledElement] applies a style to all of its children.
class StyledElement {
  final String name;
  final List<StyledElement> children;
  final dynamic style; //TODO

  StyledElement({
    this.name,
    this.children,
    this.style,
  });
}

/// A [Gesture] indicates the type of interaction by a user.
enum Gesture {
  TAP,
}

/// An [InteractableElement] is a [StyledElement] that takes user gestures (e.g. tap).
class InteractableElement extends StyledElement {
  final void Function(Gesture gesture, dynamic data) onGesture;

  InteractableElement({
    this.onGesture,
  });
}

/// A [Block] contains information about a [BlockElement] (width, height, padding, margins)
class Block {
  //TODO
}

/// A [BlockElement] is a [StyledElement] that wraps before and after the its [children].
///
/// A [BlockElement] may have a margin/padding or be a set width/height.
class BlockElement extends StyledElement {
  final Block block;

  BlockElement({
    this.block,
  });
}

/// A [ContentElement] is a type of [TextElement] that renders itself, but none of its [children].
///
/// A [ContentElement] may use its [children] to determine how it should render (e.g. <video>'s <source> tags)
class ContentElement extends StyledElement {}

enum ElementType {
  CONTENT,
  STYLED,
  BLOCK,
  INTERACTIVE,
}
