//TODO implement dimensionality
class LineHeight {
  final double? size;
  final String units;

  const LineHeight(this.size, {this.units = ""});

  factory LineHeight.percent(double percent) {
    return LineHeight(percent / 100.0 * 1.2, units: "%");
  }

  factory LineHeight.em(double em) {
    return LineHeight(em * 1.2, units: "em");
  }

  factory LineHeight.rem(double rem) {
    return LineHeight(rem * 1.2, units: "rem");
  }

  factory LineHeight.number(double num) {
    return LineHeight(num * 1.2, units: "number");
  }

  static const normal = LineHeight(1.2);
}
