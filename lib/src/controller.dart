import 'window.dart';

class WindowController {
  WindowGroup _fullScreenGroup;
  WindowGroup get fullScreen => _fullScreenGroup;
  void Function(WindowGroup) _closeWindow;

  void enterFullScreen(WindowGroup val, void Function(WindowGroup) onClose) {
    _fullScreenGroup = val;
    _closeWindow = onClose;
  }

  void exitFullScreen([bool close = false]) {
    if (close) {
      _closeWindow(_fullScreenGroup);
    }
    _fullScreenGroup = null;
  }

  WindowCollection base = WindowColumn([]);

  void addToBase(WindowTab tab) => _addTab(base, tab);

  bool _addTab(WindowCollection item, WindowTab tab) {
    if (item is WindowGroup) {
      item.addTab(tab);
      item.update();
      return true;
    }
    if (item is WindowColumn) {
      for (final child in item.children) {
        if (_addTab(child, tab)) {
          child.update();
          return true;
        }
      }
    }
    if (item is WindowRow) {
      for (final child in item.children) {
        if (_addTab(child, tab)) {
          child.update();
          return true;
        }
      }
    }
    return false;
  }
}
