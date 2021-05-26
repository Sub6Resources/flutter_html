library flutter_html_math;

import 'package:html/dom.dart' as dom;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_math_fork/flutter_math.dart';

CustomRender mathRender({OnMathError? onMathError}) => CustomRender.fromWidget(widget: (context, buildChildren) {
  String texStr = context.tree.element == null ? '' : parseMathRecursive(context.tree.element!, r'');
  return Container(
      width: context.parser.shrinkWrap ? null : MediaQuery.of(context.buildContext).size.width,
      child: Math.tex(
        texStr,
        mathStyle: MathStyle.display,
        textStyle: context.style.generateTextStyle(),
        onErrorFallback: (FlutterMathException e) {
          if (onMathError != null) {
            return onMathError.call(texStr, e.message, e.messageWithType);
          } else {
            return Text(e.message);
          }
        },
      )
  );
});

CustomRenderMatcher mathMatcher() => (context) {
  return context.tree.element?.localName == "math";
};

String parseMathRecursive(dom.Node node, String parsed) {
  if (node is dom.Element) {
    List<dom.Element> nodeList = node.nodes.whereType<dom.Element>().toList();
    if (node.localName == "math" || node.localName == "mrow") {
      nodeList.forEach((element) {
        parsed = parseMathRecursive(element, parsed);
      });
    }
    // note: munder, mover, and munderover do not support placing braces and other
    // markings above/below elements, instead they are treated as super/subscripts for now.
    if ((node.localName == "msup" || node.localName == "msub"
        || node.localName == "munder" || node.localName == "mover") && nodeList.length == 2) {
      parsed = parseMathRecursive(nodeList[0], parsed);
      parsed = parseMathRecursive(nodeList[1],
          parsed + "${node.localName == "msup" || node.localName == "mover" ? "^" : "_"}{") + "}";
    }
    if ((node.localName == "msubsup" || node.localName == "munderover") && nodeList.length == 3) {
      parsed = parseMathRecursive(nodeList[0], parsed);
      parsed = parseMathRecursive(nodeList[1], parsed + "_{") + "}";
      parsed = parseMathRecursive(nodeList[2], parsed + "^{") + "}";
    }
    if (node.localName == "mfrac" && nodeList.length == 2) {
      parsed = parseMathRecursive(nodeList[0], parsed + r"\frac{") + "}";
      parsed = parseMathRecursive(nodeList[1], parsed + "{") + "}";
    }
    // note: doesn't support answer & intermediate steps
    if (node.localName == "mlongdiv" && nodeList.length == 4) {
      parsed = parseMathRecursive(nodeList[0], parsed);
      parsed = parseMathRecursive(nodeList[2], parsed + r"\overline{)") + "}";
    }
    if (node.localName == "msqrt" && nodeList.length == 1) {
      parsed = parseMathRecursive(nodeList[0], parsed + r"\sqrt{") + "}";
    }
    if (node.localName == "mroot" && nodeList.length == 2) {
      parsed = parseMathRecursive(nodeList[1], parsed + r"\sqrt[") + "]";
      parsed = parseMathRecursive(nodeList[0], parsed + "{") + "}";
    }
    if (node.localName == "mi" || node.localName == "mn" || node.localName == "mo") {
      if (mathML2Tex.keys.contains(node.text.trim())) {
        parsed = parsed + mathML2Tex[mathML2Tex.keys.firstWhere((e) => e == node.text.trim())]!;
      } else if (node.text.startsWith("&") && node.text.endsWith(";")) {
        parsed = parsed + node.text.trim().replaceFirst("&", r"\").substring(0, node.text.trim().length - 1);
      } else {
        parsed = parsed + node.text.trim();
      }
    }
  }
  return parsed;
}

Map<String, String> mathML2Tex = {
  "sin": r"\sin",
  "sinh": r"\sinh",
  "csc": r"\csc",
  "csch": r"csch",
  "cos": r"\cos",
  "cosh": r"\cosh",
  "sec": r"\sec",
  "sech": r"\sech",
  "tan": r"\tan",
  "tanh": r"\tanh",
  "cot": r"\cot",
  "coth": r"\coth",
  "log": r"\log",
  "ln": r"\ln",
};

typedef OnMathError = Widget Function(
    String parsedTex,
    String exception,
    String exceptionWithType,
    );

