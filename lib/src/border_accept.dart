import 'package:flutter/material.dart';

import 'dotted_border.dart';
import 'tab.dart';

class WindowAcceptRegion extends StatefulWidget {
  const WindowAcceptRegion({
    Key key,
    this.onAccept,
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.size,
  }) : super(key: key);

  final void Function(WindowTab) onAccept;
  final double top, left, right, bottom;
  final Size size;

  @override
  _WindowAcceptRegionState createState() => _WindowAcceptRegionState();
}

class _WindowAcceptRegionState extends State<WindowAcceptRegion> {
  bool accepting = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: widget?.size,
      child: LayoutBuilder(
        builder: (context, dimens) => Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: DashedRect(
                color: accepting ? Colors.white : Colors.transparent,
                shadowColor:
                    accepting ? Colors.grey.shade300 : Colors.transparent,
                strokeWidth: 2.0,
                gap: 5.0,
              ),
            ),
            Positioned.fill(
              left: widget?.left ?? 0,
              right: widget?.right ?? 0,
              top: widget?.top ?? 0,
              bottom: widget?.bottom ?? 0,
              child: Container(
                child: DragTarget<WindowTab>(
                  builder: (context, accepted, rejected) => Container(),
                  onAccept: (val) {
                    if (mounted)
                      setState(() {
                        accepting = false;
                      });
                    if (widget.onAccept != null) widget.onAccept(val);
                  },
                  onWillAccept: (val) {
                    if (mounted)
                      setState(() {
                        accepting = true;
                      });
                    return true;
                  },
                  onLeave: (_) {
                    if (mounted)
                      setState(() {
                        accepting = false;
                      });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
