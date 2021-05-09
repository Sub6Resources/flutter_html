library flutter_html_table;

import 'dart:math';

import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

CustomRender tableRender() => CustomRender.fromWidget(widget: (context, buildChildren) {
  return Container(
    key: context.key,
    margin: context.style.margin,
    padding: context.style.padding,
    decoration: BoxDecoration(
      color: context.style.backgroundColor,
      border: context.style.border,
    ),
    width: context.style.width,
    height: context.style.height,
    child: LayoutBuilder(builder: (_, constraints) => _layoutCells(context, constraints)),
  );
});

CustomRenderMatcher tableMatcher() => (context) {
  return context.tree.element?.localName == "table";
};

Widget _layoutCells(RenderContext context, BoxConstraints constraints) {
  final rows = <TableRowLayoutElement>[];
  List<TrackSize> columnSizes = <TrackSize>[];
  for (var child in context.tree.children) {
    if (child is TableStyleElement) {
      // Map <col> tags to predetermined column track sizes
      columnSizes = child.children
          .where((c) => c.name == "col")
          .map((c) {
        final span = int.tryParse(c.attributes["span"] ?? "1") ?? 1;
        final colWidth = c.attributes["width"];
        return List.generate(span, (index) {
          if (colWidth != null && colWidth.endsWith("%")) {
            if (!constraints.hasBoundedWidth) {
              // In a horizontally unbounded container; always wrap content instead of applying flex
              return IntrinsicContentTrackSize();
            }
            final percentageSize = double.tryParse(
                colWidth.substring(0, colWidth.length - 1));
            return percentageSize != null && !percentageSize.isNaN
                ? FlexibleTrackSize(percentageSize * 0.01)
                : IntrinsicContentTrackSize();
          } else if (colWidth != null) {
            final fixedPxSize = double.tryParse(colWidth);
            return fixedPxSize != null
                ? FixedTrackSize(fixedPxSize)
                : IntrinsicContentTrackSize();
          } else {
            return IntrinsicContentTrackSize();
          }
        });
      })
          .expand((element) => element)
          .toList(growable: false);
    } else if (child is TableSectionLayoutElement) {
      rows.addAll(child.children.whereType());
    } else if (child is TableRowLayoutElement) {
      rows.add(child);
    }
  }

  // All table rows have a height intrinsic to their (spanned) contents
  final rowSizes =
  List.generate(rows.length, (_) => IntrinsicContentTrackSize());

  // Calculate column bounds
  int columnMax = rows
      .map((row) => row.children
      .whereType<TableCellElement>()
      .fold(0, (int value, child) => value + child.colspan))
      .fold(0, max);

  // Place the cells in the rows/columns
  final cells = <GridPlacement>[];
  final columnRowOffset = List.generate(columnMax + 1, (_) => 0);
  int rowi = 0;
  for (var row in rows) {
    int columni = 0;
    for (var child in row.children) {
      while (columnRowOffset[columni] > 0) {
        columnRowOffset[columni] = columnRowOffset[columni] - 1;
        columni++;
      }
      if (child is TableCellElement) {
        cells.add(GridPlacement(
          child: Container(
            width: double.infinity,
            padding: child.style.padding ?? row.style.padding,
            decoration: BoxDecoration(
              color: child.style.backgroundColor ?? row.style.backgroundColor,
              border: child.style.border ?? row.style.border,
            ),
            child: SizedBox.expand(
              child: Container(
                alignment: child.style.alignment ??
                    context.style.alignment ??
                    Alignment.centerLeft,
                child: StyledText(
                  textSpan: context.parser.parseTree(context, child),
                  style: child.style,
                  renderContext: context,
                ),
              ),
            ),
          ),
          columnStart: columni,
          columnSpan: child.colspan,
          rowStart: rowi,
          rowSpan: child.rowspan,
        ));
        columnRowOffset[columni] = child.rowspan - 1;
        columni += child.colspan;
      }
    }
    rowi++;
  }

  // Create column tracks (insofar there were no colgroups that already defined them)
  List<TrackSize> finalColumnSizes = columnSizes.take(columnMax).toList();
  finalColumnSizes += List.generate(
      max(0, columnMax - finalColumnSizes.length),
          (_) => IntrinsicContentTrackSize());

  return LayoutGrid(
    gridFit: GridFit.loose,
    columnSizes: finalColumnSizes,
    rowSizes: rowSizes,
    children: cells,
  );
}
