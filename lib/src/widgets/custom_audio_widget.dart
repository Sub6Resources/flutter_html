import 'dart:io';
import 'dart:ui';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/src/utils.dart';

class CustomAudioWidget extends StatefulWidget {
  final List<String> src;
  final bool showControls;
  final bool autoplay;
  final bool loop;
  final bool muted;
  final RenderContext context;

  CustomAudioWidget({
    @required this.src,
    @required this.showControls,
    @required this.autoplay,
    @required this.loop,
    @required this.muted,
    @required this.context,
  });

  @override
  State<StatefulWidget> createState() {
    return CustomAudioWidgetState();
  }
}

class CustomAudioWidgetState extends State<CustomAudioWidget> with SingleTickerProviderStateMixin {
  final assetsAudioPlayer = AssetsAudioPlayer();
  bool wasPlaying;

  @override
  initState() {
    if (widget.src.first != null) {
      assetsAudioPlayer.open(Audio.network(widget.src.first), autoStart: widget.autoplay ?? false, showNotification: true);
      assetsAudioPlayer.setLoopMode(widget.loop == true ? LoopMode.single : LoopMode.none);
      assetsAudioPlayer.setVolume(0.5);
    }
    super.initState();
  }

  @override
  dispose() {
    assetsAudioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext buildContext) {
    if (widget.src.first != null) {
      return assetsAudioPlayer.builderRealtimePlayingInfos(
          builder: (BuildContext context, info) {
            if (info == null) {
              return AspectRatio(aspectRatio: 1, child: CircularProgressIndicator());
            } else if (Platform.isAndroid) {
              return Container(
                height: 48,
                color: Theme.of(buildContext).dialogBackgroundColor,
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        if (info.isPlaying) {
                          assetsAudioPlayer.pause();
                        } else {
                          assetsAudioPlayer.play();
                        }
                      },
                      child: Container(
                        height: 48,
                        color: Colors.transparent,
                        margin: const EdgeInsets.only(left: 8.0, right: 4.0),
                        padding: const EdgeInsets.only(
                          left: 12.0,
                          right: 12.0,
                        ),
                        child: Icon(
                          info.isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 24.0),
                      child: Text(
                        "${getMMSSFormat(info.currentPosition)} / ${getMMSSFormat(info.duration)}",
                        style: const TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: GestureDetector(
                          onHorizontalDragStart: (DragStartDetails details) {
                            wasPlaying = info.isPlaying;
                            if (info.isPlaying) {
                              assetsAudioPlayer.pause();
                            }
                          },
                          onHorizontalDragUpdate: (DragUpdateDetails details) {
                            final box = context.findRenderObject() as RenderBox;
                            final Offset tapPos = box.globalToLocal(details.globalPosition);
                            final double relative = tapPos.dx / box.size.width;
                            final Duration position = info.duration * relative;
                            assetsAudioPlayer.seek(position);
                          },
                          onHorizontalDragEnd: (DragEndDetails details) {
                            if (wasPlaying) {
                              assetsAudioPlayer.play();
                            }
                          },
                          onTapDown: (TapDownDetails details) {
                            final box = context.findRenderObject() as RenderBox;
                            final Offset tapPos = box.globalToLocal(details.globalPosition);
                            final double relative = tapPos.dx / box.size.width;
                            final Duration position = info.duration * relative;
                            assetsAudioPlayer.seek(position);
                          },
                          child: Center(
                            child: Container(
                              height: MediaQuery.of(context).size.height / 2,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.transparent,
                              child: CustomPaint(
                                painter: MaterialProgressBarPainter(
                                  info,
                                  ProgressColors(playedColor: Theme.of(context).primaryColor, handleColor: Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (info.volume == 0) {
                          assetsAudioPlayer.setVolume(0.5);
                        } else {
                          assetsAudioPlayer.setVolume(0);
                        }
                      },
                      child: ClipRect(
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            right: 8.0,
                          ),
                          child: Icon(
                            info.volume == 0 ? Icons.volume_off : Icons.volume_up,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            } else {
              final barHeight = MediaQuery.of(context).orientation == Orientation.portrait ? 30.0 : 47.0;
              double latestVolume;
              return Container(
                color: Colors.transparent,
                alignment: Alignment.center,
                margin: EdgeInsets.all(5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 10.0,
                      sigmaY: 10.0,
                    ),
                    child: Container(
                      height: barHeight,
                      color: Color.fromRGBO(41, 41, 41, 0.7),
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              assetsAudioPlayer.seekBy(Duration(seconds: -15));
                            },
                            child: Container(
                              height: barHeight,
                              color: Colors.transparent,
                              margin: const EdgeInsets.only(left: 10.0),
                              padding: const EdgeInsets.only(
                                left: 6.0,
                                right: 6.0,
                              ),
                              child: Icon(
                                CupertinoIcons.gobackward_10,
                                color: Color.fromARGB(255, 200, 200, 200),
                                size: 18.0,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (info.isPlaying) {
                                assetsAudioPlayer.pause();
                              } else {
                                assetsAudioPlayer.play();
                              }
                            },
                            child: Container(
                              height: barHeight,
                              color: Colors.transparent,
                              padding: const EdgeInsets.only(
                                left: 6.0,
                                right: 6.0,
                              ),
                              child: Icon(
                                info.isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Color.fromARGB(255, 200, 200, 200),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              assetsAudioPlayer.seekBy(Duration(seconds: 15));
                            },
                            child: Container(
                              height: barHeight,
                              color: Colors.transparent,
                              padding: const EdgeInsets.only(
                                left: 6.0,
                                right: 8.0,
                              ),
                              margin: const EdgeInsets.only(
                                right: 8.0,
                              ),
                              child: Icon(
                                CupertinoIcons.goforward_10,
                                color: Color.fromARGB(255, 200, 200, 200),
                                size: 18.0,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: Text(
                              formatDuration(info.currentPosition),
                              style: TextStyle(
                                color: Color.fromARGB(255, 200, 200, 200),
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: GestureDetector(
                                  onHorizontalDragStart: (DragStartDetails details) {
                                    wasPlaying = info.isPlaying;
                                    if (info.isPlaying) {
                                      assetsAudioPlayer.pause();
                                    }
                                  },
                                  onHorizontalDragUpdate: (DragUpdateDetails details) {
                                    final box = context.findRenderObject() as RenderBox;
                                    final Offset tapPos = box.globalToLocal(details.globalPosition);
                                    final double relative = tapPos.dx / box.size.width;
                                    final Duration position = info.duration * relative;
                                    assetsAudioPlayer.seek(position);
                                  },
                                  onHorizontalDragEnd: (DragEndDetails details) {
                                    if (wasPlaying) {
                                      assetsAudioPlayer.play();
                                    }
                                  },
                                  onTapDown: (TapDownDetails details) {
                                    final box = context.findRenderObject() as RenderBox;
                                    final Offset tapPos = box.globalToLocal(details.globalPosition);
                                    final double relative = tapPos.dx / box.size.width;
                                    final Duration position = info.duration * relative;
                                    assetsAudioPlayer.seek(position);
                                  },
                                  child: Center(
                                    child: Container(
                                      height: MediaQuery.of(context).size.height,
                                      width: MediaQuery.of(context).size.width,
                                      color: Colors.transparent,
                                      child: CustomPaint(
                                        painter: CupertinoProgressBarPainter(
                                          info,
                                          ProgressColors(
                                            playedColor: const Color.fromARGB(120, 255, 255, 255,),
                                            handleColor: const Color.fromARGB(255, 255, 255, 255,),
                                            bufferedColor: const Color.fromARGB(60, 255, 255, 255,),
                                            backgroundColor: const Color.fromARGB(20, 255, 255, 255,),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: Text(
                              '-${formatDuration(info.duration - info.currentPosition)}',
                              style: TextStyle(color: Color.fromARGB(255, 200, 200, 200), fontSize: 12.0),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                if (info.volume == 0) {
                                  assetsAudioPlayer.setVolume(latestVolume ?? 0.5);
                                } else {
                                  latestVolume = info.volume;
                                  assetsAudioPlayer.setVolume(0.0);
                                }
                              },
                              child: SizedBox(
                                height: barHeight,
                                child: Icon(
                                  info.volume > 0 ? Icons.volume_up : Icons.volume_off,
                                  color: Color.fromARGB(255, 200, 200, 200),
                                  size: 16.0,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          }
      );
    } else {
      return Container(height: 0, width: 0);
    }
  }
}

class MaterialProgressBarPainter extends CustomPainter {
  MaterialProgressBarPainter(this.info, this.colors);

  RealtimePlayingInfos info;
  ProgressColors colors;

  @override
  bool shouldRepaint(CustomPainter painter) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const height = 2.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, size.height / 2),
          Offset(size.width, size.height / 2 + height),
        ),
        const Radius.circular(4.0),
      ),
      colors.backgroundPaint,
    );
    final double playedPartPercent = info.duration.inMilliseconds == 0 ? 0 : info.currentPosition.inMilliseconds / info.duration.inMilliseconds;
    final double playedPart = playedPartPercent >= 1 ? size.width : playedPartPercent * size.width;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, size.height / 2),
          Offset(playedPart, size.height / 2 + height),
        ),
        const Radius.circular(4.0),
      ),
      colors.playedPaint,
    );
    canvas.drawCircle(
      Offset(playedPart, size.height / 2 + height / 2),
      height * 3,
      colors.handlePaint,
    );
  }
}

class CupertinoProgressBarPainter extends CustomPainter {
  CupertinoProgressBarPainter(this.info, this.colors);

  RealtimePlayingInfos info;
  ProgressColors colors;

  @override
  bool shouldRepaint(CustomPainter painter) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const barHeight = 5.0;
    const handleHeight = 6.0;
    final baseOffset = size.height / 2 - barHeight / 2.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, baseOffset),
          Offset(size.width, baseOffset + barHeight),
        ),
        const Radius.circular(4.0),
      ),
      colors.backgroundPaint,
    );
    final double playedPartPercent = info.duration.inMilliseconds == 0 ? 0 : info.currentPosition.inMilliseconds / info.duration.inMilliseconds;
    final double playedPart = playedPartPercent > 1 ? size.width : playedPartPercent * size.width;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, baseOffset),
          Offset(playedPart, baseOffset + barHeight),
        ),
        const Radius.circular(4.0),
      ),
      colors.playedPaint,
    );

    final shadowPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(playedPart, baseOffset + barHeight / 2), radius: handleHeight));

    canvas.drawShadow(shadowPath, Colors.black, 0.2, false);
    canvas.drawCircle(
      Offset(playedPart, baseOffset + barHeight / 2),
      handleHeight,
      colors.handlePaint,
    );
  }
}

class ProgressColors {
  ProgressColors({
    Color playedColor = const Color.fromRGBO(255, 0, 0, 0.7),
    Color bufferedColor = const Color.fromRGBO(30, 30, 200, 0.2),
    Color handleColor = const Color.fromRGBO(200, 200, 200, 1.0),
    Color backgroundColor = const Color.fromRGBO(200, 200, 200, 0.5),
  })  : playedPaint = Paint()..color = playedColor,
        bufferedPaint = Paint()..color = bufferedColor,
        handlePaint = Paint()..color = handleColor,
        backgroundPaint = Paint()..color = backgroundColor;

  final Paint playedPaint;
  final Paint bufferedPaint;
  final Paint handlePaint;
  final Paint backgroundPaint;
}