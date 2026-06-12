import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmdb_movie_explorer/pages/movie_detail_page.dart';
import 'package:tmdb_movie_explorer/providers/basic_providers.dart';

enum ListType { watched, rated }

class MoviesList extends StatelessWidget {
  final ListType type;

  const MoviesList({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final userData = context.watch<UserData>();
    final movies = userData.getMovies(type);
    final ids = movies.keys.toList();
    final titles = movies.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          type == ListType.watched ? 'Watched Movies' : 'Rated Movies',
        ),
      ),
      body: movies.isEmpty
          ? Center(
              child: Text(
                type == ListType.watched
                    ? 'No watched movies yet'
                    : 'No rated movies yet',
              ),
            )
          : ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailPage(movieId: ids[index]),
                      ),
                    );
                  },
                  leading: Icon(
                    type == ListType.watched ? Icons.done : Icons.thumb_up,
                  ),
                  title: Text(titles[index]),
                );
              },
            ),
    );
  }
}
