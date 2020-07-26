import 'package:flutter/material.dart';

abstract class WindowCollection extends ChangeNotifier {
  double flex = 1;
  void update() {
    notifyListeners();
  }
}

class WindowTab {
  final String id;
  final Widget Function(BuildContext, bool selected, int index) title;
  final Widget child;
  final bool canClose;
  final Function() onClose;

  WindowTab(
      {@required this.id,
      @required this.title,
      this.child,
      this.canClose = true,
      this.onClose});
}

class WindowRow extends WindowCollection {
  final List<WindowCollection> children;

  WindowRow(this.children);
}

class WindowColumn extends WindowCollection {
  final List<WindowCollection> children;

  WindowColumn(this.children);
}

class WindowGroup extends WindowCollection {
  WindowGroup([WindowTab tab, bool closeable = true]) {
    if (tab != null) _tabs.add(tab);
    canClose = closeable;
  }
  bool canClose = true;
  final List<WindowTab> _tabs = [];
  List<WindowTab> get tabs => _tabs;
  int _activeTab = 0;
  int get activeTabIndex => _activeTab;

  void selectTab(int index) {
    _activeTab = index;
    notifyListeners();
  }

  void init(List<WindowTab> tabs) {
    _tabs.addAll(tabs);
    notifyListeners();
  }

  void addTab(WindowTab tab, [int index]) {
    if (index != null) {
      _tabs.insert(index, tab);
      _activeTab = index;
    } else {
      _tabs.add(tab);
      _activeTab = _tabs.length - 1;
    }
    notifyListeners();
  }

  void removeTab(WindowTab tab) {
    _tabs.remove(tab);
    if (_activeTab > _tabs.length - 1) {
      _activeTab = _tabs.length - 1;
    }
    notifyListeners();
  }

  void close() {
    if (!canClose) return;
    _tabs.clear();
    notifyListeners();
  }
}
