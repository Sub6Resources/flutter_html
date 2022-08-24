import 'package:flutter_html/src/style/length.dart';

class DimensionComputeContext {
  const DimensionComputeContext({
    required this.emValue,
    required this.autoValue,
  });

  final double emValue;
  final double autoValue;
}

/// [computeDimensionUnit] takes a [Dimension] and some information about the
/// context where the Dimension is being used, and returns a "used" value to
/// use in a rendering.
double computeDimensionValue(Dimension dimension, DimensionComputeContext computeContext) {
  switch (dimension.unit) {
    case Unit.em: return computeContext.emValue * dimension.value;
    case Unit.px: return dimension.value;
    case Unit.auto: return computeContext.autoValue;
  }
}
