import 'dart:collection';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:csslib/parser.dart' as cssparser;
import 'package:csslib/visitor.dart' as css;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/image_render.dart';
import 'package:flutter_html/src/anchor.dart';
import 'package:flutter_html/src/css_parser.dart';
import 'package:flutter_html/src/html_elements.dart';
import 'package:flutter_html/src/layout_element.dart';
import 'package:flutter_html/src/utils.dart';
import 'package:flutter_html/style.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as htmlparser;
import 'package:webview_flutter/webview_flutter.dart';

typedef OnTap = void Function(
    String? url,
    RenderContext context,
    Map<String, String> attributes,
    dom.Element? element,
);
typedef OnMathError = Widget Function(
    String parsedTex,
    String exception,
    String exceptionWithType,
);
typedef OnCssParseError = String? Function(
  String css,
  List<cssparser.Message> errors,
);
typedef CustomRender = dynamic Function(
  RenderContext context,
  Widget parsedChild,
);

class HtmlParser extends StatelessWidget {
  final Key? key;
  final dom.Document htmlData;
  final OnTap? onLinkTap;
  final OnTap? onImageTap;
  final OnCssParseError? onCssParseError;
  final ImageErrorListener? onImageError;
  final OnMathError? onMathError;
  final bool shrinkWrap;

  final Map<String, Style> style;
  final Map<String, CustomRender> customRender;
  final Map<ImageSourceMatcher, ImageRender> imageRenders;
  final List<String> tagsList;
  final NavigationDelegate? navigationDelegateForIframe;
  final OnTap? _onAnchorTap;

  HtmlParser({
    required this.key,
    required this.htmlData,
    required this.onLinkTap,
    required this.onImageTap,
    required this.onCssParseError,
    required this.onImageError,
    required this.onMathError,
    required this.shrinkWrap,
    required this.style,
    required this.customRender,
    required this.imageRenders,
    required this.tagsList,
    required this.navigationDelegateForIframe,
  }): this._onAnchorTap = key != null ? _handleAnchorTap(key, onLinkTap): null, super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, List<css.Expression>>> declarations = _getExternalCssDeclarations(htmlData.getElementsByTagName("style"), onCssParseError);
    StyledElement lexedTree = lexDomTree(
      htmlData,
      customRender.keys.toList(),
      tagsList,
      navigationDelegateForIframe,
    );
    StyledElement? externalCssStyledTree;
    if (declarations.isNotEmpty) {
      externalCssStyledTree = _applyExternalCss(declarations, lexedTree);
    }
    StyledElement inlineStyledTree = _applyInlineStyles(externalCssStyledTree ?? lexedTree, onCssParseError);
    StyledElement customStyledTree = _applyCustomStyles(style, inlineStyledTree);
    StyledElement cascadedStyledTree = _cascadeStyles(style, customStyledTree);
    StyledElement cleanedTree = cleanTree(cascadedStyledTree);
    InlineSpan parsedTree = parseTree(
      RenderContext(
        buildContext: context,
        parser: this,
        tree: cleanedTree,
        style: Style.fromTextStyle(Theme.of(context).textTheme.bodyText2!),
      ),
      cleanedTree,
    );

