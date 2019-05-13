export 'styled_element.dart';
export 'interactable_element.dart';
export 'block_element.dart';
export 'content_element.dart';

const STYLED_ELEMENTS = [
  "b",
  "i",
];

const INTERACTABLE_ELEMENTS = [
  "a",
];

const BLOCK_ELEMENTS = [
  "body",
  "div",
  "html",
];

const CONTENT_ELEMENTS = [
  "head",
  "img",
];

enum ElementType {
  CONTENT,
  STYLED,
  BLOCK,
  INTERACTABLE,
}
