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
}
