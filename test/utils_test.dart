import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/src/css_parser.dart';
import 'package:flutter_html/src/utils.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests the file lib/src/utils.dart

void main() {
  test('Tests that namedColors returns a valid color', () {
    expect(ExpressionMapping.namedColorToColor('red'),
        equals(ExpressionMapping.stringToColor(namedColors['Red']!)));
    expect(namedColors['Red'], equals('#FF0000'));
  });

  test('CustomBorderSide does not allow negative width', () {
    expect(() => CustomBorderSide(width: -5), throwsAssertionError);
    expect(CustomBorderSide(width: 0), const TypeMatcher<CustomBorderSide>());
    expect(CustomBorderSide(width: 5), const TypeMatcher<CustomBorderSide>());
  });

  const originalString = 'Hello';
  const uppercaseString = 'HELLO';
  const lowercaseString = 'hello';

  test('TextTransformUtil returns self if transform is null', () {
    expect(originalString.transformed(null), equals(originalString));
  });

  test('TextTransformUtil uppercase-s correctly', () {
    expect(originalString.transformed(TextTransform.uppercase),
        equals(uppercaseString));
  });

  test('TextTransformUtil lowercase-s correctly', () {
    expect(originalString.transformed(TextTransform.lowercase),
        equals(lowercaseString));
  });

  const originalLongString = 'Hello, world! pub.dev';
  const capitalizedLongString = 'Hello, World! Pub.Dev';

  test('TextTransformUtil capitalizes correctly', () {
    expect(originalLongString.transformed(TextTransform.capitalize),
        equals(capitalizedLongString));
  });
}
