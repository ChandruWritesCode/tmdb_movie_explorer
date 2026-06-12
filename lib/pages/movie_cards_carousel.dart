import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmdb_movie_explorer/api/image_cacher.dart';
import 'package:tmdb_movie_explorer/pages/home_page.dart';
import 'package:tmdb_movie_explorer/pages/movie_detail_page.dart';
import 'package:tmdb_movie_explorer/pages/see_all.dart';
import 'package:tmdb_movie_explorer/providers/tmdb_api_call.dart';

class CustomCarousel extends StatelessWidget {
  final MovieType type;
  final CarouselOptions? options;
  final Future<void> _moviesFuture;
  const CustomCarousel({
    required this._moviesFuture,
    this.options,
    required this.type,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final api = context.watch<ApiCallManager>();
    if (type == MovieType.popular) {
      // TODO optimize the Future builders and watch providers
      return FutureBuilder(
        future: _moviesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load movies check your connection',
                textAlign: TextAlign.center,
              ),
            );
          }

          final movies = api.popularMovies;

          if (movies.isEmpty) {
            api.getPopular();
          }

          return CarouselSlider.builder(
            options: options!,
            itemCount: movies.length,
            itemBuilder: (context, idx, realIdx) {
              return PopularMovieCard(movie: api.popularMovies[idx]);
            },
          );
        },
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                MovieTypeExtension(type).title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(),

              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SeeAllMovieList(
                        type: type,
                        moviesFuture: _moviesFuture,
                      ),
                    ),
                  );
                },
                child: const Text('See all'),
              ),
            ],
          ),
        ),
        FutureBuilder(
          future: _moviesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load movies\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              );
            }

            final itemCount = type == MovieType.top_rated
                ? api.topRatedMovies.length
                : api.upComingMovies.length;

            if (itemCount == 0) {
              if (type == MovieType.upcoming) {
                api.getUpcoming();
              } else {
                api.getTopRated();
              }
            }

            return SizedBox(
              width: double.infinity,
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: itemCount,
                itemBuilder: (context, idx) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MovieDetailPage(
                                movieId: type == MovieType.top_rated
                                    ? api.topRatedMovies[idx]['id'].toString()
                                    : api.upComingMovies[idx]['id'].toString(),
                              ),
                            ),
                          );
                        },
                        child: MovieCard(type: type, idx: idx),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class MovieCard extends StatelessWidget {
  final int idx;
  final MovieType type;

  const MovieCard({required this.type, required this.idx, super.key});

  @override
  Widget build(BuildContext context) {
    final api = context.watch<ApiCallManager>();

    try {
      String? imagePath;

      if (type == MovieType.popular) {
        if (idx >= api.popularMovies.length) {
          return Container(
            color: Colors.grey[800],
            child: const Center(child: Text('No data')),
          );
        }
        final movie = api.popularMovies[idx];
        imagePath = movie['backdrop_path'];
        return TmdbImage(
          size: TmdbImageSize.original,
          path: imagePath,
          fit: BoxFit.cover,
        );
      } else if (type == MovieType.top_rated) {
        if (idx >= api.topRatedMovies.length) {
          return Container(
            color: Colors.grey[800],
            child: const Center(child: Text('No data')),
          );
        }
        final movie = api.topRatedMovies[idx];
        imagePath = movie['poster_path'];
        return TmdbImage(
          path: imagePath,
          fit: BoxFit.cover,
          size: TmdbImageSize.w342,
        );
      } else {
        if (idx >= api.upComingMovies.length) {
          return Container(
            color: Colors.grey[800],
            child: const Center(child: Text('No data')),
          );
        }
        final movie = api.upComingMovies[idx];
        imagePath = movie['poster_path'];
        return TmdbImage(
          path: imagePath,
          fit: BoxFit.cover,
          size: TmdbImageSize.w342,
        );
      }
    } catch (e) {
      return Container(
        color: Colors.grey[800],
        child: Center(
          child: Text(
            'Error:\n$e',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.red),
          ),
        ),
      );
    }
  }
}

extension MovieTypeExtension on MovieType {
  String get title {
    switch (this) {
      case MovieType.popular:
        return "Popular";
      case MovieType.top_rated:
        return "Top Rated";
      case MovieType.upcoming:
        return "Upcoming";
    }
  }
}
