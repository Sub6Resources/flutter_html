import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:matrix_link_text/link_text.dart';
import 'code_block.dart';
import 'package:flutter_highlight/themes/monokai.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import 'image_properties.dart';
import 'spoiler.dart';
import 'pill.dart';

typedef CustomRender = Widget Function(dom.Node node, List<Widget> children);
typedef CustomTextStyle = TextStyle Function(
  dom.Node node,
  TextStyle baseStyle,
);
typedef CustomTextAlign = TextAlign Function(dom.Element elem);
typedef CustomEdgeInsets = EdgeInsets Function(dom.Node node);
typedef OnLinkTap = void Function(String url);
typedef OnImageTap = void Function(String source);
typedef OnPillTap = void Function(String identifier);
typedef GetMxcUrl = String Function(String mxc, double width, double height,
    {bool animated});
typedef GetPillInfo = Future<Map<String, dynamic>> Function(String identifier);

const OFFSET_TAGS_FONT_SIZE_FACTOR =
    0.7; //The ratio of the parent font for each of the offset tags: sup or sub

const MATRIX_TO_SCHEME = "https://matrix.to/#/";
const MATRIX_SCHEME = "matrix:";

extension CssColor on Color {
  static Map<String, String> _cssReplacements = {
    "aliceblue": "#f0f8ff",
    "antiquewhite": "#faebd7",
    "aqua": "#00ffff",
    "aquamarine": "#7fffd4",
    "azure": "#f0ffff",
    "beige": "#f5f5dc",
    "bisque": "#ffe4c4",
    "black": "#000000",
    "blanchedalmond": "#ffebcd",
    "blue": "#0000ff",
    "blueviolet": "#8a2be2",
    "brown": "#a52a2a",
    "burlywood": "#deb887",
    "cadetblue": "#5f9ea0",
    "chartreuse": "#7fff00",
    "chocolate": "#d2691e",
    "coral": "#ff7f50",
    "cornflowerblue": "#6495ed",
    "cornsilk": "#fff8dc",
    "crimson": "#dc143c",
    "cyan": "#00ffff",
    "darkblue": "#00008b",
    "darkcyan": "#008b8b",
    "darkgoldenrod": "#b8860b",
    "darkgray": "#a9a9a9",
    "darkgreen": "#006400",
    "darkgrey": "#a9a9a9",
    "darkkhaki": "#bdb76b",
    "darkmagenta": "#8b008b",
    "darkolivegreen": "#556b2f",
    "darkorange": "#ff8c00",
    "darkorchid": "#9932cc",
    "darkred": "#8b0000",
    "darksalmon": "#e9967a",
    "darkseagreen": "#8fbc8f",
    "darkslateblue": "#483d8b",
    "darkslategray": "#2f4f4f",
    "darkslategrey": "#2f4f4f",
    "darkturquoise": "#00ced1",
    "darkviolet": "#9400d3",
    "deeppink": "#ff1493",
    "deepskyblue": "#00bfff",
    "dimgray": "#696969",
    "dimgrey": "#696969",
    "dodgerblue": "#1e90ff",
    "firebrick": "#b22222",
    "floralwhite": "#fffaf0",
    "forestgreen": "#228b22",
    "fuchsia": "#ff00ff",
    "gainsboro": "#dcdcdc",
    "ghostwhite": "#f8f8ff",
    "goldenrod": "#daa520",
    "gold": "#ffd700",
    "gray": "#808080",
    "green": "#008000",
    "greenyellow": "#adff2f",
    "grey": "#808080",
    "honeydew": "#f0fff0",
    "hotpink": "#ff69b4",
    "indianred": "#cd5c5c",
    "indigo": "#4b0082",
    "ivory": "#fffff0",
    "khaki": "#f0e68c",
    "lavenderblush": "#fff0f5",
    "lavender": "#e6e6fa",
    "lawngreen": "#7cfc00",
    "lemonchiffon": "#fffacd",
    "lightblue": "#add8e6",
    "lightcoral": "#f08080",
    "lightcyan": "#e0ffff",
    "lightgoldenrodyellow": "#fafad2",
    "lightgray": "#d3d3d3",
    "lightgreen": "#90ee90",
    "lightgrey": "#d3d3d3",
    "lightpink": "#ffb6c1",
    "lightsalmon": "#ffa07a",
    "lightseagreen": "#20b2aa",
    "lightskyblue": "#87cefa",
    "lightslategray": "#778899",
    "lightslategrey": "#778899",
    "lightsteelblue": "#b0c4de",
    "lightyellow": "#ffffe0",
    "lime": "#00ff00",
    "limegreen": "#32cd32",
    "linen": "#faf0e6",
    "magenta": "#ff00ff",
    "maroon": "#800000",
    "mediumaquamarine": "#66cdaa",
    "mediumblue": "#0000cd",
    "mediumorchid": "#ba55d3",
    "mediumpurple": "#9370db",
    "mediumseagreen": "#3cb371",
    "mediumslateblue": "#7b68ee",
    "mediumspringgreen": "#00fa9a",
    "mediumturquoise": "#48d1cc",
    "mediumvioletred": "#c71585",
    "midnightblue": "#191970",
    "mintcream": "#f5fffa",
    "mistyrose": "#ffe4e1",
    "moccasin": "#ffe4b5",
    "navajowhite": "#ffdead",
    "navy": "#000080",
    "oldlace": "#fdf5e6",
    "olive": "#808000",
    "olivedrab": "#6b8e23",
    "orange": "#ffa500",
    "orangered": "#ff4500",
    "orchid": "#da70d6",
    "palegoldenrod": "#eee8aa",
    "palegreen": "#98fb98",
    "paleturquoise": "#afeeee",
    "palevioletred": "#db7093",
    "papayawhip": "#ffefd5",
    "peachpuff": "#ffdab9",
    "peru": "#cd853f",
    "pink": "#ffc0cb",
    "plum": "#dda0dd",
    "powderblue": "#b0e0e6",
    "purple": "#800080",
    "rebeccapurple": "#663399",
    "red": "#ff0000",
    "rosybrown": "#bc8f8f",
    "royalblue": "#4169e1",
    "saddlebrown": "#8b4513",
    "salmon": "#fa8072",
    "sandybrown": "#f4a460",
    "seagreen": "#2e8b57",
    "seashell": "#fff5ee",
    "sienna": "#a0522d",
    "silver": "#c0c0c0",
    "skyblue": "#87ceeb",
    "slateblue": "#6a5acd",
    "slategray": "#708090",
    "slategrey": "#708090",
    "snow": "#fffafa",
    "springgreen": "#00ff7f",
    "steelblue": "#4682b4",
    "tan": "#d2b48c",
    "teal": "#008080",
    "thistle": "#d8bfd8",
    "tomato": "#ff6347",
    "turquoise": "#40e0d0",
    "violet": "#ee82ee",
    "wheat": "#f5deb3",
    "white": "#ffffff",
    "whitesmoke": "#f5f5f5",
    "yellow": "#ffff00",
    "yellowgreen": "#9acd32",
  };

