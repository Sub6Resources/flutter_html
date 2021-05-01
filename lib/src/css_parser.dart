import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:csslib/visitor.dart' as css;
import 'package:csslib/parser.dart' as cssparser;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/src/utils.dart';
import 'package:flutter_html/style.dart';

Style declarationsToStyle(Map<String?, List<css.Expression>> declarations) {
  Style style = new Style();
  declarations.forEach((property, value) {
    if (value.isNotEmpty) {
      switch (property) {
        case 'background-color':
          style.backgroundColor = ExpressionMapping.expressionToColor(value.first) ?? style.backgroundColor;
          break;
        case 'border':
          List<css.LiteralTerm?>? borderWidths = value.whereType<css.LiteralTerm>().toList();
          /// List<css.LiteralTerm> might include other values than the ones we want for [BorderSide.width], so make sure to remove those before passing it to [ExpressionMapping]
          borderWidths.removeWhere((element) => element != null && element.text != "thin" 
              && element.text != "medium" && element.text != "thick"
              && !(element is css.LengthTerm) && !(element is css.PercentageTerm) 
              && !(element is css.EmTerm) && !(element is css.RemTerm) 
              && !(element is css.NumberTerm)
          );
          List<css.Expression?>? borderColors = value.where((element) => ExpressionMapping.expressionToColor(element) != null).toList();
          List<css.LiteralTerm?>? potentialStyles = value.whereType<css.LiteralTerm>().toList();
          /// Currently doesn't matter, as Flutter only supports "solid" or "none", but may support more in the future.
          List<String> possibleBorderValues = ["dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset", "none", "hidden"];
          /// List<css.LiteralTerm> might include other values than the ones we want for [BorderSide.style], so make sure to remove those before passing it to [ExpressionMapping]
          potentialStyles.removeWhere((element) => element != null && !possibleBorderValues.contains(element.text));
          List<css.LiteralTerm?>? borderStyles = potentialStyles;
          style.border = ExpressionMapping.expressionToBorder(borderWidths, borderStyles, borderColors);
          break;
        case 'color':
          style.color = ExpressionMapping.expressionToColor(value.first) ?? style.color;
          break;
        case 'direction':
          style.direction = ExpressionMapping.expressionToDirection(value.first);
          break;
        case 'display':
          style.display = ExpressionMapping.expressionToDisplay(value.first);
          break;
        case 'line-height':
          style.lineHeight = ExpressionMapping.expressionToLineHeight(value.first);
          break;
        case 'font-family':
          style.fontFamily = ExpressionMapping.expressionToFontFamily(value.first) ?? style.fontFamily;
          break;
        case 'font-feature-settings':
          style.fontFeatureSettings = ExpressionMapping.expressionToFontFeatureSettings(value);
          break;
        case 'font-size':
          style.fontSize = ExpressionMapping.expressionToFontSize(value.first) ?? style.fontSize;
          break;
        case 'font-style':
          style.fontStyle = ExpressionMapping.expressionToFontStyle(value.first);
          break;
        case 'font-weight':
          style.fontWeight = ExpressionMapping.expressionToFontWeight(value.first);
          break;
        case 'list-style-type':
          if (value.first is css.LiteralTerm) {
            style.listStyleType = ExpressionMapping.expressionToListStyleType(value.first as css.LiteralTerm) ?? style.listStyleType;
          }
          break;
        case 'text-align':
          style.textAlign = ExpressionMapping.expressionToTextAlign(value.first);
          break;
        case 'text-decoration':
          List<css.LiteralTerm?>? textDecorationList = value.whereType<css.LiteralTerm>().toList();
          /// List<css.LiteralTerm> might include other values than the ones we want for [textDecorationList], so make sure to remove those before passing it to [ExpressionMapping]
          textDecorationList.removeWhere((element) => element != null && element.text != "none"
              && element.text != "overline" && element.text != "underline" && element.text != "line-through");
          List<css.Expression?>? nullableList = value;
          css.Expression? textDecorationColor;
          textDecorationColor = nullableList.firstWhereOrNull(
                  (element) => element is css.HexColorTerm || element is css.FunctionTerm);
          List<css.LiteralTerm?>? potentialStyles = value.whereType<css.LiteralTerm>().toList();
          /// List<css.LiteralTerm> might include other values than the ones we want for [textDecorationStyle], so make sure to remove those before passing it to [ExpressionMapping]
          potentialStyles.removeWhere((element) => element != null && element.text != "solid"
              && element.text != "double" && element.text != "dashed" && element.text != "dotted" && element.text != "wavy");
          css.LiteralTerm? textDecorationStyle = potentialStyles.isNotEmpty ? potentialStyles.last : null;
          style.textDecoration = ExpressionMapping.expressionToTextDecorationLine(textDecorationList);
          if (textDecorationColor != null) style.textDecorationColor = ExpressionMapping.expressionToColor(textDecorationColor)
              ?? style.textDecorationColor;
          if (textDecorationStyle != null) style.textDecorationStyle = ExpressionMapping.expressionToTextDecorationStyle(textDecorationStyle);
          break;
        case 'text-decoration-color':
          style.textDecorationColor = ExpressionMapping.expressionToColor(value.first) ?? style.textDecorationColor;
          break;
        case 'text-decoration-line':
          List<css.LiteralTerm?>? textDecorationList = value.whereType<css.LiteralTerm>().toList();
          style.textDecoration = ExpressionMapping.expressionToTextDecorationLine(textDecorationList);
          break;
        case 'text-decoration-style':
          style.textDecorationStyle = ExpressionMapping.expressionToTextDecorationStyle(value.first as css.LiteralTerm);
          break;
        case 'text-shadow':
          style.textShadow = ExpressionMapping.expressionToTextShadow(value);
          break;
      }
    }
  });
  return style;
}

