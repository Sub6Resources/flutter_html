import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/src/anchor.dart';
import 'package:flutter_html/src/html_elements.dart';
import 'package:flutter_html/src/styled_element.dart';
import 'package:flutter_html/src/utils.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:html/dom.dart' as dom;

/// A [LayoutElement] is an element that breaks the normal Inline flow of
/// an html document with a more complex layout. LayoutElements handle
abstract class LayoutElement extends StyledElement {
  LayoutElement({
    String name = "[[No Name]]",
    required List<StyledElement> children,
    String? elementId,
    dom.Element? node,
  }) : super(name: name, children: children, style: Style(), node: node, elementId: elementId ?? "[[No ID]]");

  Widget? toWidget(RenderContext context);
}

class TableLayoutElement extends LayoutElement {
  TableLayoutElement({
    required String name,
    required List<StyledElement> children,
    required dom.Element node,
  }) : super(name: name, children: children, node: node, elementId: node.id);

  @override
  Widget toWidget(RenderContext context) {
    return Container(
      key: AnchorKey.of(context.parser.key, this),
      padding: style.padding?.nonNegative,
      margin: style.margin?.nonNegative,
      alignment: style.alignment,
      decoration: BoxDecoration(
        color: style.backgroundColor,
        border: style.border,
      ),
      width: style.width,
      height: style.height,
      child: LayoutBuilder(builder: (_, constraints) => _layoutCells(context, constraints)),
    );
  }

