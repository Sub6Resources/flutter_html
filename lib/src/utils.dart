import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Context<T> {
  T data;

  Context(this.data);
}

// This class is a workaround so that both an image
// and a link can detect taps at the same time.
class MultipleTapGestureRecognizer extends TapGestureRecognizer {
  bool _ready = false;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (state == GestureRecognizerState.ready) {
      _ready = true;
    }
    super.addAllowedPointer(event);
  }

  @override
  void handlePrimaryPointer(PointerEvent event) {
    if (event is PointerCancelEvent) {
      _ready = false;
    }
    super.handlePrimaryPointer(event);
  }

  @override
  void resolve(GestureDisposition disposition) {
    if (_ready && disposition == GestureDisposition.rejected) {
      _ready = false;
    }
    super.resolve(disposition);
  }

  @override
  void rejectGesture(int pointer) {
    if (_ready) {
      acceptGesture(pointer);
      _ready = false;
    }
  }
}

/// This class is a placeholder class so that the renderer can distinguish
/// between WidgetSpans and TextSpans
class CustomTextSpan extends WidgetSpan {
  const CustomTextSpan({
    this.child,
    this.inlineSpanChild,
    PlaceholderAlignment alignment = PlaceholderAlignment.bottom,
    TextBaseline baseline,
    TextStyle style,
  }) : assert(child != null),
        assert(baseline != null || !(
            identical(alignment, PlaceholderAlignment.aboveBaseline) ||
                identical(alignment, PlaceholderAlignment.belowBaseline) ||
                identical(alignment, PlaceholderAlignment.baseline)
        )),
        super(
        alignment: alignment,
        baseline: baseline,
        style: style,
        child: child,
      );

  final Widget child;
  final InlineSpan inlineSpanChild;

  @override
  void build(ParagraphBuilder builder, { double textScaleFactor = 1.0, List<PlaceholderDimensions> dimensions }) {
    assert(debugAssertIsValid());
    assert(dimensions != null);
    final bool hasStyle = style != null;
    if (hasStyle) {
      builder.pushStyle(style.getTextStyle(textScaleFactor: textScaleFactor));
    }
    assert(builder.placeholderCount < dimensions.length);
    final PlaceholderDimensions currentDimensions = dimensions[builder.placeholderCount];
    builder.addPlaceholder(
      currentDimensions.size.width,
      currentDimensions.size.height,
      alignment,
      scale: textScaleFactor,
      baseline: currentDimensions.baseline,
      baselineOffset: currentDimensions.baselineOffset,
    );
    if (hasStyle) {
      builder.pop();
    }
  }

  @override
  bool visitChildren(InlineSpanVisitor visitor) {
    return visitor(this);
  }

  @override
  InlineSpan getSpanForPositionVisitor(TextPosition position, Accumulator offset) {
    if (position.offset == offset.value) {
      return this;
    }
    offset.increment(1);
    return null;
  }

  @override
  int codeUnitAtVisitor(int index, Accumulator offset) {
    return null;
  }

  @override
  RenderComparison compareTo(InlineSpan other) {
    if (identical(this, other))
      return RenderComparison.identical;
    if (other.runtimeType != runtimeType)
      return RenderComparison.layout;
    if ((style == null) != (other.style == null))
      return RenderComparison.layout;
    final WidgetSpan typedOther = other as WidgetSpan;
    if (child != typedOther.child || alignment != typedOther.alignment) {
      return RenderComparison.layout;
    }
    RenderComparison result = RenderComparison.identical;
    if (style != null) {
      final RenderComparison candidate = style.compareTo(other.style);
      if (candidate.index > result.index)
        result = candidate;
      if (result == RenderComparison.layout)
        return result;
    }
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other))
      return true;
    if (other.runtimeType != runtimeType)
      return false;
    if (super != other)
      return false;
    return other is WidgetSpan
        && other.child == child
        && other.alignment == alignment
        && other.baseline == baseline;
  }

  @override
  int get hashCode => hashValues(super.hashCode, child, alignment, baseline);

  @override
  InlineSpan getSpanForPosition(TextPosition position) {
    assert(debugAssertIsValid());
    return null;
  }

  @override
  bool debugAssertIsValid() {
    return true;
  }
}