  static Color fromCss(String hexString) {
    if (hexString == null) {
      return null;
    }
    if (_cssReplacements.containsKey(hexString.toLowerCase())) {
      hexString = _cssReplacements[hexString.toLowerCase()];
    }
    final matches =
        RegExp(r"^#((?:[0-9a-fA-F]{3}){1,2})$").firstMatch(hexString);
    if (matches == null) {
      return null;
    }
    hexString = matches[1];
    final buffer = StringBuffer();
    buffer.write("ff");
    if (hexString.length == 3) {
      for (final char in hexString.runes) {
        buffer.write(char + char);
      }
    } else {
      buffer.write(hexString);
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

class LinkBlock extends Container {
  // final String url;
  // final EdgeInsets padding;
  // final EdgeInsets margin;
  // final OnLinkTap onLinkTap;
  final List<Widget> children;

  LinkBlock({
    String url,
    EdgeInsets padding,
    EdgeInsets margin,
    OnLinkTap onLinkTap,
    this.children,
  }) : super(
          padding: padding,
          margin: margin,
          child: GestureDetector(
            onTap: () {
              onLinkTap(url);
            },
            child: Column(
              children: children,
            ),
          ),
        );
}

class BlockText extends StatelessWidget {
  final Text child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Decoration decoration;
  final bool shrinkToFit;
  final double width;

  BlockText({
    @required this.child,
    @required this.shrinkToFit,
    this.padding,
    this.margin,
    this.decoration,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: shrinkToFit ? width : double.infinity,
      padding: this.padding,
      margin: this.margin,
      decoration: this.decoration,
      child: child,
    );
  }
}

class ParseContext {
  List<Widget> rootWidgetList; // the widgetList accumulator
  dynamic parentElement; // the parent spans accumulator
  int indentLevel = 0;
  int listCount = 0;
  String listChar = '•';
  String blockType; // blockType can be 'p', 'div', 'ul', 'ol', 'blockquote'
  bool condenseWhitespace = true;
  bool spansOnly = false;
  bool inBlock = false;
  TextStyle childStyle;
  TextStyle linkStyle;
  bool shrinkToFit;
  int maxLines;
  double indentPadding = 0;
  double indentSize = 10.0;
  TextStyle defaultTextStyle;

  ParseContext({
    this.rootWidgetList,
    this.parentElement,
    this.indentLevel = 0,
    this.listCount = 0,
    this.listChar = '•',
    this.blockType,
    this.condenseWhitespace = true,
    this.spansOnly = false,
    this.inBlock = false,
    this.childStyle,
    this.linkStyle,
    this.shrinkToFit,
    this.maxLines,
    this.indentPadding = 0,
    this.indentSize = 10.0,
    this.defaultTextStyle,
  }) {
    childStyle = childStyle ?? TextStyle();
  }

  ParseContext.fromContext(ParseContext parseContext) {
    rootWidgetList = parseContext.rootWidgetList;
    parentElement = parseContext.parentElement;
    indentLevel = parseContext.indentLevel;
    listCount = parseContext.listCount;
    listChar = parseContext.listChar;
    blockType = parseContext.blockType;
    condenseWhitespace = parseContext.condenseWhitespace;
    spansOnly = parseContext.spansOnly;
    inBlock = parseContext.inBlock;
    childStyle = parseContext.childStyle ?? TextStyle();
    linkStyle = parseContext.linkStyle ?? TextStyle();
    shrinkToFit = parseContext.shrinkToFit;
    maxLines = parseContext.maxLines;
    indentPadding = parseContext.indentPadding;
    indentSize = parseContext.indentSize;
    defaultTextStyle = parseContext.defaultTextStyle;
  }

  void addWidget(InlineSpan widget, {bool isBlock = false}) {
    if (parentElement is TextSpan) {
      parentElement.children.add(widget);
    } else {
      // the parseContext might actually be a block level style element, so we
      // need to honor the indent and styling specified by that block style.
      // e.g. ol, ul, blockquote
      bool treatLikeBlock = ['blockquote', 'ul', 'ol'].indexOf(blockType) != -1;
      TextSpan span = widget is TextSpan
          ? widget
          : TextSpan(
              children: <InlineSpan>[widget],
              style: childStyle,
            );
      parentElement = span;
      if (isBlock || treatLikeBlock) {
        Decoration decoration;
        if (blockType == 'blockquote') {
          decoration = BoxDecoration(
            border: Border(
                left: BorderSide(color: defaultTextStyle.color, width: 3)),
          );
        }
        BlockText blockText = BlockText(
          shrinkToFit: shrinkToFit,
          margin: EdgeInsets.only(
              top: rootWidgetList.length > 0 ? 8.0 : 0.0,
              left: indentLevel * indentSize),
          padding: EdgeInsets.only(
            top: 2.0,
            left: indentPadding == 0.0 ? 2.0 : indentPadding,
            right: 2.0,
            bottom: 2.0,
          ),
          decoration: decoration,
          child: Text.rich(
            parentElement,
            textAlign: TextAlign.left,
            maxLines: maxLines,
          ),
        );
        rootWidgetList.add(blockText);
      } else {
        rootWidgetList.add(BlockText(
          shrinkToFit: shrinkToFit,
          child: Text.rich(parentElement, maxLines: maxLines),
        ));
      }
    }
  }
}

class HtmlRichTextParser extends StatelessWidget {
  HtmlRichTextParser({
    this.shrinkToFit,
    this.onLinkTap,
    this.renderNewlines = false,
    this.html,
    this.customEdgeInsets,
    this.customTextStyle,
    this.customTextAlign,
    this.onImageError,
    this.linkStyle = const TextStyle(
      decoration: TextDecoration.underline,
      color: Colors.blueAccent,
      decorationColor: Colors.blueAccent,
    ),
    this.onPillTap,
    this.getPillInfo,
    this.imageProperties,
    this.onImageTap,
    this.showImages = true,
    this.getMxcUrl,
    this.maxLines,
    this.defaultTextStyle,
    this.emoteSize,
    this.setCodeLanguage,
    this.getCodeLanguage,
  });

  final double indentSize = 10.0;

  final bool shrinkToFit;
  final onLinkTap;
  final bool renderNewlines;
  final String html;
  final CustomEdgeInsets customEdgeInsets;
  final CustomTextStyle customTextStyle;
  final CustomTextAlign customTextAlign;
  final ImageErrorListener onImageError;
  final TextStyle linkStyle;
  final OnPillTap onPillTap;
  final GetPillInfo getPillInfo;
  final ImageProperties imageProperties;
  final OnImageTap onImageTap;
  final bool showImages;
  final GetMxcUrl getMxcUrl;
  final int maxLines;
  final TextStyle defaultTextStyle;
  final double emoteSize;
  final SetCodeLanguage setCodeLanguage;
  final GetCodeLanguage getCodeLanguage;

  // style elements set a default style
  // for all child nodes
  // treat ol, ul, and blockquote like style elements also
  static const _supportedStyleElements = [
    "b",
    "i",
//    "address",
    "cite",
    "var",
    "em",
    "strong",
    "kbd",
    "samp",
    "tt",
    "code",
    "ins",
    "u",
    "small",
    "abbr",
    "acronym",
    "mark",
    "ol",
    "ul",
    "del",
    "s",
    "strike",
    "ruby",
    "rp",
    "rt",
    "bdi",
    "data",
    "time",
    "span",
    "big",
    "sub",
    "font",
  ];

  // specialty elements require unique handling
  // eg. the "a" tag can contain a block of text or an image
  // sometimes "a" will be rendered with a textspan and recognizer
  // sometimes "a" will be rendered with a clickable Block
  static const _supportedSpecialtyElements = [
    "a",
    "img",
    "br",
    "table",
    "tbody",
    "caption",
    "td",
    "tfoot",
    "th",
    "thead",
    "tr",
    "q",
  ];

  // block elements are always rendered with a new
  // block-level widget, if a block level element
  // is found inside another block level element,
  // we simply treat it as a new block level element
  static const _supportedBlockElements = [
    "article",
    "aside",
    "blockquote",
    "center",
    "dd",
    "dfn",
    "div",
    "dl",
    "dt",
    "figcaption",
    "figure",
    "footer",
    "h1",
    "h2",
    "h3",
    "h4",
    "h5",
    "h6",
    "header",
    "hr",
    "li",
    "main",
    "nav",
    "noscript",
    "p",
    "pre",
    "section",
  ];

  static get _supportedElements => <String>[]
    ..addAll(_supportedStyleElements)
    ..addAll(_supportedSpecialtyElements)
    ..addAll(_supportedBlockElements);

  // this function is called recursively for each child
  // however, the first time it is called, we make sure
  // to ignore the node itself, so we only pay attention
  // to the children
  bool _hasBlockChild(dom.Node node, {bool ignoreSelf = true}) {
    bool retval = false;
    if (node is dom.Element) {
      if (_supportedBlockElements.contains(node.localName) && !ignoreSelf)
        return true;
      node.nodes.forEach((dom.Node node) {
        if (_hasBlockChild(node, ignoreSelf: false)) retval = true;
      });
    }
    return retval;
  }

  // Parses an html string and returns a list of RichText widgets that represent the body of your html document.

  @override
  Widget build(BuildContext context) {
    String data = html;

    if (renderNewlines) {
      data = data.replaceAll("\n", "<br />");
    }
    dom.Document document = parser.parse(data);
    dom.Node body = document.body;

    final widgetList = <Widget>[];
    ParseContext parseContext = ParseContext(
      rootWidgetList: widgetList,
      childStyle: DefaultTextStyle.of(context).style,
      linkStyle: linkStyle ?? TextStyle(),
      shrinkToFit: shrinkToFit,
      maxLines: maxLines,
      indentSize: indentSize,
      defaultTextStyle: defaultTextStyle,
    );

    // don't ignore the top level "body"
    _parseNode(body, parseContext, context);

    // filter out empty widgets
    List<Widget> children = [];
    int i = 0;
    widgetList.forEach((dynamic w) {
      if (w is BlockText) {
        if (w.child.textSpan == null) return;
        TextSpan childTextSpan = w.child.textSpan;
        if ((childTextSpan.text == null || childTextSpan.text.isEmpty) &&
            (childTextSpan.children == null || childTextSpan.children.isEmpty))
          return;
      } else if (w is LinkBlock) {
        if (w.children.isEmpty) return;
      } else if (w is LinkTextSpan) {
        if (w.text.isEmpty && w.children.isEmpty) return;
      }
      if (maxLines == null || i < maxLines) {
        children.add(w);
      }
      i++;
    });

    return Column(
      children: children,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  // THE WORKHORSE FUNCTION!!
  // call the function with the current node and a ParseContext
  // the ParseContext is used to do a number of things
  // first, since we call this function recursively, the parseContext holds references to
  // all the data that is relevant to a particular iteration and its child iterations
  // it holds information about whether to indent the text, whether we are in a list, etc.
  //
  // secondly, it holds the 'global' widgetList that accumulates all the block-level widgets
  //
  // thirdly, it holds a reference to the most recent "parent" so that this iteration of the
  // function can add child nodes to the parent if it should
  //
  // each iteration creates a new parseContext as a copy of the previous one if it needs to
  void _parseNode(
      dom.Node node, ParseContext parseContext, BuildContext buildContext) {
    // TEXT ONLY NODES
    // a text only node is a child of a tag with no inner html
    if (node is dom.Text) {
      // WHITESPACE CONSIDERATIONS ---
      // truly empty nodes should just be ignored
      if (node.text.trim() == "" &&
          (node.text.indexOf(" ") == -1 ||
              (parseContext.parentElement != null &&
                  !(parseContext.parentElement is TextSpan)))) {
        return;
      }

      // we might want to preserve internal whitespace
      // empty strings of whitespace might be significant or not, condense it by default
      String finalText = node.text;
      if (parseContext.condenseWhitespace) {
        finalText = condenseHtmlWhitespace(node.text);

        // if this is part of a string of spans, we will preserve leading
        // and trailing whitespace unless the previous character is whitespace
        if (parseContext.parentElement == null)
          finalText = finalText.trimLeft();
        else if (parseContext.parentElement is TextSpan ||
            parseContext.parentElement is LinkTextSpan) {
          String lastString = parseContext.parentElement.text ?? '';
          if (!parseContext.parentElement.children.isEmpty) {
            if (parseContext.parentElement.children.last is TextSpan) {
              lastString = parseContext.parentElement.children.last.text ?? '';
            } else {
              lastString = '';
            }
          }
          if (lastString.endsWith(' ') || lastString.endsWith('\n')) {
            finalText = finalText.trimLeft();
          }
        }
      }

      // if the finalText is actually empty, just return (unless it's just a space)
      if (finalText.trim().isEmpty && finalText != " ") return;

      // NOW WE HAVE OUR TRULY FINAL TEXT
      // debugPrint("Plain Text Node: '$finalText'");

      // craete a text span and detect links
      TextSpan span = LinkTextSpans(
        text: finalText,
        themeData: Theme.of(buildContext),
        onLinkTap: onLinkTap,
        textStyle: parseContext.childStyle,
        linkStyle: parseContext.childStyle.merge(parseContext.linkStyle),
      );

      // in this class, a ParentElement must be a BlockText, LinkTextSpan, Row, Column, TextSpan

      if (parseContext.parentElement is LinkTextSpan) {
        // add this node to the parent as another LinkTextSpan
        parseContext.parentElement.children.add(LinkTextSpan(
          style:
              parseContext.parentElement.style.merge(parseContext.childStyle),
          url: parseContext.parentElement.url,
          text: finalText,
          onLinkTap: onLinkTap,
        ));
      } else {
        parseContext.addWidget(span);
      }
      return;
    }

    // OTHER ELEMENT NODES
    else if (node is dom.Element) {
      // make a copy of the current context so that we can modify
      // pieces of it for the next iteration of this function
      ParseContext nextContext = new ParseContext.fromContext(parseContext);

      if (!_supportedElements.contains(node.localName)) {
        if (node.localName == "mx-reply") {
          // drop reply fallback
          return;
        }
        _propagateChildren(node.nodes, nextContext, buildContext);
        return;
      }

      // handle style elements
      if (_supportedStyleElements.contains(node.localName)) {
        TextStyle childStyle = parseContext.childStyle ?? TextStyle();

        switch (node.localName) {
          //"b","i","em","strong","code","u","small","abbr","acronym"
          case "b":
          case "strong":
            childStyle =
                childStyle.merge(TextStyle(fontWeight: FontWeight.bold));
            break;
          case "i":
          case "address":
          case "cite":
          case "var":
          case "em":
            childStyle =
                childStyle.merge(TextStyle(fontStyle: FontStyle.italic));
            break;
          case "kbd":
          case "samp":
          case "tt":
          case "code":
            childStyle = childStyle.merge(TextStyle(
              fontFamily: 'monospace',
//              background: Paint()
//                ..color = defaultTextStyle.color
//                ..style = PaintingStyle.stroke
//                ..strokeCap = StrokeCap.round
//                ..strokeJoin = StrokeJoin.round
//                ..strokeWidth = 1.0,
              backgroundColor: monokaiTheme['root'].backgroundColor,
              color: monokaiTheme['root'].color,
            ));
            nextContext.linkStyle = parseContext.linkStyle.merge(TextStyle(
              fontFamily: 'monospace',
              color: monokaiTheme['root'].color,
              backgroundColor: monokaiTheme['root'].backgroundColor,
            ));
            break;
          case "ins":
          case "u":
            childStyle = childStyle
                .merge(TextStyle(decoration: TextDecoration.underline));
            break;
          case "abbr":
          case "acronym":
            childStyle = childStyle.merge(TextStyle(
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dotted,
            ));
            break;
          case "big":
            childStyle = childStyle.merge(TextStyle(fontSize: 20.0));
            break;
          case "small":
            childStyle = childStyle.merge(TextStyle(fontSize: 10.0));
            break;
          case "mark":
            childStyle = childStyle.merge(
                TextStyle(backgroundColor: Colors.yellow, color: Colors.black));
            break;
          case "sub":
            childStyle = childStyle.merge(
              TextStyle(
                fontSize: childStyle.fontSize * OFFSET_TAGS_FONT_SIZE_FACTOR,
              ),
            );
            break;
          case "del":
          case "s":
          case "strike":
            childStyle = childStyle
                .merge(TextStyle(decoration: TextDecoration.lineThrough));
            break;
          case "ol":
            nextContext.indentLevel += 1;
            nextContext.listChar = '#';
            nextContext.listCount = 0;
            if (node.attributes['start'] != null) {
              try {
                nextContext.listCount = int.parse(node.attributes['start']) - 1;
              } catch (_) {
                // discard
              }
            }
            nextContext.blockType = 'ol';
            parseContext.parentElement = null;
            break;
          case "ul":
            nextContext.indentLevel += 1;
            nextContext.listChar = '•';
            nextContext.listCount = 0;
            nextContext.blockType = 'ul';
            parseContext.parentElement = null;
            break;
          case "span":
            if (node.attributes['data-mx-color'] != null) {
              childStyle = childStyle.merge(TextStyle(
                  color: CssColor.fromCss(
                node.attributes['data-mx-color'],
              )));
            }
            if (node.attributes['data-mx-bg-color'] != null) {
              childStyle = childStyle.merge(TextStyle(
                  backgroundColor: CssColor.fromCss(
                node.attributes['data-mx-bg-color'],
              )));
            }
            // we need to hackingly check the outerHtml as the atributes don't contain blank ones, somehow
            if (node.attributes['data-mx-spoiler'] != null ||
                node.outerHtml.split(">")[0].contains("data-mx-spoiler")) {
              final reason = node.attributes['data-mx-spoiler'];
              TextSpan span = TextSpan(
                text: '',
                children: <InlineSpan>[],
              );
              Text richText = Text.rich(span, maxLines: maxLines);
              parseContext.addWidget(WidgetSpan(
                child: Spoiler(
                  reason: reason,
                  child: richText,
                ),
              ));
              nextContext.inBlock = true;
              nextContext.parentElement = span;
            }
            // do we have latex stuffs?
            if (node.attributes['data-mx-maths'] != null) {
              parseContext.addWidget(WidgetSpan(
                child: SingleChildScrollView(
                  child: Math.tex(
                    node.attributes['data-mx-maths'],
                    onErrorFallback: (_) =>
                        Text(node.attributes['data-mx-maths']),
                    textStyle: parseContext.childStyle,
                    mathStyle: MathStyle.text,
                  ),
                  scrollDirection: Axis.horizontal,
                ),
                alignment: PlaceholderAlignment.middle,
              ));
              return; // we don't want to render the children (which is a fallback)
            }
            break;
          case "ruby":
          case "rt":
          case "rp":
          case "bdi":
          case "data":
          case "time":
            break;
          case "font":
            if (node.attributes['color'] != null ||
                node.attributes['data-mx-color'] != null) {
              childStyle = childStyle.merge(TextStyle(
                  color: CssColor.fromCss(
                node.attributes['color'] ?? node.attributes['data-mx-color'],
              )));
            }
            if (node.attributes['data-mx-bg-color'] != null) {
              childStyle = childStyle.merge(TextStyle(
                  backgroundColor: CssColor.fromCss(
                node.attributes['data-mx-bg-color'],
              )));
            }
            break;
        }

        if (customTextStyle != null) {
          final TextStyle customStyle = customTextStyle(node, childStyle);
          if (customStyle != null) {
            childStyle = customStyle;
          }
        }

        nextContext.childStyle = childStyle;
      }

      // handle specialty elements
      else if (_supportedSpecialtyElements.contains(node.localName)) {
        // should support "a","br","table","tbody","thead","tfoot","th","tr","td"

        switch (node.localName) {
          case "a":
            // if this item has block children, we create
            // a container and gesture recognizer for the entire
            // element, otherwise, we create a LinkTextSpan
            final url = node.attributes['href'] ?? null;
            final urlLower = url?.toLowerCase();
            if (urlLower != null &&
                (urlLower.startsWith(MATRIX_SCHEME) ||
                    urlLower.startsWith(MATRIX_TO_SCHEME))) {
              // this might be a pill!
              var isPill = true;
              var identifier = url;
              if (urlLower.startsWith(MATRIX_TO_SCHEME)) {
                identifier = Uri.decodeComponent(
                    url.substring(MATRIX_TO_SCHEME.length).split('?').first);
                isPill =
                    RegExp(r"^[@#!+][^:]+:[^\/]+$").firstMatch(identifier) !=
                        null;
              } else {
                final match = RegExp(r"^matrix:(r|roomid|u)\/([^\/]+)$")
                    .firstMatch(urlLower.split('?').first.split('#').first);
                isPill = match != null;
                if (isPill) {
                  identifier = {
                        'r': '#',
                        'roomid': '!',
                        'u': '@',
                      }[match.group(1)] +
                      match.group(2);
                }
              }
              if (isPill) {
                // we have a pill
                parseContext.addWidget(WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Pill(
                    identifier: identifier,
                    url: url,
                    future:
                        this.getPillInfo != null ? this.getPillInfo(url) : null,
                    onTap: this.onPillTap,
                    getMxcUrl: this.getMxcUrl,
                  ),
                ));
                return; // we return here, as we do not want to render children
              }
            }

            if (_hasBlockChild(node)) {
              LinkBlock linkContainer = LinkBlock(
                url: url,
                margin: EdgeInsets.only(
                    left: parseContext.indentLevel * indentSize),
                onLinkTap: onLinkTap,
                children: <Widget>[],
              );
              nextContext.parentElement = linkContainer;
              nextContext.rootWidgetList.add(linkContainer);
            } else {
              TextStyle _linkStyle = parseContext.childStyle.merge(linkStyle);
              LinkTextSpan span = LinkTextSpan(
                style: _linkStyle,
                url: url,
                onLinkTap: onLinkTap,
                children: <InlineSpan>[],
              );
              if (parseContext.parentElement is TextSpan) {
                nextContext.parentElement.children.add(span);
              } else {
                // start a new block element for this link and its text
                Text richText = Text.rich(span, maxLines: maxLines);
                BlockText blockElement = BlockText(
                  shrinkToFit: shrinkToFit,
                  margin: EdgeInsets.only(
                      left: parseContext.indentLevel * indentSize, top: 10.0),
                  child: richText,
                );
                parseContext.rootWidgetList.add(blockElement);
                nextContext.inBlock = true;
              }
              nextContext.childStyle = linkStyle;
              nextContext.parentElement = span;
            }
            break;

          case "img":
            if (showImages) {
              if (node.attributes['src'] != null) {
                var width = imageProperties?.width ??
                    ((node.attributes['width'] != null)
                        ? double.tryParse(node.attributes['width'])
                        : null);
                var height = imageProperties?.height ??
                    ((node.attributes['height'] != null)
                        ? double.tryParse(node.attributes['height'])
                        : null);

                if (emoteSize != null &&
                    (node.attributes['data-mx-emote'] != null ||
                        node.outerHtml
                            .split(">")[0]
                            .contains("data-mx-emote") ||
                        node.attributes['data-mx-emoticon'] != null ||
                        node.outerHtml
                            .split(">")[0]
                            .contains("data-mx-emoticon"))) {
                  // we have an emote and a set emote size....use that instead!
                  width = null;
                  height = emoteSize;
                }

                final url = node.attributes['src'].startsWith("mxc:") &&
                        getMxcUrl != null
                    ? getMxcUrl(node.attributes['src'], width, height,
                        animated: true)
                    : "";

                WidgetSpan widget = WidgetSpan(
                  alignment: PlaceholderAlignment.bottom,
                  child: GestureDetector(
                    child: Image(
                      image: CachedNetworkImageProvider(
                        url,
                        scale: imageProperties?.scale ?? 1.0,
                      ),
                      frameBuilder: (context, child, frame, _) {
                        if (node.attributes['alt'] != null && frame == null) {
                          return BlockText(
                            child: Text.rich(
                              TextSpan(
                                text: node.attributes['alt'],
                                style: nextContext.childStyle,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: maxLines,
                            ),
                            shrinkToFit: shrinkToFit,
                          );
                        }
                        if (frame != null) {
                          return child;
                        }
                        return Container();
                      },
                      width: (width ?? -1) > 0 ? width : null,
                      height: (height ?? -1) > 0 ? height : null,
                      matchTextDirection:
                          imageProperties?.matchTextDirection ?? false,
                      centerSlice: imageProperties?.centerSlice,
                      filterQuality:
                          imageProperties?.filterQuality ?? FilterQuality.low,
                      alignment: imageProperties?.alignment ?? Alignment.center,
                      colorBlendMode: imageProperties?.colorBlendMode,
                      fit: imageProperties?.fit,
                      color: imageProperties?.color,
                      repeat: imageProperties?.repeat ?? ImageRepeat.noRepeat,
                      semanticLabel: imageProperties?.semanticLabel,
                      excludeFromSemantics:
                          (imageProperties?.semanticLabel == null)
                              ? true
                              : false,
                    ),
                    onTap: () {
                      if (onImageTap != null) {
                        onImageTap(node.attributes['src']);
                      }
                    },
                  ),
                );
                parseContext.addWidget(widget);
              }
            }
            break;

          case "br":
            if (parseContext.parentElement != null &&
                parseContext.parentElement is TextSpan) {
              parseContext.parentElement.children
                  .add(TextSpan(text: '\n', children: []));
            }
            break;

          case "table":
            // new block, so clear out the parent element
            parseContext.parentElement = null;
            nextContext.parentElement = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[],
            );
            nextContext.rootWidgetList.add(Container(
              margin: EdgeInsets.symmetric(vertical: 12.0),
              child: nextContext.parentElement,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: nextContext.childStyle.color),
                  bottom: BorderSide(color: nextContext.childStyle.color),
                ),
              ),
            ));
            break;

          // we don't handle tbody, thead, or tfoot elements separately for now
          case "tbody":
          case "thead":
          case "tfoot":
            break;

          case "td":
          case "th":
            int colspan = 1;
            if (node.attributes['colspan'] != null) {
              colspan = int.tryParse(node.attributes['colspan']);
            }
            nextContext.childStyle = nextContext.childStyle.merge(TextStyle(
                fontWeight: (node.localName == 'th')
                    ? FontWeight.bold
                    : FontWeight.normal));
            Text text = Text.rich(TextSpan(text: '', children: <InlineSpan>[]),
                maxLines: maxLines);
            Expanded cell = Expanded(
              flex: colspan,
              child: Container(
                padding: EdgeInsets.all(1.0),
                child: text,
                decoration: BoxDecoration(
                  border: Border(
                      left: BorderSide(color: nextContext.childStyle.color)),
                ),
              ),
            );
            if (nextContext.parentElement is Row) {
              nextContext.parentElement.children.add(cell);
              nextContext.parentElement = text.textSpan;
            }
            break;

          case "tr":
            Row row = Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[],
            );
            if (nextContext.parentElement is Column) {
              nextContext.parentElement.children.add(Container(
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: nextContext.childStyle.color)),
                ),
                child: IntrinsicHeight(child: row),
              ));
              nextContext.parentElement = row;
            }
            break;

          // treat captions like a row with one expanded cell
          case "caption":
            // create the row
            Row row = Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[],
            );

