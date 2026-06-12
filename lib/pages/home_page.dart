import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmdb_movie_explorer/api/image_cacher.dart';
import 'package:tmdb_movie_explorer/pages/movie_cards_carousel.dart';
import 'package:tmdb_movie_explorer/pages/movie_detail_page.dart';
import 'package:tmdb_movie_explorer/pages/movies_list.dart';
import 'package:tmdb_movie_explorer/pages/search_page.dart';
import 'package:tmdb_movie_explorer/providers/basic_providers.dart';
import 'package:tmdb_movie_explorer/providers/tmdb_api_call.dart';

// ignore: constant_identifier_names
enum MovieType { popular, top_rated, upcoming }

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<void> _moviesFuture;
  int page = 0;
  bool isDrawerOpen = false;
  @override
  void initState() {
    super.initState();
    _moviesFuture = context.read<ApiCallManager>().init();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (page == 1) {
          page = 0;
        }
      },
      child: Scaffold(
        onDrawerChanged: (isOpen) {
          setState(() {
            isDrawerOpen = isOpen;
          });
        },
        key: _scaffoldKey,
        drawer: Drawer(
          width: 250,
          backgroundColor: Theme.of(context).cardColor.withAlpha(150),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: ListView(
              children: [
                // const DrawerHeader(child: Text('Movie Explorer')),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: const Text(
                    'CineVault',
                    style: TextStyle(fontSize: 25),
                  ),
                ),
                ListTile(
                  title: const Text("Toggle Mode"),
                  onTap: () {
                    context.read<SettingsProvider>().toggleDarkMode();
                  },
                  // leading: Icon(
                  //   context.watch<SettingsProvider>().darkMode
                  //       ? Icons.dark_mode
                  //       : Icons.light_mode,
                  // ),
                  trailing: SizedBox(
                    width: 110,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(Icons.light_mode),
                        Switch(
                          activeTrackColor: Colors.white,
                          activeThumbColor: Theme.of(context).highlightColor,
                          value: context.watch<SettingsProvider>().darkMode,
                          onChanged: (_) {
                            context.read<SettingsProvider>().toggleDarkMode();
                          },
                        ),
                        const Icon(Icons.dark_mode),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.movie_filter),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MoviesList(type: .watched),
                      ),
                    );
                  },
                  title: Text('Watched'),
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MoviesList(type: .rated),
                      ),
                    );
                  },
                  leading: Icon(Icons.star),
                  title: Text('Rated'),
                ),

                // ListTile(title: Text('Rated'),),

                // ListView.builder(
                //   physics: NeverScrollableScrollPhysics(),
                //   shrinkWrap: true,
                //   itemCount: context.watch<ApiCallManager>().genres.length,
                //   itemBuilder: (context, idx) {
                //     return Container(
                //       padding: EdgeInsets.all(10),
                //       child: ListTile(
                //         onTap: () {},
                //         title: Text(
                //           context.watch<ApiCallManager>().genres[idx]['name'],
                //         ),
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
          ),
        ),
        extendBody: true,
        bottomNavigationBar: Container(
          color: Colors.transparent,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 18),
          child: Material(
            type: MaterialType.canvas,
            color: const Color.fromARGB(30, 255, 255, 255),
            elevation: 12,
            borderRadius: BorderRadius.circular(10),
            clipBehavior: .antiAlias,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: NavigationBar(
                indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                height: 60,
                indicatorColor: const Color.fromARGB(123, 255, 255, 255),
                backgroundColor: Colors.black.withValues(alpha: 0.15),
                elevation: 10,
                selectedIndex: page,
                onDestinationSelected: (value) {
                  setState(() {
                    page = value;
                  });
                },
                labelBehavior: .onlyShowSelected,
                labelPadding: EdgeInsets.zero,
                destinations: [
                  const NavigationDestination(
                    label: 'home',
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_filled),
                  ),
                  const NavigationDestination(
                    label: 'search',
                    icon: Icon(Icons.search_outlined),
                    selectedIcon: Icon(Icons.search_rounded),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: IndexedStack(
          index: page,
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
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
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      context
                                          .read<ApiCallManager>()
                                          .getGenres();
                                      _scaffoldKey.currentState?.openDrawer();
                                    },
                                    child: AnimatedRotation(
                                      turns: isDrawerOpen ? 0.25 : 0.0, // 90°
                                      duration: const Duration(
                                        milliseconds: 600,
                                      ),
                                      curve: Curves.easeInOut,
                                      child: Icon(Icons.menu, size: 30),
                                    ),
                                  ),
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
                  const SizedBox(height: 125),
                ],
              ),
            ),
            SearchPage(),
          ],
        ),
      ),
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
          fit: BoxFit.contain,
        ),

        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.transparent, Colors.black],
            ),
          ),
        ),

        Positioned(
          left: 20,
          right: 20,
          bottom: 5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          MovieDetailPage(movieId: movie['id'].toString()),
                    ),
                  );
                },
                child: const Text("Details"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
