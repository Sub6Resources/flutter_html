import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

typedef CustomRender = Widget Function(dom.Node node, List<Widget> children);
typedef OnLinkTap = void Function(String url);
const OFFSET_TAGS_FONT_SIZE_FACTOR =
    0.7; //The ratio of the parent font for each of the offset tags: sup or sub

class LinkTextSpan extends TextSpan {
  // Beware!
  //
  // This class is only safe because the TapGestureRecognizer is not
  // given a deadline and therefore never allocates any resources.
  //
  // In any other situation -- setting a deadline, using any of the less trivial
  // recognizers, etc -- you would have to manage the gesture recognizer's
  // lifetime and call dispose() when the TextSpan was no longer being rendered.
  //
  // Since TextSpan itself is @immutable, this means that you would have to
  // manage the recognizer from outside the TextSpan, e.g. in the State of a
  // stateful widget that then hands the recognizer to the TextSpan.
  final String url;

  LinkTextSpan(
      {TextStyle style,
      this.url,
      String text,
      OnLinkTap onLinkTap,
      List<TextSpan> children})
      : super(
            style: style,
            text: text,
            children: children ?? <TextSpan>[],
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                onLinkTap(url);
              });
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
                )));
}

class BlockText extends StatelessWidget {
  final RichText child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final String leadingChar;
  final Decoration decoration;

  BlockText(
      {@required this.child,
      this.padding,
      this.margin,
      this.leadingChar = '',
      this.decoration});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: this.padding,
        margin: this.margin,
        decoration: this.decoration,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            leadingChar.isNotEmpty ? Text(leadingChar) : Container(),
            Expanded(child: child),
          ],
        ));
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

  ParseContext(
      {this.rootWidgetList,
      this.parentElement,
      this.indentLevel = 0,
      this.listCount = 0,
      this.listChar = '•',
      this.blockType,
      this.condenseWhitespace = true,
      this.spansOnly = false,
      this.inBlock = false,
      this.childStyle}) {
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
  }
}

class HtmlRichTextParser extends StatelessWidget {
  HtmlRichTextParser({
    @required this.width,
    this.onLinkTap,
    this.renderNewlines = false,
    this.html,
  });

  final double indentSize = 10.0;

  final double width;
  final onLinkTap;
  final bool renderNewlines;
  final String html;

  // style elements set a default style
  // for all child nodes
  // treat ol, ul, and blockquote like style elements also
  static const _supportedStyleElements = [
    "b",
    "i",
    "em",
    "strong",
    "code",
    "u",
    "small",
    "abbr",
    "acronym",
    "ol",
    "ul",
    "blockquote"
  ];

  // specialty elements require unique handling
  // eg. the "a" tag can contain a block of text or an image
  // sometimes "a" will be rendered with a textspan and recognizer
  // sometimes "a" will be rendered with a clickable Block
  static const _supportedSpecialtyElements = [
    "a",
    "br",
    "table",
    "tbody",
    "td",
    "tfoot",
    "th",
    "thead",
    "tr",
  ];

  // block elements are always rendered with a new
  // block-level widget, if a block level element
  // is found inside another block level element,
  // we simply treat it as a new block level element
  static const _supportedBlockElements = [
    "article"
        "body",
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
    "img",
    "li",
    "main",
    "p",
    "pre",
    "section",
  ];

  static get _supportedElements => List()
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

    List<Widget> widgetList = new List<Widget>();
    ParseContext parseContext = ParseContext(
      rootWidgetList: widgetList,
      childStyle: DefaultTextStyle.of(context).style,
    );

    // ignore the top level "body"
    body.nodes.forEach((dom.Node node) => _parseNode(node, parseContext));
    // _parseNode(body, parseContext);

