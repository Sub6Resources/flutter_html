import 'package:collection/collection.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/src/utils.dart';
import 'package:html/dom.dart' as html;

class WhitespaceProcessing {
  /// [processWhitespace] handles the removal of unnecessary whitespace from
  /// a StyledElement tree.
  ///
  /// The criteria for determining which whitespace is replaceable is outlined
  /// at https://www.w3.org/TR/css-text-3/
  /// and summarized at https://medium.com/@patrickbrosset/when-does-white-space-matter-in-html-b90e8a7cdd33
  static StyledElement processWhitespace(StyledElement tree) {
    tree = _processInternalWhitespace(tree);
    tree = _processInlineWhitespace(tree);
    tree = _processBlockWhitespace(tree);
    tree = _removeEmptyElements(tree);
    return tree;
  }

  /// [_processInternalWhitespace] removes unnecessary whitespace from the StyledElement tree.
  static StyledElement _processInternalWhitespace(StyledElement tree) {
    if (tree.style.whiteSpace == WhiteSpace.pre) {
      return tree;
    }

    if (tree is TextContentElement) {
      tree.text = _removeUnnecessaryWhitespace(tree.text!);
    } else {
      tree.children.forEach(_processInternalWhitespace);
    }

    return tree;
  }

  /// [_processInlineWhitespace] is responsible for removing redundant whitespace
  /// between and among inline elements. It does so by creating a boolean [Context]
  /// and passing it to the [_processInlineWhitespaceRecursive] function.
  static StyledElement _processInlineWhitespace(StyledElement tree) {
    return _processInlineWhitespaceRecursive(tree, Context(false));
  }

  /// [_processBlockWhitespace] removes unnecessary whitespace from block
  /// rendering contexts. Specifically, a space at the beginning and end of
  /// the line should be removed.
  static StyledElement _processBlockWhitespace(StyledElement tree) {
    if (tree.style.whiteSpace == WhiteSpace.pre) {
      return tree;
    }

    bool isBlockContext = false;
    for (final child in tree.children) {
      if (child.style.display == Display.block) {
        isBlockContext = true;
      }

      _processBlockWhitespace(child);
    }

    if (isBlockContext) {
      for (final child in tree.children) {
        if (child is TextContentElement) {
          child.style.display = Display.block;
        }

        _removeLeadingSpace(child);
        _removeTrailingSpace(child);
      }
    }

    return tree;
  }

  /// [_removeLeadingSpace] removes any leading space
  /// from the text of the tree at this level, no matter how deep in the tree
  /// it may be.
  static void _removeLeadingSpace(StyledElement element) {
    if (element.style.whiteSpace == WhiteSpace.pre) {
      return;
    }

    if (element is TextContentElement) {
      element.text = element.text?.trimLeft();
    } else if (element.children.isNotEmpty) {
      _removeLeadingSpace(element.children.first);
    }
  }

  /// [_removeTrailingSpace] removes any leading space
  /// from the text of the tree at this level, no matter how deep in the tree
  /// it may be.
  static void _removeTrailingSpace(StyledElement element) {
    if (element.style.whiteSpace == WhiteSpace.pre) {
      return;
    }

    if (element is TextContentElement) {
      element.text = element.text?.trimRight();
    } else if (element.children.isNotEmpty) {
      _removeTrailingSpace(element.children.last);
    }
  }

