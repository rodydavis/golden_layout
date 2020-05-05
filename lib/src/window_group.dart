import 'package:flutter/material.dart';

import 'border_accept.dart';
import 'tab.dart';
import 'theme.dart';
import 'window.dart';

enum WindowPos { top, left, bottom, right }

class RenderWindowGroup extends StatelessWidget {
  final WindowGroup group;
  final VoidCallback onFullScreen, onClose, update;
  final bool minimize;
  final Size popUpSize;
  final bool isDragging;
  final ValueChanged<bool> onDraggingChanged;
  final void Function(BuildContext, WindowTab, WindowPos) onModify;

  const RenderWindowGroup({
    Key key,
    this.group,
    this.onFullScreen,
    this.onClose,
    this.minimize = false,
    this.update,
    @required this.popUpSize,
    @required this.onDraggingChanged,
    @required this.isDragging,
    this.onModify,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _theme =
        GoldenLayoutTheme.of(context)?.theme ?? GoldenLayoutThemeData();
    return Column(
      children: [
        Container(
          color: Colors.black,
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
                      for (var i = 0; i < group.tabs.length; i++)
                        Draggable<WindowTab>(
                          data: group.tabs[i],
                          dragAnchor: DragAnchor.pointer,
                          onDragStarted: () {
                            group.removeTab(group.tabs[i]);
                            update();
                            if (group.tabs.isEmpty) onClose();
                            onDraggingChanged(true);
                          },
                          onDragCompleted: () {
                            onDraggingChanged(false);
                          },
                          onDragEnd: (_) {
                            onDraggingChanged(false);
                          },
                          onDraggableCanceled: (_, __) {
                            onDraggingChanged(false);
                          },
                          feedback: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Material(
                                elevation: 8,
                                color: _theme?.tabSelectedBackgroundColor ??
                                    Colors.grey.shade600,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    group.tabs[i].title,
                                    style: TextStyle(
                                      color: _theme?.tabLabelTextColor ??
                                          Colors.white,
                                    ),
                                  ),
                                ),
                              ),
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
                            onTap: () {
                              group.selectTab(i);
                              update();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: i == group.activeTabIndex
                                    ? _theme?.tabSelectedBackgroundColor ??
                                        Colors.grey.shade600
                                    : null,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5),
                                ),
                              ),
                              height: double.infinity,
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
                                      color: _theme?.tabLabelTextColor ??
                                          Colors.white,
                                    ),
                                  ),
                                  if (group.tabs[i].canClose) ...[
                                    Container(width: 4),
                                    InkWell(
                                      child: Icon(
                                        Icons.close,
                                        size: 18,
                                        color: _theme?.tabIconColor ??
                                            Colors.white,
                                      ),
                                      onTap: () {
                                        group.removeTab(group.tabs[i]);
                                        update();
                                        if (group.tabs.isEmpty) onClose();
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (isDragging)
                        WindowAcceptRegion(
                          size: Size(100, 32),
                          onAccept: (val) {
                            group.addTab(val);
                            update();
                          },
                        ),
                    ],
                  ),
                ),
              ),
              IconButton(
                color: _theme?.tabIconColor ?? Colors.white,
                iconSize: 18,
                icon: Icon(minimize ? Icons.minimize : Icons.fullscreen),
                onPressed: onFullScreen,
              ),
              if (onClose != null)
                IconButton(
                  color: _theme?.tabIconColor ?? Colors.white,
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
                    onAccept: (val) => onModify(context, val, WindowPos.top),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  width: dimens.maxWidth,
                  height: dimens.minHeight * 0.5,
                  child: WindowAcceptRegion(
                    onAccept: (val) => onModify(context, val, WindowPos.bottom),
                  ),
                ),
                Positioned(
                  right: 0,
                  width: dimens.maxWidth * 0.5,
                  height: dimens.minHeight,
                  child: WindowAcceptRegion(
                    left: dimens.maxWidth * 0.2,
                    onAccept: (val) => onModify(context, val, WindowPos.right),
                  ),
                ),
                Positioned(
                  left: 0,
                  width: dimens.maxWidth * 0.5,
                  height: dimens.minHeight,
                  child: WindowAcceptRegion(
                    right: dimens.maxWidth * 0.2,
                    onAccept: (val) => onModify(context, val, WindowPos.left),
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
