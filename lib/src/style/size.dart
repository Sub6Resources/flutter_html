import 'package:flutter_html/flutter_html.dart';

/// The [Width] class takes in a value and units, and defaults to px if no
/// units are provided. A helper constructor, [Width.auto] constructor is
/// provided for convenience.
class Width extends AutoOrLengthOrPercent {
  Width(super.value, [super.unit = Unit.px])
      : assert(value >= 0, 'Width value must be non-negative');

  Width.auto() : super(0, Unit.auto);
}

class Height extends AutoOrLengthOrPercent {
  Height(super.value, [super.unit = Unit.px])
      : assert(value >= 0, 'Height value must be non-negative');

  Height.auto() : super(0, Unit.auto);
}
