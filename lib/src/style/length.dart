/// These are the base unit types
enum _UnitType {
  percent,
  length,
  auto,
  lengthPercent(children: [_UnitType.length, _UnitType.percent]),
  lengthPercentAuto(children: [_UnitType.length, _UnitType.percent, _UnitType.auto]);

  final List<_UnitType> children;

  const _UnitType({this.children = const []});

  bool matches(_UnitType other) {
    return this == other || children.contains(other);
  }
}

/// A Unit represents a CSS unit
enum Unit {
  //ch,
  em(_UnitType.length),
  //ex,
  percent(_UnitType.percent),
  px(_UnitType.length),
  rem(_UnitType.length),
  //Q,
  //vh,
  //vw,
  auto(_UnitType.auto);

  const Unit(this.unitType);
  final _UnitType unitType;
}

/// Represents a CSS dimension https://drafts.csswg.org/css-values/#dimensions
abstract class Dimension {
  double value;
  Unit unit;

  Dimension(this.value, this.unit, _UnitType _dimensionUnitType)
      : assert(_dimensionUnitType.matches(unit.unitType),
            "This Dimension was given a Unit that isn't specified.");
}

/// This dimension takes a value with a length unit such as px or em. Note that
/// these can be fixed or relative (but they must not be a percent)
class Length extends Dimension {
  Length(double value, [Unit unit = Unit.px]) : super(value, unit, _UnitType.length);
}

/// This dimension takes a value with a length-percent unit such as px or em
/// or %. Note that these can be fixed or relative (but they must not be a
/// percent)
class LengthOrPercent extends Dimension {
  LengthOrPercent(double value, [Unit unit = Unit.px])
      : super(value, unit, _UnitType.lengthPercent);
}

class AutoOrLengthOrPercent extends Dimension {
  AutoOrLengthOrPercent(double value, [Unit unit = Unit.px])
      : super(value, unit, _UnitType.lengthPercentAuto);
}
