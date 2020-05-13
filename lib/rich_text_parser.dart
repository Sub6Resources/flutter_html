import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter/foundation.dart';

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
typedef GetMxcUrl = String Function(String mxc, double width, double height);
typedef GetPillInfo = Future<Map<String, dynamic>> Function(String identifier);

const OFFSET_TAGS_FONT_SIZE_FACTOR =
    0.7; //The ratio of the parent font for each of the offset tags: sup or sub

final RegExp URL_REGEX = RegExp(
    r"https?:\/\/(www\.)?[-a-zA-Z0-9@:%.,_\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\,+.~#?&//=]*)");

final MATRIX_TO_SCHEME = "https://matrix.to/#/";

extension CssColor on Color {
  static Color fromCss(String hexString) {
    if (hexString == null) {
      return null;
    }
    final matches = RegExp(r"^#((?:[0-9a-fA-F]{3}){1,2})$").firstMatch(hexString);
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
      List<InlineSpan> children})
      : super(
          style: style,
          text: text,
          children: children ?? <InlineSpan>[],
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              onLinkTap?.call(url);
            },
        );
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
  final RichText child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Decoration decoration;
  final bool shrinkToFit;
  double width;

  BlockText({
    @required this.child,
    @required this.shrinkToFit,
    this.padding,
    this.margin,
    this.decoration,
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
  RichText parentRichText;
  int indentLevel = 0;
  int listCount = 0;
  String listChar = '•';
  String blockType; // blockType can be 'p', 'div', 'ul', 'ol', 'blockquote'
  bool condenseWhitespace = true;
  bool spansOnly = false;
  bool inBlock = false;
  TextStyle childStyle;
  bool shrinkToFit;
  int maxLines;
  double indentPadding = 0;
  bool skip = false;

  ParseContext({
    this.rootWidgetList,
    this.parentElement,
    this.parentRichText,
    this.indentLevel = 0,
    this.listCount = 0,
    this.listChar = '•',
    this.blockType,
    this.condenseWhitespace = true,
    this.spansOnly = false,
    this.inBlock = false,
    this.childStyle,
    this.shrinkToFit,
    this.maxLines,
    this.indentPadding = 0,
    this.skip = false,
  }) {
    childStyle = childStyle ?? TextStyle();
  }

  ParseContext.fromContext(ParseContext parseContext) {
    rootWidgetList = parseContext.rootWidgetList;
    parentElement = parseContext.parentElement;
    parentRichText = parseContext.parentRichText;
    indentLevel = parseContext.indentLevel;
    listCount = parseContext.listCount;
    listChar = parseContext.listChar;
    blockType = parseContext.blockType;
    condenseWhitespace = parseContext.condenseWhitespace;
    spansOnly = parseContext.spansOnly;
    inBlock = parseContext.inBlock;
    childStyle = parseContext.childStyle ?? TextStyle();
    shrinkToFit = parseContext.shrinkToFit;
    maxLines = parseContext.maxLines;
    indentPadding = parseContext.indentPadding;
    skip = false;
  }

  void addWidget(InlineSpan widget) {
    if (parentElement is TextSpan) {
      if (widget is WidgetSpan) {
        if (parentRichText is RichText) {
          parentElement.children.add(widget);
          parentRichText.children.add(widget.child);
        } else {
          // we don't have a parent rich text.....as not to crash everything, let's just do our old backup
          TextSpan span = TextSpan(
            text: parentElement.text,
            style: parentElement.style,
            children: <InlineSpan>[...parentElement.children, widget],
          );
          RichText richText = RichText(text: span, maxLines: maxLines);
          BlockText blockElement = BlockText(
            shrinkToFit: shrinkToFit,
            child: richText,
          );
          rootWidgetList.removeLast();
          rootWidgetList.add(blockElement);
          parentElement = span;
          parentRichText = richText;
        }
      } else {
        parentElement.children.add(widget);
      }
    } else {
      TextSpan span = TextSpan(
        children: <InlineSpan>[widget],
      );
      RichText richText = RichText(text: span, maxLines: maxLines);
      BlockText blockElement = BlockText(
        shrinkToFit: shrinkToFit,
        child: richText,
      );
      rootWidgetList.add(blockElement);
      parentElement = span;
      parentRichText = richText;
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
      shrinkToFit: shrinkToFit,
      maxLines: maxLines,
    );

    // don't ignore the top level "body"
    _parseNode(body, parseContext, context);

    // filter out empty widgets
    List<Widget> children = [];
    int i = 0;
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

      // craete a text span and detect links
      TextSpan span;
      final links = URL_REGEX.allMatches(finalText);
      if (links.isEmpty) {
        // create a span by default
        span = TextSpan(
          children: <InlineSpan>[
            TextSpan(text: finalText),
          ],
          style: parseContext.childStyle,
        );
      } else {
        TextStyle _linkStyle = parseContext.childStyle.merge(linkStyle);
        final textParts = finalText.split(URL_REGEX);
        final textSpans = <InlineSpan>[];
        int i = 0;
        textParts.forEach((textPart) {
          textSpans.add(TextSpan(text: textPart));
          if (i < links.length) {
            final link = links.elementAt(i).group(0);
            textSpans.add(LinkTextSpan(
              style: _linkStyle,
              url: link,
              text: link,
              onLinkTap: onLinkTap,
            ));
          }
          i++;
        });
        span = TextSpan(
          children: textSpans,
          style: parseContext.childStyle,
        );
      }

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
        RichText richText;
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
          richText = RichText(
            textAlign: TextAlign.left,
            text: span,
            maxLines: maxLines,
          );
          BlockText blockText = BlockText(
            shrinkToFit: shrinkToFit,
            margin: EdgeInsets.only(
                top: 8.0,
                bottom: 8.0,
                left: parseContext.indentLevel * indentSize),
            padding: EdgeInsets.all(2.0),
            decoration: decoration,
            child: richText,
          );
          parseContext.rootWidgetList.add(blockText);
        } else {
          richText = RichText(text: span, maxLines: maxLines);
          parseContext.rootWidgetList.add(BlockText(
            child: richText,
            shrinkToFit: shrinkToFit,
          ));
        }

        // this allows future items to be added as children of this item
        parseContext.parentElement = span;
        parseContext.parentRichText = richText;

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
      // make a copy of the current context so that we can modify
      // pieces of it for the next iteration of this function
      ParseContext nextContext = new ParseContext.fromContext(parseContext);

      if (!_supportedElements.contains(node.localName)) {
        if (node.localName == "mx-reply") { // drop reply fallback
          return;
        }
        node.nodes.forEach((dom.Node childNode) {
          _parseNode(childNode, nextContext, buildContext);
        });
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
            nextContext.blockType = 'ol';
            break;
          case "ul":
            nextContext.indentLevel += 1;
            nextContext.listChar = '•';
            nextContext.listCount = 0;
            nextContext.blockType = 'ul';
            break;
          case "blockquote":
            nextContext.indentPadding += 6.0;
            nextContext.blockType = 'blockquote';
            break;
          case "span":
            if (node.attributes['data-mx-color'] != null) {
              childStyle = childStyle.merge(TextStyle(color: CssColor.fromCss(
                node.attributes['data-mx-color'],
              )));
            }
            if (node.attributes['data-mx-bg-color'] != null) {
              childStyle = childStyle.merge(TextStyle(backgroundColor: CssColor.fromCss(
                node.attributes['data-mx-bg-color'],
              )));
            }
            // we need to hackingly check the outerHtml as the atributes don't contain blank ones, somehow
            if (node.attributes['data-mx-spoiler'] != null || node.outerHtml.split(">")[0].contains("data-mx-spoiler")) {
              final reason = node.attributes['data-mx-spoiler'];
              TextSpan span = TextSpan(
                text: '',
                children: <InlineSpan>[],
              );
              RichText richText = RichText(text: span, maxLines: maxLines);
              parseContext.addWidget(WidgetSpan(
                child: Spoiler(
                  reason: reason,
                  child: richText,
                ),
              ));
              nextContext.inBlock = true;
              nextContext.parentElement = span;
              nextContext.parentRichText = richText;
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
            if (node.attributes['color'] != null || node.attributes['data-mx-color'] != null) {
              childStyle = childStyle.merge(TextStyle(color: CssColor.fromCss(
                node.attributes['color'] ?? node.attributes['data-mx-color'],
              )));
            }
            if (node.attributes['data-mx-bg-color'] != null) {
              childStyle = childStyle.merge(TextStyle(backgroundColor: CssColor.fromCss(
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
            String url = node.attributes['href'] ?? null;
            if (url != null && url.startsWith(MATRIX_TO_SCHEME)) {
              // this might be a pill!
              final identifier = url.substring(MATRIX_TO_SCHEME.length);
              final pillMatch = RegExp(r"^[@#!][^:]+:[^\/]+$").firstMatch(identifier);
              if (pillMatch != null) {
                // we have a pill
                parseContext.addWidget(WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Pill(
                    identifier: identifier,
                    future: this.getPillInfo != null ? this.getPillInfo(identifier) : null,
                    onTap: this.onPillTap,
                    getMxcUrl: this.getMxcUrl,
                  ),
                ));
                nextContext.skip = true;
                break;
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
              nextContext.parentRichText = null;
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
                nextContext.parentRichText = parseContext.parentRichText;
              } else {
                // start a new block element for this link and its text
                RichText richText = RichText(text: span, maxLines: maxLines);
                BlockText blockElement = BlockText(
                  shrinkToFit: shrinkToFit,
                  margin: EdgeInsets.only(
                      left: parseContext.indentLevel * indentSize, top: 10.0),
                  child: richText,
                );
                parseContext.rootWidgetList.add(blockElement);
                nextContext.inBlock = true;
                nextContext.parentRichText = richText;
              }
              nextContext.childStyle = linkStyle;
              nextContext.parentElement = span;
            }
            break;

          case "img":
            if (showImages) {
              if (node.attributes['src'] != null) {
                final width = imageProperties?.width ??
                    ((node.attributes['width'] != null)
                        ? double.tryParse(node.attributes['width'])
                        : null);
                final height = imageProperties?.height ??
                    ((node.attributes['height'] != null)
                        ? double.tryParse(node.attributes['height'])
                        : null);

                final url = node.attributes['src'].startsWith("mxc://") && getMxcUrl != null ?
                    getMxcUrl(node.attributes['src'], width, height) : "";

                precacheImage(
                  AdvancedNetworkImage(
                    url,
                    useDiskCache: !kIsWeb,
                  ),
                  buildContext,
                  onError: onImageError ?? (_, __) {},
                );
                WidgetSpan widget = WidgetSpan(
                  alignment: PlaceholderAlignment.bottom,
                  child: GestureDetector(
                    child: Image.network(
                      url,
                      frameBuilder: (context, child, frame, _) {
                        if (node.attributes['alt'] != null && frame == null) {
                          return BlockText(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: node.attributes['alt'],
                                style: nextContext.childStyle,
                              ),
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
            parseContext.parentRichText = null;
            nextContext.parentElement = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[],
            );
            nextContext.parentRichText = null;
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
                RichText(text: TextSpan(text: '', children: <InlineSpan>[]), maxLines: maxLines);
            Expanded cell = Expanded(
              flex: colspan,
              child: Container(padding: EdgeInsets.all(1.0), child: text),
            );
            nextContext.parentElement.children.add(cell);
            nextContext.parentElement = text.text;
            nextContext.parentRichText = text;
            break;

          case "tr":
            Row row = Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[],
            );
            nextContext.parentElement.children.add(row);
            nextContext.parentElement = row;
            nextContext.parentRichText = null;
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
                text: TextSpan(text: '', children: <InlineSpan>[]),
                maxLines: maxLines);
            Expanded cell = Expanded(
              child: Container(padding: EdgeInsets.all(2.0), child: text),
            );
            row.children.add(cell);
            nextContext.parentElement.children.add(row);
            nextContext.parentElement = text.text;
            nextContext.parentRichText = text;
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
              nextContext.parentRichText = parseContext.parentRichText;
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
        parseContext.parentRichText = null;
        TextAlign textAlign = TextAlign.left;
        if (customTextAlign != null) {
          textAlign = customTextAlign(node) ?? textAlign;
        }

        EdgeInsets _customEdgeInsets;
        if (customEdgeInsets != null) {
          _customEdgeInsets = customEdgeInsets(node);
        }

        switch (node.localName) {
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
              child: RichText(
                text: TextSpan(
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
            nextContext.parentElement = blockText.child.text;
            nextContext.parentRichText = blockText.child;
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
                    Border(left: BorderSide(color: defaultTextStyle.color, width: 3)),
              );
            }
            BlockText blockText = BlockText(
              shrinkToFit: shrinkToFit,
              margin: node.localName != 'body'
                  ? _customEdgeInsets ??
                      EdgeInsets.only(
                        // > 1 because there is the body tag, too
                        top: parseContext.rootWidgetList.length > 1 ? 8.0 : 0.0,
                        left: parseContext.indentLevel * indentSize
                      )
                  : EdgeInsets.zero,
              padding: EdgeInsets.only(
                top: 2.0,
                left: parseContext.indentPadding == 0.0 ? 2.0 : parseContext.indentPadding,
                right: 2.0,
                bottom: 2.0,
              ),
              decoration: decoration,
              child: RichText(
                textAlign: textAlign,
                text: TextSpan(
                  text: '',
                  style: nextContext.childStyle,
                  children: <InlineSpan>[],
                ),
                maxLines: maxLines,
              ),
            );
            parseContext.rootWidgetList.add(blockText);
            nextContext.parentElement = blockText.child.text;
            nextContext.parentRichText = blockText.child;
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

      if (!nextContext.skip) {
        node.nodes.forEach((dom.Node childNode) {
          _parseNode(childNode, nextContext, buildContext);
        });
      }
    }
  }

  String condenseHtmlWhitespace(String stringToTrim) {
    stringToTrim = stringToTrim.replaceAll("\n", " ");
    while (stringToTrim.indexOf("  ") != -1) {
      stringToTrim = stringToTrim.replaceAll("  ", " ");
    }
    return stringToTrim;
  }
}
