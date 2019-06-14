import 'dart:convert';
import 'package:flutter_html/style.dart';

import 'image_properties.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter_html/html_elements.dart';
import 'package:html/parser.dart' as parser;

typedef CustomRender = Widget Function(dom.Node node, List<Widget> children);
typedef CustomTextStyle = TextStyle Function(
  dom.Node node,
  TextStyle baseStyle,
);
typedef CustomEdgeInsets = EdgeInsets Function(dom.Node node);
typedef OnLinkTap = void Function(String url);
typedef OnImageTap = void Function();

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
    this.customTextStyle,
    this.customEdgeInsets,
    this.onImageError,
    this.linkStyle = const TextStyle(
      decoration: TextDecoration.underline,
      color: Colors.blueAccent,
      decorationColor: Colors.blueAccent,
    ),
    this.imageProperties,
    this.onImageTap,
    this.showImages = true,
  });

  final double indentSize = 10.0;

  final double width;
  final onLinkTap;
  final bool renderNewlines;
  final String html;
  final CustomTextStyle customTextStyle;
  final CustomEdgeInsets customEdgeInsets;
  final ImageErrorListener onImageError;
  final TextStyle linkStyle;
  final ImageProperties imageProperties;
  final OnImageTap onImageTap;
  final bool showImages;

  // style elements set a default style
  // for all child nodes
  // treat ol, ul, and blockquote like style elements also
  static const _supportedStyleElements = [
    "b",
    "i",
    "address",
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
    "blockquote",
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
    "nav",
    "noscript",
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

    // don't ignore the top level "body"
    _parseNode(body, parseContext, context);

    // filter out empty widgets
    List<Widget> children = [];
    widgetList.forEach((dynamic w) {
      if (w is BlockText) {
        if (w.child.text == null) return;
        TextSpan childTextSpan = w.child.text;
        if ((childTextSpan.text == null || childTextSpan.text.isEmpty) &&
            (childTextSpan.children == null || childTextSpan.children.isEmpty))
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
  void _parseNode(
      dom.Node node, ParseContext parseContext, BuildContext buildContext) {
    // TEXT ONLY NODES
    // a text only node is a child of a tag with no inner html
    if (node is dom.Text) {
      // WHITESPACE CONSIDERATIONS ---
      // truly empty nodes should just be ignored
      if (node.text.trim() == "" && node.text.indexOf(" ") == -1) {
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
            lastString = parseContext.parentElement.children.last.text ?? '';
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

        // this allows future items to be added as children of this item
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
      } else if (!(parseContext.parentElement.children is List<Widget>)) {
        parseContext.parentElement.children.add(span);
      } else {
        // Doing nothing... we shouldn't ever get here
      }
      return;
    }

    // OTHER ELEMENT NODES
    else if (node is dom.Element) {
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
            childStyle = childStyle.merge(TextStyle(fontFamily: 'monospace'));
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
          case "ruby":
          case "rt":
          case "rp":
          case "bdi":
          case "data":
          case "time":
          case "span":
            //No additional styles
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
              TextStyle _linkStyle = parseContext.childStyle.merge(linkStyle);
              LinkTextSpan span = LinkTextSpan(
                style: _linkStyle,
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
            // new block, so clear out the parent element
            parseContext.parentElement = null;
            nextContext.parentElement = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[],
            );
            nextContext.rootWidgetList.add(Container(
                margin: EdgeInsets.symmetric(vertical: 12.0),
                child: nextContext.parentElement));
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
            RichText text =
                RichText(text: TextSpan(text: '', children: <TextSpan>[]));
            Expanded cell = Expanded(
              flex: colspan,
              child: Container(padding: EdgeInsets.all(1.0), child: text),
            );
            nextContext.parentElement.children.add(cell);
            nextContext.parentElement = text.text;
            break;

          case "tr":
            Row row = Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[],
            );
            nextContext.parentElement.children.add(row);
            nextContext.parentElement = row;
            break;

          // treat captions like a row with one expanded cell
          case "caption":
            // create the row
            Row row = Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[],
            );

            // create an expanded cell
            RichText text = RichText(
                textAlign: TextAlign.center,
                textScaleFactor: 1.2,
                text: TextSpan(text: '', children: <TextSpan>[]));
            Expanded cell = Expanded(
              child: Container(padding: EdgeInsets.all(2.0), child: text),
            );
            row.children.add(cell);
            nextContext.parentElement.children.add(row);
            nextContext.parentElement = text.text;
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
      }

      // handle block elements
      else if (_supportedBlockElements.contains(node.localName)) {
        // block elements only show up at the "root" widget level
        // so if we have a block element, reset the parentElement to null
        parseContext.parentElement = null;
        TextAlign textAlign = TextAlign.left;

        EdgeInsets _customEdgeInsets;
        if (customEdgeInsets != null) {
          _customEdgeInsets = customEdgeInsets(node);
        }

        switch (node.localName) {
          case "hr":
            parseContext.rootWidgetList
                .add(Divider(height: 1.0, color: Colors.black38));
            break;
          case "img":
            if (showImages) {
              if (node.attributes['src'] != null) {
                if (node.attributes['src'].startsWith("data:image") &&
                    node.attributes['src'].contains("base64,")) {
                  precacheImage(
                    MemoryImage(
                      base64.decode(
                        node.attributes['src'].split("base64,")[1].trim(),
                      ),
                    ),
                    buildContext,
                    onError: onImageError,
                  );
                  parseContext.rootWidgetList.add(GestureDetector(
                    child: Image.memory(
                      base64.decode(
                          node.attributes['src'].split("base64,")[1].trim()),
                      width: imageProperties?.width ??
                          ((node.attributes['width'] != null)
                              ? double.parse(node.attributes['width'])
                              : null),
                      height: imageProperties?.height ??
                          ((node.attributes['height'] != null)
                              ? double.parse(node.attributes['height'])
                              : null),
                      scale: imageProperties?.scale ?? 1.0,
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
                    onTap: onImageTap,
                  ));
                } else {
                  precacheImage(
                    NetworkImage(node.attributes['src']),
                    buildContext,
                    onError: onImageError,
                  );
                  parseContext.rootWidgetList.add(GestureDetector(
                    child: Image.network(
                      node.attributes['src'],
                      width: imageProperties?.width ??
                          ((node.attributes['width'] != null)
                              ? double.parse(node.attributes['width'])
                              : null),
                      height: imageProperties?.height ??
                          ((node.attributes['height'] != null)
                              ? double.parse(node.attributes['height'])
                              : null),
                      scale: imageProperties?.scale ?? 1.0,
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
                    onTap: onImageTap,
                  ));
                }
                if (node.attributes['alt'] != null) {
                  parseContext.rootWidgetList.add(BlockText(
                      margin:
                          EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
                      padding: EdgeInsets.all(0.0),
                      child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: node.attributes['alt'],
                            style: nextContext.childStyle,
                            children: <TextSpan>[],
                          ))));
                }
              }
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
              margin: node.localName != 'body'
                  ? _customEdgeInsets ??
                      EdgeInsets.only(
                          top: 8.0,
                          bottom: 8.0,
                          left: parseContext.indentLevel * indentSize)
                  : EdgeInsets.zero,
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
        _parseNode(childNode, nextContext, buildContext);
      });
    }
  }

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

class HtmlParser extends StatelessWidget {
  final String html;
  final String css;
  final OnLinkTap onLinkTap;
  final Map<String, Style> style;

  HtmlParser({
    this.html,
    this.css,
    this.onLinkTap,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    dom.Document document = parseHTML(html);
    StyledElement lexedTree = lexDomTree(document);
    StyledElement styledTree = _applyCustomStyles(lexedTree);
    StyledElement cleanedTree = cleanTree(styledTree);
    InlineSpan parsedTree = parseTree(
      RenderContext(style: Theme.of(context).textTheme.body1),
      cleanedTree,
    );

    return Text.rich(parsedTree);
  }

  /// [parseHTML] converts a string to a DOM document using the dart `html` library.
  static dom.Document parseHTML(String data) {
    return parser.parse(data);
  }

  /// [lexDomTree] converts a DOM document to a simplified tree of [StyledElement]s.
  static StyledElement lexDomTree(dom.Document html) {
    StyledElement tree = StyledElement(
      name: "[Tree Root]",
      children: new List<StyledElement>(),
    );

    html.nodes.forEach((node) {
      tree.children.add(_recursiveLexer(node));
    });

    return tree;
  }

  static StyledElement _recursiveLexer(dom.Node node) {
    List<StyledElement> children = List<StyledElement>();

    node.nodes.forEach((childNode) {
      children.add(_recursiveLexer(childNode));
    });

    if (node is dom.Element) {
      if (STYLED_ELEMENTS.contains(node.localName)) {
        return parseStyledElement(node, children);
      } else if (INTERACTABLE_ELEMENTS.contains(node.localName)) {
        return parseInteractableElement(node, children);
      } else if (BLOCK_ELEMENTS.contains(node.localName)) {
        return parseBlockElement(node, children);
      } else if (CONTENT_ELEMENTS.contains(node.localName)) {
        return parseContentElement(node);
      } else {
        return EmptyContentElement();
      }
    } else if (node is dom.Text) {
      return TextContentElement(text: node.text);
    } else {
      return EmptyContentElement();
    }
  }

  /// [cleanTree] optimizes the [StyledElement] tree so all [BlockElement]s are
  /// on the first level, redundant levels are collapsed, empty elements are
  /// removed, and specialty elements are processed.
  static StyledElement cleanTree(StyledElement tree) {
    tree = _processWhitespace(tree);
    tree = _removeEmptyElements(tree);
    tree = _processListCharacters(tree);
    tree = _processBeforesAndAfters(tree);
    return tree;
  }

  StyledElement _applyCustomStyles(StyledElement tree) {
    if (style == null) return tree;
    if (style.containsKey(tree.name)) {
      if(tree.style == null) {
        tree.style = style[tree.name];
      } else {
        tree.style = tree.style.merge(style[tree.name]);
      }
    }
    tree.children?.forEach(_applyCustomStyles);

    return tree;
  }

  /// [parseTree] converts a tree of [StyledElement]s to an [InlineSpan] tree.
  InlineSpan parseTree(RenderContext context, StyledElement tree) {

    // Merge this element's style into the context so that children
    // inherit the correct style
    RenderContext newContext = RenderContext(
      style: context.style.merge(tree.style?.textStyle),
    );

    //Return the correct InlineSpan based on the element type.
    if (tree is BlockElement) {
      return WidgetSpan(
        child: Container(
          decoration: BoxDecoration(
            border: tree.style?.block?.border,
            color: tree.style?.block?.backgroundColor,
          ),
          height: tree.style.block.height,
          width: tree.style.block.width ?? double.infinity,
          margin: tree.style.block.margin,
          alignment: tree.style?.block?.alignment,
          child: RichText(
            text: TextSpan(
              style: context.style.merge(tree.style?.textStyle),
              children: tree.children
                  .map((tree) => parseTree(newContext, tree))
                  .toList(),
            ),
          ),
        ),
      );
    } else if (tree is ContentElement) {
      if (tree is TextContentElement) {
        return TextSpan(text: tree.text);
      } else {
        return WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: tree.toWidget(),
        );
      }
    } else if (tree is InteractableElement) {
      return WidgetSpan(
        child: GestureDetector(
          onTap: () => onLinkTap(tree.href),
          child: RichText(
            text: TextSpan(
              style: context.style.merge(tree.style?.textStyle),
              children: tree.children
                  .map((tree) => parseTree(newContext, tree))
                  .toList(),
            ),
          ),
        ),
      );
    } else {
      return TextSpan(
        style: context.style.merge(tree.style?.textStyle),
        children:
            tree.children.map((tree) => parseTree(newContext, tree)).toList(),
      );
    }
  }

  /// [processWhitespace] removes unnecessary whitespace from the StyledElement tree.
  static StyledElement _processWhitespace(StyledElement tree) {
    // TODO Follow specs given at https://www.w3.org/TR/css-text-3/
    // TODO another helpful resource is https://medium.com/@patrickbrosset/when-does-white-space-matter-in-html-b90e8a7cdd33
    if (tree.style?.preserveWhitespace ?? false) {
      //preserve this whitespace
    } else if (tree is TextContentElement) {
      tree.text = _removeUnnecessaryWhitespace(tree.text);
    } else {
      //TODO remove all but one space even across inline elements
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
    if (tree is BlockElement && (tree.name == "ol" || tree.name == "ul")) {
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
      } else if (child is TextContentElement &&
          (child.text.isEmpty)) {
        toRemove.add(child);
      } else {
        _removeEmptyElements(child);
      }
    });
    tree.children?.removeWhere((element) => toRemove.contains(element));

    return tree;
  }
}

/// A [CustomRenderer] is used to render html tags in your own way or implement unsupported tags.
class CustomRenderer {
  final String name;
  final Widget Function(BuildContext context) render;
  final ElementType renderAs;

  CustomRenderer(
    this.name, {
    this.render,
    this.renderAs,
  });
}

class RenderContext {
  TextStyle style;

  RenderContext({this.style});
}
