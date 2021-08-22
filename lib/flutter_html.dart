library flutter_matrix_html;

import 'package:flutter/material.dart';
import 'text_parser.dart';

import 'image_properties.dart';
import 'code_block.dart';

class Html extends StatelessWidget {
  Html({
    Key? key,
    required this.data,
    this.padding,
    this.backgroundColor,
    this.defaultTextStyle,
    this.onLinkTap,
    this.renderNewlines = false,
    this.onImageError,
    this.linkStyle = const TextStyle(
        decoration: TextDecoration.underline,
        color: Colors.blueAccent,
        decorationColor: Colors.blueAccent),
    this.shrinkToFit = false,
    this.onPillTap,
    this.getPillInfo,
    this.imageProperties,
    this.onImageTap,
    this.showImages = true,
    this.getMxcUrl,
    this.maxLines,
    this.emoteSize,
    this.getCodeLanguage,
    this.setCodeLanguage,
  }) : super(key: key);

  final String data;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final TextStyle? defaultTextStyle;
  final OnLinkTap? onLinkTap;
  final bool renderNewlines;
  final ImageErrorListener? onImageError;
  final TextStyle? linkStyle;
  final bool shrinkToFit;
  final GetMxcUrl? getMxcUrl;
  final int? maxLines;
  final OnPillTap? onPillTap;
  final GetPillInfo? getPillInfo;
  final double? emoteSize;

  /// Properties for the Image widget that gets rendered by the rich text parser
  final ImageProperties? imageProperties;
  final OnImageTap? onImageTap;
  final bool showImages;

  /// Setting and getting code langauge cache
  final SetCodeLanguage? setCodeLanguage;
  final GetCodeLanguage? getCodeLanguage;

  @override
  Widget build(BuildContext context) {
    final width = shrinkToFit ? null : MediaQuery.of(context).size.width;

    return Container(
      padding: padding,
      color: backgroundColor,
      width: width,
      child: DefaultTextStyle.merge(
        style: defaultTextStyle ?? DefaultTextStyle.of(context).style,
        child: TextParser(
          shrinkToFit: shrinkToFit,
          onLinkTap: onLinkTap,
          renderNewlines: renderNewlines,
          html: data,
          onImageError: onImageError,
          linkStyle: linkStyle,
          onPillTap: onPillTap,
          getPillInfo: getPillInfo,
          imageProperties: imageProperties,
          onImageTap: onImageTap,
          showImages: showImages,
          getMxcUrl: getMxcUrl,
          maxLines: maxLines,
          emoteSize: emoteSize,
          defaultTextStyle: defaultTextStyle,
          setCodeLanguage: setCodeLanguage,
          getCodeLanguage: getCodeLanguage,
        ),
      ),
    );
  }
}
