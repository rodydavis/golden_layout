import 'tab.dart';

abstract class WindowCollection {}

class WindowRow extends WindowCollection {
  final List<WindowCollection> children;

  WindowRow(this.children);
}

class WindowColumn extends WindowCollection {
  final List<WindowCollection> children;

  WindowColumn(this.children);
}

class WindowGroup extends WindowCollection {
  final List<WindowTab> _tabs = [];
  List<WindowTab> get tabs => _tabs;
  int _activeTab = 0;
  int get activeTabIndex => _activeTab;

  void selectTab(int index) {
    _activeTab = index;
  }

  void init(List<WindowTab> tabs) {
    _tabs.addAll(tabs);
  }

  void addTab(WindowTab tab) {
    _tabs.add(tab);
    _activeTab = _tabs.length - 1;
  }

  void removeTab(WindowTab tab) {
    _tabs.remove(tab);
    if (_activeTab > _tabs.length - 1) {
      _activeTab = _tabs.length - 1;
    }
  }

  void close() {
    _tabs.clear();
  }

  void restore() {}
}
