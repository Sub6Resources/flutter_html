import 'package:flutter/material.dart';
import 'package:flutter_html/src/css_box_widget.dart';
import 'package:flutter_html/src/tree/styled_element.dart';
import 'package:flutter_html/src/extension/extension.dart';
import 'package:flutter_html/src/style.dart';

/// [VerticalAlignBuiltin] handles rendering of sub/sup tags with a vertical
/// alignment off of the normal text baseline
class VerticalAlignBuiltIn extends Extension {
  const VerticalAlignBuiltIn();

  @override
  Set<String> get supportedTags => {
        "sub",
        "sup",
      };

  @override
  bool matches(ExtensionContext context) {
    return context.styledElement?.style.verticalAlign != null &&
        (context.styledElement!.style.verticalAlign == VerticalAlign.sub ||
            context.styledElement!.style.verticalAlign == VerticalAlign.sup);
  }

  @override
  InlineSpan build(ExtensionContext context, parseChildren) {
    return WidgetSpan(
      child: Transform.translate(
        offset: Offset(0, _getVerticalOffset(context.styledElement!)),
        child: CssBoxWidget.withInlineSpanChildren(
          children: parseChildren().values.toList(),
          style: context.styledElement!.style,
        ),
      ),
    );
  }

  double _getVerticalOffset(StyledElement tree) {
    switch (tree.style.verticalAlign) {
      case VerticalAlign.sub:
        return tree.style.fontSize!.value / 2.5;
      case VerticalAlign.sup:
        return tree.style.fontSize!.value / -2.5;
      default:
        return 0;
    }
  }
}
