import 'package:flutter/widgets.dart';
import 'package:flutter_html/src/builtins/image_builtin.dart';
import 'package:flutter_html/src/extension/html_extension.dart';

class ImageExtension extends ImageBuiltIn {
  late final InlineSpan Function(ExtensionContext) builder;

  /// [ImageExtension] allows you to extend the built-in <img> support by
  /// providing a custom way to render a specific selection of attributes
  /// or providing headers or asset package/bundle specifications.
  ImageExtension({
    super.assetBundle,
    super.assetPackage,
    super.assetSchema = "asset:",
    super.dataEncoding,
    super.fileExtensions,
    super.mimeTypes,
    super.networkDomains,
    super.networkHeaders,
    super.networkSchemas = const {"http", "https"},
    super.handleAssetImages = true,
    super.handleDataImages = true,
    super.handleNetworkImages = true,
    Widget? child,
    Widget Function(ExtensionContext)? builder,
  }) : assert((child != null) || (builder != null),
            "Either child or builder needs to be provided to ImageExtension") {
    if (child != null) {
      this.builder = (_) => WidgetSpan(child: child);
    } else {
      this.builder = (context) => WidgetSpan(child: builder!.call(context));
    }
  }

  /// See [ImageExtension]. The only difference is that this method allows you
  /// to directly pass an InlineSpan through `child` or `builder`, allowing you
  /// to construct more seamless extensions.
  ImageExtension.inline({
    super.assetBundle,
    super.assetPackage,
    super.assetSchema = "asset:",
    super.dataEncoding,
    super.fileExtensions,
    super.mimeTypes,
    super.networkDomains,
    super.networkHeaders,
    super.networkSchemas = const {"http", "https"},
    super.handleAssetImages = true,
    super.handleDataImages = true,
    super.handleNetworkImages = true,
    InlineSpan? child,
    InlineSpan Function(ExtensionContext)? builder,
  }) : assert((child != null) || (builder != null),
            "Either child or builder needs to be provided to ImageExtension.inline") {
    if (child != null) {
      this.builder = (_) => child;
    } else {
      this.builder = builder!;
    }
  }

  @override
  InlineSpan build(ExtensionContext context, parseChildren) {
    return builder.call(context);
  }
}
