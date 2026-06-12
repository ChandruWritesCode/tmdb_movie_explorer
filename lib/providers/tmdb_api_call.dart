import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tmdb_movie_explorer/api/api.dart';
import 'package:tmdb_movie_explorer/api/constants.dart';

class ApiCallManager extends ChangeNotifier {
  // variables are here you dumbass
  List upComingMovies = [];
  List topRatedMovies = [];
  List popularMovies = [];
  List genres = [];

  List? searchResults;

  void startSearch() {
    searchResults = null;
    notifyListeners();
  }

  Future<void> searchWithQuery(String query) async {
    try {
      searchResults = await _search(query);
      notifyListeners();
    } catch (e) {
      debugPrint('Search failed: $e');
      await Future.delayed(Duration(seconds: 1));
      searchWithQuery(query);
    }
  }

  Future<List<dynamic>> _search(String query) async {
    return await fetchMovies(
      'https://api.themoviedb.org/3/search/movie?query=$query&api_key=$apiKey',
    );
  }

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
        if (attempt == 3) {
          throw Exception('Detail fetch error');
        }

        await Future.delayed(const Duration(seconds: 1));
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

  Future<void> init() async {
    debugPrint('init called');
    await Future.wait([
      getUpcoming().catchError((_) => []),
      getTopRated().catchError((_) => []),
      getPopular().catchError((_) => []),
    ]);
  }

  Future<Map<String, dynamic>> fetchMovieDetails(String movieId) async {
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        final response = await http
            .get(
              Uri.parse(
                'https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey',
              ),
              headers: {'Accept': 'application/json'},
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          return jsonDecode(response.body) ?? {};
        }

        throw Exception("HTTP ${response.statusCode}");
      } catch (e) {
        debugPrint('Details fetch Attempt $attempt failed: $e');
        if (attempt == 3) {
          rethrow;
        }

        await Future.delayed(const Duration(seconds: 2));
      }
    }
    return {};
  }

  Future<void> getGenres() async {
    genres = await fetchGenresList();
    notifyListeners();
  }

  Future<List<dynamic>> getSimilarMovies(String movieId) async {
    List movies = [];
    try {
      movies = await fetchMovies(
        'https://api.themoviedb.org/3/movie/$movieId/recommendations?api_key=$apiKey',
      );
    } catch (_) {
      movies = [];
    }
    notifyListeners();
    return movies;
  }

  Future<List<dynamic>> fetchGenresList() async {
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        final response = await http
            .get(
              Uri.parse(
                'https://api.themoviedb.org/3/genre/movie/list?api_key=$apiKey',
              ),
              headers: {'Accept': 'application/json'},
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          return jsonDecode(response.body)['genres'] ?? [];
        }

        throw Exception("HTTP ${response.statusCode}");
      } catch (e) {
        // debugPrint('Attempt $attempt failed: $e');
        if (attempt == 3) rethrow;

        await Future.delayed(const Duration(seconds: 1));
      }
    }
    return [];
  }
}
