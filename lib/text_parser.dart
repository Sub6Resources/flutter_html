import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:matrix_link_text/link_text.dart';
import 'package:flutter_highlight/themes/monokai.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import 'color_extension.dart';
import 'code_block.dart';
import 'image_properties.dart';
import 'spoiler.dart';
import 'pill.dart';
import 'details.dart';
import 'textspan_extension.dart';
import 'node_extension.dart';

typedef CustomRender = Widget Function(dom.Node node, List<Widget> children);
typedef OnLinkTap = void Function(String url);
typedef OnImageTap = void Function(String source);
typedef OnPillTap = void Function(String identifier);
typedef GetMxcUrl = String Function(String mxc, double? width, double? height,
    {bool? animated});
typedef GetPillInfo = Future<Map<String, dynamic>> Function(String identifier);

const OFFSET_TAGS_FONT_SIZE_FACTOR =
    0.7; //The ratio of the parent font for each of the offset tags: sup or sub

const MATRIX_TO_SCHEME = "https://matrix.to/#/";
const MATRIX_SCHEME = "matrix:";

/*
const SUPPORTED_INLINE_ELEMENTS = <String>{
  'b',
  'strong',
  'i',
  'em',
  'br',
  'tt',
  'code',
  'ins',
  'u',
  'sub',
  'sup',
  'del',
  's',
  'strike',
  'span',
  'font',
  'a',
  'img',
};
*/

const SUPPORTED_BLOCK_ELEMENTS = <String>{
  'table',
  'thead',
  'tbody',
  'tfoot',
  'th',
  'td',
  'caption',
  'ul',
  'ol',
  'li',
  'div',
  'p',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'pre',
  'mx-reply',
  'blockquote',
  'hr',
  'details',
  'summary',
};

class TextParser extends StatelessWidget {
  TextParser({
    this.shrinkToFit = false,
    this.onLinkTap,
    this.renderNewlines = false,
    required this.html,
    this.onImageError,
    this.linkStyle = const TextStyle(
      decoration: TextDecoration.underline,
      color: Colors.blueAccent,
      decorationColor: Colors.blueAccent,
    ),
    this.onPillTap,
    this.getPillInfo,
    this.imageProperties,
    this.onImageTap,
    this.showImages = true,
    this.getMxcUrl,
    this.maxLines,
    this.defaultTextStyle,
    this.emoteSize,
    this.setCodeLanguage,
    this.getCodeLanguage,
  });

  final double indentSize = 10.0;

  final bool shrinkToFit;
  final OnLinkTap? onLinkTap;
  final bool renderNewlines;
  final String html;
  final ImageErrorListener? onImageError;
  final TextStyle? linkStyle;
  final OnPillTap? onPillTap;
  final GetPillInfo? getPillInfo;
  final ImageProperties? imageProperties;
  final OnImageTap? onImageTap;
  final bool showImages;
  final GetMxcUrl? getMxcUrl;
  final int? maxLines;
  final TextStyle? defaultTextStyle;
  final double? emoteSize;
  final SetCodeLanguage? setCodeLanguage;
  final GetCodeLanguage? getCodeLanguage;

  TextSpan _parseTextNode(
      BuildContext context, ParseContext parseContext, dom.Text node) {
    var finalText = node.text;
    if (parseContext.condenseWhitespace) {
      finalText = _condenseHtmlWhitespace(node.text);
      // condense the whitespace around the tag properly
      if (node.isFirstInBlock) {
        finalText = finalText.trimLeft();
      } else {
        final previousText = node.previousText;
        if (previousText.endsWith(' ') ||
            previousText.endsWith('\n') ||
            previousText.endsWith('\t')) {
          finalText = finalText.trimLeft();
        }
      }
    }
    return LinkTextSpans(
      text: finalText,
      themeData: Theme.of(context),
      onLinkTap: onLinkTap,
      textStyle: parseContext.textStyle,
      linkStyle: parseContext.textStyle.merge(parseContext.linkStyle),
    );
  }