  /// [_processInlineWhitespaceRecursive] analyzes the whitespace between and among different
  /// inline elements, and replaces any instance of two or more spaces with a single space, according
  /// to the w3's HTML whitespace processing specification linked to above.
  static StyledElement _processInlineWhitespaceRecursive(
    StyledElement tree,
    Context<bool> keepLeadingSpace,
  ) {
    if (tree.style.whiteSpace == WhiteSpace.pre) {
      return tree;
    }

    if (tree is TextContentElement) {
      /// initialize indices to negative numbers to make conditionals a little easier
      int textIndex = -1;
      int elementIndex = -1;

      /// initialize parent after to a whitespace to account for elements that are
      /// the last child in the list of elements
      String parentAfterText = " ";

      /// find the index of the text in the current tree
      if (tree.element?.nodes.isNotEmpty ?? false) {
        textIndex =
            tree.element!.nodes.indexWhere((element) => element == tree.node);
      }

      /// get the parent nodes
      final parentNodes = tree.element?.parent?.nodes;

      /// find the index of the tree itself in the parent nodes
      if (parentNodes?.isNotEmpty ?? false) {
        elementIndex =
            parentNodes!.indexWhere((element) => element == tree.element);
      }

      /// if the tree is any node except the last node in the node list and the
      /// next node in the node list is a text node, then get its text. Otherwise
      /// the next node will be a [dom.Element], so keep unwrapping that until
      /// we get the underlying text node, and finally get its text.
      if (elementIndex < (parentNodes?.length ?? 1) - 1 &&
          parentNodes?[elementIndex + 1] is html.Text) {
        parentAfterText = parentNodes?[elementIndex + 1].text ?? " ";
      } else if (elementIndex < (parentNodes?.length ?? 1) - 1) {
        var parentAfter = parentNodes?[elementIndex + 1];
        while (parentAfter is html.Element) {
          if (parentAfter.nodes.isNotEmpty) {
            parentAfter = parentAfter.nodes.first;
          } else {
            break;
          }
        }
        parentAfterText = parentAfter?.text ?? " ";
      }

      /// If the text is the first element in the current tree node list, it
      /// starts with a whitespace, it isn't a line break, either the
      /// whitespace is unnecessary or it is a block element, and either it is
      /// first element in the parent node list or the previous element
      /// in the parent node list ends with a whitespace, delete it.
      ///
      /// We should also delete the whitespace at any point in the node list
      /// if the previous element is a <br> because that tag makes the element
      /// act like a block element.
      if (textIndex < 1 &&
          tree.text!.startsWith(' ') &&
          tree.element?.localName != "br" &&
          (!keepLeadingSpace.data || tree.style.display == Display.block) &&
          (elementIndex < 1 ||
              (elementIndex >= 1 &&
                  parentNodes?[elementIndex - 1] is html.Text &&
                  parentNodes![elementIndex - 1].text!.endsWith(" ")))) {
        tree.text = tree.text!.replaceFirst(' ', '');
      } else if (textIndex >= 1 &&
          tree.text!.startsWith(' ') &&
          tree.element?.nodes[textIndex - 1] is html.Element &&
          (tree.element?.nodes[textIndex - 1] as html.Element).localName ==
              "br") {
        tree.text = tree.text!.replaceFirst(' ', '');
      }

      /// If the text is the last element in the current tree node list, it isn't
      /// a line break, and the next text node starts with a whitespace,
      /// update the [Context] to signify to that next text node whether it should
      /// keep its whitespace. This is based on whether the current text ends with a
      /// whitespace.
      if (textIndex == (tree.node.nodes.length - 1) &&
          tree.element?.localName != "br" &&
          parentAfterText.startsWith(' ')) {
        keepLeadingSpace.data = !tree.text!.endsWith(' ');
      }
    }

    for (var element in tree.children) {
      _processInlineWhitespaceRecursive(element, keepLeadingSpace);
    }

    return tree;
  }

  /// [_removeUnnecessaryWhitespace] removes "unnecessary" white space from the given String.
  ///
  /// The steps for removing this whitespace are as follows:
  /// (1) Remove any whitespace immediately preceding or following a newline.
  /// (2) Replace all newlines with a space
  /// (3) Replace all tabs with a space
  /// (4) Replace any instances of two or more spaces with a single space.
  static String _removeUnnecessaryWhitespace(String text) {
    return text
        .replaceAll(RegExp(r" *(?=\n)"), "")
        .replaceAll(RegExp(r"(?<=\n) *"), "")
        .replaceAll("\n", " ")
        .replaceAll("\t", " ")
        .replaceAll(RegExp(r" {2,}"), " ");
  }

  /// [_removeEmptyElements] recursively removes empty elements.
  ///
  /// An empty element is any [EmptyContentElement], any empty [TextContentElement],
  /// or any block-level [TextContentElement] that contains only whitespace and doesn't follow
  /// a block element or a line break.
  static StyledElement _removeEmptyElements(StyledElement tree) {
    Set<StyledElement> toRemove = <StyledElement>{};
    bool lastChildBlock = true;
    tree.children.forEachIndexed((index, child) {
      if (child is EmptyContentElement) {
        toRemove.add(child);
      } else if (child is TextContentElement &&
          ((tree.name == "body" &&
                  (index == 0 ||
                      index + 1 == tree.children.length ||
                      tree.children[index - 1].style.display == Display.block ||
                      tree.children[index + 1].style.display ==
                          Display.block)) ||
              tree.name == "ul") &&
          child.text!.replaceAll(' ', '').isEmpty) {
        toRemove.add(child);
      } else if (child is TextContentElement &&
          child.text!.isEmpty &&
          child.style.whiteSpace != WhiteSpace.pre) {
        toRemove.add(child);
      } else if (child is TextContentElement &&
          child.style.whiteSpace != WhiteSpace.pre &&
          tree.style.display == Display.block &&
          child.text!.isEmpty &&
          lastChildBlock) {
        toRemove.add(child);
      } else if (child.style.display == Display.none) {
        toRemove.add(child);
      } else {
        _removeEmptyElements(child);
      }

      // This is used above to check if the previous element is a block element or a line break.
      lastChildBlock = (child.style.display == Display.block ||
          child.style.display == Display.listItem ||
          (child is TextContentElement && child.text == '\n'));
    });
    tree.children.removeWhere((element) => toRemove.contains(element));

    return tree;
  }
}
