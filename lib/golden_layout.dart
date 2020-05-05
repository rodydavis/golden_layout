import 'package:flutter/material.dart';

import 'src/controller.dart';
import 'src/drag_bar.dart';
import 'src/window.dart';
import 'src/window_group.dart';

export 'src/controller.dart';
export 'src/tab.dart';
export 'src/window.dart';
export 'src/theme.dart';

class GoldenLayout extends StatefulWidget {
  final WindowController controller;
  final Size popupSize;
  final WindowCollection collection;

  const GoldenLayout({
    Key key,
    @required this.controller,
    this.collection,
    this.popupSize = const Size(450, 300),
  }) : super(key: key);

  @override
  _GoldenLayoutState createState() => _GoldenLayoutState();
}

class _GoldenLayoutState extends State<GoldenLayout> {
  WindowController _controller;

  @override
  void initState() {
    _controller = widget?.controller ?? WindowController();
    if (widget?.collection != null) {
      _controller.base = widget.collection;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, dimens) {
      if (_controller.fullScreen != null) {
        return RenderWindowGroup(
          isDragging: _isDragging,
          onDraggingChanged: (val) {
            if (mounted)
              setState(() {
                _isDragging = val;
              });
          },
          popUpSize: widget.popupSize,
          minimize: true,
          group: _controller.fullScreen,
          onFullScreen: () {
            if (mounted)
              setState(() {
                _controller.exitFullScreen();
              });
          },
          onClose: !_controller.fullScreen.canClose
              ? null
              : () {
                  if (mounted)
                    setState(() {
                      _controller.exitFullScreen(true);
                    });
                },
          update: () {
            if (mounted) setState(() {});
          },
        );
      }
      return _renderItem(
        _controller.base,
        index: 0,
        size: Size(dimens.maxWidth, dimens.maxHeight),
        onChanged: (val) {
          if (mounted)
            setState(() {
              _controller.base = val;
            });
        },
        onClose: (val) {
          if (mounted)
            setState(() {
              _controller.base = null;
            });
        },
      );
    });
  }

  Widget _renderItem(
    WindowCollection item, {
    @required int index,
    @required Size size,
    @required ValueChanged<WindowCollection> onChanged,
    @required ValueChanged<WindowCollection> onClose,
  }) {
    if (item is WindowColumn) {
      return Column(
        children: [
          for (var i = 0; i < item.children.length; i++) ...[
            Flexible(
              flex: (size.height * item.children[i].flex).round(),
              child: LayoutBuilder(
                builder: (context, dimens) => _renderItem(
                  item.children[i],
                  index: i,
                  size: Size(dimens.maxWidth, dimens.maxHeight),
                  onChanged: (val) {
                    if (mounted)
                      setState(() {
                        item.children[i] = val;
                      });
                  },
                  onClose: (val) {
                    if (mounted)
                      setState(() {
                        item.children.remove(val);
                      });
                    if (item.children.isEmpty) {
                      onClose(item);
                    }
                  },
                ),
              ),
            ),
            if (i != item.children.length - 1)
              GestureDetector(
                onVerticalDragUpdate: (val) {
                  final _current = size.height * item.children[i].flex;
                  final _height = val.delta.dy + _current;
                  if (mounted)
                    setState(() {
                      item.children[i].flex = _height / size.height;
                    });
                },
                child: HorizontalDragBar(),
              ),
          ],
        ],
      );
    }
    if (item is WindowRow) {
      return Row(
        children: [
          for (var i = 0; i < item.children.length; i++) ...[
            Flexible(
              flex: (size.width * item.children[i].flex).round(),
              child: LayoutBuilder(
                builder: (context, dimens) => _renderItem(
                  item.children[i],
                  index: i,
                  size: Size(dimens.maxWidth, dimens.maxHeight),
                  onChanged: (val) {
                    if (mounted)
                      setState(() {
                        item.children[i] = val;
                      });
                  },
                  onClose: (val) {
                    if (mounted)
                      setState(() {
                        item.children.remove(val);
                      });
                    if (item.children.isEmpty) {
                      onClose(item);
                    }
                  },
                ),
              ),
            ),
            if (i != item.children.length - 1)
              GestureDetector(
                onHorizontalDragUpdate: (val) {
                  final _current = size.width * item.children[i].flex;
                  final _width = val.delta.dx + _current;
                  if (mounted)
                    setState(() {
                      item.children[i].flex = _width / size.width;
                    });
                },
                child: VerticalDragBar(),
              ),
          ],
        ],
      );
    }
    if (item is WindowGroup) {
      return RenderWindowGroup(
        onDraggingChanged: (val) {
          if (mounted)
            setState(() {
              _isDragging = val;
            });
        },
        isDragging: _isDragging,
        popUpSize: widget.popupSize,
        group: item,
        onFullScreen: () {
          if (mounted)
            setState(() {
              _controller.enterFullScreen(item, onClose);
            });
        },
        onClose: !item.canClose
            ? null
            : () {
                if (mounted)
                  setState(() {
                    item.close();
                  });
                if (item.tabs.isEmpty) {
                  onClose(item);
                }
              },
        update: () {
          if (mounted) setState(() {});
        },
        onModify: (context, tab, pos) {
          final _group = WindowGroup()..addTab(tab);
          switch (pos) {
            case WindowPos.top:
              onChanged(WindowColumn([_group, item]));
              break;
            case WindowPos.left:
              onChanged(WindowRow([_group, item]));
              break;
            case WindowPos.bottom:
              onChanged(WindowColumn([item, _group]));
              break;
            case WindowPos.right:
              onChanged(WindowRow([item, _group]));
              break;
          }
          if (mounted) setState(() {});
        },
      );
    }
    return Container();
  }

  bool _isDragging = false;
}
