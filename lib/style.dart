import 'package:flutter/material.dart';
import 'package:flutter_html/src/block_element.dart';

///This class represents all the available CSS attributes
///for this package
class Style {
  ///CSS attribute "`background-color`"
  Color backgroundColor;

  ///CSS attribute "`color`"
  Color color;

  ///CSS attribute "`display`"
  Display display;

  ///CSS attribute "`font-family`"
  String fontFamily;

  ///CSS attribute "`font-size`"
  double fontSize;

  ///CSS attribute "`font-style`"
  FontStyle fontStyle;

  ///CSS attribute "`font-weight`"
  FontWeight fontWeight;

  ///CSS attribute "`list-style-type`"
  ListStyleType listStyleType;

  ///CSS attribute "`padding`"
  EdgeInsets padding;

  ///CSS attribute "`margin`"
  EdgeInsets margin;

  ///CSS attribute "`text-decoration`" -
  TextDecoration textDecoration;

  ///CSS attribute "`text-decoration-style`" -
  TextDecorationStyle textDecorationStyle;

  //TODO modify these to match CSS styles
  bool preserveWhitespace;
  int baselineOffset;
  String before;
  String after;
  TextDirection textDirection;
  Block block;

  Style({
    this.backgroundColor,
    this.color,
    this.display,
    this.fontFamily,
    this.fontSize,
    this.fontStyle,
    this.fontWeight,
    this.listStyleType,
    this.padding,
    this.margin,
    this.textDecoration,
    this.textDecorationStyle,
    this.preserveWhitespace,
    this.baselineOffset,
    this.before,
    this.after,
    this.textDirection,
    this.block,
  });

  //TODO: all attributes of TextStyle likely have a CSS attribute and should be supported.
  TextStyle generateTextStyle() {
    return TextStyle(
      backgroundColor: backgroundColor,
      color: color,
      decoration: textDecoration,
      decorationStyle: textDecorationStyle,
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontStyle: fontStyle,
      fontWeight: fontWeight,
    );
  }

  @override
  String toString() {
    return "Style";
  }

  Style merge(Style other) {
    if (other == null) return this;

    Block mergedBlock = block?.merge(other.block);

    return copyWith(
      backgroundColor: other.backgroundColor,
      color: other.color,
      display: other.display,
      fontFamily: other.fontFamily,
      fontSize: other.fontSize,
      fontStyle: other.fontStyle,
      fontWeight: other.fontWeight,
      padding: other.padding,
      //TODO merge EdgeInsets
      margin: other.margin,
      //TODO merge EdgeInsets
      textDecoration: other.textDecoration,
      textDecorationStyle: other.textDecorationStyle,
      preserveWhitespace: other.preserveWhitespace,
      baselineOffset: other.baselineOffset,
      before: other.before,
      after: other.after,
      textDirection: other.textDirection,
      block: mergedBlock,
    );
  }

  Style copyWith({
    Color backgroundColor,
    Color color,
    Display display,
    String fontFamily,
    double fontSize,
    FontStyle fontStyle,
    FontWeight fontWeight,
    EdgeInsets padding,
    EdgeInsets margin,
    TextDecoration textDecoration,
    TextDecorationStyle textDecorationStyle,
    bool preserveWhitespace,
    int baselineOffset,
    String before,
    String after,
    TextDirection textDirection,
    Block block,
  }) {
    return Style(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      color: color ?? this.color,
      display: display ?? this.display,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontStyle: fontStyle ?? this.fontStyle,
      fontWeight: fontWeight ?? this.fontWeight,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      textDecoration: textDecoration ?? this.textDecoration,
      textDecorationStyle: textDecorationStyle ?? this.textDecorationStyle,
      preserveWhitespace: preserveWhitespace ?? this.preserveWhitespace,
      baselineOffset: baselineOffset ?? this.baselineOffset,
      before: before ?? this.before,
      after: after ?? this.after,
      textDirection: textDirection ?? this.textDirection,
      block: block ?? this.block,
    );
  }

  Style.fromTextStyle(TextStyle textStyle) {
    this.backgroundColor = textStyle.backgroundColor;
    this.color = textStyle.color;
    this.textDecoration = textStyle.decoration;
    this.textDecorationStyle = textStyle.decorationStyle;
    this.fontFamily = textStyle.fontFamily;
    this.fontSize = textStyle.fontSize;
    this.fontStyle = textStyle.fontStyle;
    this.fontWeight = textStyle.fontWeight;
  }
}

enum Display {
  BLOCK,
  INLINE,
  INLINE_BLOCK,
  LIST_ITEM,
}

enum ListStyleType {
  DISC,
  DECIMAL,
}
