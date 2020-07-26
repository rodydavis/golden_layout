import 'package:flutter/material.dart';

class HorizontalDragBar extends StatefulWidget {
  const HorizontalDragBar({
    Key key,
  }) : super(key: key);

  @override
  _HorizontalDragBarState createState() => _HorizontalDragBarState();
}

class _HorizontalDragBarState extends State<HorizontalDragBar> {
  bool _onHover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (mounted) {
          setState(() {
            _onHover = true;
          });
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() {
            _onHover = false;
          });
        }
      },
      child: Divider(
        height: 8,
        color: _onHover ? Colors.grey : Colors.black,
        thickness: 8,
      ),
    );
  }
}

class VerticalDragBar extends StatefulWidget {
  const VerticalDragBar({
    Key key,
  }) : super(key: key);

  @override
  _VerticalDragBarState createState() => _VerticalDragBarState();
}

class _VerticalDragBarState extends State<VerticalDragBar> {
  bool _onHover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (mounted) {
          setState(() {
            _onHover = true;
          });
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() {
            _onHover = false;
          });
        }
      },
      child: VerticalDivider(
        width: 8,
        color: _onHover ? Colors.grey : Colors.black,
        thickness: 8,
      ),
    );
  }
}
