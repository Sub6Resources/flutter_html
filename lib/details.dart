import 'package:flutter/material.dart';

class Details extends StatefulWidget {
  final Widget child;
  final Widget? summary;
  final Color color;

  const Details({
    Key? key,
    required this.child,
    this.summary,
    required this.color,
  }) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  bool hidden = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.color,
        ),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          InkWell(
            onTap: () => setState(() => hidden = !hidden),
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    hidden
                        ? Icons.keyboard_arrow_right
                        : Icons.keyboard_arrow_down,
                    color: widget.color,
                  ),
                  SizedBox(width: 5),
                  widget.summary ?? Text('Summary'),
                ],
              ),
            ),
          ),
          if (!hidden) ...[
            Divider(height: 1, thickness: 1, color: widget.color),
            Padding(
              padding: EdgeInsets.all(5),
              child: widget.child,
            ),
          ],
        ],
      ),
    );
  }
}
