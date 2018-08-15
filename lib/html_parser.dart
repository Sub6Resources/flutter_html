import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class HtmlParser {
  HtmlParser({this.defaultTextStyle = const TextStyle(color: Colors.black)});

  final TextStyle defaultTextStyle;

  static const _supportedElements = [
    "b",
    "body",
    "div",
    "em",
    "h1",
    "h2",
    "h3",
    "h4",
    "h5",
    "h6",
    "i",
    "p",
    "strong",
    "u",
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
        case "b":
          return RichText(
              text: TextSpan(children: [
            TextSpan(
              children: _parseInlineElement(node),
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ], style: defaultTextStyle));
        case "body":
          return Column(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.start,
          );
        case "div":
          return Column(
            children: _parseNodeList(node.nodes),
            crossAxisAlignment: CrossAxisAlignment.start,
          );
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
        case "p":
          return RichText(
              text: TextSpan(
            children: _parseInlineElement(node),
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
    "b",
    "em",
    "h1",
    "h2",
    "h3",
    "h4",
    "h5",
    "h6",
    "i",
    "p",
    "strong",
    "u",
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
            case "b":
              textSpanList.add(TextSpan(
                  style: TextStyle(fontWeight: FontWeight.bold),
                  children: _parseInlineElement(node)));
              break;
            case "em":
              textSpanList.add(TextSpan(
                  style: TextStyle(fontStyle: FontStyle.italic),
                  children: _parseInlineElement(node)));
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
            case "p":
              textSpanList.add(TextSpan(children: _parseInlineElement(node)));
              break;
            case "strong":
              textSpanList.add(TextSpan(
                  style: TextStyle(fontWeight: FontWeight.bold),
                  children: _parseInlineElement(node)));
              break;
            case "u":
              textSpanList.add(TextSpan(
                  style: TextStyle(decoration: TextDecoration.underline),
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
}
