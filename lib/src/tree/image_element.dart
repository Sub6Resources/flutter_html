import 'package:flutter_html/flutter_html.dart';

/// An [ImageElement] is an [InteractiveElement] that displays images.
class ImageElement extends InteractiveElement {
  final String src;
  final String? alt;
  final Width? width;
  final Height? height;

  ImageElement({
    required super.name,
    required super.parent,
    required super.children,
    required super.style,
    required super.node,
    required super.elementId,
    required this.src,
    required this.alt,
    required this.width,
    required this.height,
  }) : super(href: null);
}
