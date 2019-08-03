import 'package:html/dom.dart';
import 'package:flutter/widgets.dart';

//
// Converts a hex string into a color.
//
// Returns Black if the string fails to parse.
class HexToColor extends Color {
  static _hexToColor(String code) {
    try {
      return int.parse(code.substring(1, 7), radix: 16) + 0xFF000000;
    } catch (e) {
      // Default to black
      return 4278190080;
    }
  }

  HexToColor(final String code) : super(_hexToColor(code));
}

//
// Gets a Color from a node attribute.
//
// Returns null if the color is not a hex value.
//
Color colorFromNodeAttribute(Node node) {
  Color c;
  String color = node.attributes['color'] ?? '';
  if (color.startsWith('#')) {
    // A hex color`
    c = HexToColor(color);
  }
  return c;
}
