library flutter_html_audio;

import 'package:chewie_audio/chewie_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:video_player/video_player.dart';

CustomRender audioRender() => CustomRender.fromWidget(widget: (context, buildChildren) {
  final sources = <String?>[
    if (context.tree.element?.attributes['src'] != null) context.tree.element!.attributes['src'],
    ...ReplacedElement.parseMediaSources(context.tree.element!.children),
  ];
  if (sources.isEmpty || sources.first == null) {
    return Container(height: 0, width: 0);
  }
  return Container(
    key: context.key,
    width: context.style.width ?? 300,
    height: Theme.of(context.buildContext).platform == TargetPlatform.android
        ? 48 : 75,
    child: ChewieAudio(
      controller: ChewieAudioController(
        videoPlayerController: VideoPlayerController.network(
          sources.first ?? "",
        ),
        autoPlay: context.tree.element?.attributes['autoplay'] != null,
        looping: context.tree.element?.attributes['loop'] != null,
        showControls: context.tree.element?.attributes['controls'] != null,
        autoInitialize: true,
      ),
    ),
  );
});

CustomRenderMatcher audioMatcher() => (context) {
  return context.tree.element?.localName == "audio";
};