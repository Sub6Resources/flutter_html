import 'package:flutter/widgets.dart';
import 'package:flutter_html/src/extension/html_extension.dart';

/// [TagExtension] allows you to extend the functionality of flutter_html
/// by defining the behavior of custom tags.
class TagExtension extends HtmlExtension {
  final Set<String> tagsToExtend;
  late final InlineSpan Function(ExtensionContext) builder;

  /// [TagExtension] allows you to extend the functionality of flutter_html
  /// by defining the behavior of custom tags to return a child widget.
  TagExtension({
    required this.tagsToExtend,
    Widget? child,
    Widget Function(ExtensionContext)? builder,
  }) : assert((child != null) || (builder != null),
            "Either child or builder needs to be provided to TagExtension") {
    if (child != null) {
      this.builder = (_) => WidgetSpan(child: child);
    } else {
      this.builder = (context) => WidgetSpan(child: builder!.call(context));
    }
  }

  /// [TagExtension.inline] allows you to extend the functionality of
  /// flutter_html by defining the behavior of custom tags to return
  /// a child InlineSpan.
  TagExtension.inline({
    required this.tagsToExtend,
    InlineSpan? child,
    InlineSpan Function(ExtensionContext)? builder,
  }) : assert((child != null) || (builder != null),
            "Either child or builder needs to be provided to TagExtension.inline") {
    if (child != null) {
      this.builder = (_) => child;
    } else {
      this.builder = builder!;
    }
  }

  @override
  Set<String> get supportedTags => tagsToExtend;

  @override
  InlineSpan build(ExtensionContext context, parseChildren) {
    return builder(context);
  }
}
