import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai.dart';
import 'package:isolate/isolate.dart';
import 'package:highlight/highlight.dart' show highlight;
import 'package:crypto/crypto.dart';

typedef SetCodeLanguage = FutureOr<void> Function(String key, String value);
typedef GetCodeLanguage = FutureOr<String?> Function(String key);

class CodeBlock extends StatefulWidget {
  final String code;
  final String? language;
  final SetCodeLanguage? setCodeLanguage;
  final GetCodeLanguage? getCodeLanguage;
  final Color? borderColor;
  final int? maxLines;
  CodeBlock(this.code,
      {this.language,
      this.setCodeLanguage,
      this.getCodeLanguage,
      this.borderColor,
      this.maxLines});

  @override
  _CodeBlockState createState() => _CodeBlockState();
}

final _detectionMap = <String, String>{};
final _futureDetectionMap = <String, Future<String>>{};

class _CodeBlockState extends State<CodeBlock> {
  String language = 'plain';
  final _verticalScrollController = ScrollController();
  final _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.language == null) {
      // the first 250 chars should be enough to detect the code language, hopefully
      final codeFragment = widget.code.length > 250
          ? widget.code.substring(0, 250)
          : widget.code;
      final hashKey = sha1.convert(utf8.encode(codeFragment)).toString();
      if (_detectionMap[hashKey] != null) {
        language = _detectionMap[hashKey]!;
      } else {
        _futureDetectionMap[hashKey] ??= () async {
          if (widget.getCodeLanguage != null) {
            final lang = await widget.getCodeLanguage!(hashKey);
            if (lang != null) {
              return lang;
            }
          }
          return _autodetectLanguage(codeFragment);
        }();
        _futureDetectionMap[hashKey]!.then((String lang) async {
          _detectionMap[hashKey] = lang;
          if (widget.setCodeLanguage != null) {
            await widget.setCodeLanguage!(hashKey, lang);
          }
          if (mounted) {
            WidgetsBinding.instance?.addPostFrameCallback((_) {
              if (mounted) setState(() => language = lang);
            });
          }
        });
      }
    } else {
      language = widget.language!;
    }
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.borderColor ?? Colors.black,
        ),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(9.5)),
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: widget.maxLines == 1 ? 20 : 250),
          child: Scrollbar(
            isAlwaysShown: true,
            controller: _verticalScrollController,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: _verticalScrollController,
              child: Scrollbar(
                isAlwaysShown: true,
                controller: _horizontalScrollController,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _horizontalScrollController,
                  child: HighlightView(
                    widget.code.replaceAll(RegExp(r'\n$'), ''),
                    language: language,
                    tabSize: 4,
                    theme: monokaiTheme,
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: widget.maxLines == 1 ? 2.0 : 10.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AsyncMutex {
  Completer<void>? _completer;

  Future<void> lock() async {
    while (_completer != null) {
      await _completer!.future;
    }

    _completer = Completer<void>();
  }

  void unlock() {
    assert(_completer != null);
    final completer = _completer;
    _completer = null;
    completer!.complete();
  }
}

final _mutex = AsyncMutex();

Future<String> _autodetectLanguage(String code) async {
  await _mutex.lock();
  try {
    IsolateRunner isolate;
    try {
      isolate = await IsolateRunner.spawn();
    } on UnsupportedError {
      // web does not support isolates (yet)
      // we do not want to strain poor web, so we just render plain there
      return 'plain';
    }
    try {
      return (await isolate.run<String?, String>(
              _autodetectLanguageSync, code)) ??
          'plain';
    } finally {
      await isolate.close();
    }
  } finally {
    _mutex.unlock();
  }
}

String? _autodetectLanguageSync(String code) {
  final res = highlight.parse(code, autoDetection: true);
  return res.language;
}
