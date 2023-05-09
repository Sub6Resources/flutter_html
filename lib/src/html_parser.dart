import 'package:csslib/parser.dart' as css_parser;
import 'package:csslib/visitor.dart' as css;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/src/builtins/details_element_builtin.dart';
import 'package:flutter_html/src/builtins/image_builtin.dart';
import 'package:flutter_html/src/builtins/interactive_element_builtin.dart';
import 'package:flutter_html/src/builtins/ruby_builtin.dart';
import 'package:flutter_html/src/builtins/styled_element_builtin.dart';
import 'package:flutter_html/src/builtins/text_builtin.dart';
import 'package:flutter_html/src/builtins/vertical_align_builtin.dart';
import 'package:flutter_html/src/css_parser.dart';
import 'package:flutter_html/src/processing/befores_afters.dart';
import 'package:flutter_html/src/processing/lists.dart';
import 'package:flutter_html/src/processing/margins.dart';
import 'package:flutter_html/src/processing/relative_sizes.dart';
import 'package:flutter_html/src/processing/whitespace.dart';
import 'package:html/dom.dart' as html;
import 'package:html/parser.dart' as html_parser;

//TODO had to remove RenderContext. Document alternatives
typedef OnTap = void Function(
  String? url,
  Map<String, String> attributes,
  html.Element? element,
);
typedef OnCssParseError = String? Function(
  String css,
  List<css_parser.Message> errors,
);

class HtmlParser extends StatefulWidget {
  final html.Element htmlData;
  final OnTap? onLinkTap;
  final OnTap? onAnchorTap;
  final OnTap? onImageTap;
  final OnCssParseError? onCssParseError;
  final ImageErrorListener? onImageError;
  final bool shrinkWrap;

  final Map<String, Style> style;
  final List<Extension> extensions;
  final List<String> tagsList; //TODO replace with blacklist/whitelist
  final OnTap? internalOnAnchorTap;
  final Html? root;

  HtmlParser({
    required super.key,
    required this.htmlData,
    required this.onLinkTap,
    required this.onAnchorTap,
    required this.onImageTap,
    required this.onCssParseError,
    required this.onImageError,
    required this.shrinkWrap,
    required this.style,
    required this.extensions,
    required this.tagsList,
    this.root,
  }) : internalOnAnchorTap = onAnchorTap ??
            (key != null ? _handleAnchorTap(key, onLinkTap) : onLinkTap);

  @override
  State<HtmlParser> createState() => _HtmlParserState();

  static final builtIns = [
    const ImageBuiltIn(),
    const VerticalAlignBuiltIn(),
    const InteractiveElementBuiltIn(),
    const RubyBuiltIn(),
    const DetailsElementBuiltIn(),
    const StyledElementBuiltIn(),
    const TextBuiltIn(),
  ];

  /// [parseHTML] converts a string of HTML to a DOM element using the dart `html` library.
  static html.Element parseHTML(String data) {
    return html_parser.parse(data).documentElement!;
  }

  /// [parseCss] converts a string of CSS to a CSS stylesheet using the dart `csslib` library.
  static css.StyleSheet parseCss(String data) {
    return css_parser.parse(data);
  }

  static OnTap _handleAnchorTap(Key key, OnTap? onLinkTap) =>
      (String? url, Map<String, String> attributes, html.Element? element) {
        if (url?.startsWith("#") == true) {
          final anchorContext =
              AnchorKey.forId(key, url!.substring(1))?.currentContext;
          if (anchorContext != null) {
            Scrollable.ensureVisible(anchorContext);
          }
          return;
        }
        onLinkTap?.call(url, attributes, element);
      };
}

class _HtmlParserState extends State<HtmlParser> {
  late StyledElement tree;

  @override
  void didChangeDependencies() {
    prepareTree();
    super.didChangeDependencies();
  }

  void prepareTree() {
    // Lexing Step
    lexHtmlTree();

    // Styling Step
    beforeStyleTree(tree);
    styleTree();

    // Processing Step
    beforeProcessTree(tree);
    processTree();
  }

  /// As the widget [build]s, the HTML data is processed into a tree of [StyledElement]s,
  /// which are then parsed into an [InlineSpan] tree that is then rendered to the screen by Flutter
  @override
  Widget build(BuildContext context) {
    //Parsing Step
    return CssBoxWidget.withInlineSpanChildren(
      style: tree.style,
      //TODO can we have parseTree return a list of InlineSpans rather than a single one.
      children: [parseTree()],
      shrinkWrap: widget.shrinkWrap,
    );
  }

  /// Converts the tree of Html nodes into a simplified StyledElement tree
  void lexHtmlTree() {
    tree = StyledElement(
      name: '[Tree Root]',
      children: [],
      node: widget.htmlData,
      style: Style.fromTextStyle(DefaultTextStyle.of(context)
          .style), //TODO this was Theme.of(context).textTheme.bodyText2!. Compare.
    );

    for (var node in widget.htmlData.nodes) {
      tree.children.add(_lexHtmlTreeRecursive(node));
    }
  }

