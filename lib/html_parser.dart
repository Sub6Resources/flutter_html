import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class HtmlParser {
  HtmlParser({
    @required this.width,
    this.onLinkTap,
  });

  final double width;
  final Function onLinkTap;

  static const _supportedElements = [
    "a",
    "abbr",
    "address",
    "article",
    "aside",
    "b",
    "bdi",
    "bdo",
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
    "strike",
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
    "tt",
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
              if (node.attributes.containsKey('href')) {
                String url = node.attributes['href'];
                onLinkTap(url);
              }
            }
          );
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
              children: _parseNodeList(node.nodes),
            ),
          );
        case "aside":
          return Container(
            width: width,
            child: Wrap(
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
        case "blockquote":
          return Padding(
            padding: EdgeInsets.fromLTRB(40.0, 14.0, 40.0, 14.0),
            child: Container(
              width: width,
              child: Wrap(
                children: _parseNodeList(node.nodes),
              ),
            ),
          );
        case "body":
          return Container(
            width: width,
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
          );
        case "br":
          if (node.previousElementSibling != null &&
              node.previousElementSibling.localName == "br") {
            return Container(width: width, height: 14.0);
          }
          return Container(width: width);
        case "caption":
          return Container(
            width: width,
            child: Wrap(
              alignment: WrapAlignment.center,
              children: _parseNodeList(node.nodes),
            ),
          );
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
              children: _parseNodeList(node.nodes),
            ),
          );
        case "dl":
          return Padding(
              padding: EdgeInsets.only(top: 14.0, bottom: 14.0),
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
              padding: EdgeInsets.fromLTRB(40.0, 14.0, 40.0, 14.0),
              child: Column(
                children: _parseNodeList(node.nodes),
                crossAxisAlignment: CrossAxisAlignment.center,
              ));
        case "footer":
          return Container(
            width: width,
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
          );
        case "h1":
          return DefaultTextStyle.merge(
            child: Container(
              width: width,
              child: Wrap(
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
          return Image.network(node.attributes['src']);
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
          return Container(
            width: width,
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
          );
        case "main":
          return Container(
            width: width,
            child: Wrap(
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
              children: _parseNodeList(node.nodes),
            ),
          );
        case "noscript":
          return Container(
            width: width,
            child: Wrap(
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
            padding: EdgeInsets.only(top: 14.0, bottom: 14.0),
            child: Container(
              width: width,
              child: Wrap(
                children: _parseNodeList(node.nodes),
              ),
            ),
          );
        case "pre":
          return Padding(
            padding: const EdgeInsets.all(14.0),
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
      if (node.text.trim() == "") {
        return Container();
      }

      print("Plain Text Node: '${trimStringHtml(node.text)}'");
      String finalText = trimStringHtml(node.text);
      //Temp fix for https://github.com/flutter/flutter/issues/736
      if (finalText.endsWith(" ")) {
        return Container(
            padding: EdgeInsets.only(right: 2.0), child: Text(finalText));
      } else {
        return Text(finalText);
      }
    }
    return Container();
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
}
