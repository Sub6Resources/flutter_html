import 'dart:ui';

import 'package:csslib/visitor.dart' as css;
import 'package:csslib/parser.dart' as cssparser;
import 'package:flutter/cupertino.dart';
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
      case 'line-height':
        style.lineHeight = ExpressionMapping.expressionToLineHeight(value.first);
        break;
      case 'font-family':
        style.fontFamily = ExpressionMapping.expressionToFontFamily(value.first);
        break;
      case 'font-feature-settings':
        style.fontFeatureSettings = ExpressionMapping.expressionToFontFeatureSettings(value);
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
      case 'text-decoration':
        List<css.LiteralTerm> textDecorationList  = value.whereType<css.LiteralTerm>().toList();
        /// List<css.LiteralTerm> might include other values than the ones we want for [textDecorationList], so make sure to remove those before passing it to [ExpressionMapping]
        textDecorationList.removeWhere((element) => element.text != "none" && element.text != "overline" && element.text != "underline" && element.text != "line-through");
        css.Expression textDecorationColor = value.firstWhere((element) => element is css.HexColorTerm || element is css.FunctionTerm, orElse: null);
        List<css.LiteralTerm> temp = value.whereType<css.LiteralTerm>().toList();
        /// List<css.LiteralTerm> might include other values than the ones we want for [textDecorationStyle], so make sure to remove those before passing it to [ExpressionMapping]
        temp.removeWhere((element) => element.text != "solid" && element.text != "double" && element.text != "dashed" && element.text != "dotted" && element.text != "wavy");
        css.LiteralTerm textDecorationStyle = temp.last ?? null;
        style.textDecoration = ExpressionMapping.expressionToTextDecorationLine(textDecorationList);
        if (textDecorationColor != null) style.textDecorationColor = ExpressionMapping.expressionToColor(textDecorationColor);
        if (textDecorationStyle != null) style.textDecorationStyle = ExpressionMapping.expressionToTextDecorationStyle(textDecorationStyle);
        break;
      case 'text-decoration-color':
        style.textDecorationColor = ExpressionMapping.expressionToColor(value.first);
        break;
      case 'text-decoration-line':
        style.textDecoration = ExpressionMapping.expressionToTextDecorationLine(value);
        break;
      case 'text-decoration-style':
        style.textDecorationStyle = ExpressionMapping.expressionToTextDecorationStyle(value.first);
        break;
      case 'text-shadow':
        style.textShadow = ExpressionMapping.expressionToTextShadow(value);
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
    _result[_currentProperty] = <css.Expression>[];
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

  static FontSize expressionToFontSize(css.Expression value) {
    if (value is css.NumberTerm) {
      return FontSize(double.tryParse(value.text));
    } else if (value is css.PercentageTerm) {
      return FontSize.percent(int.tryParse(value.text));
    } else if (value is css.EmTerm) {
      return FontSize.em(double.tryParse(value.text));
    } else if (value is css.RemTerm) {
      return FontSize.rem(double.tryParse(value.text));
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

  static String expressionToFontFamily(css.Expression value) {
    if (value is css.LiteralTerm) return value.text;
    return null;
  }

  static LineHeight expressionToLineHeight(css.Expression value) {
    if (value is css.NumberTerm) {
      return LineHeight.number(double.tryParse(value.text));
    } else if (value is css.PercentageTerm) {
      return LineHeight.percent(double.tryParse(value.text));
    } else if (value is css.EmTerm) {
      return LineHeight.em(double.tryParse(value.text));
    } else if (value is css.RemTerm) {
      return LineHeight.rem(double.tryParse(value.text));
    } else if (value is css.LengthTerm) {
      return LineHeight(double.tryParse(value.text.replaceAll(new RegExp(r'\s+(\d+\.\d+)\s+'), '')), units: "length");
    }
    return LineHeight.normal;
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

  static TextDecoration expressionToTextDecorationLine(List<css.LiteralTerm> value) {
    List<TextDecoration> decorationList = [];
    for (css.LiteralTerm term in value) {
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
      css.LiteralTerm exp3 = list.length > 2 ? list[2] : null;
      css.LiteralTerm exp4 = list.length > 3 ? list[3] : null;
      RegExp nonNumberRegex = RegExp(r'\s+(\d+\.\d+)\s+');
      if (exp is css.LiteralTerm && exp2 is css.LiteralTerm) {
        if (exp3 != null && (exp3 is css.HexColorTerm || exp3 is css.FunctionTerm)) {
          shadow.add(Shadow(
              color: expressionToColor(exp3), 
              offset: Offset(double.tryParse(exp.text.replaceAll(nonNumberRegex, '')), double.tryParse(exp2.text.replaceAll(nonNumberRegex, '')))
          ));
        } else if (exp3 != null && exp3 is css.LiteralTerm) {
          if (exp4 != null && (exp4 is css.HexColorTerm || exp4 is css.FunctionTerm)) {
            shadow.add(Shadow(
                color: expressionToColor(exp4), 
                offset: Offset(double.tryParse(exp.text.replaceAll(nonNumberRegex, '')), double.tryParse(exp2.text.replaceAll(nonNumberRegex, ''))), 
                blurRadius: double.tryParse(exp3.text.replaceAll(nonNumberRegex, ''))
            ));
          } else {
            shadow.add(Shadow(
                offset: Offset(double.tryParse(exp.text.replaceAll(nonNumberRegex, '')), double.tryParse(exp2.text.replaceAll(nonNumberRegex, ''))), 
                blurRadius: double.tryParse(exp3.text.replaceAll(nonNumberRegex, ''))
            ));
          }
        } else {
          shadow.add(Shadow(
              offset: Offset(double.tryParse(exp.text.replaceAll(nonNumberRegex, '')), double.tryParse(exp2.text.replaceAll(nonNumberRegex, '')))
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
}
