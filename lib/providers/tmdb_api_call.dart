import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tmdb_movie_explorer/api/api.dart';

class ApiCallManager extends ChangeNotifier {

  // variables are here you dumbass
  List upComingMovies = [];
  List topRatedMovies = [];
  List popularMovies = [];

  Future<List<dynamic>> fetchMovies(String url) async {
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        final response = await http
            .get(Uri.parse(url), headers: {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          return jsonDecode(response.body)['results'] ?? [];
        }

        throw Exception("HTTP ${response.statusCode}");
      } catch (e) {
        if (attempt == 3) rethrow;

        await Future.delayed(const Duration(seconds: 2));
      }
    }

    return [];
  }

  Future<List<dynamic>> getPopular() async {
    try {
      popularMovies = await fetchMovies(popularUrl);
    } catch (_) {
      popularMovies = [];
    }
    
    notifyListeners();
    return popularMovies;
  }

  Future<List<dynamic>> getTopRated() async {
    try {
      topRatedMovies = await fetchMovies(topRatedUrl);
    } catch (_) {
      topRatedMovies = [];
    }
    
    notifyListeners();
    return topRatedMovies;
  }

  Future<List<dynamic>> getUpcoming() async {
    try {
      upComingMovies = await fetchMovies(upcomingUrl);
    } catch (_) {
      upComingMovies = [];
    }
    
    notifyListeners();
    return upComingMovies;
  }

  Future<List> get(String type) {
    switch (type) {
      case 'Popular':
        return getPopular();

      case 'Top Rated':
        return getTopRated();

      case 'Upcoming':
        return getUpcoming();

      default:
        throw Exception('Invalid movie type: $type');
    }
  }

  Future<void> init() async {
    debugPrint('init called');
    await Future.wait([
      getUpcoming().catchError((_) => []),
      getTopRated().catchError((_) => []),
      getPopular().catchError((_) => []),
    ]);
  }
}