            // create an expanded cell
            Text text = Text.rich(TextSpan(text: '', children: <InlineSpan>[]),
                textAlign: TextAlign.center,
                textScaleFactor: 1.2,
                maxLines: maxLines);
            Expanded cell = Expanded(
              child: Container(padding: EdgeInsets.all(2.0), child: text),
            );
            row.children.add(cell);
            nextContext.parentElement.children.add(row);
            nextContext.parentElement = text.textSpan;
            break;
          case "q":
            if (parseContext.parentElement != null &&
                parseContext.parentElement is TextSpan) {
              parseContext.parentElement.children
                  .add(TextSpan(text: '"', children: []));
              TextSpan content = TextSpan(text: '', children: []);
              parseContext.parentElement.children.add(content);
              parseContext.parentElement.children
                  .add(TextSpan(text: '"', children: []));
              nextContext.parentElement = content;
            }
            break;
        }

        if (customTextStyle != null) {
          final TextStyle customStyle =
              customTextStyle(node, nextContext.childStyle);
          if (customStyle != null) {
            nextContext.childStyle = customStyle;
          }
        }
      }

      // handle block elements
      else if (_supportedBlockElements.contains(node.localName)) {
        // block elements only show up at the "root" widget level
        // so if we have a block element, reset the parentElement to null
        parseContext.parentElement = null;
        TextAlign textAlign = TextAlign.left;
        if (customTextAlign != null) {
          textAlign = customTextAlign(node) ?? textAlign;
        }

        switch (node.localName) {
          case "blockquote":
            nextContext.indentPadding += 6.0;
            nextContext.blockType = 'blockquote';
            continue myDefault;
          case "hr":
            parseContext.rootWidgetList
                .add(Divider(height: 1.0, color: Colors.black38));
            break;
          case "li":
            String leadingChar = parseContext.listChar;
            if (parseContext.blockType == 'ol') {
              // nextContext will handle nodes under this 'li'
              // but we want to increment the count at this level
              parseContext.listCount += 1;
              leadingChar = parseContext.listCount.toString() + '.';
            }
            BlockText blockText = BlockText(
              shrinkToFit: shrinkToFit,
              margin: EdgeInsets.only(
                  left: parseContext.indentLevel * indentSize, top: 3.0),
              child: Text.rich(
                TextSpan(
                  text: '$leadingChar  ',
                  style: DefaultTextStyle.of(buildContext).style,
                  children: <InlineSpan>[
                    TextSpan(text: '', style: nextContext.childStyle)
                  ],
                ),
                maxLines: maxLines,
              ),
            );
            parseContext.rootWidgetList.add(blockText);
            nextContext.parentElement = blockText.child.textSpan;
            nextContext.spansOnly = true;
            nextContext.inBlock = true;
            break;

          case "h1":
            nextContext.childStyle = nextContext.childStyle.merge(
              TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold),
            );
            continue myDefault;
          case "h2":
            nextContext.childStyle = nextContext.childStyle.merge(
              TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            );
            continue myDefault;
          case "h3":
            nextContext.childStyle = nextContext.childStyle.merge(
              TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            );
            continue myDefault;
          case "h4":
            nextContext.childStyle = nextContext.childStyle.merge(
              TextStyle(fontSize: 20.0, fontWeight: FontWeight.w100),
            );
            continue myDefault;
          case "h5":
            nextContext.childStyle = nextContext.childStyle.merge(
              TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            );
            continue myDefault;
          case "h6":
            nextContext.childStyle = nextContext.childStyle.merge(
              TextStyle(fontSize: 18.0, fontWeight: FontWeight.w100),
            );
            continue myDefault;

          case "pre":
            final textNodes = List<dom.Node>.from(node.nodes);
            textNodes.removeWhere((n) => !(n is dom.Text));
            final elementNodes = List<dom.Node>.from(node.nodes);
            elementNodes.removeWhere((n) => !(n is dom.Element));
            if (textNodes.every((n) => n.text.trim().isEmpty) &&
                elementNodes.length == 1 &&
                (elementNodes.first as dom.Element).localName == "code") {
              // alright, we have a <pre><code> which means code block
              // soooo....let's syntax-highlight it properly!
              final language = (elementNodes.first as dom.Element)
                  .classes
                  .firstWhere((s) => s.startsWith('language-'),
                      orElse: () => null)
                  ?.substring('language-'.length);
              final code = elementNodes.first.text;
              parseContext.rootWidgetList.add(CodeBlock(
                code,
                language: language,
                setCodeLanguage: setCodeLanguage,
                getCodeLanguage: getCodeLanguage,
                borderColor: defaultTextStyle.color,
                maxLines: maxLines,
              ));
              return;
            }
            nextContext.condenseWhitespace = false;
            continue myDefault;

          case "center":
            textAlign = TextAlign.center;
            // no break here
            continue myDefault;

          case "div":
            if (node.attributes['data-mx-maths'] != null) {
              parseContext.rootWidgetList.add(SingleChildScrollView(
                child: Math.tex(
                  node.attributes['data-mx-maths'],
                  onErrorFallback: (_) =>
                      Text(node.attributes['data-mx-maths']),
                  textStyle: parseContext.childStyle,
                  mathStyle: MathStyle.display,
                ),
                scrollDirection: Axis.horizontal,
              ));
              return;
            }
            continue myDefault;

          myDefault:
          default:
            nextContext.addWidget(
                TextSpan(
                  style: nextContext.childStyle,
                  children: <InlineSpan>[],
                ),
                isBlock: true);
            nextContext.spansOnly = true;
            nextContext.inBlock = true;
        }

        if (customTextStyle != null) {
          final TextStyle customStyle =
              customTextStyle(node, nextContext.childStyle);
          if (customStyle != null) {
            nextContext.childStyle = customStyle;
          }
        }
      }

      _propagateChildren(node.nodes, nextContext, buildContext);
    }
  }

  void _propagateChildren(List<dom.Node> nodes, ParseContext nextContext,
      BuildContext buildContext) {
    nodes.forEach((dom.Node childNode) {
      if ((childNode is dom.Element) &&
          !_supportedBlockElements.contains(childNode.localName) &&
          nextContext.parentElement == null) {
        nextContext.addWidget(TextSpan(
          children: <InlineSpan>[],
          style: nextContext.childStyle,
        ));
      }
      _parseNode(childNode, nextContext, buildContext);
    });
  }

  String condenseHtmlWhitespace(String stringToTrim) {
    stringToTrim = stringToTrim.replaceAll("\n", " ");
    while (stringToTrim.indexOf("  ") != -1) {
      stringToTrim = stringToTrim.replaceAll("  ", " ");
    }
    return stringToTrim;
  }
}
