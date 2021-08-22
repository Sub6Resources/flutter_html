import 'package:html/dom.dart' as dom;
import 'text_parser.dart';

extension NodeExtension on dom.Node {
  bool get isFirstInBlock {
    if (parentNode == null ||
        (this is dom.Element &&
            SUPPORTED_BLOCK_ELEMENTS
                .contains((this as dom.Element).localName?.toLowerCase()))) {
      return true;
    }
    for (final child in parentNode!.nodes) {
      if (this == child) {
        return parentNode!.isFirstInBlock;
      }
      if (!(child is dom.Text) || child.text.trim().isNotEmpty) {
        return false;
      }
    }
    return false; // wtf happened?
  }

  String get previousText {
    if (parentNode == null) {
      return '';
    }
    if (parentNode!.firstChild == this) {
      return parentNode!.previousText;
    }
    var prevText = '';
    for (final child in parentNode!.nodes) {
      if (this == child) {
        break;
      }
      if (child is dom.Element && child.localName?.toLowerCase() == 'br') {
        prevText = '\n';
      } else if (child is dom.Element) {
        prevText = child.lastChildText;
      } else if (child is dom.Text) {
        prevText = child.text;
      }
    }
    return prevText;
  }

  String get lastChildText {
    if (nodes.isEmpty) {
      return '[non-text tag]';
    }
    if (nodes.last is dom.Text) {
      return nodes.last.text ?? '';
    } else {
      return nodes.last.lastChildText;
    }
  }
}
