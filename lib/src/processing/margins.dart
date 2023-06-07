import 'dart:math';

import 'package:flutter_html/flutter_html.dart';

class MarginProcessing {
  /// [processMargins] applies processing steps for collapsing margins.
  static StyledElement processMargins(StyledElement tree) {
    return _collapseMargins(tree);
  }

  /// [collapseMargins] follows the specifications at https://www.w3.org/TR/CSS22/box.html#collapsing-margins
  /// for collapsing margins of block-level boxes. This prevents the doubling of margins between
  /// boxes, and makes for a more correct rendering of the html content.
  ///
  /// Paraphrased from the CSS specification:
  /// Margins are collapsed if both belong to vertically-adjacent box edges, i.e form one of the following pairs:
  /// (1) Top margin of a box and top margin of its first in-flow child
  /// (2) Bottom margin of a box and top margin of its next in-flow following sibling
  /// (3) Bottom margin of a last in-flow child and bottom margin of its parent (if the parent's height is not explicit)
  /// (4) Top and Bottom margins of a box with a height of zero or no in-flow children.
  static StyledElement _collapseMargins(StyledElement tree) {
    //Short circuit if we've reached a leaf of the tree
    if (tree.children.isEmpty) {
      // Handle case (4) from above.
      if (tree.style.height?.value == 0 &&
          tree.style.height?.unit != Unit.auto) {
        tree.style.margin = tree.style.margin?.collapse() ?? Margins.zero;
      }
      return tree;
    }

    //Collapsing should be depth-first.
    tree.children.forEach(_collapseMargins);

    //The root boxes and table/ruby elements do not collapse.
    if (tree.name == '[Tree Root]' ||
        tree.name == 'html' ||
        tree.style.display?.displayInternal != null) {
      return tree;
    }

    // Handle case (1) from above.
    // Top margins cannot collapse if the element has padding
    if ((tree.style.padding?.top ?? 0) == 0) {
      final parentTop = tree.style.margin?.top?.value ??
          tree.style.margin?.blockStart?.value ??
          0;
      final firstChildTop = tree.children.first.style.margin?.top?.value ??
          tree.children.first.style.margin?.blockStart?.value ??
          0;
      final newOuterMarginTop = max(parentTop, firstChildTop);

      // Set the parent's margin
      if (tree.style.margin == null) {
        tree.style.margin = Margins.only(top: newOuterMarginTop);
      } else {
        tree.style.margin =
            tree.style.margin!.copyWithEdge(top: newOuterMarginTop);
      }

      // And remove the child's margin
      if (tree.children.first.style.margin == null) {
        tree.children.first.style.margin = Margins.zero;
      } else {
        tree.children.first.style.margin =
            tree.children.first.style.margin!.copyWithEdge(top: 0);
      }
    }

    // Handle case (3) from above.
    // Bottom margins cannot collapse if the element has padding
    if ((tree.style.padding?.bottom?.value ??
            tree.style.padding?.blockEnd?.value) ==
        0) {
      final parentBottom = tree.style.margin?.bottom?.value ??
          tree.style.margin?.blockEnd?.value ??
          0;
      final lastChildBottom = tree.children.last.style.margin?.bottom?.value ??
          tree.children.last.style.margin?.blockEnd?.value ??
          0;
      final newOuterMarginBottom = max(parentBottom, lastChildBottom);

      // Set the parent's margin
      if (tree.style.margin == null) {
        tree.style.margin = Margins.only(bottom: newOuterMarginBottom);
      } else {
        tree.style.margin =
            tree.style.margin!.copyWithEdge(bottom: newOuterMarginBottom);
      }

      // And remove the child's margin
      if (tree.children.last.style.margin == null) {
        tree.children.last.style.margin = Margins.zero;
      } else {
        tree.children.last.style.margin =
            tree.children.last.style.margin!.copyWith(bottom: Margin.zero());
      }
    }

    // Handle case (2) from above.
    if (tree.children.length > 1) {
      for (int i = 1; i < tree.children.length; i++) {
        final previousSiblingBottom =
            tree.children[i - 1].style.margin?.bottom?.value ??
                tree.children[i - 1].style.margin?.blockEnd?.value ??
                0;
        final thisTop = tree.children[i].style.margin?.top?.value ??
            tree.children[i].style.margin?.blockStart?.value ??
            0;
        final newInternalMargin = max(previousSiblingBottom, thisTop);
        final newTop = newInternalMargin - previousSiblingBottom;

        if (tree.children[i].style.margin == null) {
          tree.children[i].style.margin = Margins.only(top: newTop);
        } else {
          tree.children[i].style.margin =
              tree.children[i].style.margin!.copyWithEdge(top: newTop);
        }
      }
    }

    return tree;
  }
}
