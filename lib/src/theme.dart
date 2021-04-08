import 'package:flutter/material.dart';

class GoldenLayoutThemeData {
  final Color tabSelectedBackgroundColor;
  Color? tabBackgroundColor;
  Color? backgroundColor;
  final Color draggableBarsHoveredColor;
  final Color tabIconColor;

  GoldenLayoutThemeData({
    this.tabSelectedBackgroundColor = Colors.grey,
    this.backgroundColor,
    this.draggableBarsHoveredColor = Colors.grey,
    this.tabIconColor = Colors.white,
    this.tabBackgroundColor,
  }) {
    tabBackgroundColor ??= Colors.grey.shade700;
    backgroundColor ??= Colors.grey.shade800;
  }
}

class GoldenLayoutTheme extends InheritedWidget {
  GoldenLayoutTheme({
    Key? key,
    required this.child,
    this.data,
  }) : super(key: key, child: child);

  final GoldenLayoutThemeData? data;
  @override
  final Widget child;

  GoldenLayoutThemeData get theme => data ?? GoldenLayoutThemeData();

  static GoldenLayoutTheme? of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<GoldenLayoutTheme>());
  }

  @override
  bool updateShouldNotify(GoldenLayoutTheme oldWidget) {
    return data != oldWidget.data;
  }
}
