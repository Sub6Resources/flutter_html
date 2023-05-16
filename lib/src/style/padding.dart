import 'package:flutter/material.dart';
import 'package:flutter_html/src/style/length.dart';

class HtmlPadding extends LengthOrPercent {
  HtmlPadding(double value, [Unit? unit = Unit.px])
      : assert(value >= 0, "Padding must be non-negative"),
        super(value, unit ?? Unit.px);

  HtmlPadding.zero() : super(0, Unit.px);
}

class HtmlPaddings {
  final HtmlPadding? left;
  final HtmlPadding? right;
  final HtmlPadding? inlineEnd;
  final HtmlPadding? inlineStart;
  final HtmlPadding? top;
  final HtmlPadding? bottom;
  final HtmlPadding? blockEnd;
  final HtmlPadding? blockStart;

  const HtmlPaddings({
    this.left,
    this.right,
    this.inlineEnd,
    this.inlineStart,
    this.top,
    this.bottom,
    this.blockEnd,
    this.blockStart,
  });

  HtmlPaddings copyWith({
    HtmlPadding? left,
    HtmlPadding? right,
    HtmlPadding? inlineEnd,
    HtmlPadding? inlineStart,
    HtmlPadding? top,
    HtmlPadding? bottom,
    HtmlPadding? blockEnd,
    HtmlPadding? blockStart,
  }) {
    return HtmlPaddings(
      left: left ?? this.left,
      right: right ?? this.right,
      inlineEnd: inlineEnd ?? this.inlineEnd,
      inlineStart: inlineStart ?? this.inlineStart,
      top: top ?? this.top,
      bottom: bottom ?? this.bottom,
      blockEnd: blockEnd ?? this.blockEnd,
      blockStart: blockStart ?? this.blockStart,
    );
  }

  HtmlPaddings copyWithEdge({
    double? left,
    double? right,
    double? inlineEnd,
    double? inlineStart,
    double? top,
    double? bottom,
    double? blockEnd,
    double? blockStart,
  }) {
    return HtmlPaddings(
      left: left != null ? HtmlPadding(left, this.left?.unit) : this.left,
      right: right != null ? HtmlPadding(right, this.right?.unit) : this.right,
      inlineEnd: inlineEnd != null
          ? HtmlPadding(inlineEnd, this.inlineEnd?.unit)
          : this.inlineEnd,
      inlineStart: inlineStart != null
          ? HtmlPadding(inlineStart, this.inlineStart?.unit)
          : this.inlineStart,
      top: top != null ? HtmlPadding(top, this.top?.unit) : this.top,
      bottom:
          bottom != null ? HtmlPadding(bottom, this.bottom?.unit) : this.bottom,
      blockEnd: blockEnd != null
          ? HtmlPadding(blockEnd, this.blockEnd?.unit)
          : this.blockEnd,
      blockStart: blockStart != null
          ? HtmlPadding(blockStart, this.blockStart?.unit)
          : this.blockStart,
    );
  }

  /// Analogous to [EdgeInsets.zero]
  static HtmlPaddings get zero => HtmlPaddings.all(0);

  /// Analogous to [EdgeInsets.all]
  HtmlPaddings.all(double value, {Unit? unit})
      : left = HtmlPadding(value, unit),
        right = HtmlPadding(value, unit),
        inlineEnd = null,
        inlineStart = null,
        top = HtmlPadding(value, unit),
        bottom = HtmlPadding(value, unit),
        blockEnd = null,
        blockStart = null;

  /// Analogous to [EdgeInsets.only]
  HtmlPaddings.only({
    double? left,
    double? right,
    double? inlineEnd,
    double? inlineStart,
    double? top,
    double? bottom,
    double? blockEnd,
    double? blockStart,
    Unit? unit,
  })  : left = left != null ? HtmlPadding(left, unit) : null,
        right = right != null ? HtmlPadding(right, unit) : null,
        inlineEnd = inlineEnd != null ? HtmlPadding(inlineEnd, unit) : null,
        inlineStart =
            inlineStart != null ? HtmlPadding(inlineStart, unit) : null,
        top = top != null ? HtmlPadding(top, unit) : null,
        bottom = bottom != null ? HtmlPadding(bottom, unit) : null,
        blockEnd = blockEnd != null ? HtmlPadding(blockEnd, unit) : null,
        blockStart = blockStart != null ? HtmlPadding(blockStart, unit) : null;

  /// Analogous to [EdgeInsets.symmetric]
  HtmlPaddings.symmetric({double? horizontal, double? vertical, Unit? unit})
      : left = horizontal != null ? HtmlPadding(horizontal, unit) : null,
        right = horizontal != null ? HtmlPadding(horizontal, unit) : null,
        inlineEnd = null,
        inlineStart = null,
        top = vertical != null ? HtmlPadding(vertical, unit) : null,
        bottom = vertical != null ? HtmlPadding(vertical, unit) : null,
        blockEnd = null,
        blockStart = null;

  HtmlPaddings merge(HtmlPaddings? other) {
    return copyWith(
      left: other?.left,
      right: other?.right,
      top: other?.top,
      bottom: other?.bottom,
      inlineEnd: other?.inlineEnd,
      inlineStart: other?.inlineStart,
      blockStart: other?.blockStart,
      blockEnd: other?.blockEnd,
    );
  }

  /// Calculates the padding EdgeInsets given the textDirection.
  EdgeInsets toEdgeInsets(TextDirection textDirection) {
    late double? leftPad;
    late double? rightPad;
    double? topPad = top?.value ?? blockStart?.value ?? 0;
    double? bottomPad = bottom?.value ?? blockEnd?.value ?? 0;

    switch (textDirection) {
      case TextDirection.rtl:
        leftPad = left?.value ?? inlineEnd?.value ?? 0;
        rightPad = right?.value ?? inlineStart?.value ?? 0;
        break;
      case TextDirection.ltr:
        leftPad = left?.value ?? inlineStart?.value ?? 0;
        rightPad = right?.value ?? inlineEnd?.value ?? 0;
        break;
    }

    return EdgeInsets.fromLTRB(leftPad, topPad, rightPad, bottomPad);
  }
}
