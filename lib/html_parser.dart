import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class HtmlParser {
  HtmlParser({this.defaultTextStyle = const TextStyle(color: Colors.black)});

  final TextStyle defaultTextStyle;

  static const _supportedElements = [
    "a",
    "abbr",
    "address",
    "article",
    "aside",
    "b",
    "blockquote",
    "body",
    "br",
    "caption",
    "cite",
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
    "strong",
    "table",
    "tbody",
    "td",
    "template",
    "tfoot",
    "th",
    "thead",
    "time",
    "tr",
    "u",
    "ul", //partial
    "var",
  ];

  ///Parses an html string and returns a list of widgets that represent the body of your html document.
  List<Widget> parse(String data) {
    List<Widget> widgetList = new List<Widget>();

    dom.Document document = parser.parse(data);
    widgetList.add(_parseNode(document.body));
    return widgetList;
  }

  Widget _parseNode(dom.Node node) {
    if (node is dom.Element) {
      print("Found ${node.localName}");
      if (!_supportedElements.contains(node.localName)) {
        return Container();
      }
      switch (node.localName) {
        case "a":
          return RichText(
              text: TextSpan(
            children: [
              TextSpan(
                children: _parseInlineElement(node),
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              )
            ],
            style: defaultTextStyle,
          ));
        case "abbr":
          return RichText(
              text: TextSpan(
            children: [
              TextSpan(
                children: _parseInlineElement(node),
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dotted,
                ),
              )
            ],
            style: defaultTextStyle,
          ));
        case "address":
          return RichText(
              text: TextSpan(children: [
            TextSpan(
              children: _parseInlineElement(node),
              style: TextStyle(fontStyle: FontStyle.italic),
            )
          ], style: defaultTextStyle));
        case "article":
          return Column(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.start,
          );
        case "aside":
          return Column(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.start,
          );
        case "b":
          return RichText(
              text: TextSpan(children: [
            TextSpan(
              children: _parseInlineElement(node),
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ], style: defaultTextStyle));
        case "blockquote":
          return Padding(
              padding: EdgeInsets.fromLTRB(40.0, 14.0, 40.0, 14.0),
              child: Column(
                children: _parseNodeList(node.nodes),
                crossAxisAlignment: CrossAxisAlignment.start,
              ));
        case "body":
          return Column(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.start,
          );
        case "br":
          return Container(height: 14.0);
        case "caption":
          return Column(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.center,
          );
        case "cite":
          return RichText(
              text: TextSpan(
            children: [
              TextSpan(
                  children: _parseInlineElement(node),
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                  ))
            ],
            style: defaultTextStyle,
          ));
        case "code":
          return RichText(
              text: TextSpan(
            children: [
              TextSpan(
                  children: _parseInlineElement(node),
                  style: TextStyle(
                    fontFamily: 'monospace',
                  ))
            ],
            style: defaultTextStyle,
          ));
        case "data":
          return RichText(
              text: TextSpan(
            children: _parseInlineElement(node),
            style: defaultTextStyle,
          ));
        case "dd":
          return Padding(
              padding: EdgeInsets.only(left: 40.0),
              child: Column(
                children: _parseNodeList(node.nodes),
                crossAxisAlignment: CrossAxisAlignment.start,
              ));
        case "del":
          return RichText(
              text: TextSpan(
            children: [
              TextSpan(
                  children: _parseInlineElement(node),
                  style: TextStyle(
                    decoration: TextDecoration.lineThrough,
                  ))
            ],
            style: defaultTextStyle,
          ));
        case "dfn":
          return RichText(
              text: TextSpan(
            children: [
              TextSpan(
                  children: _parseInlineElement(node),
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                  ))
            ],
            style: defaultTextStyle,
          ));
        case "div":
          return Column(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.start,
          );
        case "dl":
          return Padding(
              padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: Column(
                children: _parseNodeList(node.nodes),
                crossAxisAlignment: CrossAxisAlignment.start,
              ));
        case "dt":
          return RichText(
              text: TextSpan(
            children: _parseInlineElement(node),
            style: defaultTextStyle,
          ));
        case "em":
          return RichText(
              text: TextSpan(
            children: [
              TextSpan(
                  children: _parseInlineElement(node),
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                  ))
            ],
            style: defaultTextStyle,
          ));
        case "figcaption":
          return RichText(
              text: TextSpan(
            children: _parseInlineElement(node),
            style: defaultTextStyle,
          ));
        case "figure":
          return Padding(
              padding: EdgeInsets.fromLTRB(40.0, 14.0, 40.0, 14.0),
              child: Column(
                children: _parseNodeList(node.nodes),
                crossAxisAlignment: CrossAxisAlignment.start,
              ));
        case "footer":
          return Column(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.start,
          );
        case "h1":
          return RichText(
              text: TextSpan(
            children: [
              TextSpan(
                  children: _parseInlineElement(node),
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                  ))
            ],
            style: defaultTextStyle,
          ));
        case "h2":
          return RichText(
              text: TextSpan(
            children: [
              TextSpan(
                  children: _parseInlineElement(node),
                  style: TextStyle(
                    fontSize: 21.0,
                    fontWeight: FontWeight.bold,
                  ))
            ],
            style: defaultTextStyle,
          ));
        case "h3":
          return RichText(
              text: TextSpan(
            children: [
              TextSpan(
                  children: _parseInlineElement(node),
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ))
            ],
            style: defaultTextStyle,
          ));
        case "h4":
          return RichText(
              text: TextSpan(
            children: [
              TextSpan(
                  children: _parseInlineElement(node),
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ))
            ],
            style: defaultTextStyle,
          ));
        case "h5":
          return RichText(
              text: TextSpan(
            children: [
              TextSpan(
                  children: _parseInlineElement(node),
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                  ))
            ],
            style: defaultTextStyle,
          ));
        case "h6":
          return RichText(
              text: TextSpan(
            children: [
              TextSpan(
                  children: _parseInlineElement(node),
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                  ))
            ],
            style: defaultTextStyle,
          ));
        case "header":
          return Column(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.start,
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
          return RichText(
              text: TextSpan(
            children: [
              TextSpan(
                children: _parseInlineElement(node),
                style: TextStyle(fontStyle: FontStyle.italic),
              )
            ],
            style: defaultTextStyle,
          ));
        case "img":
          return Image.network(node.attributes['src']);
        case "ins":
          return RichText(
              text: TextSpan(
            children: [
              TextSpan(
                children: _parseInlineElement(node),
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              )
            ],
            style: defaultTextStyle,
          ));
        case "kbd":
          return RichText(
              text: TextSpan(
            children: [
              TextSpan(
                  children: _parseInlineElement(node),
                  style: TextStyle(
                    fontFamily: 'monospace',
                  ))
            ],
            style: defaultTextStyle,
          ));
        case "li":
          return RichText(
              text: TextSpan(
            children: _parseInlineElement(node),
            style: defaultTextStyle,
          ));
        case "main":
          return Column(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.start,
          );
        case "mark":
          return RichText(
              text: TextSpan(
            children: [
              TextSpan(
                children: _parseInlineElement(node),
                style: TextStyle(
                    color: Colors.black, background: _getPaint(Colors.yellow)),
              )
            ],
            style: defaultTextStyle,
          ));
        case "nav":
          return Column(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.start,
          );
        case "noscript":
          return Column(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.start,
          );
        case "ol":
          return Column(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.start,
          );
        case "p":
          return RichText(
              text: TextSpan(
            children: _parseInlineElement(node),
            style: defaultTextStyle,
          ));
        case "pre":
          return Padding(
            padding: const EdgeInsets.only(top: 14.0, bottom: 14.0),
            child: RichText(
                text: TextSpan(
              children: [
                TextSpan(
                    children: _parseInlineElement(node),
                    style: TextStyle(
                      fontFamily: 'monospace',
                    ))
              ],
              style: defaultTextStyle,
            )),
          );
        case "q":
          return RichText(
              text: TextSpan(
            children: [
              TextSpan(text: "\""),
              TextSpan(
                children: _parseInlineElement(node),
              ),
              TextSpan(text: "\"")
            ],
            style: defaultTextStyle,
          ));
        case "rp":
          return RichText(
              text: TextSpan(
            children: _parseInlineElement(node),
            style: defaultTextStyle,
          ));
        case "rt":
          return RichText(
              text: TextSpan(
            children: _parseInlineElement(node),
            style: defaultTextStyle,
          ));
        case "ruby":
          return RichText(
              text: TextSpan(
            children: _parseInlineElement(node),
            style: defaultTextStyle,
          ));
        case "s":
          return RichText(
              text: TextSpan(
            children: [
              TextSpan(
                  children: _parseInlineElement(node),
                  style: TextStyle(
                    decoration: TextDecoration.lineThrough,
                  ))
            ],
            style: defaultTextStyle,
          ));
        case "samp":
          return RichText(
              text: TextSpan(
            children: [
              TextSpan(
                  children: _parseInlineElement(node),
                  style: TextStyle(
                    fontFamily: 'monospace',
                  ))
            ],
            style: defaultTextStyle,
          ));
        case "section":
          return Column(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.start,
          );
        case "small":
          return RichText(
              text: TextSpan(
            children: [
              TextSpan(
                  children: _parseInlineElement(node),
                  style: TextStyle(
                    fontSize: 10.0,
                  ))
            ],
            style: defaultTextStyle,
          ));
        case "span":
          return RichText(
              text: TextSpan(
            children: _parseInlineElement(node),
            style: defaultTextStyle,
          ));
        case "strong":
          return RichText(
              text: TextSpan(
            children: [
              TextSpan(
                  children: _parseInlineElement(node),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ))
            ],
            style: defaultTextStyle,
          ));
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
          return Column(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.center,
          );
        case "template":
          return Container();
        case "tfoot":
          return Column(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.start,
          );
        case "th":
          return Column(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.center,
          );
        case "thead":
          return Column(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.start,
          );
        case "time":
          return RichText(
              text: TextSpan(
            children: _parseInlineElement(node),
            style: defaultTextStyle,
          ));
        case "tr":
          return Row(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.center,
          );
        case "u":
          return RichText(
              text: TextSpan(
            children: [
              TextSpan(
                children: _parseInlineElement(node),
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              )
            ],
            style: defaultTextStyle,
          ));
        case "ul":
          return Column(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.start,
          );
        case "var":
          return RichText(
              text: TextSpan(
            children: [
              TextSpan(
                children: _parseInlineElement(node),
                style: TextStyle(fontStyle: FontStyle.italic),
              )
            ],
            style: defaultTextStyle,
          ));
      }
    } else if (node is dom.Text) {
      if (node.text.trim() == "") {
        return Container();
      }
      print("Plain Text Node: '${node.text}'");
      return Text(node.text, style: defaultTextStyle);
    }
    return Container();
  }

  List<Widget> _parseNodeList(List<dom.Node> nodeList) {
    return nodeList.map((node) {
      return _parseNode(node);
    }).toList();
  }

  static const _supportedInlineElements = [
    "a",
    "abbr",
    "address",
    "b",
    "br",
    "cite",
    "code",
    "data",
    "dfn",
    "dt",
    "em",
    "figcaption",
    "h1",
    "h2",
    "h3",
    "h4",
    "h5",
    "h6",
    "i",
    "ins",
    "kbd",
    "mark",
    "p",
    "pre",
    "q",
    "rp",
    "rt",
    "ruby",
    "s",
    "samp",
    "small",
    "span",
    "strong",
    "time",
    "u",
    "var",
  ];

  List<TextSpan> _parseInlineElement(dom.Element element) {
    List<TextSpan> textSpanList = new List<TextSpan>();

    element.nodes.forEach((node) {
      if (node is dom.Element) {
        print("Found inline ${node.localName}");
        if (!_supportedInlineElements.contains(node.localName)) {
          textSpanList.add(TextSpan(text: node.text));
        } else {
          switch (node.localName) {
            case "a":
              textSpanList.add(TextSpan(
                style: TextStyle(decoration: TextDecoration.underline),
                children: _parseInlineElement(node),
              ));
              break;
            case "abbr":
              textSpanList.add(TextSpan(
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dotted,
                ),
                children: _parseInlineElement(node),
              ));
              break;
              break;
            case "address":
              textSpanList.add(TextSpan(
                style: TextStyle(fontWeight: FontWeight.bold),
                children: _parseInlineElement(node),
              ));
              break;
            case "b":
              textSpanList.add(TextSpan(
                style: TextStyle(fontWeight: FontWeight.bold),
                children: _parseInlineElement(node),
              ));
              break;
            case "br":
              textSpanList.add(TextSpan(
                text: "\n",
              ));
              break;
            case "cite":
              textSpanList.add(TextSpan(
                style: TextStyle(fontStyle: FontStyle.italic),
                children: _parseInlineElement(node),
              ));
              break;
            case "code":
              textSpanList.add(TextSpan(
                style: TextStyle(fontFamily: 'monospace'),
                children: _parseInlineElement(node),
              ));
              break;
            case "data":
              textSpanList.add(TextSpan(
                children: _parseInlineElement(node),
              ));
              break;
            case "del":
              textSpanList.add(TextSpan(
                style: TextStyle(decoration: TextDecoration.lineThrough),
                children: _parseInlineElement(node),
              ));
              break;
            case "dfn":
              textSpanList.add(TextSpan(
                style: TextStyle(fontStyle: FontStyle.italic),
                children: _parseInlineElement(node),
              ));
              break;
            case "dt":
              textSpanList.add(TextSpan(
                children: _parseInlineElement(node),
              ));
              break;
            case "em":
              textSpanList.add(TextSpan(
                style: TextStyle(fontStyle: FontStyle.italic),
                children: _parseInlineElement(node),
              ));
              break;
            case "figcaption":
              textSpanList.add(TextSpan(
                children: _parseInlineElement(node),
              ));
              break;
            case "h1":
              textSpanList.add(TextSpan(
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              ));
              break;
            case "h2":
              textSpanList.add(TextSpan(
                style: TextStyle(
                  fontSize: 21.0,
                  fontWeight: FontWeight.bold,
                ),
              ));
              break;
            case "h3":
              textSpanList.add(TextSpan(
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ));
              break;
            case "h4":
              textSpanList.add(TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ));
              break;
            case "h5":
              textSpanList.add(TextSpan(
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ));
              break;
            case "h6":
              textSpanList.add(TextSpan(
                style: TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                ),
              ));
              break;
            case "i":
              textSpanList.add(TextSpan(
                  style: TextStyle(fontStyle: FontStyle.italic),
                  children: _parseInlineElement(node)));
              break;
            case "ins":
              textSpanList.add(TextSpan(
                  style: TextStyle(decoration: TextDecoration.underline),
                  children: _parseInlineElement(node)));
              break;
            case "kbd":
              textSpanList.add(TextSpan(
                style: TextStyle(fontFamily: 'monospace'),
                children: _parseInlineElement(node),
              ));
              break;
            case "mark":
              textSpanList.add(TextSpan(
                style: TextStyle(
                    color: Colors.black, background: _getPaint(Colors.yellow)),
                children: _parseInlineElement(node),
              ));
              break;
            case "p":
              textSpanList.add(TextSpan(children: _parseInlineElement(node)));
              break;
            case "pre":
              textSpanList.add(TextSpan(
                style: TextStyle(fontFamily: 'monospace'),
              ));
              break;
            case "q":
              textSpanList.add(TextSpan(
                children: [
                  TextSpan(text: "\""),
                  TextSpan(children: _parseInlineElement(node)),
                  TextSpan(text: "\""),
                ],
              ));
              break;
            case "rp":
              textSpanList.add(TextSpan(
                children: _parseInlineElement(node),
              ));
              break;
            case "rt":
              textSpanList.add(TextSpan(
                children: _parseInlineElement(node),
              ));
              break;
            case "ruby":
              textSpanList.add(TextSpan(
                children: _parseInlineElement(node),
              ));
              break;
            case "s":
              textSpanList.add(TextSpan(
                style: TextStyle(decoration: TextDecoration.lineThrough),
                children: _parseInlineElement(node),
              ));
              break;
            case "samp":
              textSpanList.add(TextSpan(
                style: TextStyle(fontFamily: 'monospace'),
                children: _parseInlineElement(node),
              ));
              break;
            case "small":
              textSpanList.add(TextSpan(
                style: TextStyle(fontSize: 10.0),
                children: _parseInlineElement(node),
              ));
              break;
            case "span":
              textSpanList.add(TextSpan(
                children: _parseInlineElement(node),
              ));
              break;
            case "strong":
              textSpanList.add(TextSpan(
                  style: TextStyle(fontWeight: FontWeight.bold),
                  children: _parseInlineElement(node)));
              break;
            case "time":
              textSpanList.add(TextSpan(
                children: _parseInlineElement(node),
              ));
              break;
            case "u":
              textSpanList.add(TextSpan(
                  style: TextStyle(decoration: TextDecoration.underline),
                  children: _parseInlineElement(node)));
              break;
            case "var":
              textSpanList.add(TextSpan(
                  style: TextStyle(fontStyle: FontStyle.italic),
                  children: _parseInlineElement(node)));
              break;
          }
        }
      } else {
        print("Text Node: '${node.text}'");
        textSpanList.add(TextSpan(text: node.text));
      }
    });

    return textSpanList;
  }

  Paint _getPaint(Color color) {
    Paint paint = new Paint();
    paint.color = color;
    return paint;
  }
}
