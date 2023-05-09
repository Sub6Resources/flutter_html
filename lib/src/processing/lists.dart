import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/src/style/marker.dart';
import 'package:list_counter/list_counter.dart';

class ListProcessing {
  static StyledElement processLists(StyledElement tree) {
    tree = _preprocessListMarkers(tree);
    tree = _processListCounters(tree);
    tree = _processListMarkers(tree);
    return tree;
  }

  /// [_preprocessListMarkers] adds marker pseudo elements to the front of all list
  /// items.
  static StyledElement _preprocessListMarkers(StyledElement tree) {
    tree.style.listStylePosition ??= ListStylePosition.outside;

    if (tree.style.display == Display.listItem) {
      // Add the marker pseudo-element if it doesn't exist
      tree.style.marker ??= Marker(
        content: Content.normal,
        style: tree.style,
      );

      // Inherit styles from originating widget
      tree.style.marker!.style =
          tree.style.copyOnlyInherited(tree.style.marker!.style ?? Style());

      // Add the implicit counter-increment on `list-item` if it isn't set
      // explicitly already
      tree.style.counterIncrement ??= {};
      if (!tree.style.counterIncrement!.containsKey('list-item')) {
        tree.style.counterIncrement!['list-item'] = 1;
      }
    }

    // Add the counters to ol and ul types.
    if (tree.name == 'ol' || tree.name == 'ul') {
      tree.style.counterReset ??= {};
      if (!tree.style.counterReset!.containsKey('list-item')) {
        tree.style.counterReset!['list-item'] = 0;
      }
    }

    for (var child in tree.children) {
      _preprocessListMarkers(child);
    }

    return tree;
  }

  /// [_processListCounters] adds the appropriate counter values to each
  /// StyledElement on the tree.
  static StyledElement _processListCounters(StyledElement tree,
      [ListQueue<Counter>? counters]) {
    // Add the counters for the current scope.
    tree.counters.addAll(counters?.deepCopy() ?? []);

    // Create any new counters
    if (tree.style.counterReset != null) {
      tree.style.counterReset!.forEach((counterName, initialValue) {
        tree.counters.add(Counter(counterName, initialValue ?? 0));
      });
    }

    // Increment any counters that are to be incremented
    if (tree.style.counterIncrement != null) {
      tree.style.counterIncrement!.forEach((counterName, increment) {
        tree.counters
            .lastWhereOrNull(
              (counter) => counter.name == counterName,
            )
            ?.increment(increment ?? 1);

        // If we didn't newly create the counter, increment the counter in the old copy as well.
        if (tree.style.counterReset == null ||
            !tree.style.counterReset!.containsKey(counterName)) {
          counters
              ?.lastWhereOrNull(
                (counter) => counter.name == counterName,
              )
              ?.increment(increment ?? 1);
        }
      });
    }

    for (var element in tree.children) {
      _processListCounters(element, tree.counters);
    }

    return tree;
  }

  /// [_processListMarkers] finally applies the marker content to the tree
  /// as a [Marker] on the [Style] object.
  static StyledElement _processListMarkers(StyledElement tree) {
    if (tree.style.display == Display.listItem) {
      final listStyleType = tree.style.listStyleType ?? ListStyleType.decimal;
      final counterStyle = CounterStyleRegistry.lookup(
        listStyleType.counterStyle,
      );
      String counterContent;
      if (tree.style.marker?.content.isNormal ?? true) {
        counterContent = counterStyle.generateMarkerContent(
          tree.counters.lastOrNull?.value ?? 0,
        );
      } else if (!(tree.style.marker?.content.display ?? true)) {
        counterContent = '';
      } else {
        counterContent = tree.style.marker?.content.replacementContent ??
            counterStyle.generateMarkerContent(
              tree.counters.lastOrNull?.value ?? 0,
            );
      }
      tree.style.marker = Marker(
        content: Content(counterContent),
        style: tree.style.marker?.style,
      );
    }

    for (var child in tree.children) {
      _processListMarkers(child);
    }

    return tree;
  }
}
