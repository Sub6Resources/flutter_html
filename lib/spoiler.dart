import 'package:flutter/material.dart';

class Spoiler extends StatefulWidget {
  final Widget child;
  final String? reason;

  const Spoiler({
    Key? key,
    required this.child,
    this.reason,
  }) : super(key: key);

  @override
  _SpoilerState createState() => _SpoilerState();
}

class _SpoilerState extends State<Spoiler> {
  bool hidden = true;

  @override
  Widget build(BuildContext context) {
    final fontSize = DefaultTextStyle.of(context).style.fontSize ?? 14.0;
    return InkWell(
      child: AbsorbPointer(
        absorbing: hidden,
        child: Wrap(
          children: <Widget>[
            if (this.widget.reason?.isNotEmpty ?? false)
              Padding(
                padding: EdgeInsets.only(
                  top: fontSize * 0.15,
                ),
                child: Text(
                  "(${this.widget.reason})",
                  style: TextStyle(
                    fontSize: fontSize * 0.7,
                  ),
                ),
              ),
            Container(
              color: hidden ? Colors.black : null,
              child: Opacity(
                opacity: hidden ? 0.0 : 1.0,
                child: this.widget.child,
              ),
            ),
          ],
        ),
      ),
      onTap: () => setState(() {
        hidden = !hidden;
      }),
    );
  }
}