  InlineSpan _optimizeTextspan(InlineSpan textSpan) {
    if (!(textSpan is TextSpan)) {
      return textSpan;
    }
    // if we have only one child and inherit all styles...return it
    if ((textSpan.text?.isEmpty ?? true) &&
        textSpan.children?.length == 1 &&
        (textSpan.style == null || textSpan.style == TextStyle()) &&
        (textSpan.recognizer == null ||
            (textSpan.children!.first is TextSpan &&
                (textSpan.children!.first as TextSpan).recognizer ==
                    textSpan.recognizer))) {
      return _optimizeTextspan(textSpan.children!.first);
    }
    // if our child node is just blank, then append its child nodes one up
    // so, we flatten the tree
    {
      final textSpanChildren = textSpan.children;
      if (textSpanChildren != null) {
        final optimizedChildren = <InlineSpan>[];
        for (var child in textSpanChildren) {
          child = _optimizeTextspan(child);
          if (child is TextSpan &&
              !(child is LinkTextSpan) &&
              (child.text?.isEmpty ?? true) &&
              (child.style == null || child.style == TextStyle())) {
            if (child.children != null) {
              optimizedChildren.addAll(child.children!);
            }
          } else {
            optimizedChildren.add(child);
          }
        }
        textSpan.children!.clear();
        textSpan.children!.addAll(optimizedChildren);
      }
    }
    // now we try to merge children together
    {
      final textSpanChildren = textSpan.children;
      if (textSpanChildren != null) {
        final optimizedChildren = <InlineSpan>[];
        for (final child in textSpanChildren) {
          final lastChild =
              optimizedChildren.isEmpty ? null : optimizedChildren.last;
          if (lastChild != null &&
              lastChild is TextSpan &&
              child is TextSpan &&
              (lastChild.children?.isEmpty ?? true) &&
              (child.children?.isEmpty ?? true) &&
              (lastChild.style ?? TextStyle()) ==
                  (child.style ?? TextStyle()) &&
              lastChild.recognizer == child.recognizer) {
            optimizedChildren.removeLast();
            // since we checked that the two recognizers are the same, we don't need to
            // dispose them here yet.
            optimizedChildren.add(TextSpan(
              text: (lastChild.text ?? '') + (child.text ?? ''),
              style: child.style,
              recognizer: child.recognizer,
            ));
          } else {
            optimizedChildren.add(child);
          }
        }
        textSpan.children!.clear();
        textSpan.children!.addAll(optimizedChildren);
      }
    }
    // we don't care much about additional optimization for now
    return textSpan;
  }

  InlineSpan _parseInlineChildNodes(
      BuildContext context, ParseContext parseContext, List<dom.Node> nodes) {
    final children = <InlineSpan>[];
    for (final node in nodes) {
      final ts = _parseInlineNode(context, parseContext, node);
      children.add(ts);
    }
    return TextSpan(children: children);
  }

