const int _percent = 0x1;
const int _length = 0x2;
const int _auto = 0x4;
const int _lengthPercent = _length | _percent;
const int _margin = _lengthPercent | _auto;

//TODO there are more unit-types that need support
enum Unit {
  //ch,
  em(_length),
  //ex,
  percent(_percent),
  px(_length),
  //rem,
  //Q,
  //vh,
  //vw,
  auto(_auto);
  const Unit(this.unitType);
  final int unitType;
}

/// Represents a CSS dimension https://drafts.csswg.org/css-values/#dimensions
abstract class Dimension {
  final double value;
  final Unit unit;

  Dimension(this.value, this.unit) {
    assert((unit.unitType | _unitType) == _unitType, "You used a unit for the property that was not allowed");
  }

  int get _unitType;
}

class Length extends Dimension {
  Length(double value, [Unit unit = Unit.px]) : super(value, unit);

  @override
  int get _unitType => _length;
}

class LengthOrPercent extends Dimension {
  LengthOrPercent(double value, [Unit unit = Unit.px]) : super(value, unit);

  @override
  int get _unitType => _lengthPercent;
}

class Margin extends Dimension {
  Margin(double value, [Unit? unit = Unit.px]): super(value, unit ?? Unit.px);

  Margin.auto(): super(0, Unit.auto);

  @override
  int get _unitType => _margin;
}