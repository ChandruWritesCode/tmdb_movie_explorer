import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmdb_movie_explorer/pages/home_page.dart';
import 'package:tmdb_movie_explorer/pages/movie_detail_page.dart';
import 'package:tmdb_movie_explorer/providers/tmdb_api_call.dart';

class SeeAllMovieList extends StatelessWidget {
  final MovieType type;
  final Future<void> _moviesFuture;
  const SeeAllMovieList({
    required this.type,
    super.key,
    required this._moviesFuture,
  });

  @override
  Widget build(BuildContext context) {
    final api = context.watch<ApiCallManager>();
    return Scaffold(
      appBar: AppBar(title: Text(type.title), centerTitle: true),
      body: FutureBuilder(
        future: _moviesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          final itemCount = type == MovieType.top_rated
              ? api.topRatedMovies.length
              : api.upComingMovies.length;
          final moviesList = type == MovieType.top_rated
              ? api.topRatedMovies
              : api.upComingMovies;
          return SizedBox(
            width: double.infinity,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: itemCount,
              itemBuilder: (context, idx) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => MovieDetailPage()),
                    );
                  },
                  child: Column(
                    // to contain the divider
                    children: [
                      Row(
                        // to house the thumb image with details
                        children: [
                          Container(
                            // movie thumb image
                            width: 120,
                            padding: const EdgeInsets.all(10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: MovieCard(type: type, idx: idx),
                            ),
                          ),
                          Column(
                            // details and actions
                            children: [
                              SizedBox(
                                width: 200,
                                child: Text(
                                  overflow: TextOverflow.fade,
                                  maxLines: 2,
                                  moviesList[idx]['title'],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 200,
                                child: Text(
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 4,
                                  softWrap: true,
                                  moviesList[idx]['overview'],
                                ),
                              ),
                              SizedBox(
                                width: 200,
                                child: Text(
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  'Release: ${moviesList[idx]['release_date']}',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Divider(),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
