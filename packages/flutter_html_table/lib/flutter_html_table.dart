library flutter_html_table;

import 'dart:math';

import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

/// The CustomRender function that will render the <table> HTML tag
CustomRender tableRender() =>
    CustomRender.widget(widget: (context, buildChildren) {
      return CssBoxWidget(
        key: context.key,
        style: context.style,
        child: LayoutBuilder(
          builder: (_, constraints) => _layoutCells(context, constraints),
        ),
      );
    });

/// A CustomRenderMatcher for matching the <table> HTML tag
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
                  return const IntrinsicContentTrackSize();
                }
                final percentageSize =
                    double.tryParse(colWidth.substring(0, colWidth.length - 1));
                return percentageSize != null && !percentageSize.isNaN
                    ? FlexibleTrackSize(percentageSize * 0.01)
                    : const IntrinsicContentTrackSize();
              } else if (colWidth != null) {
                final fixedPxSize = double.tryParse(colWidth);
                return fixedPxSize != null
                    ? FixedTrackSize(fixedPxSize)
                    : const IntrinsicContentTrackSize();
              } else {
                return const IntrinsicContentTrackSize();
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
      List.generate(rows.length, (_) => const IntrinsicContentTrackSize());

  // Calculate column bounds
  int columnMax = 0;
  List<int> rowSpanOffsets = [];
  for (final row in rows) {
    final cols = row.children
            .whereType<TableCellElement>()
            .fold(0, (int value, child) => value + child.colspan) +
        rowSpanOffsets.fold<int>(0, (int offset, child) => child);
    columnMax = max(cols, columnMax);
    rowSpanOffsets = [
      ...rowSpanOffsets.map((value) => value - 1).where((value) => value > 0),
      ...row.children
          .whereType<TableCellElement>()
          .map((cell) => cell.rowspan - 1),
    ];
  }

  // Place the cells in the rows/columns
  final cells = <GridPlacement>[];
  final columnRowOffset = List.generate(columnMax, (_) => 0);
  final columnColspanOffset = List.generate(columnMax, (_) => 0);
  int rowi = 0;
  for (var row in rows) {
    int columni = 0;
    for (var child in row.children) {
      if (columni > columnMax - 1) {
        break;
      }
      if (child is TableCellElement) {
        while (columnRowOffset[columni] > 0) {
          columnRowOffset[columni] = columnRowOffset[columni] - 1;
          columni +=
              columnColspanOffset[columni].clamp(1, columnMax - columni - 1);
        }
        cells.add(GridPlacement(
          columnStart: columni,
          columnSpan: min(child.colspan, columnMax - columni),
          rowStart: rowi,
          rowSpan: min(child.rowspan, rows.length - rowi),
          child: CssBoxWidget(
            style: child.style
                .merge(row.style), //TODO padding/decoration(color/border)
            child: SizedBox.expand(
              child: Container(
                alignment: child.style.alignment ??
                    context.style.alignment ??
                    Alignment.centerLeft,
                child: CssBoxWidget.withInlineSpanChildren(
                  children: [context.parser.parseTree(context, child)],
                  style: child.style, //TODO updated this. Does it work?
                ),
              ),
            ),
          ),
        ));
        columnRowOffset[columni] = child.rowspan - 1;
        columnColspanOffset[columni] = child.colspan;
        columni += child.colspan;
      }
    }
    while (columni < columnRowOffset.length) {
      columnRowOffset[columni] = columnRowOffset[columni] - 1;
      columni++;
    }
    rowi++;
  }

  // Create column tracks (insofar there were no colgroups that already defined them)
  List<TrackSize> finalColumnSizes = columnSizes.take(columnMax).toList();
  finalColumnSizes += List.generate(max(0, columnMax - finalColumnSizes.length),
      (_) => const IntrinsicContentTrackSize());

  if (finalColumnSizes.isEmpty || rowSizes.isEmpty) {
    // No actual cells to show
    return const SizedBox();
  }

  return LayoutGrid(
    gridFit: GridFit.loose,
    columnSizes: finalColumnSizes,
    rowSizes: rowSizes,
    children: cells,
  );
}
