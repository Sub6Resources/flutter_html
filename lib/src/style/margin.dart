import 'package:flutter/material.dart';
import 'package:flutter_html/src/style/length.dart';

class Margin extends AutoOrLengthOrPercent {
  Margin(double value, [Unit? unit = Unit.px]) : super(value, unit ?? Unit.px);

  Margin.auto() : super(0, Unit.auto);

  Margin.zero() : super(0, Unit.px);

  @override
  String toString() {
    if (unit == Unit.auto) {
      return "auto";
    } else {
      return "$value${unit.name}";
    }
  }

  @override
  int get hashCode => Object.hash(value, unit);

  @override
  bool operator ==(Object other) {
    return other is Margin && other.value == value && other.unit == unit;
  }
}

class Margins {
  final Margin? left;
  final Margin? right;
  final Margin? inlineEnd;
  final Margin? inlineStart;
  final Margin? top;
  final Margin? bottom;
  final Margin? blockEnd;
  final Margin? blockStart;

  const Margins({
    this.left,
    this.right,
    this.inlineEnd,
    this.inlineStart,
    this.top,
    this.bottom,
    this.blockEnd,
    this.blockStart,
  });

  /// Auto margins already have a "value" of zero so can be considered collapsed.
  Margins collapse() {
    return Margins(
        left: left?.unit == Unit.auto ? left : Margin(0, Unit.px),
        right: right?.unit == Unit.auto ? right : Margin(0, Unit.px),
        inlineEnd:
            inlineEnd?.unit == Unit.auto ? inlineEnd : Margin(0, Unit.px),
        inlineStart:
            inlineStart?.unit == Unit.auto ? inlineStart : Margin(0, Unit.px),
        top: top?.unit == Unit.auto ? top : Margin(0, Unit.px),
        bottom: bottom?.unit == Unit.auto ? bottom : Margin(0, Unit.px),
        blockEnd: blockEnd?.unit == Unit.auto ? blockEnd : Margin(0, Unit.px),
        blockStart:
            blockStart?.unit == Unit.auto ? blockStart : Margin(0, Unit.px));
  }

  Margins copyWith({
    Margin? left,
    Margin? right,
    Margin? inlineEnd,
    Margin? inlineStart,
    Margin? top,
    Margin? bottom,
    Margin? blockEnd,
    Margin? blockStart,
  }) {
    return Margins(
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

  Margins copyWithEdge({
    double? left,
    double? right,
    double? inlineEnd,
    double? inlineStart,
    double? top,
    double? bottom,
    double? blockEnd,
    double? blockStart,
  }) {
    return Margins(
      left: left != null ? Margin(left, this.left?.unit) : this.left,
      right: right != null ? Margin(right, this.right?.unit) : this.right,
      inlineEnd: inlineEnd != null
          ? Margin(inlineEnd, this.inlineEnd?.unit)
          : this.inlineEnd,
      inlineStart: inlineStart != null
          ? Margin(inlineStart, this.inlineStart?.unit)
          : this.inlineStart,
      top: top != null ? Margin(top, this.top?.unit) : this.top,
      bottom: bottom != null ? Margin(bottom, this.bottom?.unit) : this.bottom,
      blockEnd: blockEnd != null
          ? Margin(blockEnd, this.blockEnd?.unit)
          : this.blockEnd,
      blockStart: blockStart != null
          ? Margin(blockStart, this.blockStart?.unit)
          : this.blockStart,
    );
  }

  /// Analogous to [EdgeInsets.zero]
  static Margins get zero => Margins.all(0);

  /// Analogous to [EdgeInsets.all]
  Margins.all(double value, [Unit? unit])
      : left = Margin(value, unit),
        right = Margin(value, unit),
        inlineEnd = null,
        inlineStart = null,
        top = Margin(value, unit),
        bottom = Margin(value, unit),
        blockEnd = null,
        blockStart = null;

  /// Analogous to [EdgeInsets.only]
  Margins.only({
    double? left,
    double? right,
    double? inlineEnd,
    double? inlineStart,
    double? top,
    double? bottom,
    double? blockEnd,
    double? blockStart,
    Unit? unit,
  })  : left = Margin(left ?? 0, unit),
        right = Margin(right ?? 0, unit),
        inlineEnd = inlineEnd != null ? Margin(inlineEnd, unit) : null,
        inlineStart = inlineStart != null ? Margin(inlineStart, unit) : null,
        top = Margin(top ?? 0, unit),
        bottom = Margin(bottom ?? 0, unit),
        blockEnd = blockEnd != null ? Margin(blockEnd, unit) : null,
        blockStart = blockStart != null ? Margin(blockStart, unit) : null;

  /// Analogous to [EdgeInsets.symmetric]
  Margins.symmetric({double? horizontal, double? vertical, Unit? unit})
      : left = Margin(horizontal ?? 0, unit),
        right = Margin(horizontal ?? 0, unit),
        inlineEnd = null,
        inlineStart = null,
        top = Margin(vertical ?? 0, unit),
        bottom = Margin(vertical ?? 0, unit),
        blockEnd = null,
        blockStart = null;

  Margins merge(Margins? other) {
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

  @override
  String toString() {
    return "<$top,$right,$bottom,$left,$inlineStart,$inlineEnd,$blockStart,$blockEnd>";
  }

  @override
  int get hashCode {
    return Object.hash(
        left, right, inlineStart, inlineEnd, top, bottom, blockStart, blockEnd);
  }

  @override
  bool operator ==(Object other) {
    return other is Margins &&
        (left == other.left ||
            (left?.value == 0 &&
                left?.unit != Unit.auto &&
                other.left == null)) &&
        (right == other.right ||
            (right?.value == 0 &&
                right?.unit != Unit.auto &&
                other.right == null)) &&
        (top == other.top ||
            (top?.value == 0 && top?.unit != Unit.auto && other.top == null)) &&
        (bottom == other.bottom ||
            (bottom?.value == 0 &&
                bottom?.unit != Unit.auto &&
                other.bottom == null)) &&
        inlineStart == other.inlineStart &&
        inlineEnd == other.inlineEnd &&
        blockStart == other.blockStart &&
        blockEnd == other.blockEnd;
  }
}
