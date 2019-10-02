import 'dart:math';

import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/src/layout_element.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter/material.dart';
import 'package:csslib/visitor.dart' as css;
import 'package:html/dom.dart' as dom;
import 'package:flutter_html/src/html_elements.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:csslib/parser.dart' as cssparser;

typedef OnLinkTap = void Function(String url);
typedef CustomRender = Widget Function(
    RenderContext context, Widget child, Map<String, String> elementAttributes);

class HtmlParser extends StatelessWidget {
  final String htmlData;
  final String cssData;
  final OnLinkTap onLinkTap;
  final Map<String, Style> style;
  final Map<String, CustomRender> customRender;
  final List<String> blacklistedElements;

  HtmlParser({
    @required this.htmlData,
    @required this.cssData,
    this.onLinkTap,
    this.style,
    this.customRender,
    this.blacklistedElements,
  });

  @override
  Widget build(BuildContext context) {
    dom.Document document = parseHTML(htmlData);
    css.StyleSheet sheet = parseCSS(cssData);
    StyledElement lexedTree = lexDomTree(document, customRender?.keys?.toList() ?? [], blacklistedElements);
    StyledElement styledTree = applyCSS(lexedTree, sheet);
    StyledElement inlineStyledTree = applyInlineStyles(styledTree);
    StyledElement customStyledTree = _applyCustomStyles(inlineStyledTree);
    StyledElement cleanedTree = cleanTree(customStyledTree);
    InlineSpan parsedTree = parseTree(
      RenderContext(style: Style.fromTextStyle(Theme.of(context).textTheme.body1)),
      cleanedTree,
    );

    return RichText(text: parsedTree);
  }

  /// [parseHTML] converts a string to a DOM document using the dart `html` library.
  static dom.Document parseHTML(String data) {
    return htmlparser.parse(data);
  }

  ///TODO document
  static css.StyleSheet parseCSS(String data) {
    return cssparser.parse(data);
  }

  /// [lexDomTree] converts a DOM document to a simplified tree of [StyledElement]s.
  static StyledElement lexDomTree(
      dom.Document html, List<String> customRenderTags, List<String> blacklistedElements) {
    StyledElement tree = StyledElement(
      name: "[Tree Root]",
      children: new List<StyledElement>(),
      node: html.documentElement,
    );

    html.nodes.forEach((node) {
      tree.children.add(_recursiveLexer(node, customRenderTags, blacklistedElements));
    });

    return tree;
  }

  ///TODO document
  static StyledElement _recursiveLexer(
      dom.Node node, List<String> customRenderTags, List<String> blacklistedElements) {
    List<StyledElement> children = List<StyledElement>();

    node.nodes.forEach((childNode) {
      children.add(_recursiveLexer(childNode, customRenderTags, blacklistedElements));
    });

    //TODO(Sub6Resources): There's probably a more efficient way to look this up.
    if (node is dom.Element) {
      if (blacklistedElements?.contains(node.localName) ?? false) {
        return EmptyContentElement();
      }
      if (STYLED_ELEMENTS.contains(node.localName)) {
        return parseStyledElement(node, children);
      } else if (INTERACTABLE_ELEMENTS.contains(node.localName)) {
        return parseInteractableElement(node, children);
      } else if (REPLACED_ELEMENTS.contains(node.localName)) {
        return parseReplacedElement(node);
      } else if (LAYOUT_ELEMENTS.contains(node.localName)) {
        return parseLayoutElement(node, children);
      } else if (customRenderTags.contains(node.localName)) {
        return parseStyledElement(node, children);
      } else {
        return EmptyContentElement();
      }
    } else if (node is dom.Text) {
      return TextContentElement(text: node.text);
    } else {
      return EmptyContentElement();
    }
  }

  ///TODO document
  static StyledElement applyCSS(StyledElement tree, css.StyleSheet sheet) {
    //TODO
//    sheet.topLevels.forEach((treeNode) {
//      if (treeNode is css.RuleSet) {
//        print(treeNode
//            .selectorGroup.selectors.first.simpleSelectorSequences.first.simpleSelector.name);
//      }
//    });

    //Make sure style is never null.
    if(tree.style == null) {
      tree.style = Style();
    }

    tree.children?.forEach((e) => applyCSS(e, sheet));

    return tree;
  }

