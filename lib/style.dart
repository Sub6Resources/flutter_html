import 'package:flutter/material.dart';
import 'package:flutter_html/block_element.dart';

class Style {
  TextStyle textStyle;
  bool preserveWhitespace;
  int baselineOffset;
  String before;
  String after;
  TextDirection textDirection;
  Block block;

  Style({
    this.textStyle,
    this.preserveWhitespace,
    this.baselineOffset,
    this.before,
    this.after,
    this.textDirection,
    this.block,
  });

  @override
  String toString() {
    return "(Text Style: ($textStyle}),)";
  }

  Style merge(Style other) {
    if (other == null) return this;

    TextStyle mergedTextStyle = textStyle?.merge(other.textStyle);
    Block mergedBlock = block?.merge(other.block);

    return copyWith(
      textStyle: mergedTextStyle,
      preserveWhitespace: other.preserveWhitespace,
      baselineOffset: other.baselineOffset,
      before: other.before,
      after: other.after,
      textDirection: other.textDirection,
      block: mergedBlock,
    );
  }

  Style copyWith({
    TextStyle textStyle,
    bool preserveWhitespace,
    int baselineOffset,
    String before,
    String after,
    TextDirection textDirection,
    Block block,
  }) {
    return Style(
      textStyle: textStyle ?? this.textStyle,
      preserveWhitespace: preserveWhitespace ?? this.preserveWhitespace,
      baselineOffset: baselineOffset ?? this.baselineOffset,
      before: before ?? this.before,
      after: after ?? this.after,
      textDirection: textDirection ?? this.textDirection,
      block: block ?? this.block,
    );
  }
}