  Widget _layoutCells(RenderContext context, BoxConstraints constraints) {
    final rows = <TableRowLayoutElement>[];
    List<TrackSize> columnSizes = <TrackSize>[];
    for (var child in children) {
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
    final rowSizes = List.generate(rows.length, (_) => IntrinsicContentTrackSize());

    // Calculate column bounds
    int columnMax = 0;
    List<int> rowSpanOffsets = [];
    for (final row in rows) {
      final cols = row.children.whereType<TableCellElement>().fold(0, (int value, child) => value + child.colspan) +
          rowSpanOffsets.fold<int>(0, (int offset, child) => child);
      columnMax = max(cols, columnMax);
      rowSpanOffsets = [
        ...rowSpanOffsets.map((value) => value - 1).where((value) => value > 0),
        ...row.children.whereType<TableCellElement>().map((cell) => cell.rowspan - 1),
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
        if (columni > columnMax - 1 ) {
          break;
        }
        if (child is TableCellElement) {
          while (columnRowOffset[columni] > 0) {
            columnRowOffset[columni] = columnRowOffset[columni] - 1;
            columni += columnColspanOffset[columni].clamp(1, columnMax - columni - 1);
          }
          cells.add(GridPlacement(
            child: Container(
              width: child.style.width ?? double.infinity,
              height: child.style.height,
              padding: child.style.padding?.nonNegative ?? row.style.padding?.nonNegative,
              decoration: BoxDecoration(
                color: child.style.backgroundColor ?? row.style.backgroundColor,
                border: child.style.border ?? row.style.border,
              ),
              child: SizedBox.expand(
                child: Container(
                  alignment: child.style.alignment ??
                      style.alignment ??
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
            columnSpan: min(child.colspan, columnMax - columni),
            rowStart: rowi,
            rowSpan: min(child.rowspan, rows.length - rowi),
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
    finalColumnSizes += List.generate(
        max(0, columnMax - finalColumnSizes.length),
        (_) => IntrinsicContentTrackSize());

    if (finalColumnSizes.isEmpty || rowSizes.isEmpty) {
      // No actual cells to show
      return SizedBox();
    }

    return LayoutGrid(
      gridFit: GridFit.loose,
      columnSizes: finalColumnSizes,
      rowSizes: rowSizes,
      children: cells,
    );
  }
}

class TableSectionLayoutElement extends LayoutElement {
  TableSectionLayoutElement({
    required String name,
    required List<StyledElement> children,
  }) : super(name: name, children: children);

  @override
  Widget toWidget(RenderContext context) {
    // Not rendered; TableLayoutElement will instead consume its children
    return Container(child: Text("TABLE SECTION"));
  }
}

class TableRowLayoutElement extends LayoutElement {
  TableRowLayoutElement({
    required String name,
    required List<StyledElement> children,
    required dom.Element node,
  }) : super(name: name, children: children, node: node);

  @override
  Widget toWidget(RenderContext context) {
    // Not rendered; TableLayoutElement will instead consume its children
    return Container(child: Text("TABLE ROW"));
  }
}

class TableCellElement extends StyledElement {
  int colspan = 1;
  int rowspan = 1;

  TableCellElement({
    required String name,
    required String elementId,
    required List<String> elementClasses,
    required List<StyledElement> children,
    required Style style,
    required dom.Element node,
  }) : super(name: name, elementId: elementId, elementClasses: elementClasses, children: children, style: style, node: node) {
    colspan = _parseSpan(this, "colspan");
    rowspan = _parseSpan(this, "rowspan");
  }

  static int _parseSpan(StyledElement element, String attributeName) {
    final spanValue = element.attributes[attributeName];
    return spanValue == null ? 1 : int.tryParse(spanValue) ?? 1;
  }
}

TableCellElement parseTableCellElement(
  dom.Element element,
  List<StyledElement> children,
) {
  final cell = TableCellElement(
    name: element.localName!,
    elementId: element.id,
    elementClasses: element.classes.toList(),
    children: children,
    node: element,
    style: Style(),
  );
  if (element.localName == "th") {
    cell.style = Style(
      fontWeight: FontWeight.bold,
    );
  }
  return cell;
}

class TableStyleElement extends StyledElement {
  TableStyleElement({
    required String name,
    required List<StyledElement> children,
    required Style style,
    required dom.Element node,
  }) : super(name: name, children: children, style: style, node: node);
}

TableStyleElement parseTableDefinitionElement(
  dom.Element element,
  List<StyledElement> children,
) {
  switch (element.localName) {
    case "colgroup":
    case "col":
      return TableStyleElement(
        name: element.localName!,
        children: children,
        node: element,
        style: Style(),
      );
    default:
      return TableStyleElement(
        name: "[[No Name]]",
        children: children,
        node: element,
        style: Style(),
      );
  }
}

class DetailsContentElement extends LayoutElement {
  List<dom.Element> elementList;

  DetailsContentElement({
    required String name,
    required List<StyledElement> children,
    required dom.Element node,
    required this.elementList,
  }) : super(name: name, node: node, children: children, elementId: node.id);

  @override
  Widget toWidget(RenderContext context) {
    List<InlineSpan>? childrenList = children.map((tree) => context.parser.parseTree(context, tree)).toList();
    List<InlineSpan> toRemove = [];
    for (InlineSpan child in childrenList) {
      if (child is TextSpan && child.text != null && child.text!.trim().isEmpty) {
        toRemove.add(child);
      }
    }
    for (InlineSpan child in toRemove) {
      childrenList.remove(child);
    }
    InlineSpan? firstChild = childrenList.isNotEmpty == true ? childrenList.first : null;
    return ExpansionTile(
        key: AnchorKey.of(context.parser.key, this),
        expandedAlignment: Alignment.centerLeft,
        title: elementList.isNotEmpty == true && elementList.first.localName == "summary" ? StyledText(
          textSpan: TextSpan(
            style: style.generateTextStyle(),
            children: firstChild == null ? [] : [firstChild],
          ),
          style: style,
          renderContext: context,
        ) : Text("Details"),
        children: [
          StyledText(
            textSpan: TextSpan(
              style: style.generateTextStyle(),
              children: getChildren(childrenList, context, elementList.isNotEmpty == true && elementList.first.localName == "summary" ? firstChild : null)
            ),
            style: style,
            renderContext: context,
          ),
        ]
    );
  }

  List<InlineSpan> getChildren(List<InlineSpan> children, RenderContext context, InlineSpan? firstChild) {
    if (firstChild != null) children.removeAt(0);
    return children;
  }
}

class EmptyLayoutElement extends LayoutElement {
  EmptyLayoutElement({required String name}) : super(name: name, children: []);

  @override
  Widget? toWidget(_) => null;
}

LayoutElement parseLayoutElement(
    dom.Element element,
    List<StyledElement> children,
) {
  switch (element.localName) {
    case "details":
      if (children.isEmpty) {
        return EmptyLayoutElement(name: "empty");
      }
      return DetailsContentElement(
          node: element,
          name: element.localName!,
          children: children,
          elementList: element.children
      );
    case "table":
      return TableLayoutElement(
        name: element.localName!,
        children: children,
        node: element,
      );
    case "thead":
    case "tbody":
    case "tfoot":
      return TableSectionLayoutElement(
        name: element.localName!,
        children: children,
      );
    case "tr":
      return TableRowLayoutElement(
        name: element.localName!,
        children: children,
        node: element,
      );
    default:
      return TableLayoutElement(
          children: children,
          name: "[[No Name]]",
          node: element
      );
  }
}
