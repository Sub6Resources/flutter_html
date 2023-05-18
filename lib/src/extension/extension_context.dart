import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:flutter_html/src/html_parser.dart';
import 'package:flutter_html/src/style.dart';
import 'package:flutter_html/src/tree/styled_element.dart';
import 'package:html/dom.dart' as html;

/// Provides information about the current element on the Html tree for
/// an [Extension] to use.
class ExtensionContext {
  /// Allows matchers to get a sense for what step the HtmlParser is pinging
  /// them for. Only non-null in calls to `matches`.
  final CurrentStep currentStep;

  /// The HTML node being represented as a Flutter widget.
  final html.Node node;

  /// Returns the reference to the Html element if this Html node represents
  /// and element. Otherwise returns null.
  html.Element? get element {
    if (node is html.Element) {
      return (node as html.Element);
    }

    return null;
  }

  /// Returns the name of the Html element, or an empty string if the node is
  /// a text content node, comment node, or any other node without a name.
  String get elementName {
    if (node is html.Element) {
      return (node as html.Element).localName ?? '';
    }

    return '';
  }

  /// Returns the HTML within this element, or an empty string if there is none.
  String get innerHtml {
    if (node is html.Element) {
      return (node as html.Element).innerHtml;
    }

    return node.text ?? "";
  }

  /// Returns the list of child Elements on this html Node, or an empty list if
  /// there are no children.
  List<html.Element> get elementChildren {
    return node.children;
  }

  /// Returns a linked hash map representing the attributes of the node, or an
  /// empty map if it has no attributes.
  LinkedHashMap<String, String> get attributes {
    return LinkedHashMap.from(node.attributes.map((key, value) {
      // Key is either a String or html.AttributeName
      return MapEntry(key.toString(), value);
    }));
  }

  /// Returns the id of the element, or an empty string if it is not present or
  /// this Node is not an html Element.
  String get id {
    if (node is html.Element) {
      return (node as html.Element).id;
    }

    return '';
  }

  /// Returns a set of classes on this Element, or an empty set if none are
  /// present or this Node is not an html Element.
  Set<String> get classes {
    if (node is html.Element) {
      return (node as html.Element).classes;
    }

    return <String>{};
  }

  /// A reference to the [HtmlParser] instance. Useful for calling callbacks
  /// on the [Html] widget like [onLinkTap].
  final HtmlParser parser;

  /// A reference to the [StyledElement] representation of this node.
  /// Guaranteed to be non-null only after the preparing step
  final StyledElement? styledElement;

  /// A reference to the [Style] on the [StyledElement] representation of this
  /// node. Guaranteed to be non-null only after the preparing step.
  Style? get style {
    return styledElement?.style;
  }

  /// The [StyledElement] version of this node's children. Guaranteed to be
  /// non-null only after the preparing step.
  List<StyledElement> get styledElementChildren {
    return styledElement!.children;
  }

  final BuildChildrenCallback? _callbackToBuildChildren;
  Map<StyledElement, InlineSpan>? _builtChildren;

  /// A map between the original [StyledElement] children of this node and the
  /// fully built [InlineSpan] children of this node.
  Map<StyledElement, InlineSpan>? get builtChildrenMap {
    _builtChildren ??= _callbackToBuildChildren?.call();

    return _builtChildren;
  }

  /// The [InlineSpan] version of this node's children. Constructed lazily.
  /// Guaranteed to be non-null only when `currentStep` is `building`.
  List<InlineSpan>? get inlineSpanChildren {
    _builtChildren ??= _callbackToBuildChildren?.call();

    return _builtChildren?.values.toList();
  }

  /// Guaranteed to be non-null only when `currentStep` is `building`,
  /// but it might not necessarily be the nearest BuildContext. Probably should
  /// use a `Builder` Widget if you need the most relevant BuildContext.
  final BuildContext? buildContext;

  /// Constructs a new [ExtensionContext] object with the given information.
  ExtensionContext({
    required this.currentStep,
    required this.node,
    required this.parser,
    this.styledElement,
    this.buildContext,
    BuildChildrenCallback? buildChildrenCallback,
  }) : _callbackToBuildChildren = buildChildrenCallback;
}

typedef BuildChildrenCallback = Map<StyledElement, InlineSpan> Function();

enum CurrentStep {
  preparing,
  preStyling,
  preProcessing,
  building,
}
