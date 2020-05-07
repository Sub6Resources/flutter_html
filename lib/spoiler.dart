import 'package:flutter/material.dart';

class Spoiler extends StatefulWidget {
  final Widget child;
  final String reason;

  const Spoiler({
    Key key,
    this.child,
    this.reason,
  }) : super(key: key);

  @override
  _SpoilerState createState() => _SpoilerState();
}

class _SpoilerState extends State<Spoiler> {
  bool hidden = true;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Wrap(
        children: <Widget>[
          if (this.widget.reason != null && this.widget.reason.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(
                top: DefaultTextStyle.of(context).style.fontSize * 0.15,
              ),
              child: Text("(${this.widget.reason})",
                style: TextStyle(
                  fontSize: DefaultTextStyle.of(context).style.fontSize * 0.7,
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
      onTap: () => setState(() {
        hidden = !hidden;
      }),
    );
  }
}