    // filter out empty widgets
    List<Widget> children = [];
    widgetList.forEach((dynamic w) {
      if (w is BlockText) {
        if (w.child.text == null) return;
        if ((w.child.text.text == null || w.child.text.text.isEmpty) &&
            (w.child.text.children == null || w.child.text.children.isEmpty))
          return;
      } else if (w is LinkBlock) {
        if (w.children.isEmpty) return;
      } else if (w is LinkTextSpan) {
        if (w.text.isEmpty && w.children.isEmpty) return;
      }
      children.add(w);
    });

    return Column(
      children: children,
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
  void _parseNode(dom.Node node, ParseContext parseContext) {
    // TEXT ONLY NODES
    // a text only node is a child of a tag with no inner html
    if (node is dom.Text) {
      // WHITESPACE CONSIDERATIONS ---
      // truly empty nodes, should just be ignored
      if (node.text.trim() == "" && node.text.indexOf(" ") == -1) {
        return;
      }

      // if (node.text.trim() == "" &&
      //     node.text.indexOf(" ") != -1 &&
      //     parseContext.condenseWhitespace) {
      //   node.text = " ";
      // }

      // we might want to preserve internal whitespace
      // empty strings of whitespace might be significant or not, condense it by default
      String finalText = parseContext.condenseWhitespace
          ? condenseHtmlWhitespace(node.text)
          : node.text;

      // if this is part of a string of spans, we will preserve leading and trailing whitespace
      if (!(parseContext.parentElement is TextSpan ||
          parseContext.parentElement is LinkTextSpan))
        finalText = finalText.trim();

      // if the finalText is actually empty, just return
      if (finalText.isEmpty) return;

      // NOW WE HAVE OUR TRULY FINAL TEXT
      // debugPrint("Plain Text Node: '$finalText'");

      // create a span by default
      TextSpan span = TextSpan(
          text: finalText,
          children: <TextSpan>[],
          style: parseContext.childStyle);

      // in this class, a ParentElement must be a BlockText, LinkTextSpan, Row, Column, TextSpan

      // the parseContext might actually be a block level style element, so we
      // need to honor the indent and styling specified by that block style.
      // e.g. ol, ul, blockquote
      bool treatLikeBlock =
          ['blockquote', 'ul', 'ol'].indexOf(parseContext.blockType) != -1;

      // if there is no parentElement, contain the span in a BlockText
      if (parseContext.parentElement == null) {
        // if this is inside a context that should be treated like a block
        // but the context is not actually a block, create a block
        // and append it to the root widget tree
        if (treatLikeBlock) {
          Decoration decoration;
          if (parseContext.blockType == 'blockquote') {
            decoration = BoxDecoration(
              border:
                  Border(left: BorderSide(color: Colors.black38, width: 2.0)),
            );
            parseContext.childStyle = parseContext.childStyle.merge(TextStyle(
              fontStyle: FontStyle.italic,
            ));
          }
          BlockText blockText = BlockText(
            margin: EdgeInsets.only(
                top: 8.0,
                bottom: 8.0,
                left: parseContext.indentLevel * indentSize),
            padding: EdgeInsets.all(2.0),
            decoration: decoration,
            child: RichText(
              textAlign: TextAlign.left,
              text: span,
            ),
          );
          parseContext.rootWidgetList.add(blockText);
        } else {
          parseContext.rootWidgetList
              .add(BlockText(child: RichText(text: span)));
        }

        // this allows future items to be added as children
        parseContext.parentElement = span;

        // if the parent is a LinkTextSpan, keep the main attributes of that span going.
      } else if (parseContext.parentElement is LinkTextSpan) {
        // add this node to the parent as another LinkTextSpan
        parseContext.parentElement.children.add(LinkTextSpan(
          style:
              parseContext.parentElement.style.merge(parseContext.childStyle),
          url: parseContext.parentElement.url,
          text: finalText,
          onLinkTap: onLinkTap,
        ));

        // if the parent is a normal span, just add this to that list
      } else {
        parseContext.parentElement.children.add(span);
      }
      return;
    }

    // OTHER ELEMENT NODES
    else if (node is dom.Element) {
      assert(() {
        // debugPrint("Found ${node.localName}");
        // debugPrint(node.outerHtml);
        return true;
      }());

      if (!_supportedElements.contains(node.localName)) {
        return;
      }

      // make a copy of the current context so that we can modify
      // pieces of it for the next iteration of this function
      ParseContext nextContext = new ParseContext.fromContext(parseContext);

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
          case "em":
            childStyle =
                childStyle.merge(TextStyle(fontStyle: FontStyle.italic));
            break;
          case "code":
            childStyle = childStyle.merge(TextStyle(fontFamily: 'monospace'));
            break;
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
          case "small":
            childStyle = childStyle.merge(TextStyle(fontSize: 12.0));
            break;
          case "ol":
            nextContext.indentLevel += 1;
            nextContext.listChar = '#';
            nextContext.listCount = 0;
            nextContext.blockType = 'ol';
            break;
          case "ul":
            nextContext.indentLevel += 1;
            nextContext.listChar = '•';
            nextContext.listCount = 0;
            nextContext.blockType = 'ul';
            break;
          case "blockquote":
            nextContext.indentLevel += 1;
            nextContext.blockType = 'blockquote';
            break;
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
            String url = node.attributes['href'] ?? null;

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
              TextStyle linkStyle = parseContext.childStyle.merge(TextStyle(
                decoration: TextDecoration.underline,
                color: Colors.blueAccent,
                decorationColor: Colors.blueAccent,
              ));
              LinkTextSpan span = LinkTextSpan(
                style: linkStyle,
                url: url,
                onLinkTap: onLinkTap,
                children: <TextSpan>[],
              );
              if (parseContext.parentElement is TextSpan) {
                nextContext.parentElement.children.add(span);
              } else {
                // start a new block element for this link and its text
                BlockText blockElement = BlockText(
                  margin: EdgeInsets.only(
                      left: parseContext.indentLevel * indentSize, top: 10.0),
                  child: RichText(text: span),
                );
                parseContext.rootWidgetList.add(blockElement);
                nextContext.inBlock = true;
              }
              nextContext.childStyle = linkStyle;
              nextContext.parentElement = span;
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
          case "tbody":
          case "thead":
            // new block, so clear out the parent element
            parseContext.parentElement = null;
            nextContext.parentElement = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            );
            nextContext.rootWidgetList.add(nextContext.parentElement);
            break;

          case "td":
          case "th":
            int colspan = 1;
            if (node.attributes['colspan'] != null) {
              colspan = int.tryParse(node.attributes['colspan']);
            }
            Expanded cell = Expanded(
              flex: colspan,
              child: Wrap(),
            );
            nextContext.parentElement.children.add(cell);
            nextContext.parentElement = cell.child;
            break;

          case "tr":
            Row row = Row(
              crossAxisAlignment: CrossAxisAlignment.center,
            );
            nextContext.parentElement.children.add(row);
            nextContext.parentElement = row;
            break;
        }
      }

