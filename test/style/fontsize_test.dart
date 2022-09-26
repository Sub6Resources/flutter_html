import 'package:flutter_html/src/style/fontsize.dart';
import 'package:flutter_html/src/style/length.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Check basic FontSize inheritance', () {
    final FontSize parent = FontSize(16);
    const FontSize? child = null;

    final result = FontSize.inherit(parent, child);

    expect(result?.value, equals(16));
  });

  test('Check double null FontSize inheritance', () {
    const FontSize? parent = null;
    const FontSize? child = null;

    final result = FontSize.inherit(parent, child);

    expect(result?.value, equals(null));
  });

  test('Check basic em inheritance', () {
    final FontSize parent = FontSize(16);
    final FontSize child = FontSize(1, Unit.em);

    final result = FontSize.inherit(parent, child);

    expect(result?.value, equals(16));
  });

  test('Check factor em inheritance', () {
    final FontSize parent = FontSize(16);
    final FontSize child = FontSize(0.5, Unit.em);

    final result = FontSize.inherit(parent, child);

    expect(result?.value, equals(8));
  });

  test('Check basic % inheritance', () {
    final FontSize parent = FontSize(16);
    final FontSize child = FontSize(100, Unit.percent);

    final result = FontSize.inherit(parent, child);

    expect(result?.value, equals(16));
  });

  test('Check scaled % inheritance', () {
    final FontSize parent = FontSize(16);
    final FontSize child = FontSize(50, Unit.percent);

    final result = FontSize.inherit(parent, child);

    expect(result?.value, equals(8));
  });
}
