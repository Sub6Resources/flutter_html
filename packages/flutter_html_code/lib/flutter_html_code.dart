library flutter_html_code;

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:collection/collection.dart';

class CodeExtension extends HtmlExtension {
  final TextStyle? style;
  final Map<String, TextStyle> theme;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final String? defaultLanguage;

  CodeExtension({
    this.style,
    this.theme = const {},
    this.padding,
    this.borderRadius,
    this.defaultLanguage,
  });

  @override
  Set<String> get supportedTags => {'code'};

  @override
  InlineSpan build(
    ExtensionContext context,
    Map<StyledElement, InlineSpan> Function() parseChildren,
  ) =>
      WidgetSpan(
        child: Material(
          clipBehavior: Clip.hardEdge,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: HighlightView(
              context.element?.text ?? '',
              language: context.element?.className
                      .split(' ')
                      .singleWhereOrNull(
                        (className) => className.startsWith('language-'),
                      )
                      ?.split('language-')
                      .last ??
                  defaultLanguage,
              theme: theme,
              padding: padding ??
                  EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical:
                        context.element?.parent?.localName == 'pre' ? 6 : 0,
                  ),
              textStyle: style,
            ),
          ),
        ),
      );
}
