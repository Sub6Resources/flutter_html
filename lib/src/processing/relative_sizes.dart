import 'package:flutter_html/flutter_html.dart';

class RelativeSizesProcessing {

  /// [processRelativeValues] handles CSS size types like `em` and `rem` that
  /// depend on the font sizes of ancestors in the style tree.
  static StyledElement processRelativeValues(StyledElement tree) {
    return _calculateRelativeValues(tree, 1.0); //TODO do we really need to use devicePixelRatio?
  }

  /// [_calculateRelativeValues] converts rem values to px sizes and then
  /// applies relative calculations
  static StyledElement _calculateRelativeValues(
      StyledElement tree, double devicePixelRatio) {
    double remSize = (tree.style.fontSize?.value ?? FontSize.medium.value);

    //If the root element has a rem-based fontSize, then give it the default
    // font size times the set rem value.
    if (tree.style.fontSize?.unit == Unit.rem) {
      tree.style.fontSize = FontSize(FontSize.medium.value * remSize);
    }

    _applyRelativeValuesRecursive(tree, remSize, devicePixelRatio);
    tree.style.setRelativeValues(remSize, remSize / devicePixelRatio);

    return tree;
  }

  /// This is the recursive worker function for [_calculateRelativeValues]
  static void _applyRelativeValuesRecursive(
      StyledElement tree, double remFontSize, double devicePixelRatio) {
    //When we get to this point, there should be a valid fontSize at every level.
    assert(tree.style.fontSize != null);

    final parentFontSize = tree.style.fontSize!.value;

    for (var child in tree.children) {
      if (child.style.fontSize == null) {
        child.style.fontSize = FontSize(parentFontSize);
      } else {
        switch (child.style.fontSize!.unit) {
          case Unit.em:
            child.style.fontSize =
                FontSize(parentFontSize * child.style.fontSize!.value);
            break;
          case Unit.percent:
            child.style.fontSize = FontSize(
                parentFontSize * (child.style.fontSize!.value / 100.0));
            break;
          case Unit.rem:
            child.style.fontSize =
                FontSize(remFontSize * child.style.fontSize!.value);
            break;
          case Unit.px:
          case Unit.auto:
          //Ignore
            break;
        }
      }

      // Note: it is necessary to scale down the emSize by the factor of
      // devicePixelRatio since Flutter seems to calculates font sizes using
      // physical pixels, but margins/padding using logical pixels.
      final emSize = child.style.fontSize!.value / devicePixelRatio;

      tree.style.setRelativeValues(remFontSize, emSize);

      _applyRelativeValuesRecursive(child, remFontSize, devicePixelRatio);
    }
  }
}