  ///TODO document
  static StyledElement applyInlineStyles(StyledElement tree) {
    //TODO

    return tree;
  }

  /// [applyCustomStyles] applies the [Style] objects passed into the [Html]
  /// widget onto the [StyledElement] tree.
  StyledElement _applyCustomStyles(StyledElement tree) {
    if (style == null) return tree;
    style.forEach((key, style) {
      if (tree.matchesSelector(key)) {
        if (tree.style == null) {
          tree.style = style;
        } else {
          tree.style = tree.style.merge(style);
        }
      }
    });
    tree.children?.forEach(_applyCustomStyles);

    return tree;
  }

  /// [cleanTree] optimizes the [StyledElement] tree so all [BlockElement]s are
  /// on the first level, redundant levels are collapsed, empty elements are
  /// removed, and specialty elements are processed.
  static StyledElement cleanTree(StyledElement tree) {
    tree = _processInternalWhitespace(tree);
    tree = _processInlineWhitespace(tree);
    tree = _removeEmptyElements(tree);
    tree = _processListCharacters(tree);
    tree = _processBeforesAndAfters(tree);
    tree = _collapseMargins(tree);
    return tree;
  }

  /// [parseTree] converts a tree of [StyledElement]s to an [InlineSpan] tree.
  InlineSpan parseTree(RenderContext context, StyledElement tree) {
    // Merge this element's style into the context so that children
    // inherit the correct style
    RenderContext newContext = RenderContext(
      style: context.style.merge(tree.style),
    );

    if (customRender?.containsKey(tree.name) ?? false) {
      return WidgetSpan(
        child: ContainerSpan(
          thisContext: context,
          newContext: newContext,
          style: tree.style,
          child: customRender[tree.name].call(
            newContext,
            ContainerSpan(
              thisContext: context,
              newContext: newContext,
              style: tree.style,
              children: tree.children?.map((tree) => parseTree(newContext, tree))?.toList() ?? [],
            ),
            tree.attributes,
          ),
        ),
      );
    }

    //Return the correct InlineSpan based on the element type.
    if (tree.style?.display == Display.BLOCK) {
      return WidgetSpan(
        child: ContainerSpan(
          newContext: newContext,
          thisContext: context,
          style: tree.style,
          children: tree.children?.map((tree) => parseTree(newContext, tree))?.toList() ?? [],
        ),
      );
    } else if(tree.style?.display == Display.LIST_ITEM) {
      return WidgetSpan(
        child: ContainerSpan(
          newContext: newContext,
          thisContext: context,
          style: tree.style,
          child: Stack(
            children: <Widget>[
              SizedBox(
                width: newContext.style.fontSize * 1.5, //TODO(Sub6Resources): this is a somewhat arbitrary constant.
                child: Text(newContext.style.markerContent ?? "", textAlign: TextAlign.center, style: newContext.style.generateTextStyle()),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: RichText(
                  text: TextSpan(
                    children: tree.children?.map((tree) => parseTree(newContext, tree))?.toList() ?? [],
                    style: tree.style.generateTextStyle(),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    } else if (tree is ReplacedElement) {
      if (tree is TextContentElement) {
        return TextSpan(text: tree.text);
      } else {
        return WidgetSpan(
          alignment: PlaceholderAlignment.aboveBaseline,
          baseline: TextBaseline.alphabetic,
          child: tree.toWidget(context),
        );
      }
    } else if (tree is InteractableElement) {
      return WidgetSpan(
        child: GestureDetector(
          onTap: () => onLinkTap(tree.href),
          child: RichText(
            text: TextSpan(
              style: newContext.style.generateTextStyle(),
              children: tree.children.map((tree) => parseTree(newContext, tree)).toList() ?? [],
            ),
          ),
        ),
      );
    } else if (tree is LayoutElement) {
      return WidgetSpan(
        child: tree.toWidget(context),
      );
    } else {
      ///[tree] is an inline element.
      return TextSpan(
        style: newContext.style.generateTextStyle(),
        children: tree.children.map((tree) => parseTree(newContext, tree)).toList(),
      );
    }
  }

  /// [processWhitespace] removes unnecessary whitespace from the StyledElement tree.
  ///
  /// The criteria for determining which whitespace is replaceable is outlined
  /// at https://www.w3.org/TR/css-text-3/
  /// and summarized at https://medium.com/@patrickbrosset/when-does-white-space-matter-in-html-b90e8a7cdd33
  static StyledElement _processInternalWhitespace(StyledElement tree) {
    if ((tree.style?.whiteSpace ?? WhiteSpace.NORMAL) == WhiteSpace.PRE) {
      // Preserve this whitespace
    } else if (tree is TextContentElement) {
      tree.text = _removeUnnecessaryWhitespace(tree.text);
    } else {
      tree.children?.forEach(_processInternalWhitespace);
    }
    return tree;
  }

  ///TODO document
  static StyledElement _processInlineWhitespace(StyledElement tree) {
    final whitespaceParsingContext = WhitespaceParsingContext(false);
    tree = _processInlineWhitespaceRecursive(tree, whitespaceParsingContext);
    return tree;
  }

  ///TODO document
  static StyledElement _processInlineWhitespaceRecursive(StyledElement tree, WhitespaceParsingContext wpc) {

    if(tree.style.display == Display.BLOCK) {
      wpc.inTrailingSpaceContext = false;
    }

    if(tree is TextContentElement) {
      if(wpc.inTrailingSpaceContext && tree.text.startsWith(' ')) {
        tree.text = tree.text.replaceFirst(' ', '');
      }

      if(tree.text.endsWith(' ')) {
        wpc.inTrailingSpaceContext = true;
      } else {
        wpc.inTrailingSpaceContext = false;
      }
    }

    tree.children?.forEach((e) => _processInlineWhitespaceRecursive(e, wpc));

    return tree;
  }

  /// [removeUnnecessaryWhitespace] removes "unnecessary" white space from the given String.
  ///
  /// The steps for removing this whitespace are as follows:
  /// (1) Remove any whitespace immediately preceding or following a newline.
  /// (2) Replace all newlines with a space
  /// (3) Replace all tabs with a space
  /// (4) Replace any instances of two or more spaces with a single space.
  static String _removeUnnecessaryWhitespace(String text) {
    return text
        .replaceAll(RegExp("\ *(?=\n)"), "")
        .replaceAll(RegExp("(?:\n)\ *"), "")
        .replaceAll("\n", " ")
        .replaceAll("\t", " ")
        .replaceAll(RegExp(" {2,}"), " ");
  }

  /// [processListCharacters] adds list characters to the front of all list items.
  /// TODO document better
  static StyledElement _processListCharacters(StyledElement tree) {
    if (tree.name == "ol" || tree.name == "ul") {
      for (int i = 0; i < tree.children?.length; i++) {
        if (tree.children[i].name == "li") {
          switch(tree.style.listStyleType) {
            case ListStyleType.DISC:
              tree.children[i].style.markerContent = '•';
              break;
            case ListStyleType.DECIMAL:
              tree.children[i].style.markerContent = '${i + 1}.';
              break;
          }}
      }
    }
    tree.children?.forEach(_processListCharacters);
    return tree;
  }

  /// TODO document better
  static StyledElement _processBeforesAndAfters(StyledElement tree) {
    if (tree.style?.before != null) {
      tree.children.insert(0, TextContentElement(text: tree.style.before));
    }
    if (tree.style?.after != null) {
      tree.children.add(TextContentElement(text: tree.style.after));
    }
    tree.children?.forEach(_processBeforesAndAfters);
    return tree;
  }

  /// [collapseMargins] follows the specifications at https://www.w3.org/TR/CSS21/box.html#collapsing-margins
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
    if (tree.children == null || tree.children.isEmpty) {
      // Handle case (4) from above.
      if((tree.style.height ?? 0) == 0) {
        tree.style.margin = EdgeInsets.zero;
      }
      return tree;
    }

    //Collapsing should be depth-first.
    tree.children?.forEach(_collapseMargins);

    //The root boxes do not collapse.
    if (tree.name == '[Tree Root]' || tree.name == 'html') {
      return tree;
    }

    // Handle case (1) from above.
    // Top margins cannot collapse if the element has padding
    if ((tree.style.padding?.top ?? 0) == 0) {
      final parentTop = tree.style.margin?.top ?? 0;
      final firstChildTop = tree.children.first.style.margin?.top ?? 0;
      final newOuterMarginTop = max(parentTop, firstChildTop);

      // Set the parent's margin
      if(tree.style.margin == null) {
        tree.style.margin = EdgeInsets.only(top: newOuterMarginTop);
      } else {
        tree.style.margin = tree.style.margin.copyWith(top: newOuterMarginTop);
      }

      // And remove the child's margin
      if(tree.children.first.style.margin == null) {
        tree.children.first.style.margin = EdgeInsets.zero;
      } else {
        tree.children.first.style.margin = tree.children.first.style.margin.copyWith(top: 0);
      }
    }

    // Handle case (3) from above.
    // Bottom margins cannot collapse if the element has padding
    if ((tree.style.padding?.bottom ?? 0) == 0) {
      final parentBottom = tree.style.margin?.bottom ?? 0;
      final lastChildBottom = tree.children.last.style.margin?.bottom ?? 0;
      final newOuterMarginBottom = max(parentBottom, lastChildBottom);

      // Set the parent's margin
      if(tree.style.margin == null) {
        tree.style.margin = EdgeInsets.only(bottom: newOuterMarginBottom);
      } else {
        tree.style.margin = tree.style.margin.copyWith(bottom: newOuterMarginBottom);
      }

      // And remove the child's margin
      if(tree.children.last.style.margin == null) {
        tree.children.last.style.margin = EdgeInsets.zero;
      } else {
        tree.children.last.style.margin = tree.children.last.style.margin.copyWith(bottom: 0);
      }
    }

    // Handle case (2) from above.
    if(tree.children.length > 1) {
      for (int i = 1; i < tree.children.length; i++) {
        final previousSiblingBottom = tree.children[i - 1].style.margin?.bottom ?? 0;
        final thisTop = tree.children[i].style.margin?.top ?? 0;
        final newInternalMargin = max(previousSiblingBottom, thisTop) / 2;

        if(tree.children[i - 1].style.margin == null) {
          tree.children[i - 1].style.margin = EdgeInsets.only(bottom: newInternalMargin);
        } else {
          tree.children[i - 1].style.margin = tree.children[i - 1].style.margin.copyWith(bottom: newInternalMargin);
        }

        if(tree.children[i].style.margin == null) {
          tree.children[i].style.margin = EdgeInsets.only(top: newInternalMargin);
        } else {
          tree.children[i].style.margin = tree.children[i].style.margin.copyWith(top: newInternalMargin);
        }
      }
    }

    return tree;
  }

  /// [removeEmptyElements] recursively removes empty elements.
  static StyledElement _removeEmptyElements(StyledElement tree) {
    List<StyledElement> toRemove = new List<StyledElement>();
    tree.children?.forEach((child) {
      if (child is EmptyContentElement) {
        toRemove.add(child);
      } else if (child is TextContentElement && (child.text.isEmpty)) {
        toRemove.add(child);
      } else {
        _removeEmptyElements(child);
      }
    });
    tree.children?.removeWhere((element) => toRemove.contains(element));

    return tree;
  }
}

///TODO document better
class RenderContext {
  final Style style;

  RenderContext({
    this.style,
  });
}

///TODO document
class WhitespaceParsingContext {
  bool inTrailingSpaceContext;

  WhitespaceParsingContext(this.inTrailingSpaceContext);
}

///TODO document
class ContainerSpan extends StatelessWidget {
  final Widget child;
  final List<InlineSpan> children;
  final Style style;
  final RenderContext thisContext;
  final RenderContext newContext;

  ContainerSpan({
    this.child,
    this.children,
    this.style,
    this.thisContext,
    this.newContext,
  });

  @override
  Widget build(BuildContext _) {
    return Container(
      decoration: BoxDecoration(
        border: style?.border,
        color: style?.backgroundColor,
      ),
      height: style?.height,
      width: style?.width,
      padding: style?.padding,
      margin: style?.margin,
      alignment: style?.alignment,
      child: child ??
          RichText(
            text: TextSpan(
              style: thisContext.style.merge(style).generateTextStyle(),
              children: children,
            ),
          ),
    );
  }
}