Style inlineCSSToStyle(String? inlineStyle) {
  final sheet = cssparser.parse("*{$inlineStyle}");
  final declarations = DeclarationVisitor().getDeclarations(sheet)!;
  return declarationsToStyle(declarations);
}

class DeclarationVisitor extends css.Visitor {
  Map<String?, List<css.Expression>>? _result;
  String? _currentProperty;

  Map<String?, List<css.Expression>>? getDeclarations(css.StyleSheet sheet) {
    _result = new Map<String?, List<css.Expression>>();
    sheet.visit(this);
    return _result;
  }

  @override
  void visitDeclaration(css.Declaration node) {
    _currentProperty = node.property;
    _result![_currentProperty] = <css.Expression>[];
    node.expression!.visit(this);
  }

  @override
  void visitExpressions(css.Expressions node) {
    node.expressions.forEach((expression) {
      _result![_currentProperty]!.add(expression);
    });
  }
}

//Mapping functions
class ExpressionMapping {

  static Border expressionToBorder(List<css.Expression?>? borderWidths, List<css.LiteralTerm?>? borderStyles, List<css.Expression?>? borderColors) {
    CustomBorderSide left = CustomBorderSide();
    CustomBorderSide top = CustomBorderSide();
    CustomBorderSide right = CustomBorderSide();
    CustomBorderSide bottom = CustomBorderSide();
    if (borderWidths != null && borderWidths.isNotEmpty) {
      top.width = expressionToBorderWidth(borderWidths.first);
      if (borderWidths.length == 4) {
        right.width = expressionToBorderWidth(borderWidths[1]);
        bottom.width = expressionToBorderWidth(borderWidths[2]);
        left.width = expressionToBorderWidth(borderWidths.last);
      }
      if (borderWidths.length == 3) {
        left.width = expressionToBorderWidth(borderWidths[1]);
        right.width = expressionToBorderWidth(borderWidths[1]);
        bottom.width = expressionToBorderWidth(borderWidths.last);
      }
      if (borderWidths.length == 2) {
        bottom.width = expressionToBorderWidth(borderWidths.first);
        left.width = expressionToBorderWidth(borderWidths.last);
        right.width = expressionToBorderWidth(borderWidths.last);
      }
      if (borderWidths.length == 1) {
        bottom.width = expressionToBorderWidth(borderWidths.first);
        left.width = expressionToBorderWidth(borderWidths.first);
        right.width = expressionToBorderWidth(borderWidths.first);
      }
    }
    if (borderStyles != null && borderStyles.isNotEmpty) {
      top.style = expressionToBorderStyle(borderStyles.first);
      if (borderStyles.length == 4) {
        right.style = expressionToBorderStyle(borderStyles[1]);
        bottom.style = expressionToBorderStyle(borderStyles[2]);
        left.style = expressionToBorderStyle(borderStyles.last);
      }
      if (borderStyles.length == 3) {
        left.style = expressionToBorderStyle(borderStyles[1]);
        right.style = expressionToBorderStyle(borderStyles[1]);
        bottom.style = expressionToBorderStyle(borderStyles.last);
      }
      if (borderStyles.length == 2) {
        bottom.style = expressionToBorderStyle(borderStyles.first);
        left.style = expressionToBorderStyle(borderStyles.last);
        right.style = expressionToBorderStyle(borderStyles.last);
      }
      if (borderStyles.length == 1) {
        bottom.style = expressionToBorderStyle(borderStyles.first);
        left.style = expressionToBorderStyle(borderStyles.first);
        right.style = expressionToBorderStyle(borderStyles.first);
      }
    }
    if (borderColors != null && borderColors.isNotEmpty) {
      top.color = expressionToColor(borderColors.first);
      if (borderColors.length == 4) {
        right.color = expressionToColor(borderColors[1]);
        bottom.color = expressionToColor(borderColors[2]);
        left.color = expressionToColor(borderColors.last);
      }
      if (borderColors.length == 3) {
        left.color = expressionToColor(borderColors[1]);
        right.color = expressionToColor(borderColors[1]);
        bottom.color = expressionToColor(borderColors.last);
      }
      if (borderColors.length == 2) {
        bottom.color = expressionToColor(borderColors.first);
        left.color = expressionToColor(borderColors.last);
        right.color = expressionToColor(borderColors.last);
      }
      if (borderColors.length == 1) {
        bottom.color = expressionToColor(borderColors.first);
        left.color = expressionToColor(borderColors.first);
        right.color = expressionToColor(borderColors.first);
      }
    }
    return Border(
        top: BorderSide(width: top.width, color: top.color ?? Colors.black, style: top.style),
        right: BorderSide(width: right.width, color: right.color ?? Colors.black, style: right.style),
        bottom: BorderSide(width: bottom.width, color: bottom.color ?? Colors.black, style: bottom.style),
        left: BorderSide(width: left.width, color: left.color ?? Colors.black, style: left.style)
    );
  }