  InlineSpan _parseInlineNode(
      BuildContext context, ParseContext parseContext, dom.Node node) {
    if (node is dom.Text) {
      return _parseTextNode(context, parseContext, node);
    } else if (node is dom.Element) {
      final tag = node.localName?.toLowerCase();
      if (SUPPORTED_BLOCK_ELEMENTS.contains(tag)) {
        return TextSpan(
          children: <InlineSpan>[
            TextSpan(text: '\n'),
            WidgetSpan(child: _parseNode(context, parseContext, node)),
            TextSpan(text: '\n'),
          ],
        );
      }
      final nextContext = ParseContext.fromContext(parseContext);
      final fontSize = nextContext.textStyle.fontSize ?? 14.0;
      switch (tag) {
        case 'b':
        case 'strong':
          nextContext.textStyle = nextContext.textStyle
              .merge(TextStyle(fontWeight: FontWeight.bold));
          break;
        case 'i':
        case 'em':
          nextContext.textStyle = nextContext.textStyle
              .merge(TextStyle(fontStyle: FontStyle.italic));
          break;
        case 'br':
          return TextSpan(text: '\n', style: parseContext.textStyle);
        case 'tt':
          nextContext.textStyle =
              nextContext.textStyle.merge(TextStyle(fontFamily: 'monospace'));
          nextContext.linkStyle = parseContext.linkStyle.merge(TextStyle(
            fontFamily: 'monospace',
          ));
          break;
        case 'code':
          nextContext.textStyle = nextContext.textStyle.merge(TextStyle(
            fontFamily: 'monospace',
            backgroundColor: monokaiTheme['root']?.backgroundColor,
            color: monokaiTheme['root']?.color,
          ));
          nextContext.linkStyle = nextContext.linkStyle.merge(TextStyle(
            fontFamily: 'monospace',
            backgroundColor: monokaiTheme['root']?.backgroundColor,
            color: monokaiTheme['root']?.color,
          ));
          break;
        case 'ins':
        case 'u':
          nextContext.textStyle = nextContext.textStyle
              .merge(TextStyle(decoration: TextDecoration.underline));
          break;
        case 'sub':
          // at bottom
          nextContext.textStyle = nextContext.textStyle.merge(
            TextStyle(
              fontSize: fontSize * OFFSET_TAGS_FONT_SIZE_FACTOR,
            ),
          );
          break;
        case 'sup':
          // at top
          nextContext.textStyle = nextContext.textStyle.merge(
            TextStyle(
              fontSize: fontSize * OFFSET_TAGS_FONT_SIZE_FACTOR,
            ),
          );
          return WidgetSpan(
            alignment: PlaceholderAlignment.top,
            child: _parseChildNodes(context, nextContext, node.nodes),
          );
        case 'del':
        case 's':
        case 'strike':
          nextContext.textStyle = nextContext.textStyle
              .merge(TextStyle(decoration: TextDecoration.lineThrough));
          break;
        case 'span':
          if (node.attributes['data-mx-color'] != null) {
            nextContext.textStyle = nextContext.textStyle.merge(TextStyle(
                color: CssColor.fromCss(
              node.attributes['data-mx-color'],
            )));
          }
          if (node.attributes['data-mx-bg-color'] != null) {
            nextContext.textStyle = nextContext.textStyle.merge(TextStyle(
                backgroundColor: CssColor.fromCss(
              node.attributes['data-mx-bg-color'],
            )));
          }
          // we need to hackingly check the outerHtml as the atributes don't contain blank ones, somehow
          if (node.attributes['data-mx-spoiler'] != null ||
              node.outerHtml.split('>').first.contains('data-mx-spoiler')) {
            return WidgetSpan(
              child: Spoiler(
                reason: node.attributes['data-mx-spoiler'],
                child: _parseChildNodes(context, nextContext, node.nodes),
              ),
            );
          }
          // maybe we have latex stuff?
          if (node.attributes['data-mx-maths'] != null) {
            return WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Math.tex(
                  // we just did a null check here...
                  node.attributes['data-mx-maths']!,
                  onErrorFallback: (_) =>
                      Text(node.attributes['data-mx-maths']!),
                  textStyle: parseContext.textStyle,
                  mathStyle: MathStyle.text,
                ),
              ),
            );
          }
          break;
        case 'font':
          if (node.attributes['color'] != null ||
              node.attributes['data-mx-color'] != null) {
            nextContext.textStyle = nextContext.textStyle.merge(TextStyle(
                color: CssColor.fromCss(
              node.attributes['color'] ?? node.attributes['data-mx-color'],
            )));
          }
          if (node.attributes['data-mx-bg-color'] != null) {
            nextContext.textStyle = nextContext.textStyle.merge(TextStyle(
                backgroundColor: CssColor.fromCss(
              node.attributes['data-mx-bg-color'],
            )));
          }
          break;
        case 'a':
          final url = node.attributes['href'];
          final urlLower = url?.toLowerCase();
          if (url != null &&
              urlLower != null &&
              (urlLower.startsWith(MATRIX_SCHEME) ||
                  urlLower.startsWith(MATRIX_TO_SCHEME))) {
            // this might be a pill!
            var isPill = true;
            var identifier = url;
            if (urlLower.startsWith(MATRIX_TO_SCHEME)) {
              final urlPart =
                  url.substring(MATRIX_TO_SCHEME.length).split('?').first;
              try {
                identifier = Uri.decodeComponent(urlPart);
              } catch (_) {
                identifier = urlPart;
              }
              isPill = RegExp(r'^[@#!+][^:]+:[^\/]+$').firstMatch(identifier) !=
                  null;
            } else {
              final match = RegExp(r'^matrix:(r|roomid|u)\/([^\/]+)$')
                  .firstMatch(urlLower.split('?').first.split('#').first);
              isPill = match != null && match.group(2) != null;
              if (isPill) {
                final sigil = {
                  'r': '#',
                  'roomid': '!',
                  'u': '@',
                }[match.group(1)];
                if (sigil == null) {
                  isPill = false;
                } else {
                  identifier = sigil + match.group(2)!;
                }
              }
            }
            if (isPill) {
              return WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Pill(
                  identifier: identifier,
                  url: url,
                  future: getPillInfo?.call(url),
                  onTap: onPillTap,
                  getMxcUrl: getMxcUrl,
                ),
              );
            }
          }
          nextContext.textStyle =
              parseContext.textStyle.merge(parseContext.linkStyle);
          return LinkTextSpan(
            style: nextContext.textStyle,
            url: url ?? '',
            onLinkTap: onLinkTap,
            children: <InlineSpan>[
              _parseInlineChildNodes(context, nextContext, node.nodes)
            ],
          );
        case 'img':
          if (!showImages || node.attributes['src'] == null) {
            return TextSpan();
          }
          var width = imageProperties?.width ??
              ((node.attributes['width'] != null)
                  ? double.tryParse(node.attributes['width']!)
                  : null);
          var height = imageProperties?.height ??
              ((node.attributes['height'] != null)
                  ? double.tryParse(node.attributes['height']!)
                  : null);

