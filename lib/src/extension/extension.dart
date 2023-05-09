import 'package:flutter/painting.dart';
import 'package:flutter_html/src/extension/extension_context.dart';
import 'package:flutter_html/src/style.dart';
import 'package:flutter_html/src/tree/styled_element.dart';

export 'package:flutter_html/src/extension/extension_context.dart';
export 'package:flutter_html/src/extension/helpers/tag_extension.dart';
export 'package:flutter_html/src/extension/helpers/matcher_extension.dart';

/// The [Extension] class allows you to customize the behavior of flutter_html
/// or add additional functionality.
///
/// TODO add additional documentation
///
abstract class Extension {
  const Extension();

  /// Tells the [HtmlParser] what additional tags to add to the default
  /// supported tag list (the extension's user can still override this by
  /// setting an explicit tagList on the Html widget).
  ///
  /// Extension creators should override this with any additional tags
  /// that should be visible to the end user.
  Set<String> get supportedTags;

  /// This method is called to test whether or not this extension needs to do
  /// any work in this context.
  ///
  /// By default returns true if [supportedTags] contains the element's name
  bool matches(ExtensionContext context) {
    return supportedTags.contains(context.elementName);
  }

  /// Converts parsed HTML to a StyledElement.
  StyledElement lex(ExtensionContext context, List<StyledElement> children) {
    return StyledElement(
      node: context.node,
      style: Style(),
      elementClasses: context.classes.toList(),
      elementId: context.id,
      children: children,
      name: context.elementName,
    );
  }

  /// Called before styles are applied to the tree. Default behavior: do nothing;
  void beforeStyle(ExtensionContext context) {}

  /// Called after styling, but before extra elements/whitespace has been
  /// removed, margins collapsed, list characters processed, or relative
  /// values calculated. Default behavior: do nothing;
  void beforeProcessing(ExtensionContext context) {}

  /// The final step in the chain. Converts the StyledElement tree, with its
  /// attached `Style` elements, into an `InlineSpan` tree that includes
  /// Widget/TextSpans that can be rendered in a RichText widget.
  InlineSpan parse(ExtensionContext context,
      Map<StyledElement, InlineSpan> Function() parseChildren) {
    throw UnimplementedError(
        "Extension `$runtimeType` matched `${context.styledElement!.name}` but didn't implement `parse`");
  }

  /// Called when the Html widget is being destroyed. This would be a very
  /// good place to dispose() any controllers or free any resources that
  /// the extension uses. Default behavior: do nothing.
  void onDispose() {
    // Subclasses may override this to clean up when the extension is being disposed.
  }
}
