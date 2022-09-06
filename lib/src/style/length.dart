/// Increase new base unit types' values by a factor of 2 each time.
const int _percent = 0x1;
const int _length = 0x2;
const int _auto = 0x4;

/// These values are combinations of the base unit-types
const int _lengthPercent = _length | _percent;
const int _lengthPercentAuto = _lengthPercent | _auto;

/// A Unit represents a CSS unit
enum Unit {
  //ch,
  em(_length),
  //ex,
  percent(_percent),
  px(_length),
  rem(_length),
  //Q,
  //vh,
  //vw,
  auto(_auto);

  const Unit(this.unitType);
  final int unitType;
}

/// Represents a CSS dimension https://drafts.csswg.org/css-values/#dimensions
abstract class Dimension {
  double value;
  Unit unit;

  Dimension(this.value, this.unit, int _dimensionUnitType)
      : assert(
            identical((unit.unitType | _dimensionUnitType), _dimensionUnitType),
            "This dimension was given a Unit that isn't specified.");
}

/// This dimension takes a value with a length unit such as px or em. Note that
/// these can be fixed or relative (but they must not be a percent)
class Length extends Dimension {
  Length(double value, [Unit unit = Unit.px]) : super(value, unit, _length);
}

/// This dimension takes a value with a length-percent unit such as px or em
/// or %. Note that these can be fixed or relative (but they must not be a
/// percent)
class LengthOrPercent extends Dimension {
  LengthOrPercent(double value, [Unit unit = Unit.px])
      : super(value, unit, _lengthPercent);
}

class AutoOrLengthOrPercent extends Dimension {
  AutoOrLengthOrPercent(double value, [Unit unit = Unit.px])
      : super(value, unit, _lengthPercentAuto);
}
