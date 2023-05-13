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
  final OnCssParseError? onCssParseError;
  final bool shrinkWrap;
  final Map<String, Style> style;
  final List<HtmlExtension> extensions;
  final Set<String>? doNotRenderTheseTags;
  final Set<String>? onlyRenderTheseTags;
  final OnTap? internalOnAnchorTap;
  final Html? root;

  HtmlParser({
    required super.key,
    required this.htmlData,
    required this.onLinkTap,
    required this.onAnchorTap,
    required this.onCssParseError,
    required this.shrinkWrap,
    required this.style,
    required this.extensions,
    required this.doNotRenderTheseTags,
    required this.onlyRenderTheseTags,
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
    // Preparing Step
    prepareHtmlTree();

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
    //Rendering Step
    return CssBoxWidget.withInlineSpanChildren(
      style: tree.style,
      //TODO can we have buildTree return a list of InlineSpans rather than a single one.
      children: [buildTree()],
      shrinkWrap: widget.shrinkWrap,
    );
  }

  @override
  void dispose() {
    for (var e in widget.extensions) {
      e.onDispose();
    }
    super.dispose();
  }

  /// Converts the tree of Html nodes into a simplified StyledElement tree
  void prepareHtmlTree() {
    tree = StyledElement(
      name: '[Tree Root]',
      children: [],
      node: widget.htmlData,
      style: Style.fromTextStyle(DefaultTextStyle.of(context)
          .style), //TODO this was Theme.of(context).textTheme.bodyText2!. Compare.
    );

    for (var node in widget.htmlData.nodes) {
      tree.children.add(_prepareHtmlTreeRecursive(node));
    }
  }

  bool _isTagRestricted(ExtensionContext context) {
    // Block the tag from rendering if it is restricted.
    if (context.node is! html.Element) {
      return false;
    }

    if (widget.doNotRenderTheseTags != null &&
        widget.doNotRenderTheseTags!.contains(context.elementName)) {
      return true;
    }

    if (widget.onlyRenderTheseTags != null &&
        !widget.onlyRenderTheseTags!.contains(context.elementName)) {
      return true;
    }

    return false;
  }

  /// Recursive helper method for [lexHtmlTree].
  StyledElement _prepareHtmlTreeRecursive(html.Node node) {
    // Set the extension context for this node.
    final extensionContext = ExtensionContext(
      parser: widget,
      buildContext: context,
      node: node,
      currentStep: CurrentStep.preparing,
    );

    // Block the tag from rendering if it is restricted.
    if (_isTagRestricted(extensionContext)) {
      return EmptyContentElement(node: node);
    }

    // Lex this element's children
    final children = node.nodes.map(_prepareHtmlTreeRecursive).toList();

    // Loop through every extension and see if it can handle this node
    for (final extension in widget.extensions) {
      if (extension.matches(extensionContext)) {
        return extension.prepare(extensionContext, children);
      }
    }

    // Loop through built in elements and see if they can handle this node.
    for (final builtIn in HtmlParser.builtIns) {
      if (builtIn.matches(extensionContext)) {
        return builtIn.prepare(extensionContext, children);
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
      currentStep: CurrentStep.preStyling,
    );

    // Prevent restricted tags from getting sent to extensions.
    if (_isTagRestricted(extensionContext)) {
      return;
    }

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
      currentStep: CurrentStep.preProcessing,
    );

    // Prevent restricted tags from getting sent to extensions
    if (_isTagRestricted(extensionContext)) {
      return;
    }

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

  /// [buildTree] converts a tree of [StyledElement]s to an [InlineSpan] tree.
  InlineSpan buildTree() {
    //TODO, can't we just break tree out from parent element created in lexHtmlTree?
    return _buildTreeRecursive(tree);
  }

  InlineSpan _buildTreeRecursive(StyledElement tree) {
    // Set the extension context for this node.
    final extensionContext = ExtensionContext(
      parser: widget,
      buildContext: context,
      node: tree.node,
      styledElement: tree,
      currentStep: CurrentStep.building,
    );

    // Block restricted tags from getting sent to extensions
    if (_isTagRestricted(extensionContext)) {
      return const TextSpan(text: "");
    }

    // Generate a function that allows children to be generated
    Map<StyledElement, InlineSpan> parseChildren() {
      return Map.fromEntries(tree.children.map((child) {
        return MapEntry(child, _buildTreeRecursive(child));
      }));
    }

    // Loop through every extension and see if it can handle this node
    for (final extension in widget.extensions) {
      if (extension.matches(extensionContext)) {
        return extension.build(extensionContext, parseChildren);
      }
    }

    // Loop through built in elements and see if they can handle this node.
    for (final builtIn in HtmlParser.builtIns) {
      if (builtIn.matches(extensionContext)) {
        return builtIn.build(extensionContext, parseChildren);
      }
    }

    return const TextSpan(text: "");
  }
}
