import 'dart:collection';
import 'dart:math';

import 'package:csslib/parser.dart' as cssparser;
import 'package:csslib/visitor.dart' as css;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/src/css_parser.dart';
import 'package:flutter_html/src/html_elements.dart';
import 'package:flutter_html/src/layout_element.dart';
import 'package:flutter_html/src/utils.dart';
import 'package:flutter_html/style.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as htmlparser;

typedef OnTap = void Function(String url);
typedef CustomRender = Widget Function(
  RenderContext context,
  Widget parsedChild,
  Map<String, String> attributes,
  dom.Element element,
);

class HtmlParser extends StatelessWidget {
  final String htmlData;
  final String cssData;
  final OnTap onLinkTap;
  final OnTap onImageTap;
  final ImageErrorListener onImageError;
  final bool shrinkWrap;

  final Map<String, Style> style;
  final Map<String, CustomRender> customRender;
  final List<String> blacklistedElements;

  HtmlParser({
    @required this.htmlData,
    @required this.cssData,
    this.onLinkTap,
    this.onImageTap,
    this.onImageError,
    this.shrinkWrap,
    this.style,
    this.customRender,
    this.blacklistedElements,
  });

  @override
  Widget build(BuildContext context) {
    dom.Document document = parseHTML(htmlData);
    css.StyleSheet sheet = parseCSS(cssData);
    StyledElement lexedTree = lexDomTree(
      document,
      customRender?.keys?.toList() ?? [],
      blacklistedElements,
    );
    // TODO(Sub6Resources): this could be simplified to a single recursive descent.
    StyledElement styledTree = applyCSS(lexedTree, sheet);
    StyledElement inlineStyledTree = applyInlineStyles(styledTree);
    StyledElement customStyledTree = _applyCustomStyles(inlineStyledTree);
    StyledElement cascadedStyledTree = _cascadeStyles(customStyledTree);
    StyledElement cleanedTree = cleanTree(cascadedStyledTree);
    InlineSpan parsedTree = parseTree(
      RenderContext(
        buildContext: context,
        parser: this,
        style: Style.fromTextStyle(Theme.of(context).textTheme.body1),
      ),
      cleanedTree,
    );

    return StyledText(textSpan: parsedTree, style: cleanedTree.style);
  }

  /// [parseHTML] converts a string of HTML to a DOM document using the dart `html` library.
  static dom.Document parseHTML(String data) {
    return htmlparser.parse(data);
  }

  /// [parseCSS] converts a string of CSS to a CSS stylesheet using the dart `csslib` library.
  static css.StyleSheet parseCSS(String data) {
    return cssparser.parse(data);
  }

  /// [lexDomTree] converts a DOM document to a simplified tree of [StyledElement]s.
  static StyledElement lexDomTree(
    dom.Document html,
    List<String> customRenderTags,
    List<String> blacklistedElements,
  ) {
    StyledElement tree = StyledElement(
      name: "[Tree Root]",
      children: new List<StyledElement>(),
      node: html.documentElement,
    );

    html.nodes.forEach((node) {
      tree.children
          .add(_recursiveLexer(node, customRenderTags, blacklistedElements));
    });

    return tree;
  }

