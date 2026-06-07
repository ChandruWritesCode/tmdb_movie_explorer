import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _darkMode = true;
  String _userName = '';
  bool _firstLogin = true;
  int thumbIdx=0;

  bool get darkMode => _darkMode;
  bool get firstLogin => _firstLogin;
  String get userName => _userName;
  set setThumbIdx(int idx){
    thumbIdx = idx;
    notifyListeners();
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    _darkMode = _prefs.getBool('darkMode') ?? true;
    _userName = _prefs.getString('userName') ?? '';

    _firstLogin = _prefs.getBool('firstLogin') ?? true;

    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _darkMode = !_darkMode;
    await _prefs.setBool('darkMode', _darkMode);
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    await _prefs.setString('userName', name);
    _firstLogin = false;
    await _prefs.setBool('firstLogin', false);
    notifyListeners();
  }
}
