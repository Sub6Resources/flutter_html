import 'package:flutter/painting.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/src/extension/extension_context.dart';

/// The [Extension] class allows you to customize the behavior of flutter_html
/// or add additional functionality.
///
/// TODO add additional documentation
///
abstract class Extension {
  /// Tells the [HtmlParser] what additional tags to add to the default
  /// supported tag list (the extension's user can still override this by
  /// setting an explicit tagList on the Html widget).
  ///
  /// Extension creators should override this with any additional tags
  /// that should be visible to the end user.
  List<String> get supportedTags;

  /// This method is called to test whether or not this extension needs to do
  /// any work in this context.
  ///
  /// Subclasses must override this method and return true if they'd like the
  /// other methods to be called in a certain context.
  bool matches(ExtensionContext context);

  // Converts parsed HTML to a StyledElement. Need to define default behavior, or perhaps defer this step back to the Html widget by default
  StyledElement lex(ExtensionContext context) {
    throw UnimplementedError("TODO");
  }

  // Called before styles are applied to the tree. Default behavior: return tree;
  StyledElement beforeStyle(ExtensionContext context) {
    return context.styledElement!;
  }

  // Called after styling, but before extra elements/whitespace has been removed, margins collapsed, list characters processed, or relative values calculated. Default behavior: return tree;
  StyledElement beforeProcessing(ExtensionContext context) {
    return context.styledElement!;
  }

  //The final step in the chain. Converts the StyledElement tree, with its attached `Style` elements, into an `InlineSpan` tree that includes Widget/TextSpans that can be rendered in a RichText or Text.rich widget. Need to define default behavior, or perhaps defer this step back to the Html widget by default
  InlineSpan parse(ExtensionContext context) {
    throw UnimplementedError("TODO");
  }

  //Called when the Html widget is being destroyed. This would be a very good place to dispose() any controllers or free any resources that the extension uses. Default behavior: do nothing.
  void onDispose() {
    // Subclasses may override this to clean up when the extension is being disposed.
  }
}
