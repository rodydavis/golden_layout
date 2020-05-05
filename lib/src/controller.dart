import 'window.dart';

class WindowController {
  WindowGroup _fullScreenGroup;
  WindowGroup get fullScreen => _fullScreenGroup;

  void enterFullScreen(WindowGroup val) {
    _fullScreenGroup = val;
  }

  void exitFullScreen() {
    _fullScreenGroup = null;
  }

  WindowCollection base = WindowColumn([]);
}
