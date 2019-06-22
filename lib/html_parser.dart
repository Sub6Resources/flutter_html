import 'dart:convert';
import 'package:flutter_html/rich_text_parser.dart';

import 'image_properties.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;

class HtmlOldParser extends StatelessWidget {
  HtmlOldParser({
    @required this.width,
    this.onLinkTap,
    this.renderNewlines = false,
    this.customRender,
    this.blockSpacing,
    this.html,
    this.onImageError,
    this.linkStyle = const TextStyle(
        decoration: TextDecoration.underline,
        color: Colors.blueAccent,
        decorationColor: Colors.blueAccent),
    this.showImages = true,
  });

  final double width;
  final OnLinkTap onLinkTap;
  final bool renderNewlines;
  final CustomRender customRender;
  final double blockSpacing;
  final String html;
  final ImageErrorListener onImageError;
  final TextStyle linkStyle;
  final bool showImages;

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
                style: linkStyle,
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
            child: Divider(height: 1.0, color: Colors.black38),
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
          return Builder(
            builder: (BuildContext context) {
              if (showImages) {
                if (node.attributes['src'] != null) {
                  if (node.attributes['src'].startsWith("data:image") &&
                      node.attributes['src'].contains("base64,")) {
                    precacheImage(
                      MemoryImage(base64.decode(
                          node.attributes['src'].split("base64,")[1].trim())),
                      context,
                      onError: onImageError,
                    );
                    return Image.memory(base64.decode(
                        node.attributes['src'].split("base64,")[1].trim()));
                  }
                  precacheImage(
                    NetworkImage(node.attributes['src']),
                    context,
                    onError: onImageError,
                  );
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
              }
              return Container();
            },
          );
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
