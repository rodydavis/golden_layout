import 'package:flutter/material.dart';

class WindowTab {
  final String title;
  final Widget child;
  final bool canClose;

  WindowTab({
    @required this.title,
    this.child,
    this.canClose = true,
  });
}
