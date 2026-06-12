import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmdb_movie_explorer/pages/movies_list.dart';

class SettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _darkMode = true;
  int thumbIdx = 0;

  bool get darkMode => _darkMode;
  set setThumbIdx(int idx) {
    thumbIdx = idx;
    notifyListeners();
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    _darkMode = _prefs.getBool('darkMode') ?? true;

    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _darkMode = !_darkMode;
    await _prefs.setBool('darkMode', _darkMode);
    notifyListeners();
  }
}

class UserData extends ChangeNotifier {
  late SharedPreferences _prefs;

  Map<String, String> _watchedMovies = {};
  Map<String, String> _ratedMovies = {};

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    final watchedJson = _prefs.getString('watchedMovies');
    final ratedJson = _prefs.getString('ratedMovies');

    if (watchedJson != null) {
      _watchedMovies = Map<String, String>.from(jsonDecode(watchedJson));
    }

    if (ratedJson != null) {
      _ratedMovies = Map<String, String>.from(jsonDecode(ratedJson));
    }
  }

  bool isWatched(String movieId) {
    return _watchedMovies.containsKey(movieId);
  }

  bool isRated(String movieId) {
    return _ratedMovies.containsKey(movieId);
  }

  int getSize(ListType type) {
    return type == ListType.watched
        ? _watchedMovies.length
        : _ratedMovies.length;
  }

  List<String> getTitles(ListType type) {
    return type == ListType.watched
        ? _watchedMovies.values.toList()
        : _ratedMovies.values.toList();
  }

  List<String> getIds(ListType type) {
    return type == ListType.watched
        ? _watchedMovies.keys.toList()
        : _ratedMovies.keys.toList();
  }

  Future<void> setWatched(String movieId, String title) async {
    if (_watchedMovies.containsKey(movieId)) {
      _watchedMovies.remove(movieId);
    } else {
      _watchedMovies[movieId] = title;
    }

    await _prefs.setString('watchedMovies', jsonEncode(_watchedMovies));

    notifyListeners();
  }

  Future<void> setRated(String movieId, String title) async {
    if (_ratedMovies.containsKey(movieId)) {
      _ratedMovies.remove(movieId);
    } else {
      _ratedMovies[movieId] = title;
    }

    await _prefs.setString('ratedMovies', jsonEncode(_ratedMovies));

    notifyListeners();
  }

  Future<void> clearWatched() async {
    _watchedMovies.clear();

    await _prefs.remove('watchedMovies');

    notifyListeners();
  }

  Future<void> clearRated() async {
    _ratedMovies.clear();

    await _prefs.remove('ratedMovies');

    notifyListeners();
  }

  Map<String, String> getMovies(ListType type) {
    return type == ListType.watched ? _watchedMovies : _ratedMovies;
  }
}
