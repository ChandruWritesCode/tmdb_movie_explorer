import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:tmdb_movie_explorer/api/image_cacher.dart';
import 'package:tmdb_movie_explorer/heroWidgets/all_heros.dart';
import 'package:tmdb_movie_explorer/pages/movie_detail_page.dart';
import 'package:tmdb_movie_explorer/pages/see_all.dart';
import 'package:tmdb_movie_explorer/pages/settings_page.dart';
import 'package:tmdb_movie_explorer/providers/tmdb_api_call.dart';

// ignore: constant_identifier_names
enum MovieType { popular, top_rated, upcoming }

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<void> _moviesFuture;
  int page = 0;
  @override
  void initState() {
    super.initState();

    _moviesFuture = Future.wait([
      context.read<ApiCallManager>().get('Popular'),
      context.read<ApiCallManager>().get('Top Rated'),
      context.read<ApiCallManager>().get('Upcoming'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 100,
            tileMode: TileMode.repeated,
          ),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedIndex: page,
            onDestinationSelected: (value) {
              setState(() {
                page = value;
              });
            },
            labelBehavior: .onlyShowSelected,
            destinations: [
              NavigationDestination(
                label: 'home',
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_filled),
              ),
              NavigationDestination(
                label: 'search',
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
              ),
            ],
          ),
        ),
      ),
      body: page == 0
          ? SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 600,
                    child: Stack(
                      children: [
                        CustomCarousel(
                          moviesFuture: _moviesFuture,
                          options: CarouselOptions(
                            height: 600,
                            viewportFraction: 1,
                            autoPlay: true,
                            enlargeCenterPage: false,
                          ),
                          type: MovieType.popular,
                        ),

                        SafeArea(
                          child: Container(
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  child: const LogoAnim(),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const SettingsPage(),
                                      ),
                                    );
                                  },
                                  icon: const UserHero(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  CustomCarousel(
                    moviesFuture: _moviesFuture,
                    options: CarouselOptions(
                      viewportFraction: 0.4,
                      autoPlay: false,
                    ),
                    type: MovieType.top_rated,
                  ),

                  CustomCarousel(
                    moviesFuture: _moviesFuture,
                    options: CarouselOptions(
                      viewportFraction: 0.4,
                      autoPlay: false,
                    ),
                    type: MovieType.upcoming,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            )
          : Center(child: Text("Search feature will be added soon!")),
    );
  }
}

class PopularMovieCard extends StatelessWidget {
  final Map<String, dynamic> movie;

  const PopularMovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        TmdbImage(
          size: TmdbImageSize.original,
          path: movie['poster_path'],
          fit: BoxFit.fitHeight,
        ),

        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.transparent,
                Colors.transparent,
                Colors.transparent,
                Colors.black,
              ],
            ),
          ),
        ),

        Positioned(
          left: 20,
          right: 20,
          bottom: 5,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Play"),
                  ),

                  const SizedBox(width: 12),

                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => MovieDetailPage()),
                      );
                    },
                    child: const Text("Details"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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
      return FutureBuilder(
        future: _moviesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // if (snapshot.hasError) {
          //   return Center(child: Text('${snapshot.error}'));
          // }

          final movies = api.popularMovies;

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
                type.title,
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

            final itemCount = type == MovieType.top_rated
                ? api.topRatedMovies.length
                : api.upComingMovies.length;

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
                      borderRadius: BorderRadius.circular(20),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MovieDetailPage(),
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
