import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

/// Adds Highlighting to the to the Text elements for the specified range and color
class HighlightBuiltIn extends HtmlExtension {
  const HighlightBuiltIn();

  static const defaultHighlightColor = Color.fromARGB(150, 255, 229, 127);

  @override
  bool matches(ExtensionContext context) {
    return supportedTags.contains(context.elementName);
  }

  @override
  Set<String> get supportedTags => {
        "o-highlight",
      };

  /// Traverse each element and add highlighting for the range, if the range
  /// stops in the middle of an element, split the stylized element
  @override
  void beforeProcessing(ExtensionContext context) {
    String? rangeStr = context.element!.attributes["range"];
    if (rangeStr == null) {
      return;
    }
    final int? range = int.tryParse(rangeStr);
    if (range == null) {
      return;
    }
    String? colorStr = context.element!.attributes["color"];
    Color color;
    if (colorStr == null) {
      // Colors.amberAccent.shade100 with 150 transparency
      color = defaultHighlightColor;
    } else {
      final colorChannels = colorStr
          .split(",")
          .map((e) => int.tryParse(e))
          .where((e) => e != null)
          .cast<int>()
          .toList(growable: false);
      if (colorChannels.length != 4) {
        color = defaultHighlightColor;
      }
      color = Color.fromARGB(colorChannels[0], colorChannels[1],
          colorChannels[2], colorChannels[3]);
    }
    _traverseAndAddStyle(context.styledElement!, Style(backgroundColor: color),
        _IntWrapper(range), 0);
  }

  void _traverseAndAddStyle(StyledElement element, Style style,
      _IntWrapper characterCount, int skip) {
    // add style to this element, if character count is smaller than length, break up and return, otherwise go down until no children, then, start going up
    // good opportunity to publish tree node. then add that as a depends to here and changed styled element to inherit from
    _traverseAndAddStyleDownInclusive(element, style, characterCount, skip);
    if (characterCount.val > 0 && element.parent != null) {
      int parentShouldSkip = 1;
      for (final parentChildElement in element.parent!.children) {
        if (parentChildElement == element) break;
        parentShouldSkip++;
      }
      _traverseAndAddStyle(
          element.parent!, style, characterCount, parentShouldSkip);
    }
  }

  void _traverseAndAddStyleDownInclusive(StyledElement element, Style style,
      _IntWrapper characterCount, int skip) {
    if (characterCount.val > 0) {
      if (element is TextContentElement) {
        int length = element.text?.length ?? 0;
        if (length > characterCount.val) {
          final splitElement = element.split(characterCount.val);
          assert(splitElement.length == 2);
          splitElement[0].style =
              splitElement[0].style.copyOnlyInherited(style);
          characterCount.val -= characterCount.val;
          return;
        } else {
          element.style = element.style.copyOnlyInherited(style);
          characterCount.val -= length;
        }
      }
    }
    for (int i = skip;
        i < element.children.length && characterCount.val > 0;
        ++i) {
      _traverseAndAddStyleDownInclusive(
          element.children[i], style, characterCount, 0);
    }
  }

  /// Adds a marker to the highlight that a comment can be attached to
  @override
  InlineSpan build(ExtensionContext context) {
    String? range = context.element!.attributes["color"];
    // TODO replace with custom span that creates a floating widget
    return const TextSpan();
  }
}

class _IntWrapper {
  _IntWrapper(this.val);

  int val;
}
