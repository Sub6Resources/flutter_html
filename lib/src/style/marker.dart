import 'package:flutter_html/flutter_html.dart';

class Marker {
  final Content content;

  Style? style;

  Marker({
    this.content = Content.normal,
    this.style,
  });
}

class Content {
  final String? replacementContent;
  final bool _normal;
  final bool display;

  const Content(this.replacementContent)
      : _normal = false,
        display = true;
  const Content._normal()
      : _normal = true,
        display = true,
        replacementContent = null;
  const Content._none()
      : _normal = false,
        display = false,
        replacementContent = null;

  static const Content none = Content._none();
  static const Content normal = Content._normal();

  bool get isNormal => _normal;
}
