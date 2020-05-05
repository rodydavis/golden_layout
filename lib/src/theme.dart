import 'package:flutter/material.dart';

class GoldenLayoutThemeData {
  final Color tabSelectedBackgroundColor;
  final Color backgroundColor;
  final Color draggableBarsHoveredColor;
  final Color tabIconColor;

  const GoldenLayoutThemeData({
    this.tabSelectedBackgroundColor = Colors.grey,
    this.backgroundColor = Colors.black,
    this.draggableBarsHoveredColor = Colors.grey,
    this.tabIconColor = Colors.white,
  });
}

class GoldenLayoutTheme extends InheritedWidget {
  GoldenLayoutTheme({
    Key key,
    @required this.child,
    @required this.data,
  }) : super(key: key, child: child);

  final GoldenLayoutThemeData data;
  final Widget child;

  GoldenLayoutThemeData get theme => data ?? GoldenLayoutThemeData();

  static GoldenLayoutTheme of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<GoldenLayoutTheme>());
  }

  @override
  bool updateShouldNotify(GoldenLayoutTheme oldWidget) {
    return data != oldWidget.data;
  }
}