  /// Recursive helper method for [lexHtmlTree].
  StyledElement _lexHtmlTreeRecursive(html.Node node) {
    // Lex this element's children
    final children = node.nodes.map(_lexHtmlTreeRecursive).toList();

    // Set the extension context for this node.
    final extensionContext = ExtensionContext(
      parser: widget,
      buildContext: context,
      node: node,
    );

    // Block the widget from rendering if it isn't in the tag list.
    if (node is html.Element &&
        !widget.tagsList.contains(extensionContext.elementName)) {
      return EmptyContentElement(node: node);
    }

    // Loop through every extension and see if it can handle this node
    for (final extension in widget.extensions) {
      if (extension.matches(extensionContext)) {
        return extension.lex(extensionContext, children);
      }
    }

    // Loop through built in elements and see if they can handle this node.
    for (final builtIn in HtmlParser.builtIns) {
      if (builtIn.matches(extensionContext)) {
        return builtIn.lex(extensionContext, children);
      }
    }

    // If no extension or built-in matches, then return an empty content element.
    return EmptyContentElement(node: node);
  }

  /// Called before any styling is cascaded on the tree
  void beforeStyleTree(StyledElement tree) {
    final extensionContext = ExtensionContext(
      node: tree.node,
      parser: widget,
      styledElement: tree,
      buildContext: context,
    );

    // Loop through every extension and see if it wants to process this element
    for (final extension in widget.extensions) {
      if (extension.matches(extensionContext)) {
        extension.beforeStyle(extensionContext);
      }
    }

    // Loop through built in elements and see if they want to process this element.
    for (final builtIn in HtmlParser.builtIns) {
      if (builtIn.matches(extensionContext)) {
        builtIn.beforeStyle(extensionContext);
      }
    }

    // Do the same recursively
    tree.children.forEach(beforeStyleTree);
  }

  /// [styleTree] takes the lexed [StyleElement] tree and applies external,
  /// inline, and custom CSS/Flutter styles, and then cascades the styles down the tree.
  void styleTree() {
    final styleTagContents = widget.htmlData
        .getElementsByTagName("style")
        .map((e) => e.innerHtml)
        .join();
    final styleTagDeclarations =
        parseExternalCss(styleTagContents, widget.onCssParseError);

    _styleTreeRecursive(tree, styleTagDeclarations);
  }

  /// Recursive helper method for [styleTree].
  void _styleTreeRecursive(StyledElement tree, styleTagDeclarations) {
    // Apply external CSS
    styleTagDeclarations.forEach((selector, style) {
      if (tree.matchesSelector(selector)) {
        tree.style = tree.style.merge(declarationsToStyle(style));
      }
    });

    // Apply inline styles
    if (tree.attributes.containsKey("style")) {
      final newStyle =
          inlineCssToStyle(tree.attributes['style'], widget.onCssParseError);
      if (newStyle != null) {
        tree.style = tree.style.merge(newStyle);
      }
    }

    // Apply custom styles
    widget.style.forEach((selector, style) {
      if (tree.matchesSelector(selector)) {
        tree.style = tree.style.merge(style);
      }
    });

    // Cascade applicable styles down the tree. Recurse for all children
    for (final child in tree.children) {
      child.style = tree.style.copyOnlyInherited(child.style);
      _styleTreeRecursive(child, styleTagDeclarations);
    }
  }

  /// Called before any processing is done on the tree
  void beforeProcessTree(StyledElement tree) {
    final extensionContext = ExtensionContext(
      node: tree.node,
      parser: widget,
      styledElement: tree,
      buildContext: context,
    );

    // Loop through every extension and see if it can process this element
    for (final extension in widget.extensions) {
      if (extension.matches(extensionContext)) {
        extension.beforeProcessing(extensionContext);
      }
    }

    // Loop through built in elements and see if they can process this element.
    for (final builtIn in HtmlParser.builtIns) {
      if (builtIn.matches(extensionContext)) {
        builtIn.beforeProcessing(extensionContext);
      }
    }

    // Do the same recursively
    tree.children.forEach(beforeProcessTree);
  }

  /// [processTree] takes the now-styled [StyleElement] tree and does some final
  /// processing steps: removing unnecessary whitespace and empty elements,
  /// calculating relative values, processing list markers and counters,
  /// processing `before`/`after` generated elements, and collapsing margins
  /// according to CSS rules.
  void processTree() {
    tree = WhitespaceProcessing.processWhitespace(tree);
    tree = RelativeSizesProcessing.processRelativeValues(tree);
    tree = ListProcessing.processLists(tree);
    tree = BeforesAftersProcessing.processBeforesAfters(tree);
    tree = MarginProcessing.processMargins(tree);
  }

  /// [parseTree] converts a tree of [StyledElement]s to an [InlineSpan] tree.
  InlineSpan parseTree() {
    //TODO, can't we just break tree out from parent element created in lexHtmlTree?
    return _parseTreeRecursive(tree);
  }

  InlineSpan _parseTreeRecursive(StyledElement tree) {
    Map<StyledElement, InlineSpan> parseChildren() {
      return Map.fromEntries(tree.children.map((child) {
        return MapEntry(child, _parseTreeRecursive(child));
      }));
    }

    // Set the extension context for this node.
    final extensionContext = ExtensionContext(
      parser: widget,
      buildContext: context,
      node: tree.node,
      styledElement: tree,
    );

    // Loop through every extension and see if it can handle this node
    for (final extension in widget.extensions) {
      if (extension.matches(extensionContext)) {
        return extension.parse(extensionContext, parseChildren);
      }
    }

    // Loop through built in elements and see if they can handle this node.
    for (final builtIn in HtmlParser.builtIns) {
      if (builtIn.matches(extensionContext)) {
        return builtIn.parse(extensionContext, parseChildren);
      }
    }

    return const TextSpan(text: "");
  }
}
