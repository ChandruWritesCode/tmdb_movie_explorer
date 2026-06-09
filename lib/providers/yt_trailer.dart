import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tmdb_movie_explorer/api/constants.dart';

class YtTrailer extends ChangeNotifier {
  late String videoListUrl;
  Future<String> fetchYtId(String movieId) async {
    final url =
        'https://api.themoviedb.org/3/movie/$movieId/videos?api_key=$apiKey';

    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 15));

        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}');
        }

        final videos = jsonDecode(response.body)['results'] as List;

        debugPrint('Movie ID: $movieId');
        debugPrint('Videos found: ${videos.length}');
        debugPrint(response.body);

        // 1. Official Trailer first
        for (final v in videos) {
          if (v['site'] == 'YouTube' &&
              v['type'] == 'Trailer' &&
              v['official'] == true) {
            return v['key'];
          }
        }

        // 2. Any Trailer
        for (final v in videos) {
          if (v['site'] == 'YouTube' && v['type'] == 'Trailer') {
            return v['key'];
          }
        }

        // 3. ANY YouTube video fallback (important for your dataset)
        for (final v in videos) {
          if (v['site'] == 'YouTube') {
            return v['key'];
          }
        }


        return '';
      } catch (e) {
        // debugPrint('Attempt $attempt failed: $e');

        if (attempt == 3) rethrow;

        await Future.delayed(const Duration(seconds: 2));
      }
    }

    return '';
  }
}