      // handle block elements
      else if (_supportedBlockElements.contains(node.localName)) {
        // block elements only show up at the "root" widget level
        // so if we have a block element, reset the parentElement to null
        parseContext.parentElement = null;
        TextAlign textAlign = TextAlign.left;

        switch (node.localName) {
          case "hr":
            parseContext.rootWidgetList
                .add(Divider(height: 1.0, color: Colors.black38));
            break;
          case "img":
            if (node.attributes['src'] != null) {
              parseContext.rootWidgetList
                  .add(Image.network(node.attributes['src']));
            } else if (node.attributes['alt'] != null) {
              parseContext.rootWidgetList.add(BlockText(
                  margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
                  padding: EdgeInsets.all(0.0),
                  child: RichText(
                      text: TextSpan(
                    text: node.attributes['alt'],
                    children: <TextSpan>[],
                  ))));
            }
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
              margin: EdgeInsets.only(
                  left: parseContext.indentLevel * indentSize, top: 3.0),
              child: RichText(
                text: TextSpan(
                  text: '',
                  style: nextContext.childStyle,
                  children: <TextSpan>[],
                ),
              ),
              leadingChar: '$leadingChar  ',
            );
            parseContext.rootWidgetList.add(blockText);
            nextContext.parentElement = blockText.child.text;
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
            nextContext.condenseWhitespace = false;
            continue myDefault;

          case "center":
            textAlign = TextAlign.center;
            // no break here
            continue myDefault;

          myDefault:
          default:
            Decoration decoration;
            if (parseContext.blockType == 'blockquote') {
              decoration = BoxDecoration(
                border:
                    Border(left: BorderSide(color: Colors.black38, width: 2.0)),
              );
              nextContext.childStyle = nextContext.childStyle.merge(TextStyle(
                fontStyle: FontStyle.italic,
              ));
            }
            BlockText blockText = BlockText(
              margin: EdgeInsets.only(
                  top: 8.0,
                  bottom: 8.0,
                  left: parseContext.indentLevel * indentSize),
              padding: EdgeInsets.all(2.0),
              decoration: decoration,
              child: RichText(
                textAlign: textAlign,
                text: TextSpan(
                  text: '',
                  style: nextContext.childStyle,
                  children: <TextSpan>[],
                ),
              ),
            );
            parseContext.rootWidgetList.add(blockText);
            nextContext.parentElement = blockText.child.text;
            nextContext.spansOnly = true;
            nextContext.inBlock = true;
        }
      }

      node.nodes.forEach((dom.Node childNode) {
        _parseNode(childNode, nextContext);
      });
    }
  }

  // List<dynamic> _parseNodeList({
  //   @required List<dom.Node> nodeList,
  //   @required List<BlockText> rootWidgetList,  // the widgetList accumulator
  //   int parentIndex,         // the parent spans list accumulator
  //   int indentLevel = 0,
  //   int listCount = 0,
  //   String listChar = '•',
  //   String blockType,          // blockType can be 'p', 'div', 'ul', 'ol', 'blockquote'
  //   bool condenseWhitespace = true,
  //   }) {
  //   return nodeList.map((node) {
  //     return _parseNode(
  //       node: node,
  //       rootWidgetList: rootWidgetList,
  //       parentIndex: parentIndex,
  //       indentLevel: indentLevel,
  //       listCount: listCount,
  //       listChar: listChar,
  //       blockType: blockType,
  //       condenseWhitespace: condenseWhitespace,
  //     );
  //   }).toList();
  // }

  Paint _getPaint(Color color) {
    Paint paint = new Paint();
    paint.color = color;
    return paint;
  }

  String condenseHtmlWhitespace(String stringToTrim) {
    stringToTrim = stringToTrim.replaceAll("\n", " ");
    while (stringToTrim.indexOf("  ") != -1) {
      stringToTrim = stringToTrim.replaceAll("  ", " ");
    }
    return stringToTrim;
  }

  bool _isNotFirstBreakTag(dom.Node node) {
    int index = node.parentNode.nodes.indexOf(node);
    if (index == 0) {
      if (node.parentNode == null) {
        return false;
      }
      return _isNotFirstBreakTag(node.parentNode);
    } else if (node.parentNode.nodes[index - 1] is dom.Element) {
      if ((node.parentNode.nodes[index - 1] as dom.Element).localName == "br") {
        return true;
      }
      return false;
    } else if (node.parentNode.nodes[index - 1] is dom.Text) {
      if ((node.parentNode.nodes[index - 1] as dom.Text).text.trim() == "") {
        return _isNotFirstBreakTag(node.parentNode.nodes[index - 1]);
      } else {
        return false;
      }
    }
    return false;
  }
}