  /// [_recursiveLexer] is the recursive worker function for [lexDomTree].
  ///
  /// It runs the parse functions of every type of
  /// element and returns a [StyledElement] tree representing the element.
  static StyledElement _recursiveLexer(
    dom.Node node,
    List<String> customRenderTags,
    List<String> blacklistedElements,
  ) {
    List<StyledElement> children = List<StyledElement>();

    node.nodes.forEach((childNode) {
      children.add(
          _recursiveLexer(childNode, customRenderTags, blacklistedElements));
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
      } else if (TABLE_STYLE_ELEMENTS.contains(node.localName)) {
        return parseTableDefinitionElement(node, children);
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

    //Make sure style is never null.
    if (tree.style == null) {
      tree.style = Style();
    }

    tree.children?.forEach((e) => applyCSS(e, sheet));

    return tree;
  }

  /// [applyInlineStyle] applies inline styles (i.e. `style="..."`) recursively into the StyledElement tree.
  static StyledElement applyInlineStyles(StyledElement tree) {

    if(tree.attributes.containsKey("style")) {
      tree.style = tree.style.merge(inlineCSSToStyle(tree.attributes['style']));
    }

    tree.children?.forEach(applyInlineStyles);

    return tree;
  }

  /// [applyCustomStyles] applies the [Style] objects passed into the [Html]
  /// widget onto the [StyledElement] tree, no cascading of styles is done at this point.
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

  /// [_cascadeStyles] cascades all of the inherited styles down the tree, applying them to each
  /// child that doesn't specify a different style.
  StyledElement _cascadeStyles(StyledElement tree) {
    tree.children?.forEach((child) {
      child.style = tree.style.copyOnlyInherited(child.style);
      _cascadeStyles(child);
    });

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
    tree = _processFontSize(tree);
    return tree;
  }

  /// [parseTree] converts a tree of [StyledElement]s to an [InlineSpan] tree.
  ///
  /// [parseTree] is responsible for handling the [customRender] parameter and
  /// deciding what different `Style.display` options look like as Widgets.
  InlineSpan parseTree(RenderContext context, StyledElement tree) {
    // Merge this element's style into the context so that children
    // inherit the correct style
    RenderContext newContext = RenderContext(
      buildContext: context.buildContext,
      parser: this,
      style: context.style.copyOnlyInherited(tree.style),
    );

    if (customRender?.containsKey(tree.name) ?? false) {
      return WidgetSpan(
        child: ContainerSpan(
          newContext: newContext,
          style: tree.style,
          shrinkWrap: context.parser.shrinkWrap,
          child: customRender[tree.name].call(
            newContext,
            ContainerSpan(
              newContext: newContext,
              style: tree.style,
              shrinkWrap: context.parser.shrinkWrap,
              children: tree.children
                      ?.map((tree) => parseTree(newContext, tree))
                      ?.toList() ??
                  [],
            ),
            tree.attributes,
            tree.element,
          ),
        ),
      );
    }

    //Return the correct InlineSpan based on the element type.
    if (tree.style?.display == Display.BLOCK) {
      return WidgetSpan(
        child: ContainerSpan(
          newContext: newContext,
          style: tree.style,
          shrinkWrap: context.parser.shrinkWrap,
          children: tree.children
                  ?.map((tree) => parseTree(newContext, tree))
                  ?.toList() ??
              [],
        ),
      );
    } else if (tree.style?.display == Display.LIST_ITEM) {
      return WidgetSpan(
        child: ContainerSpan(
          newContext: newContext,
          style: tree.style,
          shrinkWrap: context.parser.shrinkWrap,
          child: Stack(
            children: <Widget>[
              PositionedDirectional(
                width: 30, //TODO derive this from list padding.
                start: 0,
                child: Text('${newContext.style.markerContent}\t',
                    textAlign: TextAlign.right,
                    style: newContext.style.generateTextStyle()),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: 30), //TODO derive this from list padding.
                child: StyledText(
                  textSpan: TextSpan(
                    children: tree.children
                            ?.map((tree) => parseTree(newContext, tree))
                            ?.toList() ??
                        [],
                    style: newContext.style.generateTextStyle(),
                  ),
                  style: newContext.style,
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
          alignment: tree.alignment,
          baseline: TextBaseline.alphabetic,
          child: tree.toWidget(context),
        );
      }
    } else if (tree is InteractableElement) {
      return WidgetSpan(
        child: RawGestureDetector(
          gestures: {
            MultipleTapGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                MultipleTapGestureRecognizer>(
              () => MultipleTapGestureRecognizer(),
              (instance) {
                instance..onTap = () => onLinkTap?.call(tree.href);
              },
            ),
          },
          child: StyledText(
            textSpan: TextSpan(
              style: newContext.style.generateTextStyle(),
              children: tree.children
                      .map((tree) => parseTree(newContext, tree))
                      .toList() ??
                  [],
            ),
            style: newContext.style,
          ),
        ),
      );
    } else if (tree is LayoutElement) {
      return WidgetSpan(
        child: tree.toWidget(context),
      );
    } else if (tree.style.verticalAlign != null &&
        tree.style.verticalAlign != VerticalAlign.BASELINE) {
      double verticalOffset;
      switch (tree.style.verticalAlign) {
        case VerticalAlign.SUB:
          verticalOffset = tree.style.fontSize.size / 2.5;
          break;
        case VerticalAlign.SUPER:
          verticalOffset = tree.style.fontSize.size / -2.5;
          break;
        default:
          break;
      }
      //Requires special layout features not available in the TextStyle API.
      return WidgetSpan(
        child: Transform.translate(
          offset: Offset(0, verticalOffset),
          child: StyledText(
            textSpan: TextSpan(
              style: newContext.style.generateTextStyle(),
              children: tree.children
                      .map((tree) => parseTree(newContext, tree))
                      .toList() ??
                  [],
            ),
            style: newContext.style,
          ),
        ),
      );
    } else {
      ///[tree] is an inline element.
      return TextSpan(
        style: newContext.style.generateTextStyle(),
        children:
            tree.children.map((tree) => parseTree(newContext, tree)).toList(),
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

  /// [_processInlineWhitespace] is responsible for removing redundant whitespace
  /// between and among inline elements. It does so by creating a boolean [Context]
  /// and passing it to the [_processInlineWhitespaceRecursive] function.
  static StyledElement _processInlineWhitespace(StyledElement tree) {
    final whitespaceParsingContext = Context(false);
    tree = _processInlineWhitespaceRecursive(tree, whitespaceParsingContext);
    return tree;
  }

  /// [_processInlineWhitespaceRecursive] analyzes the whitespace between and among different
  /// inline elements, and replaces any instance of two or more spaces with a single space, according
  /// to the w3's HTML whitespace processing specification linked to above.
  static StyledElement _processInlineWhitespaceRecursive(
    StyledElement tree,
    Context<bool> wpc,
  ) {
    if (tree.style.display == Display.BLOCK) {
      wpc.data = false;
    }
    
    if (tree is ImageContentElement || tree is SvgContentElement) {
      wpc.data = false;
    }

    if (tree is TextContentElement) {
      if (wpc.data && tree.text.startsWith(' ')) {
        tree.text = tree.text.replaceFirst(' ', '');
      }

      if (tree.text.endsWith(' ')) {
        wpc.data = true;
      } else {
        wpc.data = false;
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
        .replaceAll(RegExp("\ *(?=\n)"), "\n")
        .replaceAll(RegExp("(?:\n)\ *"), "\n")
        .replaceAll("\n", " ")
        .replaceAll("\t", " ")
        .replaceAll(RegExp(" {2,}"), " ");
  }

  /// [processListCharacters] adds list characters to the front of all list items.
  ///
  /// The function uses the [_processListCharactersRecursive] function to do most of its work.
  static StyledElement _processListCharacters(StyledElement tree) {
    final olStack = ListQueue<Context<int>>();
    tree = _processListCharactersRecursive(tree, olStack);
    return tree;
  }

  /// [_processListCharactersRecursive] uses a Stack of integers to properly number and
  /// bullet all list items according to the [ListStyleType] they have been given.
  static StyledElement _processListCharactersRecursive(
      StyledElement tree, ListQueue<Context<int>> olStack) {
    if (tree.name == 'ol') {
      olStack.add(Context(0));
    } else if (tree.style.display == Display.LIST_ITEM) {
      switch (tree.style.listStyleType) {
        case ListStyleType.DISC:
          tree.style.markerContent = '•';
          break;
        case ListStyleType.DECIMAL:
          olStack.last.data += 1;
          tree.style.markerContent = '${olStack.last.data}.';
      }
    }

    tree.children?.forEach((e) => _processListCharactersRecursive(e, olStack));

    if (tree.name == 'ol') {
      olStack.removeLast();
    }

    return tree;
  }

  /// [_processBeforesAndAfters] adds text content to the beginning and end of
  /// the list of the trees children according to the `before` and `after` Style
  /// properties.
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
      if ((tree.style.height ?? 0) == 0) {
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
      if (tree.style.margin == null) {
        tree.style.margin = EdgeInsets.only(top: newOuterMarginTop);
      } else {
        tree.style.margin = tree.style.margin.copyWith(top: newOuterMarginTop);
      }

      // And remove the child's margin
      if (tree.children.first.style.margin == null) {
        tree.children.first.style.margin = EdgeInsets.zero;
      } else {
        tree.children.first.style.margin =
            tree.children.first.style.margin.copyWith(top: 0);
      }
    }

    // Handle case (3) from above.
    // Bottom margins cannot collapse if the element has padding
    if ((tree.style.padding?.bottom ?? 0) == 0) {
      final parentBottom = tree.style.margin?.bottom ?? 0;
      final lastChildBottom = tree.children.last.style.margin?.bottom ?? 0;
      final newOuterMarginBottom = max(parentBottom, lastChildBottom);

      // Set the parent's margin
      if (tree.style.margin == null) {
        tree.style.margin = EdgeInsets.only(bottom: newOuterMarginBottom);
      } else {
        tree.style.margin =
            tree.style.margin.copyWith(bottom: newOuterMarginBottom);
      }

      // And remove the child's margin
      if (tree.children.last.style.margin == null) {
        tree.children.last.style.margin = EdgeInsets.zero;
      } else {
        tree.children.last.style.margin =
            tree.children.last.style.margin.copyWith(bottom: 0);
      }
    }

    // Handle case (2) from above.
    if (tree.children.length > 1) {
      for (int i = 1; i < tree.children.length; i++) {
        final previousSiblingBottom =
            tree.children[i - 1].style.margin?.bottom ?? 0;
        final thisTop = tree.children[i].style.margin?.top ?? 0;
        final newInternalMargin = max(previousSiblingBottom, thisTop) / 2;

        if (tree.children[i - 1].style.margin == null) {
          tree.children[i - 1].style.margin =
              EdgeInsets.only(bottom: newInternalMargin);
        } else {
          tree.children[i - 1].style.margin = tree.children[i - 1].style.margin
              .copyWith(bottom: newInternalMargin);
        }

        if (tree.children[i].style.margin == null) {
          tree.children[i].style.margin =
              EdgeInsets.only(top: newInternalMargin);
        } else {
          tree.children[i].style.margin =
              tree.children[i].style.margin.copyWith(top: newInternalMargin);
        }
      }
    }

    return tree;
  }

  /// [removeEmptyElements] recursively removes empty elements.
  ///
  /// An empty element is any [EmptyContentElement], any empty [TextContentElement],
  /// or any block-level [TextContentElement] that contains only whitespace and doesn't follow
  /// a block element or a line break.
  static StyledElement _removeEmptyElements(StyledElement tree) {
    List<StyledElement> toRemove = new List<StyledElement>();
    bool lastChildBlock = true;
    tree.children?.forEach((child) {
      if (child is EmptyContentElement) {
        toRemove.add(child);
      } else if (child is TextContentElement && (child.text.isEmpty)) {
        toRemove.add(child);
      } else if (child is TextContentElement &&
          child.style.whiteSpace != WhiteSpace.PRE &&
          tree.style.display == Display.BLOCK &&
          child.text.trim().isEmpty &&
          lastChildBlock) {
        toRemove.add(child);
      } else {
        _removeEmptyElements(child);
      }

      // This is used above to check if the previous element is a block element or a line break.
      lastChildBlock = (child.style.display == Display.BLOCK ||
          child.style.display == Display.LIST_ITEM ||
          (child is TextContentElement && child.text == '\n'));
    });
    tree.children?.removeWhere((element) => toRemove.contains(element));

    return tree;
  }

  /// [_processFontSize] changes percent-based font sizes (negative numbers in this implementation)
  /// to pixel-based font sizes.
  static StyledElement _processFontSize(StyledElement tree) {
    double parentFontSize = tree.style?.fontSize?.size ?? FontSize.medium.size;

    tree.children?.forEach((child) {
      if ((child.style.fontSize?.size ?? parentFontSize) < 0) {
        child.style.fontSize =
            FontSize(parentFontSize * -child.style.fontSize.size);
      }

      _processFontSize(child);
    });
    return tree;
  }
}

/// The [RenderContext] is available when parsing the tree. It contains information
/// about the [BuildContext] of the `Html` widget, contains the configuration available
/// in the [HtmlParser], and contains information about the [Style] of the current
/// tree root.
class RenderContext {
  final BuildContext buildContext;
  final HtmlParser parser;
  final Style style;

  RenderContext({
    this.buildContext,
    this.parser,
    this.style,
  });
}

/// A [ContainerSpan] is a widget with an [InlineSpan] child or children.
///
/// A [ContainerSpan] can have a border, background color, height, width, padding, and margin
/// and can represent either an INLINE or BLOCK-level element.
class ContainerSpan extends StatelessWidget {
  final Widget child;
  final List<InlineSpan> children;
  final Style style;
  final RenderContext newContext;
  final bool shrinkWrap;

  ContainerSpan({
    this.child,
    this.children,
    this.style,
    this.newContext,
    this.shrinkWrap = false,
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
      alignment: shrinkWrap ? null : style?.alignment,
      child: child ??
          StyledText(
            textSpan: TextSpan(
              style: newContext.style.generateTextStyle(),
              children: children,
            ),
            style: newContext.style,
          ),
    );
  }
}

class StyledText extends StatelessWidget {
  final InlineSpan textSpan;
  final Style style;

  const StyledText({
    this.textSpan,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: style.display == Display.BLOCK || style.display == Display.LIST_ITEM? double.infinity: null,
      child: Text.rich(
        textSpan,
        style: style.generateTextStyle(),
        textAlign: style.textAlign,
        textDirection: style.direction,
      ),
    );
  }
}
