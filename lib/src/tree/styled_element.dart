import 'dart:collection';

import 'package:flutter_html/src/style.dart';
import 'package:html/dom.dart' as dom;
//TODO(Sub6Resources): don't use the internal code of the html package as it may change unexpectedly.
//ignore: implementation_imports
import 'package:html/src/query_selector.dart';
import 'package:list_counter/list_counter.dart';

/// A [StyledElement] applies a style to all of its children.
class StyledElement {
  final String name;
  final String elementId;
  late final List<String> elementClasses;
  StyledElement? parent;
  late final List<StyledElement> children;
  Style style;
  final dom.Node node;
  final Map<dom.Node, int> nodeToIndex;
  final ListQueue<Counter> counters = ListQueue<Counter>();

  //int globalCharacterCount;

  StyledElement({
    this.name = "[[No name]]",
    this.elementId = "[[No ID]]",
    List<String>? elementClasses,
    this.parent,
    List<StyledElement>? children,
    required this.style,
    required this.node,
    required this.nodeToIndex,
  }) {
    this.elementClasses = elementClasses ?? [];
    this.children = children ?? [];
    for (final e in this.children) {
      e.parent = this;
    }
  }

  bool matchesSelector(String selector) {
    return (element != null && matches(element!, selector)) || name == selector;
  }

  Map<String, String> get attributes => node.attributes.map((key, value) {
        return MapEntry(key.toString(), value);
      });

  dom.Element? get element {
    if (node is dom.Element) {
      return node as dom.Element;
    }
    return null;
  }

  @override
  String toString() {
    String selfData =
        "[$name] ${children.length} ${elementClasses.isNotEmpty == true ? 'C:${elementClasses.toString()}' : ''}${elementId.isNotEmpty == true ? 'ID: $elementId' : ''}";
    for (var child in children) {
      selfData += ("\n${child.toString()}")
          .replaceAll(RegExp("^", multiLine: true), "-");
    }
    return selfData;
  }

  //************************************************************************//

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is StyledElement && other.node == node;
  }

  @override
  int get hashCode => node.hashCode;
}

FontSize numberToFontSize(String num) {
  switch (num) {
    case "1":
      return FontSize.xxSmall;
    case "2":
      return FontSize.xSmall;
    case "3":
      return FontSize.small;
    case "4":
      return FontSize.medium;
    case "5":
      return FontSize.large;
    case "6":
      return FontSize.xLarge;
    case "7":
      return FontSize.xxLarge;
  }
  if (num.startsWith("+")) {
    final relativeNum = double.tryParse(num.substring(1)) ?? 0;
    return numberToFontSize((3 + relativeNum).toString());
  }
  if (num.startsWith("-")) {
    final relativeNum = double.tryParse(num.substring(1)) ?? 0;
    return numberToFontSize((3 - relativeNum).toString());
  }
  return FontSize.medium;
}

extension DeepCopy on ListQueue<Counter> {
  ListQueue<Counter> deepCopy() {
    return ListQueue<Counter>.from(map((counter) {
      return Counter(counter.name, counter.value);
    }));
  }
}
