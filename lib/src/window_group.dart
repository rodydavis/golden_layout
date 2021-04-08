import 'package:flutter/material.dart';

import 'border_accept.dart';
import 'dotted_border.dart';
import 'theme.dart';
import 'window.dart';

enum WindowPos { top, left, bottom, right, tab }

void _noModifyAction(BuildContext context, WindowTab tab, WindowPos position,
    [int? index]) {}

class RenderWindowGroup extends StatefulWidget {
  final WindowGroup group;
  final VoidCallback onFullScreen, update;
  final VoidCallback? onClose;
  final bool minimize;
  final Size popUpSize;
  final bool isDragging;
  final void Function(WindowTab) onCancel;
  final ValueChanged<bool> onDraggingChanged;
  final void Function(BuildContext, WindowTab, WindowPos, [int? index])
      onModify;
  final WindowTab Function()? onAddTab;

  const RenderWindowGroup({
    Key? key,
    required this.group,
    required this.onFullScreen,
    this.onClose,
    this.minimize = false,
    required this.update,
    required this.onCancel,
    required this.popUpSize,
    required this.onDraggingChanged,
    required this.isDragging,
    this.onModify = _noModifyAction,
    required this.onAddTab,
  }) : super(key: key);

  @override
  _RenderWindowGroupState createState() => _RenderWindowGroupState();
}

class _RenderWindowGroupState extends State<RenderWindowGroup> {
  int? accepting;
  WindowTab? _draggingTab;

  @override
  void initState() {
    widget.group.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _theme =
        GoldenLayoutTheme.of(context)?.theme ?? GoldenLayoutThemeData();
    return Column(
      children: [
        Container(
          color: _theme.backgroundColor,
          height: 32,
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 4),
                      for (var i = 0; i < widget.group.tabs.length; i++)
                        Draggable<WindowTab>(
                          data: widget.group.tabs[i],
                          dragAnchor: DragAnchor.child,
                          onDragStarted: () {
                            _draggingTab = widget.group.tabs[i];
                            widget.group.removeTab(_draggingTab);
                            widget.update();
                            if (widget.group.tabs.isEmpty) {
                              widget.onClose?.call();
                            }
                            widget.onDraggingChanged(true);
                          },
                          onDragCompleted: () {
                            widget.onDraggingChanged(false);
                            _draggingTab = null;
                          },
                          onDragEnd: (_) {
                            widget.onDraggingChanged(false);
                            _draggingTab = null;
                          },
                          onDraggableCanceled: (_, __) {
                            widget.onDraggingChanged(false);
                            widget.onCancel(_draggingTab!);
                            _draggingTab = null;
                          },
                          feedback: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Material(
                                elevation: 8,
                                color: Colors.red,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: widget.group.tabs[i]
                                      .title(context, false, i),
                                ),
                              ),
                              SizedBox.fromSize(
                                size: widget.popUpSize,
                                child:
                                    Material(elevation: 8, child: Container()),
                              ),
                            ],
                          ),
                          child: DragTarget<WindowTab>(
                            onLeave: (_) {
                              if (mounted) {
                                setState(() {
                                  accepting = null;
                                });
                              }
                            },
                            onWillAccept: (val) {
                              if (mounted) {
                                setState(() {
                                  accepting = i;
                                });
                              }
                              return true;
                            },
                            onAccept: (val) {
                              widget.onModify(
                                  context, val, WindowPos.tab, accepting);
                              if (mounted) {
                                setState(() {
                                  accepting = null;
                                });
                              }
                            },
                            builder: (context, accepted, rejected) {
                              final selected = i == widget.group.activeTabIndex;
                              return InkWell(
                                onTap: () {
                                  widget.group.selectTab(i);
                                  widget.update();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? _theme.tabSelectedBackgroundColor
                                        : _theme.backgroundColor,
                                    borderRadius: selected
                                        ? BorderRadius.only(
                                            topLeft: Radius.circular(5),
                                            topRight: Radius.circular(5),
                                          )
                                        : null,
                                  ),
                                  height: double.infinity,
                                  margin: EdgeInsets.only(
                                    top: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      if (accepting != i)
                                        Container(
                                          child: widget.group.tabs[i]
                                              .title(context, false, i),
                                        ),
                                      if (accepting == i)
                                        Container(
                                          width: 100,
                                          height: double.infinity,
                                          child: DashedRect(
                                            color: Colors.white,
                                            shadowColor: Colors.grey.shade300,
                                            strokeWidth: 2.0,
                                            gap: 5.0,
                                          ),
                                        ),
                                      if (widget.group.tabs[i].canClose &&
                                          selected) ...[
                                        Container(width: 4),
                                        InkWell(
                                          onTap: () {
                                            widget.group.tabs[i].onClose
                                                ?.call();
                                            widget.group.removeTab(
                                                widget.group.tabs[i]);
                                            widget.update();
                                            if (widget.group.tabs.isEmpty) {
                                              widget.onClose?.call();
                                            }
                                          },
                                          child: Icon(
                                            Icons.close,
                                            size: 18,
                                            color: _theme.tabIconColor,
                                          ),
                                        ),
                                      ],
                                      if (!selected &&
                                          i + 1 != widget.group.activeTabIndex)
                                        VerticalDivider(
                                          indent: 4,
                                          width: 1,
                                          thickness: 1,
                                          color: Colors.grey.shade500,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      if (widget.onAddTab != null)
                        IconButton(
                            iconSize: 20,
                            icon: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                            onPressed: () =>
                                widget.group.addTab(widget.onAddTab!())),
                      if (widget.isDragging)
                        WindowAcceptRegion(
                          size: Size(100, 32),
                          onAccept: (val) {
                            widget.group.addTab(val);
                            widget.update();
                          },
                        ),
                    ],
                  ),
                ),
              ),
              IconButton(
                color: _theme.tabIconColor,
                iconSize: 18,
                icon: Icon(widget.minimize ? Icons.minimize : Icons.fullscreen),
                onPressed: widget.onFullScreen,
              ),
              if (widget.onClose != null)
                IconButton(
                  color: _theme.tabIconColor,
                  iconSize: 18,
                  icon: Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, dimens) => Stack(
              children: [
                Positioned.fill(
                  child: widget.group.tabs.isEmpty
                      ? Container()
                      : widget.group.tabs[widget.group.activeTabIndex].child ??
                          Container(),
                ),
                Positioned(
                  top: 0,
                  width: dimens.maxWidth,
                  height: dimens.minHeight * 0.5,
                  child: WindowAcceptRegion(
                    onAccept: (val) =>
                        widget.onModify(context, val, WindowPos.top),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  width: dimens.maxWidth,
                  height: dimens.minHeight * 0.5,
                  child: WindowAcceptRegion(
                    onAccept: (val) =>
                        widget.onModify(context, val, WindowPos.bottom),
                  ),
                ),
                Positioned(
                  right: 0,
                  width: dimens.maxWidth * 0.5,
                  height: dimens.minHeight,
                  child: WindowAcceptRegion(
                    left: dimens.maxWidth * 0.2,
                    onAccept: (val) =>
                        widget.onModify(context, val, WindowPos.right),
                  ),
                ),
                Positioned(
                  left: 0,
                  width: dimens.maxWidth * 0.5,
                  height: dimens.minHeight,
                  child: WindowAcceptRegion(
                    right: dimens.maxWidth * 0.2,
                    onAccept: (val) =>
                        widget.onModify(context, val, WindowPos.left),
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
