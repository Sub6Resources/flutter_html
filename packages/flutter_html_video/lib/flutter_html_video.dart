library flutter_html_video;

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:video_player/video_player.dart';

CustomRender videoRender() => CustomRender.fromWidget(widget: (context, buildChildren) {
  final sources = <String?>[
    if (context.tree.element?.attributes['src'] != null) context.tree.element!.attributes['src'],
    ...ReplacedElement.parseMediaSources(context.tree.element!.children),
  ];
  if (sources.isEmpty || sources.first == null) {
    return Container(height: 0, width: 0);
  }
  final width = double.tryParse(context.tree.element?.attributes['width'] ?? "");
  final height = double.tryParse(context.tree.element?.attributes['height'] ?? "");
  final double _width = width ?? (height ?? 150) * 2;
  final double _height = height ?? (width ?? 300) / 2;
  return AspectRatio(
    aspectRatio: _width / _height,
    child: Container(
      key: context.key,
      child: Chewie(
        controller: ChewieController(
          videoPlayerController: VideoPlayerController.network(
            sources.first ?? "",
          ),
          placeholder: context.tree.element?.attributes['poster'] != null
              ? Image.network(context.tree.element!.attributes['poster']!)
              : Container(color: Colors.black),
          autoPlay: context.tree.element?.attributes['autoplay'] != null,
          looping: context.tree.element?.attributes['loop'] != null,
          showControls: context.tree.element?.attributes['controls'] != null,
          autoInitialize: true,
          aspectRatio: _width / _height,
        ),
      ),
    ),
  );
});

CustomRenderMatcher videoMatcher() => (context) {
  return context.tree.element?.localName == "video";
};