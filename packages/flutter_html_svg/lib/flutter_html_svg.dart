library flutter_html_svg;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
// ignore: implementation_imports
import 'package:flutter_html/src/tree/image_element.dart';
import 'package:flutter_svg/flutter_svg.dart';

// TODO re-add MultipleGestureDetector for image taps in this extension

class SvgHtmlExtension extends HtmlExtension {
  final String? dataEncoding;
  final String? dataMimeType;
  final List<String> networkSchemas;
  final List<String>? networkDomains;
  final String? extension;
  final String assetSchema;
  final AssetBundle? assetBundle;
  final String? assetPackage;

  const SvgHtmlExtension({
    this.dataEncoding = "base64",
    this.dataMimeType = "image/svg+xml",
    this.networkSchemas = const ["https", "http"],
    this.networkDomains,
    this.extension = "svg",
    this.assetSchema = "asset:",
    this.assetBundle,
    this.assetPackage,
  });

  @override
  Set<String> get supportedTags => {"svg", "img"};

  @override
  bool matches(ExtensionContext context) {
    if (!supportedTags.contains(context.elementName)) {
      return false;
    }

    if (context.elementName == "svg") {
      return true;
    }

    return _matchesSvgNetworkSource(context) ||
        _matchesSvgAssetUri(context) ||
        _matchesSvgDataUri(context);
  }

  /// Matches an <img> tag with encoded svg data.
  bool _matchesSvgDataUri(ExtensionContext context) {
    final attributes = context.attributes;

    if (attributes['src'] == null) {
      return false;
    }

    final dataUri = _dataUriFormat.firstMatch(attributes['src']!);

    return context.elementName == "img" &&
        dataUri != null &&
        (dataMimeType == null || dataUri.namedGroup('mime') == dataMimeType) &&
        (dataEncoding == null ||
            dataUri.namedGroup('encoding') == dataEncoding);
  }

  /// Matches an <img> tag with an svg network image
  bool _matchesSvgNetworkSource(ExtensionContext context) {
    final attributes = context.attributes;

    if (attributes['src'] == null) {
      return false;
    }

    final src = Uri.tryParse(attributes['src']!);
    if (src == null) {
      return false;
    }

    return context.elementName == "img" &&
        networkSchemas.contains(src.scheme) &&
        (networkDomains == null || networkDomains!.contains(src.host)) &&
        (extension == null || src.path.endsWith(".$extension"));
  }

  /// Matches an <img> tag with an svg asset image
  bool _matchesSvgAssetUri(ExtensionContext context) {
    final attributes = context.attributes;

    return context.elementName == "img" &&
        attributes['src'] != null &&
        attributes['src']!.startsWith(assetSchema) &&
        attributes['src']!.endsWith(".$extension");
  }

  @override
  StyledElement prepare(
      ExtensionContext context, List<StyledElement> children) {
    if (context.elementName == "svg") {
      final parsedWidth = double.tryParse(context.attributes['width'] ?? "");
      final parsedHeight = double.tryParse(context.attributes['height'] ?? "");

      return SvgTagElement(
        name: context.elementName,
        elementId: context.id,
        node: context.node,
        children: children,
        style: Style(),
        width: parsedWidth != null ? Width(parsedWidth) : null,
        height: parsedHeight != null ? Height(parsedHeight) : null,
      );
    }

    if (context.elementName == "img") {
      final parsedWidth = double.tryParse(context.attributes['width'] ?? "");
      final parsedHeight = double.tryParse(context.attributes['height'] ?? "");

      return ImageElement(
        name: context.elementName,
        elementId: context.id,
        node: context.node,
        children: children,
        style: Style(),
        src: context.attributes['src'] ?? "",
        alt: context.attributes['alt'],
        width: parsedWidth != null ? Width(parsedWidth) : null,
        height: parsedHeight != null ? Height(parsedHeight) : null,
      );
    }

    return super.prepare(context, children);
  }

  @override
  InlineSpan build(ExtensionContext context) {
    late final Widget widget;

    if (context.elementName == "svg") {
      widget = _renderSvgTag(context);
    } else if (context.styledElement is ImageElement) {
      if (_matchesSvgAssetUri(context)) {
        widget = _renderAssetSvg(context);
      } else if (_matchesSvgDataUri(context)) {
        widget = _renderDataSvg(context);
      } else if (_matchesSvgNetworkSource(context)) {
        widget = _renderNetworkSvg(context);
      }
    }

    return WidgetSpan(
      child: CssBoxWidget(
        style: context.styledElement!.style,
        childIsReplaced: true,
        child: widget,
      ),
    );
  }

  Widget _renderSvgTag(ExtensionContext context) {
    final element = context.styledElement as SvgTagElement;
    final imageStyle = Style(
      width: element.width,
      height: element.height,
    ).merge(context.styledElement!.style);

    return SvgPicture.string(
      context.element!.outerHtml,
      width: imageStyle.width?.value,
      height: imageStyle.height?.value,
    );
  }

  Widget _renderDataSvg(ExtensionContext context) {
    final element = context.styledElement as ImageElement;
    final imageStyle = Style(
      width: element.width,
      height: element.height,
    ).merge(context.styledElement!.style);
    final dataUri = _dataUriFormat.firstMatch(element.src);
    final data = dataUri?.namedGroup('data');
    if (data == null) return const SizedBox(height: 0, width: 0);

    if (dataUri?.namedGroup('encoding') == 'base64') {
      return SvgPicture.memory(
        base64.decode(data.trim()),
        width: imageStyle.width?.value,
        height: imageStyle.height?.value,
      );
    } else {
      return SvgPicture.string(
        Uri.decodeFull(data),
        width: imageStyle.width?.value,
        height: imageStyle.height?.value,
      );
    }
  }

  Widget _renderNetworkSvg(ExtensionContext context) {
    final element = context.styledElement as ImageElement;
    final imageStyle = Style(
      width: element.width,
      height: element.height,
    ).merge(context.styledElement!.style);

    return SvgPicture.network(
      element.src,
      width: imageStyle.width?.value,
      height: imageStyle.height?.value,
    );
  }

  Widget _renderAssetSvg(ExtensionContext context) {
    final element = context.styledElement as ImageElement;

    final imageStyle = Style(
      width: element.width,
      height: element.height,
    ).merge(context.styledElement!.style);

    final assetPath = element.src.replaceFirst(assetSchema, '');

    return SvgPicture.asset(
      assetPath,
      width: imageStyle.width?.value,
      height: imageStyle.height?.value,
      bundle: assetBundle,
      package: assetPackage,
    );
  }
}

class SvgTagElement extends ReplacedElement {
  final Width? width;
  final Height? height;

  SvgTagElement({
    required super.name,
    required super.elementId,
    required super.node,
    required super.style,
    required super.children,
    this.width,
    this.height,
  });
}

/// Defines the format that a data URI might take
final _dataUriFormat = RegExp(
    r"^(?<scheme>data):(?<mime>image/[\w+\-.]+);*(?<encoding>base64)?,\s*(?<data>.*)");