  static double expressionToBorderWidth(css.Expression? value) {
    if (value is css.NumberTerm) {
      return double.tryParse(value.text) ?? 1.0;
    } else if (value is css.PercentageTerm) {
      return (double.tryParse(value.text) ?? 400) / 100;
    } else if (value is css.EmTerm) {
      return double.tryParse(value.text) ?? 1.0;
    } else if (value is css.RemTerm) {
      return double.tryParse(value.text) ?? 1.0;
    } else if (value is css.LengthTerm) {
      return double.tryParse(value.text.replaceAll(new RegExp(r'\s+(\d+\.\d+)\s+'), '')) ?? 1.0;
    } else if (value is css.LiteralTerm) {
      switch (value.text) {
        case "thin":
          return 2.0;
        case "medium":
          return 4.0;
        case "thick":
          return 6.0;
      }
    }
    return 4.0;
  }

  static BorderStyle expressionToBorderStyle(css.LiteralTerm? value) {
    if (value != null && value.text != "none" && value.text != "hidden") {
      return BorderStyle.solid;
    }
    return BorderStyle.none;
  }

  static Color? expressionToColor(css.Expression? value) {
    if (value != null) {
      if (value is css.HexColorTerm) {
        return stringToColor(value.text);
      } else if (value is css.FunctionTerm) {
        if (value.text == 'rgba' || value.text == 'rgb') {
          return rgbOrRgbaToColor(value.span!.text);
        } else if (value.text == 'hsla' || value.text == 'hsl') {
          return hslToRgbToColor(value.span!.text);
        }
      } else if (value is css.LiteralTerm) {
        return namedColorToColor(value.text);
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

  static List<FontFeature> expressionToFontFeatureSettings(List<css.Expression> value) {
    List<FontFeature> fontFeatures = [];
    for (int i = 0; i < value.length; i++) {
      css.Expression exp = value[i];
      if (exp is css.LiteralTerm) {
        if (exp.text != "on" && exp.text != "off" && exp.text != "1" && exp.text != "0") {
          if (i < value.length - 1) {
            css.Expression nextExp = value[i+1];
            if (nextExp is css.LiteralTerm && (nextExp.text == "on" || nextExp.text == "off" || nextExp.text == "1" || nextExp.text == "0")) {
              fontFeatures.add(FontFeature(exp.text, nextExp.text == "on" || nextExp.text == "1" ? 1 : 0));
            } else {
              fontFeatures.add(FontFeature.enable(exp.text));
            }
          } else {
            fontFeatures.add(FontFeature.enable(exp.text));
          }
        }
      }
    }
    List<FontFeature> finalFontFeatures = fontFeatures.toSet().toList();
    return finalFontFeatures;
  }

  static FontSize? expressionToFontSize(css.Expression value) {
    if (value is css.NumberTerm) {
      return FontSize(double.tryParse(value.text));
    } else if (value is css.PercentageTerm) {
      return FontSize.percent(int.tryParse(value.text)!);
    } else if (value is css.EmTerm) {
      return FontSize.em(double.tryParse(value.text));
    } else if (value is css.RemTerm) {
      return FontSize.rem(double.tryParse(value.text)!);
    } else if (value is css.LengthTerm) {
      return FontSize(double.tryParse(value.text.replaceAll(new RegExp(r'\s+(\d+\.\d+)\s+'), '')));
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

  static String? expressionToFontFamily(css.Expression value) {
    if (value is css.LiteralTerm) return value.text;
    return null;
  }

  static LineHeight expressionToLineHeight(css.Expression value) {
    if (value is css.NumberTerm) {
      return LineHeight.number(double.tryParse(value.text)!);
    } else if (value is css.PercentageTerm) {
      return LineHeight.percent(double.tryParse(value.text)!);
    } else if (value is css.EmTerm) {
      return LineHeight.em(double.tryParse(value.text)!);
    } else if (value is css.RemTerm) {
      return LineHeight.rem(double.tryParse(value.text)!);
    } else if (value is css.LengthTerm) {
      return LineHeight(double.tryParse(value.text.replaceAll(new RegExp(r'\s+(\d+\.\d+)\s+'), '')), units: "length");
    }
    return LineHeight.normal;
  }

  static ListStyleType? expressionToListStyleType(css.LiteralTerm value) {
    switch (value.text) {
      case 'disc':
        return ListStyleType.DISC;
      case 'circle':
        return ListStyleType.CIRCLE;
      case 'decimal':
        return ListStyleType.DECIMAL;
      case 'lower-alpha':
        return ListStyleType.LOWER_ALPHA;
      case 'lower-latin':
        return ListStyleType.LOWER_LATIN;
      case 'lower-roman':
        return ListStyleType.LOWER_ROMAN;
      case 'square':
        return ListStyleType.SQUARE;
      case 'upper-alpha':
        return ListStyleType.UPPER_ALPHA;
      case 'upper-latin':
        return ListStyleType.UPPER_LATIN;
      case 'upper-roman':
        return ListStyleType.UPPER_ROMAN;
    }
    return null;
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

  static TextDecoration expressionToTextDecorationLine(List<css.LiteralTerm?> value) {
    List<TextDecoration> decorationList = [];
    for (css.LiteralTerm? term in value) {
      if (term != null) {
        switch(term.text) {
          case "overline":
            decorationList.add(TextDecoration.overline);
            break;
          case "underline":
            decorationList.add(TextDecoration.underline);
            break;
          case "line-through":
            decorationList.add(TextDecoration.lineThrough);
            break;
          default:
            decorationList.add(TextDecoration.none);
            break;
        }
      }
    }
    if (decorationList.contains(TextDecoration.none)) decorationList = [TextDecoration.none];
    return TextDecoration.combine(decorationList);
  }

  static TextDecorationStyle expressionToTextDecorationStyle(css.LiteralTerm value) {
    switch(value.text) {
      case "wavy":
        return TextDecorationStyle.wavy;
      case "dotted":
        return TextDecorationStyle.dotted;
      case "dashed":
        return TextDecorationStyle.dashed;
      case "double":
        return TextDecorationStyle.double;
      default:
        return TextDecorationStyle.solid;
    }
  }

  static List<Shadow> expressionToTextShadow(List<css.Expression> value) {
    List<Shadow> shadow = [];
    List<int> indices = [];
    List<List<css.Expression>> valueList = [];
    for (css.Expression e in value) {
      if (e is css.OperatorComma) {
        indices.add(value.indexOf(e));
      }
    }
    indices.add(value.length);
    int previousIndex = 0;
    for (int i in indices) {
      valueList.add(value.sublist(previousIndex, i));
      previousIndex = i + 1;
    }
    for (List<css.Expression> list in valueList) {
      css.Expression exp = list[0];
      css.Expression exp2 = list[1];
      css.LiteralTerm? exp3 = list.length > 2 ? list[2] as css.LiteralTerm? : null;
      css.LiteralTerm? exp4 = list.length > 3 ? list[3] as css.LiteralTerm? : null;
      RegExp nonNumberRegex = RegExp(r'\s+(\d+\.\d+)\s+');
      if (exp is css.LiteralTerm && exp2 is css.LiteralTerm) {
        if (exp3 != null && ExpressionMapping.expressionToColor(exp3) != null) {
          shadow.add(Shadow(
              color: expressionToColor(exp3)!,
              offset: Offset(double.tryParse(exp.text.replaceAll(nonNumberRegex, ''))!, double.tryParse(exp2.text.replaceAll(nonNumberRegex, ''))!)
          ));
        } else if (exp3 != null && exp3 is css.LiteralTerm) {
          if (exp4 != null && ExpressionMapping.expressionToColor(exp4) != null) {
            shadow.add(Shadow(
                color: expressionToColor(exp4)!,
                offset: Offset(double.tryParse(exp.text.replaceAll(nonNumberRegex, ''))!, double.tryParse(exp2.text.replaceAll(nonNumberRegex, ''))!),
                blurRadius: double.tryParse(exp3.text.replaceAll(nonNumberRegex, ''))!
            ));
          } else {
            shadow.add(Shadow(
                offset: Offset(double.tryParse(exp.text.replaceAll(nonNumberRegex, ''))!, double.tryParse(exp2.text.replaceAll(nonNumberRegex, ''))!),
                blurRadius: double.tryParse(exp3.text.replaceAll(nonNumberRegex, ''))!
            ));
          }
        } else {
          shadow.add(Shadow(
              offset: Offset(double.tryParse(exp.text.replaceAll(nonNumberRegex, ''))!, double.tryParse(exp2.text.replaceAll(nonNumberRegex, ''))!)
          ));
        }
      }
    }
    List<Shadow> finalShadows = shadow.toSet().toList();
    return finalShadows;
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

  static Color? rgbOrRgbaToColor(String text) {
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

  static Color hslToRgbToColor(String text) {
    final hslText = text.replaceAll(')', '').replaceAll(' ', '');
    final hslValues = hslText.split(',').toList();
    List<double?> parsedHsl = [];
    hslValues.forEach((element) {
      if (element.contains("%") && double.tryParse(element.replaceAll("%", "")) != null) {
        parsedHsl.add(double.tryParse(element.replaceAll("%", ""))! * 0.01);
      } else {
        if (element != hslValues.first && (double.tryParse(element) == null || double.tryParse(element)! > 1)) {
          parsedHsl.add(null);
        } else {
          parsedHsl.add(double.tryParse(element));
        }
      }
    });
    if (parsedHsl.length == 4 && !parsedHsl.contains(null)) {
      return HSLColor.fromAHSL(parsedHsl.last!, parsedHsl.first!, parsedHsl[1]!, parsedHsl[2]!).toColor();
    } else if (parsedHsl.length == 3 && !parsedHsl.contains(null)) {
      return HSLColor.fromAHSL(1.0, parsedHsl.first!, parsedHsl[1]!, parsedHsl.last!).toColor();
    } else return Colors.black;
  }

  static Color? namedColorToColor(String text) {
     String namedColor = namedColors.keys.firstWhere((element) => element.toLowerCase() == text.toLowerCase(), orElse: () => "");
     if (namedColor != "") {
       return stringToColor(namedColors[namedColor]!);
     } else return null;
  }
}
