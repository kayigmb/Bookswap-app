import 'package:flutter/foundation.dart';

class SettingsProvider with ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _swapRequestNotifications = true;
  bool _chatNotifications = true;
  bool _darkMode = false;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get swapRequestNotifications => _swapRequestNotifications;
  bool get chatNotifications => _chatNotifications;
  bool get darkMode => _darkMode;

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void toggleSwapRequestNotifications(bool value) {
    _swapRequestNotifications = value;
    notifyListeners();
  }

  void toggleChatNotifications(bool value) {
    _chatNotifications = value;
    notifyListeners();
  }

  void toggleDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }
}

