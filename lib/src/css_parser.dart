import 'dart:ui';

import 'package:csslib/visitor.dart' as css;
import 'package:csslib/parser.dart' as cssparser;
import 'package:flutter_html/style.dart';

Style declarationsToStyle(Map<String, List<css.Expression>> declarations) {
  Style style = new Style();
  declarations.forEach((property, value) {
    switch (property) {
      case 'background-color':
        style.backgroundColor = ExpressionMapping.expressionToColor(value.first);
        break;
      case 'color':
        style.color = ExpressionMapping.expressionToColor(value.first);
        break;
      case 'direction':
        style.direction = ExpressionMapping.expressionToDirection(value.first);
        break;
      case 'display':
        style.display = ExpressionMapping.expressionToDisplay(value.first);
        break;
      case 'font-family':
        style.fontFamily = ExpressionMapping.expressionToFontFamily(value.first);
        break;
      case 'font-size':
        style.fontSize = ExpressionMapping.expressionToFontSize(value.first);
        break;
      case 'font-style':
        style.fontStyle = ExpressionMapping.expressionToFontStyle(value.first);
        break;
      case 'font-weight':
        style.fontWeight = ExpressionMapping.expressionToFontWeight(value.first);
        break;
      case 'text-align':
        style.textAlign = ExpressionMapping.expressionToTextAlign(value.first);
        break;
    }
  });
  return style;
}

Style inlineCSSToStyle(String inlineStyle) {
  final sheet = cssparser.parse("*{$inlineStyle}");
  final declarations = DeclarationVisitor().getDeclarations(sheet);
  return declarationsToStyle(declarations);
}

class DeclarationVisitor extends css.Visitor {
  Map<String, List<css.Expression>> _result;
  String _currentProperty;

  Map<String, List<css.Expression>> getDeclarations(css.StyleSheet sheet) {
    _result = new Map<String, List<css.Expression>>();
    sheet.visit(this);
    return _result;
  }

  @override
  void visitDeclaration(css.Declaration node) {
    _currentProperty = node.property;
    _result[_currentProperty] = new List<css.Expression>();
    node.expression.visit(this);
  }

  @override
  void visitExpressions(css.Expressions node) {
    node.expressions.forEach((expression) {
      _result[_currentProperty].add(expression);
    });
  }
}

//Mapping functions
class ExpressionMapping {
  static Color expressionToColor(css.Expression value) {
    if (value is css.HexColorTerm) {
      return stringToColor(value.text);
    } else if (value is css.FunctionTerm) {
      if (value.text == 'rgba') {
        return rgbOrRgbaToColor(value.span.text);
      } else if (value.text == 'rgb') {
        return rgbOrRgbaToColor(value.span.text);
      }
    }
    return null;
  }

  static TextDirection expressionToDirection(css.Expression value) {
    if (value is css.LiteralTerm) {
      switch(value.text) {
        case "ltr":
          return TextDirection.ltr;
        case "rtl":
          return TextDirection.rtl;
      }
    }
    return TextDirection.ltr;
  }

  static Display expressionToDisplay(css.Expression value) {
    if (value is css.LiteralTerm) {
      switch(value.text) {
        case 'block':
          return Display.BLOCK;
        case 'inline-block':
          return Display.INLINE_BLOCK;
        case 'inline':
          return Display.INLINE;
        case 'list-item':
          return Display.LIST_ITEM;
        case 'none':
          return Display.NONE;
      }
    }
    return Display.INLINE;
  }

  static FontSize expressionToFontSize(css.Expression value) {
    if (value is css.NumberTerm) {
      return FontSize(double.tryParse(value.text), "");
    } else if (value is css.PercentageTerm) {
      return FontSize.percent(int.tryParse(value.text));
    } else if (value is css.EmTerm) {
      return FontSize.em(double.tryParse(value.text));
    } else if (value is css.RemTerm) {
      return FontSize.rem(double.tryParse(value.text));
    } else if (value is css.LiteralTerm) {
      switch (value.text) {
        case "xx-small":
          return FontSize.xxSmall;
        case "x-small":
          return FontSize.xSmall;
        case "small":
          return FontSize.small;
        case "medium":
          return FontSize.medium;
        case "large":
          return FontSize.large;
        case "x-large":
          return FontSize.xLarge;
        case "xx-large":
          return FontSize.xxLarge;
      }
      return FontSize(double.tryParse(value.text.replaceAll(new RegExp(r'\s+(\d+\.\d+)\s+'), '')), "");
    }
    return null;
  }

  static FontStyle expressionToFontStyle(css.Expression value) {
    if (value is css.LiteralTerm) {
      switch(value.text) {
        case "italic":
        case "oblique":
          return FontStyle.italic;
      }
      return FontStyle.normal;
    }
    return FontStyle.normal;
  }

  static FontWeight expressionToFontWeight(css.Expression value) {
    if (value is css.NumberTerm) {
      switch (value.text) {
        case "100":
          return FontWeight.w100;
        case "200":
          return FontWeight.w200;
        case "300":
          return FontWeight.w300;
        case "400":
          return FontWeight.w400;
        case "500":
          return FontWeight.w500;
        case "600":
          return FontWeight.w600;
        case "700":
          return FontWeight.w700;
        case "800":
          return FontWeight.w800;
        case "900":
          return FontWeight.w900;
      }
    } else if (value is css.LiteralTerm) {
      switch(value.text) {
        case "bold":
          return FontWeight.bold;
        case "bolder":
          return FontWeight.w900;
        case "lighter":
          return FontWeight.w200;
      }
      return FontWeight.normal;
    }
    return FontWeight.normal;
  }

  static String expressionToFontFamily(css.Expression value) {
    if (value is css.LiteralTerm) return value.text;
    return null;
  }

  static Color stringToColor(String _text) {
    var text = _text.replaceFirst('#', '');
    if (text.length == 3)
      text = text.replaceAllMapped(
          RegExp(r"[a-f]|\d"), (match) => '${match.group(0)}${match.group(0)}');
    int color = int.parse(text, radix: 16);

    if (color <= 0xffffff) {
      return new Color(color).withAlpha(255);
    } else {
      return new Color(color);
    }
  }

  static Color rgbOrRgbaToColor(String text) {
    final rgbaText = text.replaceAll(')', '').replaceAll(' ', '');
    try {
      final rgbaValues =
          rgbaText.split(',').map((value) => double.parse(value)).toList();
      if (rgbaValues.length == 4) {
        return Color.fromRGBO(
          rgbaValues[0].toInt(),
          rgbaValues[1].toInt(),
          rgbaValues[2].toInt(),
          rgbaValues[3],
        );
      } else if (rgbaValues.length == 3) {
        return Color.fromRGBO(
          rgbaValues[0].toInt(),
          rgbaValues[1].toInt(),
          rgbaValues[2].toInt(),
          1.0,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static TextAlign expressionToTextAlign(css.Expression value) {
    if (value is css.LiteralTerm) {
      switch(value.text) {
        case "center":
          return TextAlign.center;
        case "left":
          return TextAlign.left;
        case "right":
          return TextAlign.right;
        case "justify":
          return TextAlign.justify;
        case "end":
          return TextAlign.end;
        case "start":
          return TextAlign.start;
      }
    }
    return TextAlign.start;
  }
}
