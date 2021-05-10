# flutter_html_table

Table widget for flutter_html.

This package renders table elements using the [`flutter_layout_grid`](https://pub.dev/packages/flutter_layout_grid) plugin.

When rendering table elements, the package tries to calculate the best fit for each element and size its cell accordingly. `Rowspan`s and `colspan`s are considered in this process, so cells that span across multiple rows and columns are rendered as expected. Heights are determined intrinsically to maintain an optimal aspect ratio for the cell.

#### Registering the `CustomRender`:

```dart
Widget html = Html(
  customRender: {
    tableMatcher(): tableRender(),
  }
);
```
