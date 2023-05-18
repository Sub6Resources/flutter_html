import 'package:flutter/widgets.dart';
import 'package:flutter_html/src/extension/html_extension.dart';

class MatcherExtension extends HtmlExtension {
  final bool Function(ExtensionContext) matcher;
  late final InlineSpan Function(ExtensionContext) builder;

  MatcherExtension({
    required this.matcher,
    Widget? child,
    Widget Function(ExtensionContext)? builder,
  }) : assert((child != null) || (builder != null)) {
    if (child != null) {
      this.builder = (_) => WidgetSpan(child: child);
    } else {
      this.builder = (context) => WidgetSpan(child: builder!(context));
    }
  }

  MatcherExtension.inline({
    required this.matcher,
    InlineSpan? child,
    InlineSpan Function(ExtensionContext)? builder,
  }) : assert((child != null) || (builder != null)) {
    if (child != null) {
      this.builder = (_) => child;
    } else {
      this.builder = builder!;
    }
  }

  @override
  Set<String> get supportedTags => const {};

  @override
  bool matches(ExtensionContext context) {
    return matcher(context);
  }

  @override
  InlineSpan build(ExtensionContext context) {
    return builder(context);
  }
}
