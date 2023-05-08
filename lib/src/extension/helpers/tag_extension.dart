import 'package:flutter/widgets.dart';
import 'package:flutter_html/src/extension/extension.dart';
import 'package:flutter_html/src/style.dart';
import 'package:flutter_html/src/tree/styled_element.dart';

/// [TagExtension] allows you to extend the functionality of flutter_html
/// by defining the behavior of custom tags.
class TagExtension extends Extension {
  final Set<String> tagsToExtend;
  late final InlineSpan Function(ExtensionContext) builder;

  /// [TagExtension] allows you to extend the functionality of flutter_html
  /// by defining the behavior of custom tags to return a child widget.
  TagExtension({
    required this.tagsToExtend,
    Widget? child,
    Widget Function(ExtensionContext)? builder,
  }): assert((child == null) ^ (builder == null), "Either child or builder needs to be provided to TagExtension") {
    if(child != null) {
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
  }): assert((child == null) ^ (builder == null), "Either child or builder needs to be provided to TagExtension.inline") {
    if(child != null) {
      this.builder = (_) => child;
    } else {
      this.builder = builder!;
    }
  }

  @override
  Set<String> get supportedTags => tagsToExtend;

  @override
  StyledElement lex(ExtensionContext context, List<StyledElement> children) {
    return StyledElement(
      node: context.node,
      children: children,
      style: Style(),
      elementId: context.id,
      elementClasses: context.classes.toList(),
      name: context.elementName,
    );
  }

  @override
  InlineSpan parse(ExtensionContext context, parseChildren) {
    return builder(context);
  }

}