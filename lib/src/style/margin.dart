import 'package:flutter/material.dart';
import 'package:flutter_html/src/style/length.dart';

class Margin extends AutoOrLengthOrPercent {
  Margin(double value, [Unit? unit = Unit.px]) : super(value, unit ?? Unit.px);

  Margin.auto() : super(0, Unit.auto);

  Margin.zero() : super(0, Unit.px);
}

class Margins {
  final Margin? left;
  final Margin? right;
  final Margin? top;
  final Margin? bottom;

  const Margins({this.left, this.right, this.top, this.bottom});

  /// Auto margins already have a "value" of zero so can be considered collapsed.
  Margins collapse() => Margins(
        left: left?.unit == Unit.auto ? left : Margin(0, Unit.px),
        right: right?.unit == Unit.auto ? right : Margin(0, Unit.px),
        top: top?.unit == Unit.auto ? top : Margin(0, Unit.px),
        bottom: bottom?.unit == Unit.auto ? bottom : Margin(0, Unit.px),
      );

  Margins copyWith(
          {Margin? left, Margin? right, Margin? top, Margin? bottom}) =>
      Margins(
        left: left ?? this.left,
        right: right ?? this.right,
        top: top ?? this.top,
        bottom: bottom ?? this.bottom,
      );

  Margins copyWithEdge(
          {double? left, double? right, double? top, double? bottom}) =>
      Margins(
        left: left != null ? Margin(left, this.left?.unit) : this.left,
        right: right != null ? Margin(right, this.right?.unit) : this.right,
        top: top != null ? Margin(top, this.top?.unit) : this.top,
        bottom:
            bottom != null ? Margin(bottom, this.bottom?.unit) : this.bottom,
      );

  // bool get isAutoHorizontal => (left is MarginAuto) || (right is MarginAuto);

  /// Analogous to [EdgeInsets.zero]
  static Margins get zero => Margins.all(0);

  /// Analogous to [EdgeInsets.all]
  Margins.all(double value, {Unit? unit})
      : left = Margin(value, unit),
        right = Margin(value, unit),
        top = Margin(value, unit),
        bottom = Margin(value, unit);

  /// Analogous to [EdgeInsets.only]
  Margins.only(
      {double? left, double? right, double? top, double? bottom, Unit? unit})
      : left = Margin(left ?? 0, unit),
        right = Margin(right ?? 0, unit),
        top = Margin(top ?? 0, unit),
        bottom = Margin(bottom ?? 0, unit);

  /// Analogous to [EdgeInsets.symmetric]
  Margins.symmetric({double? horizontal, double? vertical, Unit? unit})
      : left = Margin(horizontal ?? 0, unit),
        right = Margin(horizontal ?? 0, unit),
        top = Margin(vertical ?? 0, unit),
        bottom = Margin(vertical ?? 0, unit);
}
