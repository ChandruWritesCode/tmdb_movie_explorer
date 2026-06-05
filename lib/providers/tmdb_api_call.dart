import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tmdb_movie_explorer/api/api.dart';

class ApiCallManager extends ChangeNotifier {
  Future<List> getPopular() async {
    final response = await http.get(Uri.parse(popularUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['results'];
      return data;
    } else {
      throw Exception('failed to get popular');
    }
  }

  Future<List> getTopRated() async {
    final response = await http.get(Uri.parse(topRatedUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['results'];
      return data;
    } else {
      throw Exception('failed to get top rated');
    }
  }

  Future<List> getUpcoming() async {
    final response = await http.get(Uri.parse(upcomingUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['results'];
      return data;
    } else {
      throw Exception('failed to get upcoming');
    }
  }

  Future<List> get(String type) async {
    if(type == 'Popular') {
      return getPopular();
    } else if(type == 'Top Rated'){
      return getTopRated();
    } else {
      return getUpcoming();
    }
  }

  // variables are here you dumbass
  List upComingMovies = [];
  List topRatedMovies = [];
  List popularMovies = [];
  int x=0;

  Future<String?> init() async {
    try {
      upComingMovies = await getUpcoming();
      topRatedMovies = await getTopRated();
      popularMovies = await getPopular();
      notifyListeners();
    } catch (e) {
      if (upComingMovies.isEmpty ||
          topRatedMovies.isEmpty ||
          popularMovies.isEmpty) {
        print('init is called');
        init();
        notifyListeners();
      }
    }
    return null;
  }
}