    // This is the final scaling that assumes any other StyledText instances are
    // using textScaleFactor = 1.0 (which is the default). This ensures the correct
    // scaling is used, but relies on https://github.com/flutter/flutter/pull/59711
    // to wrap everything when larger accessibility fonts are used.
    return StyledText(
      textSpan: parsedTree,
      style: cleanedTree.style,
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      renderContext: RenderContext(
        buildContext: context,
        parser: this,
        tree: cleanedTree,
        style: Style.fromTextStyle(Theme.of(context).textTheme.bodyText2!),
      ),
    );
  }

  /// [parseHTML] converts a string of HTML to a DOM document using the dart `html` library.
  static dom.Document parseHTML(String data) {
    return htmlparser.parse(data);
  }

  /// [parseCss] converts a string of CSS to a CSS stylesheet using the dart `csslib` library.
  static css.StyleSheet parseCss(String data) {
    return cssparser.parse(data);
  }

  /// [lexDomTree] converts a DOM document to a simplified tree of [StyledElement]s.
  static StyledElement lexDomTree(
    dom.Document html,
    List<String> customRenderTags,
    List<String> tagsList,
    NavigationDelegate? navigationDelegateForIframe,
  ) {
    StyledElement tree = StyledElement(
      name: "[Tree Root]",
      children: <StyledElement>[],
      node: html.documentElement,
      style: Style(),
    );

    html.nodes.forEach((node) {
      tree.children.add(_recursiveLexer(
        node,
        customRenderTags,
        tagsList,
        navigationDelegateForIframe,
      ));
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
    List<String> tagsList,
    NavigationDelegate? navigationDelegateForIframe,
  ) {
    List<StyledElement> children = <StyledElement>[];

    node.nodes.forEach((childNode) {
      children.add(_recursiveLexer(
        childNode,
        customRenderTags,
        tagsList,
        navigationDelegateForIframe,
      ));
    });

    //TODO(Sub6Resources): There's probably a more efficient way to look this up.
    if (node is dom.Element) {
      if (!tagsList.contains(node.localName)) {
        return EmptyContentElement();
      }
      if (STYLED_ELEMENTS.contains(node.localName)) {
        return parseStyledElement(node, children);
      } else if (INTERACTABLE_ELEMENTS.contains(node.localName)) {
        return parseInteractableElement(node, children);
      } else if (REPLACED_ELEMENTS.contains(node.localName)) {
        return parseReplacedElement(node, navigationDelegateForIframe);
      } else if (LAYOUT_ELEMENTS.contains(node.localName)) {
        return parseLayoutElement(node, children);
      } else if (TABLE_CELL_ELEMENTS.contains(node.localName)) {
        return parseTableCellElement(node, children);
      } else if (TABLE_DEFINITION_ELEMENTS.contains(node.localName)) {
        return parseTableDefinitionElement(node, children);
      } else if (customRenderTags.contains(node.localName)) {
        return parseStyledElement(node, children);
      } else {
        return EmptyContentElement();
      }
    } else if (node is dom.Text) {
      return TextContentElement(text: node.text, style: Style(), element: node.parent, node: node);
    } else {
      return EmptyContentElement();
    }
  }

  static Map<String, Map<String, List<css.Expression>>> _getExternalCssDeclarations(List<dom.Element> styles, OnCssParseError? errorHandler) {
    String fullCss = "";
    for (final e in styles) {
      fullCss = fullCss + e.innerHtml;
    }
    if (fullCss.isNotEmpty) {
      final declarations = parseExternalCss(fullCss, errorHandler);
      return declarations;
    } else {
      return {};
    }
  }

  static StyledElement _applyExternalCss(Map<String, Map<String, List<css.Expression>>> declarations, StyledElement tree) {
    declarations.forEach((key, style) {
      if (tree.matchesSelector(key)) {
        tree.style = tree.style.merge(declarationsToStyle(style));
      }
    });

    tree.children.forEach((e) => _applyExternalCss(declarations, e));

    return tree;
  }

  static StyledElement _applyInlineStyles(StyledElement tree, OnCssParseError? errorHandler) {
    if (tree.attributes.containsKey("style")) {
      final newStyle = inlineCssToStyle(tree.attributes['style'], errorHandler);
      if (newStyle != null) {
        tree.style = tree.style.merge(newStyle);
      }
    }

    tree.children.forEach((e) => _applyInlineStyles(e, errorHandler));
    return tree;
  }

  /// [applyCustomStyles] applies the [Style] objects passed into the [Html]
  /// widget onto the [StyledElement] tree, no cascading of styles is done at this point.
  static StyledElement _applyCustomStyles(Map<String, Style> style, StyledElement tree) {
    style.forEach((key, style) {
      if (tree.matchesSelector(key)) {
        tree.style = tree.style.merge(style);
      }
    });
    tree.children.forEach((e) => _applyCustomStyles(style, e));

    return tree;
  }

  /// [_cascadeStyles] cascades all of the inherited styles down the tree, applying them to each
  /// child that doesn't specify a different style.
  static StyledElement _cascadeStyles(Map<String, Style> style, StyledElement tree) {
    tree.children.forEach((child) {
      child.style = tree.style.copyOnlyInherited(child.style);
      _cascadeStyles(style, child);
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
      tree: tree,
      style: context.style.copyOnlyInherited(tree.style),
    );
    List<int> indices = [];
    tree.children.forEachIndexed((index, element) {
      //we want the element to be a block element, but we don't want to add
      //new-lines before/after the html and body
      if (element.style.display == Display.BLOCK
          && element.element?.localName != "html"
          && element.element?.localName != "body"
      ) {
        //if the parent element is body and the element is first, we don't want
        //to add a new-line before
        if (index == 0 && element.element?.parent?.localName == "body") {
          indices.add(index + 1);
        } else {
          indices.addAll([index, index + 1]);
        }
      }
    });
    //we don't need a new-line at the end
    if (indices.isNotEmpty && indices.last == tree.children.length) {
      indices.removeLast();
    }
    indices = indices.toSet().toList();
    if (customRender.containsKey(tree.name)) {
      final render = customRender[tree.name]!.call(
        newContext,
        ContainerSpan(
          key: AnchorKey.of(key, tree),
          newContext: newContext,
          style: tree.style,
          shrinkWrap: context.parser.shrinkWrap,
          children: tree.children.map((tree) => parseTree(newContext, tree)).toList(),
        ),
      );
      if (render != null) {
        assert(render is InlineSpan || render is Widget);
        return render is InlineSpan
            ? render
            : WidgetSpan(
                child: ContainerSpan(
                  key: AnchorKey.of(key, tree),
                  newContext: newContext,
                  style: tree.style,
                  shrinkWrap: context.parser.shrinkWrap,
                  child: render,
                ),
              );
      }
    }

    //Return the correct InlineSpan based on the element type.
    if (tree.style.display == Display.BLOCK && !(tree is ReplacedElement)) {
      return WidgetSpan(
        child: ContainerSpan(
          key: AnchorKey.of(key, tree),
          newContext: newContext,
          style: tree.style,
          shrinkWrap: context.parser.shrinkWrap,
          children: tree.children.map((tree) => parseTree(newContext, tree)).toList(),
          indices: indices,
        ),
      );
    } else if (tree.style.display == Display.LIST_ITEM) {
      List<InlineSpan> getChildren(StyledElement tree) {
        InlineSpan tabSpan = WidgetSpan(child: Text("\t", textAlign: TextAlign.right));
        List<InlineSpan> children = tree.children.map((tree) => parseTree(newContext, tree)).toList();
        if (tree.style.listStylePosition == ListStylePosition.INSIDE) {
          children.insert(0, tabSpan);
        }
        return children;
      }

      return WidgetSpan(
        child: ContainerSpan(
          key: AnchorKey.of(key, tree),
          newContext: newContext,
          style: tree.style,
          shrinkWrap: context.parser.shrinkWrap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            textDirection: tree.style.direction,
            children: [
              tree.style.listStylePosition == ListStylePosition.OUTSIDE ?
              Padding(
                padding: tree.style.padding ?? EdgeInsets.only(left: tree.style.direction != TextDirection.rtl ? 10.0 : 0.0, right: tree.style.direction == TextDirection.rtl ? 10.0 : 0.0),
                child: Text(
                    "${newContext.style.markerContent}",
                    textAlign: TextAlign.right,
                    style: newContext.style.generateTextStyle()
                ),
              ) : Container(height: 0, width: 0),
              Text("\t", textAlign: TextAlign.right),
              Expanded(
                  child: Padding(
                      padding: tree.style.listStylePosition == ListStylePosition.INSIDE ?
                        EdgeInsets.only(left: tree.style.direction != TextDirection.rtl ? 10.0 : 0.0, right: tree.style.direction == TextDirection.rtl ? 10.0 : 0.0) : EdgeInsets.zero,
                      child: StyledText(
                        textSpan: TextSpan(
                          text: (tree.style.listStylePosition ==
                              ListStylePosition.INSIDE)
                              ? '${newContext.style.markerContent}'
                              : null,
                          children: getChildren(tree),
                          style: newContext.style.generateTextStyle(),
                        ),
                        style: newContext.style,
                        renderContext: context,
                      )
                  )
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
          child: tree.toWidget(context)!,
        );
      }
    } else if (tree is InteractableElement) {
      InlineSpan addTaps(InlineSpan childSpan, TextStyle childStyle) {
        if (childSpan is TextSpan) {
          return TextSpan(
            text: childSpan.text,
            children: childSpan.children
                ?.map((e) => addTaps(e, childStyle.merge(childSpan.style)))
                .toList(),
            style: newContext.style.generateTextStyle().merge(
                childSpan.style == null
                    ? childStyle
                    : childStyle.merge(childSpan.style)),
            semanticsLabel: childSpan.semanticsLabel,
            recognizer: TapGestureRecognizer()
              ..onTap =
                  _onAnchorTap != null ? () => _onAnchorTap!(tree.href, context, tree.attributes, tree.element) : null,
          );
        } else {
          return WidgetSpan(
            child: RawGestureDetector(
              key: AnchorKey.of(key, tree),
              gestures: {
                MultipleTapGestureRecognizer:
                    GestureRecognizerFactoryWithHandlers<
                        MultipleTapGestureRecognizer>(
                  () => MultipleTapGestureRecognizer(),
                  (instance) {
                    instance
                      ..onTap = _onAnchorTap != null
                          ? () => _onAnchorTap!(tree.href, context, tree.attributes, tree.element)
                          : null;
                  },
                ),
              },
              child: (childSpan as WidgetSpan).child,
            ),
          );
        }
      }

      return TextSpan(
        children: tree.children
                .map((tree) => parseTree(newContext, tree))
                .map((childSpan) {
              return addTaps(childSpan,
                  newContext.style.generateTextStyle().merge(childSpan.style));
            }).toList(),
      );
    } else if (tree is LayoutElement) {
      return WidgetSpan(
        child: tree.toWidget(context)!,
      );
    } else if (tree.style.verticalAlign != null &&
        tree.style.verticalAlign != VerticalAlign.BASELINE) {
      late double verticalOffset;
      switch (tree.style.verticalAlign) {
        case VerticalAlign.SUB:
          verticalOffset = tree.style.fontSize!.size! / 2.5;
          break;
        case VerticalAlign.SUPER:
          verticalOffset = tree.style.fontSize!.size! / -2.5;
          break;
        default:
          break;
      }
      //Requires special layout features not available in the TextStyle API.
      return WidgetSpan(
        child: Transform.translate(
          key: AnchorKey.of(key, tree),
          offset: Offset(0, verticalOffset),
          child: StyledText(
            textSpan: TextSpan(
              style: newContext.style.generateTextStyle(),
              children: tree.children
                      .map((tree) => parseTree(newContext, tree))
                      .toList(),
            ),
            style: newContext.style,
            renderContext: newContext,
          ),
        ),
      );
    } else {
      ///[tree] is an inline element.
      final children = tree.children.map((tree) => parseTree(newContext, tree)).toList();
      //use provided indices to insert new-lines at those locations
      //makes sure to account for list size changes with "+ i"
      indices.forEachIndexed((i, element) {
        if (newContext.parser.shrinkWrap) {
          children.insert(element + i, TextSpan(text: "\n"));
        }
      });
      return TextSpan(
        style: newContext.style.generateTextStyle(),
        children: children,
      );
    }
  }

  static OnTap _handleAnchorTap(Key key, OnTap? onLinkTap) =>
          (String? url, RenderContext context, Map<String, String> attributes, dom.Element? element) {
        if (url?.startsWith("#") == true) {
          final anchorContext = AnchorKey.forId(key, url!.substring(1))?.currentContext;
          if (anchorContext != null) {
            Scrollable.ensureVisible(anchorContext);
          }
          return;
        }
        onLinkTap?.call(url, context, attributes, element);
      };

  /// [processWhitespace] removes unnecessary whitespace from the StyledElement tree.
  ///
  /// The criteria for determining which whitespace is replaceable is outlined
  /// at https://www.w3.org/TR/css-text-3/
  /// and summarized at https://medium.com/@patrickbrosset/when-does-white-space-matter-in-html-b90e8a7cdd33
  static StyledElement _processInternalWhitespace(StyledElement tree) {
    if ((tree.style.whiteSpace ?? WhiteSpace.NORMAL) == WhiteSpace.PRE) {
      // Preserve this whitespace
    } else if (tree is TextContentElement) {
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
      int index = -1;
      if ((tree.element?.nodes.length ?? 0) > 1) {
        index = tree.element?.nodes.indexWhere((element) => element == tree.node) ?? -1;
      }
      if (index < 1 && tree.text!.startsWith(' ')
          && tree.element?.localName != "br") {
        tree.text = tree.text!.replaceFirst(' ', '');
      }
      if (index == (tree.element?.nodes.length ?? 1) - 1
          && (tree.text!.endsWith(' ') || tree.text!.endsWith('\n'))
          && tree.element?.localName != "br") {
        tree.text = tree.text!.trimRight();
      }
    }

    tree.children.forEach((e) => _processInlineWhitespaceRecursive(e, wpc));

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
      olStack.add(Context((tree.attributes['start'] != null ? int.tryParse(tree.attributes['start'] ?? "") ?? 1 : 1) - 1));
    } else if (tree.style.display == Display.LIST_ITEM && tree.style.listStyleType != null) {
      switch (tree.style.listStyleType!) {
        case ListStyleType.DISC:
          tree.style.markerContent = '•';
          break;
        case ListStyleType.DECIMAL:
          if (olStack.isEmpty) {
            olStack.add(Context((tree.attributes['start'] != null ? int.tryParse(tree.attributes['start'] ?? "") ?? 1 : 1) - 1));
          }
          olStack.last.data += 1;
          tree.style.markerContent = '${olStack.last.data}.';
          break;
      }
    }

    tree.children.forEach((e) => _processListCharactersRecursive(e, olStack));

    if (tree.name == 'ol') {
      olStack.removeLast();
    }

    return tree;
  }

  /// [_processBeforesAndAfters] adds text content to the beginning and end of
  /// the list of the trees children according to the `before` and `after` Style
  /// properties.
  static StyledElement _processBeforesAndAfters(StyledElement tree) {
    if (tree.style.before != null) {
      tree.children.insert(
          0, TextContentElement(text: tree.style.before, style: tree.style.copyWith(beforeAfterNull: true, display: Display.INLINE)));
    }
    if (tree.style.after != null) {
      tree.children
          .add(TextContentElement(text: tree.style.after, style: tree.style.copyWith(beforeAfterNull: true, display: Display.INLINE)));
    }

    tree.children.forEach(_processBeforesAndAfters);

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
    if (tree.children.isEmpty) {
      // Handle case (4) from above.
      if ((tree.style.height ?? 0) == 0) {
        tree.style.margin = EdgeInsets.zero;
      }
      return tree;
    }

    //Collapsing should be depth-first.
    tree.children.forEach(_collapseMargins);

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
        tree.style.margin = tree.style.margin!.copyWith(top: newOuterMarginTop);
      }

      // And remove the child's margin
      if (tree.children.first.style.margin == null) {
        tree.children.first.style.margin = EdgeInsets.zero;
      } else {
        tree.children.first.style.margin =
            tree.children.first.style.margin!.copyWith(top: 0);
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
            tree.style.margin!.copyWith(bottom: newOuterMarginBottom);
      }

      // And remove the child's margin
      if (tree.children.last.style.margin == null) {
        tree.children.last.style.margin = EdgeInsets.zero;
      } else {
        tree.children.last.style.margin =
            tree.children.last.style.margin!.copyWith(bottom: 0);
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
          tree.children[i - 1].style.margin = tree.children[i - 1].style.margin!
              .copyWith(bottom: newInternalMargin);
        }

        if (tree.children[i].style.margin == null) {
          tree.children[i].style.margin =
              EdgeInsets.only(top: newInternalMargin);
        } else {
          tree.children[i].style.margin =
              tree.children[i].style.margin!.copyWith(top: newInternalMargin);
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
    List<StyledElement> toRemove = <StyledElement>[];
    bool lastChildBlock = true;
    tree.children.forEach((child) {
      if (child is EmptyContentElement || child is EmptyLayoutElement) {
        toRemove.add(child);
      } else if (child is TextContentElement && (child.text!.trim().isEmpty)) {
        toRemove.add(child);
      } else if (child is TextContentElement &&
          child.style.whiteSpace != WhiteSpace.PRE &&
          tree.style.display == Display.BLOCK &&
          child.text!.trim().isEmpty &&
          lastChildBlock) {
        toRemove.add(child);
      } else if (child.style.display == Display.NONE) {
        toRemove.add(child);
      } else {
        _removeEmptyElements(child);
      }

      // This is used above to check if the previous element is a block element or a line break.
      lastChildBlock = (child.style.display == Display.BLOCK ||
          child.style.display == Display.LIST_ITEM ||
          (child is TextContentElement && child.text == '\n'));
    });
    tree.children.removeWhere((element) => toRemove.contains(element));

    return tree;
  }

  /// [_processFontSize] changes percent-based font sizes (negative numbers in this implementation)
  /// to pixel-based font sizes.
  static StyledElement _processFontSize(StyledElement tree) {
    double? parentFontSize = tree.style.fontSize?.size ?? FontSize.medium.size;

    tree.children.forEach((child) {
      if ((child.style.fontSize?.size ?? parentFontSize)! < 0) {
        child.style.fontSize =
            FontSize(parentFontSize! * -child.style.fontSize!.size!);
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
  final StyledElement tree;
  final Style style;

  RenderContext({
    required this.buildContext,
    required this.parser,
    required this.tree,
    required this.style,
  });
}

/// A [ContainerSpan] is a widget with an [InlineSpan] child or children.
///
/// A [ContainerSpan] can have a border, background color, height, width, padding, and margin
/// and can represent either an INLINE or BLOCK-level element.
class ContainerSpan extends StatelessWidget {
  final AnchorKey? key;
  final Widget? child;
  final List<InlineSpan>? children;
  final Style style;
  final RenderContext newContext;
  final bool shrinkWrap;
  final List<int> indices;

  ContainerSpan({
    this.key,
    this.child,
    this.children,
    required this.style,
    required this.newContext,
    this.shrinkWrap = false,
    this.indices = const [],
  }): super(key: key);

  @override
  Widget build(BuildContext _) {
    //use provided indices to insert new-lines at those locations
    //makes sure to account for list size changes with "+ i"
    indices.forEachIndexed((i, element) {
      if (children != null && newContext.parser.shrinkWrap) {
        children!.insert(element + i, TextSpan(text: "\n"));
      }
    });
    return Container(
      decoration: BoxDecoration(
        border: style.border,
        color: style.backgroundColor,
      ),
      height: style.height,
      width: style.width,
      padding: style.padding,
      margin: style.margin,
      alignment: shrinkWrap ? null : style.alignment,
      child: child ??
          StyledText(
            textSpan: TextSpan(
              style: newContext.style.generateTextStyle(),
              children: children,
            ),
            style: newContext.style,
            renderContext: newContext,
          ),
    );
  }
}

class StyledText extends StatelessWidget {
  final InlineSpan textSpan;
  final Style style;
  final double textScaleFactor;
  final RenderContext renderContext;
  final AnchorKey? key;

  const StyledText({
    required this.textSpan,
    required this.style,
    this.textScaleFactor = 1.0,
    required this.renderContext,
    this.key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: calculateWidth(),
      child: Text.rich(
        textSpan,
        style: style.generateTextStyle(),
        textAlign: style.textAlign,
        textDirection: style.direction,
        textScaleFactor: textScaleFactor,
        maxLines: style.maxLines,
        overflow: style.textOverflow,
      ),
    );
  }

  double? calculateWidth() {
    //if there is a specific text align then we should return the whole width,
    //otherwise the text align will appear to be unchanged.
    //potentially find a way to keep track of the max width needed for other
    //elements in the doc and use that instead?
    if (style.textAlign != null &&
        ((style.textAlign != TextAlign.left && (style.direction == null || style.direction == TextDirection.ltr)) ||
        (style.textAlign != TextAlign.right && style.direction == TextDirection.rtl))) {
      return double.infinity;
    }
    if ((style.display == Display.BLOCK || style.display == Display.LIST_ITEM) && !renderContext.parser.shrinkWrap) {
      print(renderContext.tree.element?.localName);
      return double.infinity;
    }
    if (!renderContext.parser.shrinkWrap && renderContext.tree.element?.localName == "html") {
      return MediaQuery.of(renderContext.buildContext).size.width;
    }
    return null;
  }
}
