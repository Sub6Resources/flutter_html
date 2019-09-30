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

  //TODO(Sub6Resources): Apply inline styles
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

  static StyledElement applyCSS(StyledElement tree, css.StyleSheet sheet) {
    sheet.topLevels.forEach((treeNode) {
      if (treeNode is css.RuleSet) {
        print(treeNode
            .selectorGroup.selectors.first.simpleSelectorSequences.first.simpleSelector.name);
      }
    });

    return tree;
  }

  static StyledElement applyInlineStyles(StyledElement tree) {
    //TODO

    return tree;
  }

  /// [_applyCustomStyles] applies the [Style] objects passed into the [Html]
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
    tree = _processWhitespace(tree);
    tree = _removeEmptyElements(tree);
    //TODO(Sub6Resources): Make this better.
    tree = _processListCharacters(tree);
    tree = _processBeforesAndAfters(tree);
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
      ///[tree] is an inline element, as such, it can only have horizontal margins.
      return TextSpan(
        style: newContext.style.generateTextStyle(),
        children: tree.children.map((tree) => parseTree(newContext, tree)).toList(),
      );
    }
  }

  /// [processWhitespace] removes unnecessary whitespace from the StyledElement tree.
  static StyledElement _processWhitespace(StyledElement tree) {
    // Goal is to Follow specs given at https://www.w3.org/TR/css-text-3/
    // specs outlined less technically at https://medium.com/@patrickbrosset/when-does-white-space-matter-in-html-b90e8a7cdd33
    if (tree.style?.preserveWhitespace ?? false) {
      //preserve this whitespace
    } else if (tree is TextContentElement) {
      tree.text = _removeUnnecessaryWhitespace(tree.text);
    } else {
      //TODO(Sub6Resources): remove all but one space even across inline elements
      tree.children?.forEach(_processWhitespace);
    }
    return tree;
  }

  /// [_removeUnnecessaryWhitespace] removes most unnecessary whitespace
  static String _removeUnnecessaryWhitespace(String text) {
    return text
        .replaceAll(RegExp("\ *(?=\n)"), "")
        .replaceAll(RegExp("(?:\n)\ *"), "")
        .replaceAll("\n", " ")
        .replaceAll("\t", " ")
        .replaceAll(RegExp(" {2,}"), " ");
  }

  /// [processListCharacters] adds list characters to the front of all list items.
  static StyledElement _processListCharacters(StyledElement tree) {
    if (tree.style?.display == Display.BLOCK && (tree.name == "ol" || tree.name == "ul")) {
      for (int i = 0; i < tree.children?.length; i++) {
        if (tree.children[i].name == "li") {
          tree.children[i].children?.insert(
            0,
            TextContentElement(
              text: tree.name == "ol" ? "${i + 1}.\t" : "•\t",
            ),
          );
        }
      }
    }
    tree.children?.forEach(_processListCharacters);
    return tree;
  }

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

class RenderContext {
  final Style style;

  RenderContext({this.style});
}

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
