/// These are the base unit types
enum UnitType {
  percent,
  length,
  auto,
  lengthPercent(children: [UnitType.length, UnitType.percent]),
  lengthPercentAuto(
      children: [UnitType.length, UnitType.percent, UnitType.auto]);

  final List<UnitType> children;

  const UnitType({this.children = const []});

  bool matches(UnitType other) {
    return this == other || children.contains(other);
  }
}

/// A Unit represents a CSS unit
enum Unit {
  //ch,
  em(UnitType.length),
  //ex,
  percent(UnitType.percent),
  px(UnitType.length),
  rem(UnitType.length),
  //Q,
  //vh,
  //vw,
  auto(UnitType.auto);

  const Unit(this.unitType);
  final UnitType unitType;
}

/// Represents a CSS dimension https://drafts.csswg.org/css-values/#dimensions
abstract class Dimension {
  double value;
  Unit unit;

  Dimension(this.value, this.unit, UnitType dimensionUnitType)
      : assert(dimensionUnitType.matches(unit.unitType),
            "This Dimension was given a Unit that isn't specified.");
}

/// This dimension takes a value with a length unit such as px or em. Note that
/// these can be fixed or relative (but they must not be a percent)
class Length extends Dimension {
  Length(double value, [Unit unit = Unit.px])
      : super(value, unit, UnitType.length);
}

/// This dimension takes a value with a length-percent unit such as px or em
/// or %. Note that these can be fixed or relative (but they must not be a
/// percent)
class LengthOrPercent extends Dimension {
  LengthOrPercent(double value, [Unit unit = Unit.px])
      : super(value, unit, UnitType.lengthPercent);
}

class AutoOrLengthOrPercent extends Dimension {
  AutoOrLengthOrPercent(double value, [Unit unit = Unit.px])
      : super(value, unit, UnitType.lengthPercentAuto);
}