          if (emoteSize != null &&
              (node.attributes['data-mx-emote'] != null ||
                  node.outerHtml.split('>').first.contains('data-mx-emote') ||
                  node.attributes['data-mx-emoticon'] != null ||
                  node.outerHtml
                      .split('>')
                      .first
                      .contains('data-mx-emoticon'))) {
            // we have an emote and a set emote size....use that instead!
            width = null;
            height = emoteSize;
          }
          final url =
              node.attributes['src']!.startsWith('mxc:') && getMxcUrl != null
                  ? getMxcUrl!(node.attributes['src']!, width, height,
                      animated: true)
                  : '';
          return WidgetSpan(
            alignment: PlaceholderAlignment.bottom,
            child: GestureDetector(
              onTap: () => onImageTap?.call(node.attributes['src']!),
              child: Image(
                image: CachedNetworkImageProvider(
                  url,
                  scale: imageProperties?.scale ?? 1.0,
                ),
                frameBuilder: (context, child, frame, _) {
                  if (node.attributes['alt'] != null && frame == null) {
                    return Text(
                      node.attributes['alt']!,
                      style: parseContext.textStyle,
                      textAlign: TextAlign.center,
                      maxLines: maxLines,
                    );
                  }
                  if (frame != null) {
                    return child;
                  }
                  return Container();
                },
                width: (width ?? -1) > 0 ? width : null,
                height: (height ?? -1) > 0 ? height : null,
                matchTextDirection:
                    imageProperties?.matchTextDirection ?? false,
                centerSlice: imageProperties?.centerSlice,
                filterQuality:
                    imageProperties?.filterQuality ?? FilterQuality.low,
                alignment: imageProperties?.alignment ?? Alignment.center,
                colorBlendMode: imageProperties?.colorBlendMode,
                fit: imageProperties?.fit,
                color: imageProperties?.color,
                repeat: imageProperties?.repeat ?? ImageRepeat.noRepeat,
                semanticLabel: imageProperties?.semanticLabel,
                excludeFromSemantics:
                    (imageProperties?.semanticLabel == null) ? true : false,
              ),
            ),
          );
      }
      return _parseInlineChildNodes(context, nextContext, node.nodes);
    } else {
      return WidgetSpan(child: _parseNode(context, parseContext, node));
    }
  }

  List<Widget> _parseChildNodesList(BuildContext context,
      ParseContext parseContext, List<dom.Node> nodes, Iterable<String> tags) {
    final widgets = <Widget>[];
    for (final node in nodes) {
      if (!(node is dom.Element) ||
          !tags.contains(node.localName?.toLowerCase())) {
        continue;
      }
      widgets.add(_parseNode(context, parseContext, node));
    }
    return widgets;
  }

  _ParseTableResult _parseChildTable(
      BuildContext context, ParseContext parseContext, List<dom.Node> nodes) {
    final rows = <List<Widget>>[];
    Widget? caption;
    for (final node in nodes) {
      if (!(node is dom.Element)) {
        continue;
      }
      final tag = node.localName?.toLowerCase();
      if ({'thead', 'tbody', 'tfoot'}.contains(tag)) {
        rows.addAll(_parseChildTable(context, parseContext, node.nodes).rows);
      } else if (tag == 'tr') {
        rows.add(_parseChildNodesList(
            context, parseContext, node.nodes, {'td', 'th'}));
      } else if (tag == 'caption') {
        final nextContext = ParseContext.fromContext(parseContext);
        nextContext.textStyle = nextContext.textStyle.merge(TextStyle(
          fontSize: (nextContext.textStyle.fontSize ?? 14.0) * (18.0 / 14.0),
          fontWeight: FontWeight.w600,
        ));
        caption = _parseChildNodes(context, nextContext, node.nodes);
      }
    }
    var maxColumns = 0;
    for (final r in rows) {
      if (r.length > maxColumns) {
        maxColumns = r.length;
      }
    }
    for (final r in rows) {
      while (r.length < maxColumns) {
        r.add(Container());
      }
    }
    return _ParseTableResult(
      rows: rows,
      caption: caption,
    );
  }

  Widget _parseChildNodes(
      BuildContext context, ParseContext parseContext, List<dom.Node> nodes,
      {Iterable<String>? ignoreTags}) {
    var currentChildren = <InlineSpan>[];
    final widgets = <Widget>[];
    var lastNodeBlock = false;
    final cleanup = (bool thisNodeBlock, bool lastElement) {
      if (currentChildren.isNotEmpty) {
        widgets.add(CleanRichText(
          _optimizeTextspan(TextSpan(children: currentChildren)),
          maxLines: maxLines,
        ));
        currentChildren = <InlineSpan>[];
      }
      // trailing blank nodes and trailing SizedBox'es
      while (widgets.isNotEmpty &&
          ((widgets.last is SizedBox) ||
              (widgets.last is CleanRichText &&
                  (widgets.last as CleanRichText).child is TextSpan &&
                  ((widgets.last as CleanRichText).child as TextSpan)
                      .isBlank))) {
        widgets.removeLast();
      }
      if ((thisNodeBlock || lastNodeBlock) &&
          !lastElement &&
          widgets.isNotEmpty) {
        widgets.add(SizedBox(height: 4));
      }
    };
    for (final node in nodes) {
      if (node is dom.Element &&
          (node.localName?.toLowerCase() == 'mx-reply' ||
              (ignoreTags != null &&
                  ignoreTags.contains(node.localName?.toLowerCase())))) {
        continue;
      }
      final widget = _parseNode(context, parseContext, node);
      final thisNodeBlock = SUPPORTED_BLOCK_ELEMENTS
          .contains(node is dom.Element ? node.localName?.toLowerCase() : null);
      if (widget is CleanRichText && !lastNodeBlock && !thisNodeBlock) {
        currentChildren.add(widget.child);
      } else {
        cleanup(thisNodeBlock, false);
        widgets.add(widget);
      }
      lastNodeBlock = thisNodeBlock;
    }
    cleanup(lastNodeBlock, true);
    while (maxLines != null && widgets.length > maxLines!) {
      widgets.removeLast();
    }
    if (widgets.length == 1) {
      return widgets.first;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  static const _listBulletPoints = <String>['●', '○', '■', '‣'];

  Widget _parseNode(
      BuildContext context, ParseContext parseContext, dom.Node node) {
    if (node is dom.Text) {
      return CleanRichText(_parseTextNode(context, parseContext, node),
          maxLines: maxLines);
    } else if (node is dom.Element) {
      final tag = node.localName?.toLowerCase();
      if (!SUPPORTED_BLOCK_ELEMENTS.contains(tag)) {
        return CleanRichText(_parseInlineNode(context, parseContext, node),
            maxLines: maxLines);
      }
      final nextContext = ParseContext.fromContext(parseContext);
      final fontSize = nextContext.textStyle.fontSize ?? 14.0;
      switch (node.localName?.toLowerCase()) {
        case 'blockquote':
          return Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                    color: defaultTextStyle?.color ?? Colors.black, width: 3),
              ),
            ),
            padding: EdgeInsets.only(
              left: 6.0,
              right: 2.0,
              top: 2.0,
              bottom: 2.0,
            ),
            child: _parseChildNodes(context, nextContext, node.nodes),
          );
        case 'pre':
          final textNodes = List<dom.Node>.from(node.nodes);
          textNodes.removeWhere((n) => !(n is dom.Text));
          final elementNodes = List<dom.Node>.from(node.nodes);
          elementNodes.removeWhere((n) => !(n is dom.Element));
          if (textNodes.every((n) => n.text?.trim().isEmpty ?? true) &&
              elementNodes.length == 1 &&
              (elementNodes.first as dom.Element).localName == "code") {
            // alright, we have a <pre><code> which means code block
            // soooo....let's syntax-highlight it properly!
            final language = (elementNodes.first as dom.Element)
                .classes
                .cast<String?>()
                .firstWhere((s) => s?.startsWith('language-') ?? false,
                    orElse: () => null)
                ?.substring('language-'.length);
            final code = elementNodes.first.text ?? '';
            return CodeBlock(
              code,
              language: language,
              setCodeLanguage: setCodeLanguage,
              getCodeLanguage: getCodeLanguage,
              borderColor: defaultTextStyle?.color ?? Colors.black,
              maxLines: maxLines,
            );
          }
          nextContext.condenseWhitespace = false;
          nextContext.textStyle = nextContext.textStyle.merge(TextStyle(
            fontFamily: 'monospace',
          ));
          break;
        case 'div':
          if (node.attributes['data-mx-maths'] != null) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Math.tex(
                node.attributes['data-mx-maths']!,
                onErrorFallback: (_) => Text(node.attributes['data-mx-maths']!),
                textStyle: parseContext.textStyle,
                mathStyle: MathStyle.display,
              ),
            );
          }
          break;
        case 'h1':
          nextContext.textStyle = nextContext.textStyle.merge(TextStyle(
            fontSize: fontSize * (26.0 / 14.0),
            fontWeight: FontWeight.bold,
          ));
          break;
        case 'h2':
          nextContext.textStyle = nextContext.textStyle.merge(TextStyle(
            fontSize: fontSize * (24.0 / 14.0),
            fontWeight: FontWeight.bold,
          ));
          break;
        case 'h3':
          nextContext.textStyle = nextContext.textStyle.merge(TextStyle(
            fontSize: fontSize * (22.0 / 14.0),
            fontWeight: FontWeight.bold,
          ));
          break;
        case 'h4':
          nextContext.textStyle = nextContext.textStyle.merge(TextStyle(
            fontSize: fontSize * (20.0 / 14.0),
            fontWeight: FontWeight.w600,
          ));
          break;
        case 'h5':
          nextContext.textStyle = nextContext.textStyle.merge(TextStyle(
            fontSize: fontSize * (18.0 / 14.0),
            fontWeight: FontWeight.bold,
          ));
          break;
        case 'h6':
          nextContext.textStyle = nextContext.textStyle.merge(TextStyle(
            fontSize: fontSize * (18.0 / 14.0),
            fontWeight: FontWeight.w600,
          ));
          break;
        case 'ul':
          final bulletPoint = _listBulletPoints[
              parseContext.listDepth % _listBulletPoints.length];
          nextContext.listDepth++;
          final entries =
              _parseChildNodesList(context, nextContext, node.nodes, {'li'});
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: entries.map((e) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 0.5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      width: fontSize,
                      child: Text(bulletPoint, style: nextContext.textStyle),
                    ),
                    Flexible(child: e),
                  ],
                ),
              );
            }).toList(),
          );
        case 'ol':
          nextContext.listDepth++;
          var entry = 1;
          if (node.attributes['start'] is String &&
              RegExp(r'^[0-9]+$', multiLine: false)
                  .hasMatch(node.attributes['start']!)) {
            entry = int.parse(node.attributes['start']!);
          }
          final entries =
              _parseChildNodesList(context, nextContext, node.nodes, {'li'});
          final olWidth =
              fontSize * ((entry + entries.length).toString().length) * 0.6 + 5;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: entries.map((e) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 0.5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      width: olWidth,
                      child: Text('${entry++}.', style: nextContext.textStyle),
                    ),
                    Flexible(child: e),
                  ],
                ),
              );
            }).toList(),
          );
        case 'table':
          final res = _parseChildTable(context, parseContext, node.nodes);
          final table = Table(
            border:
                TableBorder.all(color: defaultTextStyle?.color ?? Colors.black),
            children: res.rows
                .map((r) => TableRow(
                      children: r,
                    ))
                .toList(),
          );
          if (res.caption == null) {
            return table;
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              res.caption!,
              table,
            ],
          );
        case 'td':
          return Padding(
            padding: EdgeInsets.all(2.0),
            child: _parseChildNodes(context, nextContext, node.nodes),
          );
        case 'th':
          nextContext.textStyle = nextContext.textStyle
              .merge(TextStyle(fontWeight: FontWeight.bold));
          return Padding(
            padding: EdgeInsets.all(2.0),
            child: _parseChildNodes(context, nextContext, node.nodes),
          );
        case 'hr':
          return Divider(
              height: 3.0,
              thickness: 3.0,
              color: defaultTextStyle?.color ?? Colors.black);
        case 'details':
          final summaryRes = _parseChildNodesList(
              context, parseContext, node.nodes, {'summary'});
          final nodes = _parseChildNodes(context, nextContext, node.nodes,
              ignoreTags: {'summary'});
          return Details(
            child: nodes,
            summary: summaryRes.isEmpty ? null : summaryRes.first,
            color: defaultTextStyle?.color ?? Colors.black,
          );
      }
      return _parseChildNodes(context, nextContext, node.nodes);
    } else {
      return _parseChildNodes(context, parseContext, node.nodes);
    }
  }

  String _condenseHtmlWhitespace(String stringToTrim) {
    stringToTrim = stringToTrim.replaceAll('\n', ' ').replaceAll('\r', '');
    while (stringToTrim.contains('  ')) {
      stringToTrim = stringToTrim.replaceAll('  ', ' ');
    }
    return stringToTrim;
  }

  @override
  Widget build(BuildContext context) {
    String data = html;

    if (renderNewlines) {
      data = data.replaceAll('\n', '<br />');
    }

    final parseContext = ParseContext(
      textStyle: defaultTextStyle,
      linkStyle: linkStyle,
    );
    final widget =
        _parseNode(context, parseContext, parser.parseFragment(data));
    if (shrinkToFit) {
      return widget;
    }
    return Container(
      width: double.infinity,
      child: widget,
    );
  }
}

class ParseContext {
  TextStyle textStyle;
  TextStyle linkStyle;
  bool condenseWhitespace = true;
  int listDepth = 0;

  ParseContext({
    TextStyle? textStyle,
    TextStyle? linkStyle,
    this.condenseWhitespace = true,
    this.listDepth = 0,
  })  : this.textStyle = textStyle ?? TextStyle(),
        this.linkStyle = linkStyle ?? TextStyle();

  ParseContext.fromContext(ParseContext parseContext)
      : this.textStyle = parseContext.textStyle,
        this.linkStyle = parseContext.linkStyle,
        this.condenseWhitespace = parseContext.condenseWhitespace,
        this.listDepth = parseContext.listDepth;
}

class _ParseTableResult {
  final List<List<Widget>> rows;
  final Widget? caption;
  _ParseTableResult({required this.rows, this.caption});
}
