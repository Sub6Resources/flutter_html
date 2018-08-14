import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class HtmlParser {
  static const _supportedElements = ["b", "body", "div", "i", "u"];

  ///Parses an html string and returns a list of widgets that represent the body of your html document.
  static List<Widget> parse(String data) {
    List<Widget> widgetList = new List<Widget>();

    dom.Document document = parser.parse(data);
    widgetList.add(_parseNode(document.body));
    return widgetList;
  }

  static Widget _parseNode(dom.Node node) {
    if (node is dom.Element) {
      print("Found ${node.localName}");
      if (!_supportedElements.contains(node.localName)) {
        return Placeholder();
      }
      switch (node.localName) {
        case "b":
          return RichText(
              text: TextSpan(
            children: _parseInlineElement(node),
            style: HtmlTextStyles.italics,
          ));
        case "body":
          return Column(
            children: _parseNodeList(node.nodes),
          );
        case "div":
          return Column(
            children: _parseNodeList(node.nodes),
          );
        case "i":
          return RichText(
              text: TextSpan(
            children: _parseInlineElement(node),
            style: HtmlTextStyles.italics,
          ));
        case "u":
          return RichText(
              text: TextSpan(
            children: _parseInlineElement(node),
            style: HtmlTextStyles.underline,
          ));
      }
    } else if (node is dom.Text) {
      print("Plain Text Node: '${node.text}'");
      return Text(node.text);
    }
    return Placeholder();
  }

  static List<Widget> _parseNodeList(List<dom.Node> nodeList) {
    return nodeList.map((node) {
      return _parseNode(node);
    }).toList();
  }

  static const _supportedInlineElements = ["b", "i", "u"];

  static List<TextSpan> _parseInlineElement(dom.Element element) {
    List<TextSpan> textSpanList = new List<TextSpan>();

    element.nodes.forEach((node) {
      if (node is dom.Element) {
        print("Found inline ${node.localName}");
        if (!_supportedInlineElements.contains(node.localName)) {
          textSpanList.add(TextSpan(text: node.text));
        } else {
          switch (node.localName) {
            case "b":
              textSpanList.add(
                  TextSpan(style: HtmlTextStyles.bold, children: _parseInlineElement(node)));
              break;
            case "i":
              textSpanList.add(
                  TextSpan(style: HtmlTextStyles.italics, children: _parseInlineElement(node)));
              break;
            case "u":
              textSpanList.add(
                TextSpan(style: HtmlTextStyles.underline, children: _parseInlineElement(node)));
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

///A class to hold static TextSpan styles
class HtmlTextStyles {
  static const bold = TextStyle(fontWeight: FontWeight.bold);
  static const italics = TextStyle(fontStyle: FontStyle.italic);
  static const underline = TextStyle(decoration: TextDecoration.underline);
}
