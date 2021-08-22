import 'package:flutter/material.dart';

extension TextSpanExtension on TextSpan {
  bool get isBlank => textContent.trim().isEmpty;

  String get textContent =>
      (text ?? '') +
      (children == null
          ? ''
          : children!
              .map((c) => c is TextSpan ? c.textContent : 'widget')
              .join(''));
}
