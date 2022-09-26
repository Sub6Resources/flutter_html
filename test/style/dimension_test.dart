import 'package:flutter_html/src/style/length.dart';
import 'package:flutter_test/flutter_test.dart';

const nonZeroNumber = 16.0;

void main() {
  test("Basic length unspecified units test", () {
    final length = Length(nonZeroNumber);
    expect(length.value, equals(nonZeroNumber));
    expect(length.unit, equals(Unit.px));
  });

  test("Basic length-percent unspecified units test", () {
    final lengthPercent = LengthOrPercent(nonZeroNumber);
    expect(lengthPercent.value, equals(nonZeroNumber));
    expect(lengthPercent.unit, equals(Unit.px));
  });

  test("Zero-length unspecified units test", () {
    final length = Length(0);
    expect(length.value, equals(0));
    expect(length.unit, equals(Unit.px));
  });

  test("Zero-percent-length unspecified units test", () {
    final lengthPercent = LengthOrPercent(0);
    expect(lengthPercent.value, equals(0));
    expect(lengthPercent.unit, equals(Unit.px));
  });

  test("Pass in invalid unit", () {
    expect(() => Length(nonZeroNumber, Unit.percent), throwsAssertionError);
  });

  test("Pass in invalid unit with zero", () {
    expect(() => Length(0, Unit.percent), throwsAssertionError);
  });

  test("Pass in a valid unit", () {
    final lengthPercent = LengthOrPercent(nonZeroNumber, Unit.percent);
    expect(lengthPercent.value, equals(nonZeroNumber));
    expect(lengthPercent.unit, equals(Unit.percent));
  });
}
