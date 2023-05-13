import 'package:flutter_html/flutter_html.dart';

class BeforesAftersProcessing {
  static StyledElement processBeforesAfters(StyledElement tree) {
    return _processBeforesAndAfters(tree);
  }

  /// [_processBeforesAndAfters] adds text content to the beginning and end of
  /// the list of the trees children according to the `before` and `after` Style
  /// properties.
  static StyledElement _processBeforesAndAfters(StyledElement tree) {
    if (tree.style.before != null) {
      tree.children.insert(
        0,
        TextContentElement(
          text: tree.style.before,
          style: tree.style.copyWith(
            beforeAfterNull: true,
            display: Display.inline,
          ),
          node: tree.node, // TODO should we really just copy this from parent?
        ),
      );
    }
    if (tree.style.after != null) {
      tree.children.add(TextContentElement(
        text: tree.style.after,
        style: tree.style.copyWith(
          beforeAfterNull: true,
          display: Display.inline,
        ),
        node: tree.node, // TODO should we really just copy this from parent?
      ));
    }

    tree.children.forEach(_processBeforesAndAfters);

    return tree;
  }
}
