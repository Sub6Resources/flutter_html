import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/src/styled_element.dart';

class AnchorKey extends GlobalKey {
  final Key parentKey;
  final String id;

  const AnchorKey._(this.parentKey, this.id) : super.constructor();

  static AnchorKey of(Key parentKey, StyledElement id) {
    return forId(parentKey, id.elementId);
  }

  static AnchorKey forId(Key parentKey, String id) {
    if (id == null || id.isEmpty) {
      return null;
    }
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
