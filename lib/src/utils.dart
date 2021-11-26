import 'dart:convert';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

Map<String, String> namedColors = {
  "White": "#FFFFFF",
  "Silver": "#C0C0C0",
  "Gray": "#808080",
  "Black": "#000000",
  "Red": "#FF0000",
  "Maroon": "#800000",
  "Yellow": "#FFFF00",
  "Olive": "#808000",
  "Lime": "#00FF00",
  "Green": "#008000",
  "Aqua": "#00FFFF",
  "Teal": "#008080",
  "Blue": "#0000FF",
  "Navy": "#000080",
  "Fuchsia": "#FF00FF",
  "Purple": "#800080",
};

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

class Context<T> {
  T data;

  Context(this.data);
}

// This class is a workaround so that both an image
// and a link can detect taps at the same time.
class MultipleTapGestureDetector extends InheritedWidget {
  final void Function()? onTap;

  const MultipleTapGestureDetector({
    Key? key,
    required Widget child,
    required this.onTap,
  }) : super(key: key, child: child);

  static MultipleTapGestureDetector? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MultipleTapGestureDetector>();
  }

  @override
  bool updateShouldNotify(MultipleTapGestureDetector oldWidget) => false;
}

class CustomBorderSide {
  CustomBorderSide({
    this.color = const Color(0xFF000000),
    this.width = 1.0,
    this.style = BorderStyle.none,
  }) : assert(width >= 0.0);

  Color? color;
  double width;
  BorderStyle style;
}

String getRandString(int len) {
  var random = Random.secure();
  var values = List<int>.generate(len, (i) =>  random.nextInt(255));
  return base64UrlEncode(values);
}