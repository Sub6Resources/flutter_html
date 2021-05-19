import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/src/styled_element.dart';

class AnchorKey extends GlobalKey {
  final Key parentKey;
  final String id;

  const AnchorKey._(this.parentKey, this.id) : super.constructor();

  static AnchorKey? of(Key? parentKey, StyledElement? id, HtmlParser parser) {
    if (parser.strictMode && parser.anchors.contains(id?.elementId)) {
      throw Exception("Duplicate ID detected in HTML code. To prevent a "
          "'Duplicate GlobalKey' error, please do one of the following: 1) "
          "Correct the duplicate ID in the HTML to a unique ID or 2) Disable "
          "strictMode, in which case the duplicate ID will be ignored.");
    }
    return forId(parentKey, id?.elementId, parser.anchors, checkKeys: true);
  }

  static AnchorKey? forId(Key? parentKey, String? id, List<String> anchors, {bool checkKeys = false}) {
    if (checkKeys && anchors.contains(id)) {
      return null;
    }
    if (parentKey == null || id == null || id.isEmpty || id == "[[No ID]]") {
      return null;
    }
    anchors.add(id);
    return AnchorKey._(parentKey, id);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnchorKey && runtimeType == other.runtimeType && parentKey == other.parentKey && id == other.id;

  @override
  int get hashCode => parentKey.hashCode ^ id.hashCode;

  @override
  String toString() {
    return 'AnchorKey{parentKey: $parentKey, id: #$id}';
  }
}