class HtmlOldParser extends StatelessWidget {
  HtmlOldParser({
    @required this.width,
    this.onLinkTap,
    this.renderNewlines = false,
    this.customRender,
    this.blockSpacing,
    this.html,
  });

  final double width;
  final OnLinkTap onLinkTap;
  final bool renderNewlines;
  final CustomRender customRender;
  final double blockSpacing;
  final String html;

  static const _supportedElements = [
    "a",
    "abbr",
    "acronym",
    "address",
    "article",
    "aside",
    "b",
    "bdi",
    "bdo",
    "big",
    "blockquote",
    "body",
    "br",
    "caption",
    "cite",
    "center",
    "code",
    "data",
    "dd",
    "del",
    "dfn",
    "div",
    "dl",
    "dt",
    "em",
    "figcaption",
    "figure",
    "font",
    "footer",
    "h1",
    "h2",
    "h3",
    "h4",
    "h5",
    "h6",
    "header",
    "hr",
    "i",
    "img",
    "ins",
    "kbd",
    "li",
    "main",
    "mark",
    "nav",
    "noscript",
    "ol", //partial
    "p",
    "pre",
    "q",
    "rp",
    "rt",
    "ruby",
    "s",
    "samp",
    "section",
    "small",
    "span",
    "strike",
    "strong",
    "sub",
    "sup",
    "table",
    "tbody",
    "td",
    "template",
    "tfoot",
    "th",
    "thead",
    "time",
    "tr",
    "tt",
    "u",
    "ul", //partial
    "var",
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      children: parse(html),
    );
  }

  ///Parses an html string and returns a list of widgets that represent the body of your html document.
  List<Widget> parse(String data) {
    List<Widget> widgetList = new List<Widget>();

    if (renderNewlines) {
      data = data.replaceAll("\n", "<br />");
    }
    dom.Document document = parser.parse(data);
    widgetList.add(_parseNode(document.body));
    return widgetList;
  }

  Widget _parseNode(dom.Node node) {
    if (customRender != null) {
      final Widget customWidget =
          customRender(node, _parseNodeList(node.nodes));
      if (customWidget != null) {
        return customWidget;
      }
    }

    if (node is dom.Element) {
      if (!_supportedElements.contains(node.localName)) {
        return Container();
      }

      switch (node.localName) {
        case "a":
          return GestureDetector(
              child: DefaultTextStyle.merge(
                child: Wrap(
                  children: _parseNodeList(node.nodes),
                ),
                style: const TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blueAccent,
                    decorationColor: Colors.blueAccent),
              ),
              onTap: () {
                if (node.attributes.containsKey('href') && onLinkTap != null) {
                  String url = node.attributes['href'];
                  onLinkTap(url);
                }
              });
        case "abbr":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dotted,
            ),
          );
        case "acronym":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dotted,
            ),
          );
        case "address":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          );
        case "article":
          return Container(
            width: width,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: _parseNodeList(node.nodes),
            ),
          );
        case "aside":
          return Container(
            width: width,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: _parseNodeList(node.nodes),
            ),
          );
        case "b":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          );
        case "bdi":
          return Wrap(
            children: _parseNodeList(node.nodes),
          );
        case "bdo":
          if (node.attributes["dir"] != null) {
            return Directionality(
              child: Wrap(
                children: _parseNodeList(node.nodes),
              ),
              textDirection: node.attributes["dir"] == "rtl"
                  ? TextDirection.rtl
                  : TextDirection.ltr,
            );
          }
          //Direction attribute is required, just render the text normally now.
          return Wrap(
            children: _parseNodeList(node.nodes),
          );
        case "big":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontSize: 20.0,
            ),
          );
        case "blockquote":
          return Padding(
            padding:
                EdgeInsets.fromLTRB(40.0, blockSpacing, 40.0, blockSpacing),
            child: Container(
              width: width,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: _parseNodeList(node.nodes),
              ),
            ),
          );
        case "body":
          return Container(
            width: width,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: _parseNodeList(node.nodes),
            ),
          );
        case "br":
          if (_isNotFirstBreakTag(node)) {
            return Container(width: width, height: blockSpacing);
          }
          return Container(width: width);
        case "caption":
          return Container(
            width: width,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              children: _parseNodeList(node.nodes),
            ),
          );
        case "center":
          return Container(
              width: width,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: _parseNodeList(node.nodes),
                alignment: WrapAlignment.center,
              ));
        case "cite":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          );
        case "code":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontFamily: 'monospace',
            ),
          );
        case "data":
          return Wrap(
            children: _parseNodeList(node.nodes),
          );
        case "dd":
          return Padding(
              padding: EdgeInsets.only(left: 40.0),
              child: Container(
                width: width,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: _parseNodeList(node.nodes),
                ),
              ));
        case "del":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
            ),
          );
        case "dfn":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          );
        case "div":
          return Container(
            width: width,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: _parseNodeList(node.nodes),
            ),
          );
        case "dl":
          return Padding(
              padding: EdgeInsets.only(top: blockSpacing, bottom: blockSpacing),
              child: Column(
                children: _parseNodeList(node.nodes),
                crossAxisAlignment: CrossAxisAlignment.start,
              ));
        case "dt":
          return Wrap(
            children: _parseNodeList(node.nodes),
          );
        case "em":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          );
        case "figcaption":
          return Wrap(
            children: _parseNodeList(node.nodes),
          );
        case "figure":
          return Padding(
              padding:
                  EdgeInsets.fromLTRB(40.0, blockSpacing, 40.0, blockSpacing),
              child: Column(
                children: _parseNodeList(node.nodes),
                crossAxisAlignment: CrossAxisAlignment.center,
              ));
        case "font":
          return Wrap(
            children: _parseNodeList(node.nodes),
          );
        case "footer":
          return Container(
            width: width,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: _parseNodeList(node.nodes),
            ),
          );
        case "h1":
          return DefaultTextStyle.merge(
            child: Container(
              width: width,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: _parseNodeList(node.nodes),
              ),
            ),
            style: const TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
            ),
          );
        case "h2":
          return DefaultTextStyle.merge(
            child: Container(
              width: width,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: _parseNodeList(node.nodes),
              ),
            ),
            style: const TextStyle(
              fontSize: 21.0,
              fontWeight: FontWeight.bold,
            ),
          );
        case "h3":
          return DefaultTextStyle.merge(
            child: Container(
              width: width,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: _parseNodeList(node.nodes),
              ),
            ),
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          );
        case "h4":
          return DefaultTextStyle.merge(
            child: Container(
              width: width,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: _parseNodeList(node.nodes),
              ),
            ),
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          );
        case "h5":
          return DefaultTextStyle.merge(
            child: Container(
              width: width,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: _parseNodeList(node.nodes),
              ),
            ),
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          );
        case "h6":
          return DefaultTextStyle.merge(
            child: Container(
              width: width,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: _parseNodeList(node.nodes),
              ),
            ),
            style: const TextStyle(
              fontSize: 10.0,
              fontWeight: FontWeight.bold,
            ),
          );
        case "header":
          return Container(
            width: width,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: _parseNodeList(node.nodes),
            ),
          );
        case "hr":
          return Padding(
            padding: EdgeInsets.only(top: 7.0, bottom: 7.0),
            child: Container(
              height: 0.0,
              decoration: BoxDecoration(border: Border.all()),
            ),
          );
        case "i":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          );
        case "img":
          if (node.attributes['src'] != null) {
            return Image.network(node.attributes['src']);
          } else if (node.attributes['alt'] != null) {
            //Temp fix for https://github.com/flutter/flutter/issues/736
            if (node.attributes['alt'].endsWith(" ")) {
              return Container(
                  padding: EdgeInsets.only(right: 2.0),
                  child: Text(node.attributes['alt']));
            } else {
              return Text(node.attributes['alt']);
            }
          }
          return Container();
        case "ins":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              decoration: TextDecoration.underline,
            ),
          );
        case "kbd":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontFamily: 'monospace',
            ),
          );
        case "li":
          String type = node.parent.localName; // Parent type; usually ol or ul
          const EdgeInsets markPadding = EdgeInsets.symmetric(horizontal: 4.0);
          Widget mark;
          switch (type) {
            case "ul":
              mark = Container(child: Text('•'), padding: markPadding);
              break;
            case "ol":
              int index = node.parent.children.indexOf(node) + 1;
              mark = Container(child: Text("$index."), padding: markPadding);
              break;
            default: //Fallback to middle dot
              mark = Container(width: 0.0, height: 0.0);
              break;
          }
          return Container(
            width: width,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                mark,
                Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: _parseNodeList(node.nodes))
              ],
            ),
          );
        case "main":
          return Container(
            width: width,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: _parseNodeList(node.nodes),
            ),
          );
        case "mark":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: TextStyle(
              color: Colors.black,
              background: _getPaint(Colors.yellow),
            ),
          );
        case "nav":
          return Container(
            width: width,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: _parseNodeList(node.nodes),
            ),
          );
        case "noscript":
          return Container(
            width: width,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.start,
              children: _parseNodeList(node.nodes),
            ),
          );
        case "ol":
          return Column(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.start,
          );
        case "p":
          return Padding(
            padding: EdgeInsets.only(top: blockSpacing, bottom: blockSpacing),
            child: Container(
              width: width,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.start,
                children: _parseNodeList(node.nodes),
              ),
            ),
          );
        case "pre":
          return Padding(
            padding: EdgeInsets.all(blockSpacing),
            child: DefaultTextStyle.merge(
              child: Text(node.innerHtml),
              style: const TextStyle(
                fontFamily: 'monospace',
              ),
            ),
          );
        case "q":
          List<Widget> children = List<Widget>();
          children.add(Text("\""));
          children.addAll(_parseNodeList(node.nodes));
          children.add(Text("\""));
          return DefaultTextStyle.merge(
            child: Wrap(
              children: children,
            ),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          );
        case "rp":
          return Wrap(
            children: _parseNodeList(node.nodes),
          );
        case "rt":
          return Wrap(
            children: _parseNodeList(node.nodes),
          );
        case "ruby":
          return Wrap(
            children: _parseNodeList(node.nodes),
          );
        case "s":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
            ),
          );
        case "samp":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontFamily: 'monospace',
            ),
          );
        case "section":
          return Container(
            width: width,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: _parseNodeList(node.nodes),
            ),
          );
        case "small":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontSize: 10.0,
            ),
          );
        case "span":
          return Wrap(
            children: _parseNodeList(node.nodes),
          );
        case "strike":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
            ),
          );
        case "strong":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          );
        case "sub":
        case "sup":
          //Use builder to capture the parent font to inherit the font styles
          return Builder(builder: (BuildContext context) {
            final DefaultTextStyle parent = DefaultTextStyle.of(context);
            TextStyle parentStyle = parent.style;

            var painter = new TextPainter(
                text: new TextSpan(
                  text: node.text,
                  style: parentStyle,
                ),
                textDirection: TextDirection.ltr);
            painter.layout();
            //print(painter.size);

            //Get the height from the default text
            var height = painter.size.height *
                1.35; //compute a higher height for the text to increase the offset of the Positioned text

            painter = new TextPainter(
                text: new TextSpan(
                  text: node.text,
                  style: parentStyle.merge(TextStyle(
                      fontSize:
                          parentStyle.fontSize * OFFSET_TAGS_FONT_SIZE_FACTOR)),
                ),
                textDirection: TextDirection.ltr);
            painter.layout();
            //print(painter.size);

            //Get the width from the reduced/positioned text
            var width = painter.size.width;

            //print("Width: $width, Height: $height");

            return DefaultTextStyle.merge(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Stack(
                    fit: StackFit.loose,
                    children: [
                      //The Stack needs a non-positioned object for the next widget to respect the space so we create
                      //a sized box to fill the required space
                      SizedBox(
                        width: width,
                        height: height,
                      ),
                      DefaultTextStyle.merge(
                        child: Positioned(
                          child: Wrap(children: _parseNodeList(node.nodes)),
                          bottom: node.localName == "sub" ? 0 : null,
                          top: node.localName == "sub" ? null : 0,
                        ),
                        style: TextStyle(
                            fontSize: parentStyle.fontSize *
                                OFFSET_TAGS_FONT_SIZE_FACTOR),
                      )
                    ],
                  )
                ],
              ),
            );
          });
        case "table":
          return Column(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.start,
          );
        case "tbody":
          return Column(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.start,
          );
        case "td":
          int colspan = 1;
          if (node.attributes['colspan'] != null) {
            colspan = int.tryParse(node.attributes['colspan']);
          }
          return Expanded(
            flex: colspan,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: _parseNodeList(node.nodes),
            ),
          );
        case "template":
          //Not usually displayed in HTML
          return Container();
        case "tfoot":
          return Column(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.start,
          );
        case "th":
          int colspan = 1;
          if (node.attributes['colspan'] != null) {
            colspan = int.tryParse(node.attributes['colspan']);
          }
          return DefaultTextStyle.merge(
            child: Expanded(
              flex: colspan,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                children: _parseNodeList(node.nodes),
              ),
            ),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          );
        case "thead":
          return Column(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.start,
          );
        case "time":
          return Wrap(
            children: _parseNodeList(node.nodes),
          );
        case "tr":
          return Row(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.center,
          );
        case "tt":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontFamily: 'monospace',
            ),
          );
        case "u":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              decoration: TextDecoration.underline,
            ),
          );
        case "ul":
          return Column(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.start,
          );
        case "var":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          );
      }
    } else if (node is dom.Text) {
      //We don't need to worry about rendering extra whitespace
      if (node.text.trim() == "" && node.text.indexOf(" ") == -1) {
        return Wrap();
      }
      if (node.text.trim() == "" && node.text.indexOf(" ") != -1) {
        node.text = " ";
      }

      String finalText = trimStringHtml(node.text);
      //Temp fix for https://github.com/flutter/flutter/issues/736
      if (finalText.endsWith(" ")) {
        return Container(
            padding: EdgeInsets.only(right: 2.0), child: Text(finalText));
      } else {
        return Text(finalText);
      }
    }
    return Wrap();
  }

  List<Widget> _parseNodeList(List<dom.Node> nodeList) {
    return nodeList.map((node) {
      return _parseNode(node);
    }).toList();
  }

  Paint _getPaint(Color color) {
    Paint paint = new Paint();
    paint.color = color;
    return paint;
  }

  String trimStringHtml(String stringToTrim) {
    stringToTrim = stringToTrim.replaceAll("\n", "");
    while (stringToTrim.indexOf("  ") != -1) {
      stringToTrim = stringToTrim.replaceAll("  ", " ");
    }
    return stringToTrim;
  }

  bool _isNotFirstBreakTag(dom.Node node) {
    int index = node.parentNode.nodes.indexOf(node);
    if (index == 0) {
      if (node.parentNode == null) {
        return false;
      }
      return _isNotFirstBreakTag(node.parentNode);
    } else if (node.parentNode.nodes[index - 1] is dom.Element) {
      if ((node.parentNode.nodes[index - 1] as dom.Element).localName == "br") {
        return true;
      }
      return false;
    } else if (node.parentNode.nodes[index - 1] is dom.Text) {
      if ((node.parentNode.nodes[index - 1] as dom.Text).text.trim() == "") {
        return _isNotFirstBreakTag(node.parentNode.nodes[index - 1]);
      } else {
        return false;
      }
    }
    return false;
  }
}
