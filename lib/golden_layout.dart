import 'package:flutter/material.dart';

import 'src/controller.dart';
import 'src/dotted_border.dart';
import 'src/tab.dart';
import 'src/window.dart';

export 'src/controller.dart';
export 'src/tab.dart';
export 'src/window.dart';

class GoldenLayout extends StatefulWidget {
  final WindowController controller;
  final Size popupSize;
  const GoldenLayout({
    Key key,
    this.controller,
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.fullScreen != null) {
      return Container(
        child: RenderWindowGroup(
          popUpSize: widget.popupSize,
          minimize: true,
          group: _controller.fullScreen,
          onFullScreen: () {
            if (mounted)
              setState(() {
                _controller.exitFullScreen();
              });
          },
          onClose: () {
            if (mounted)
              setState(() {
                _controller.fullScreen.close();
              });
          },
          update: () {
            if (mounted) setState(() {});
          },
        ),
      );
    }
    return _renderItem(_controller.base);
  }

  Widget _renderItem(WindowCollection item) {
    if (item is WindowColumn) {
      return Column(
        children: [
          for (final item in item.children)
            Flexible(
              flex: 1,
              child: _renderItem(item),
            ),
        ],
      );
    }
    if (item is WindowRow) {
      return Row(
        children: [
          for (final item in item.children)
            Flexible(
              flex: 1,
              child: _renderItem(item),
            ),
        ],
      );
    }
    if (item is WindowGroup) {
      return RenderWindowGroup(
        popUpSize: widget.popupSize,
        group: item,
        onFullScreen: () {
          if (mounted)
            setState(() {
              _controller.enterFullScreen(item);
            });
        },
        onClose: () {
          if (mounted)
            setState(() {
              item.close();
            });
        },
        update: () {
          if (mounted) setState(() {});
        },
      );
    }
    return Container();
  }
}

class RenderWindowGroup extends StatelessWidget {
  final WindowGroup group;
  final VoidCallback onFullScreen, onClose, update;
  final bool minimize;
  final VoidCallback onTabLongPress, onTapEnd;
  final Size popUpSize;

  const RenderWindowGroup({
    Key key,
    this.group,
    this.onFullScreen,
    this.onClose,
    this.minimize = false,
    this.update,
    this.onTabLongPress,
    this.onTapEnd,
    @required this.popUpSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.black,
          height: 32,
          child: Row(
            children: [
              Container(width: 4),
              for (var i = 0; i < group.tabs.length; i++)
                Draggable<WindowTab>(
                  data: group.tabs[i],
                  dragAnchor: DragAnchor.pointer,
                  feedback: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Material(
                      //   elevation: 8,
                      //   child: Text(group.tabs[i].title),
                      // ),
                      SizedBox.fromSize(
                        size: popUpSize,
                        child: Material(
                          elevation: 8,
                          child: group.tabs[i].child,
                        ),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onLongPress: onTabLongPress,
                    onTapCancel: onTapEnd,
                    onTap: () {
                      group.selectTab(i);
                      update();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: i == group.activeTabIndex
                            ? Colors.grey.shade600
                            : null,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                        ),
                      ),
                      padding: EdgeInsets.only(
                        left: 4,
                        right: 4,
                        bottom: 4,
                      ),
                      margin: EdgeInsets.only(
                        top: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            group.tabs[i].title,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          Container(width: 4),
                          InkWell(
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.white,
                            ),
                            onTap: () {
                              group.removeTab(group.tabs[i]);
                              update();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Spacer(),
              IconButton(
                color: Colors.white,
                iconSize: 18,
                icon: Icon(minimize ? Icons.minimize : Icons.fullscreen),
                onPressed: onFullScreen,
              ),
              IconButton(
                color: Colors.white,
                iconSize: 18,
                icon: Icon(Icons.close),
                onPressed: onClose,
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, dimens) => Stack(
              children: [
                Positioned.fill(
                  child: group.tabs.isEmpty
                      ? Container()
                      : group.tabs[group.activeTabIndex].child ?? Container(),
                ),
                Positioned(
                  top: 0,
                  width: dimens.maxWidth,
                  height: dimens.minHeight * 0.5,
                  child: WindowAcceptRegion(
                    onAccept: (val) {},
                  ),
                ),
                Positioned(
                  bottom: 0,
                  width: dimens.maxWidth,
                  height: dimens.minHeight * 0.5,
                  child: WindowAcceptRegion(
                    onAccept: (val) {},
                  ),
                ),
                Positioned(
                  right: 0,
                  width: dimens.maxWidth * 0.5,
                  height: dimens.minHeight,
                  child: WindowAcceptRegion(
                    left: dimens.maxWidth * 0.2,
                    onAccept: (val) {},
                  ),
                ),
                Positioned(
                  left: 0,
                  width: dimens.maxWidth * 0.5,
                  height: dimens.minHeight,
                  child: WindowAcceptRegion(
                    right: dimens.maxWidth * 0.2,
                    onAccept: (val) {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class WindowAcceptRegion extends StatefulWidget {
  const WindowAcceptRegion({
    Key key,
    this.onAccept,
    this.top,
    this.left,
    this.right,
    this.bottom,
  }) : super(key: key);

  final Function(WindowTab) onAccept;
  final double top, left, right, bottom;

  @override
  _WindowAcceptRegionState createState() => _WindowAcceptRegionState();
}

class _WindowAcceptRegionState extends State<WindowAcceptRegion> {
  bool accepting = false;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, dimens) => Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: DashedRect(
              color: accepting ? Colors.white : Colors.transparent,
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
    );
  }
}
