import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tmdb_movie_explorer/api/image_cacher.dart';
import 'package:tmdb_movie_explorer/pages/home_page.dart';
import 'package:tmdb_movie_explorer/providers/tmdb_api_call.dart';
import 'package:tmdb_movie_explorer/providers/yt_trailer.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class MovieDetailPage extends StatefulWidget {
  final String movieId;

  const MovieDetailPage({super.key, required this.movieId});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  Map movieDetails = {};
  bool isDetailsError = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetails();
    });
  }

  Future<void> _loadDetails() async {
    try {
      final details = await context.read<ApiCallManager>().fetchMovieDetails(
        widget.movieId,
      );

      if (!mounted) return;

      setState(() {
        movieDetails = details;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isDetailsError = true;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isDetailsError) {
      setState(() {
        isDetailsError = false;
        _loadDetails();
      });
    }

    if (movieDetails.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  movieDetails['title'],
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    textBaseline: TextBaseline.alphabetic,
                  ),
                  overflow: TextOverflow.fade,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  TmdbImage(
                    fit: BoxFit.cover,
                    path: movieDetails['backdrop_path'],
                    size: TmdbImageSize.w780,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black54,
                          Colors.black,
                        ],
                        stops: const [0.0, 0.6, 0.85, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.star_rate, color: Colors.yellow),
                        const SizedBox(width: 2),
                        Text(
                          '${movieDetails['vote_average']}/10 • ${Duration(minutes: movieDetails['runtime']).inHours}h ${movieDetails['runtime'] % 60}m • ${DateFormat('dd-MMM-yyyy').format(DateTime.parse(movieDetails['release_date']))}',
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: movieDetails['genres'].length,
                      itemBuilder: (context, idx) {
                        if (idx == movieDetails['genres'].length - 1) {
                          return Text('${movieDetails['genres'][idx]['name']}');
                        }
                        return Text(
                          '${movieDetails['genres'][idx]['name']} • ',
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: FilledButton(
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.all(
                            Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              CustomYtWidget(movieId: widget.movieId),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.movie),
                        SizedBox(width: 10),
                        Text('Trailer'),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: ButtonStyle(
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.all(
                                  Radius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          onPressed: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 5,
                            children: [Icon(Icons.add), Text('My list')],
                          ),
                        ),
                      ),
                      Expanded(
                        child: OutlinedButton(
                          style: ButtonStyle(
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.all(
                                  Radius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          onPressed: () {},
                          child: Row(
                            spacing: 0.329,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [Icon(Icons.done), Text('Watched')],
                          ),
                        ),
                      ),
                      Expanded(
                        child: OutlinedButton(
                          style: ButtonStyle(
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.all(
                                  Radius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          onPressed: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [Icon(Icons.thumb_up), Text('Rate')],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Text(movieDetails['overview'] ?? ''),
                ),
                SizedBox(child: SimilarMovies(movieId: widget.movieId)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomYtWidget extends StatefulWidget {
  final String movieId;
  const CustomYtWidget({super.key, required this.movieId});
  @override
  State<CustomYtWidget> createState() => _CustomYtWidgetState();
}

class _CustomYtWidgetState extends State<CustomYtWidget> {
  bool isYtError = false;
  bool isAvailable = true;
  bool isLoading = true;
  final controller = YoutubePlayerController(
    params: YoutubePlayerParams(
      mute: false,
      showControls: true,
      showVideoAnnotations: false,

      showFullscreenButton: true,
    ),
  );
  @override
  void initState() {
    super.initState();

    controller.stream.listen((value) {
      if (value.fullScreenOption.enabled) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrailer();
    });
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  Future<void> _loadTrailer() async {
    try {
      final ytID = await context.read<YtTrailer>().fetchYtId(widget.movieId);

      if (!mounted) return;

      if (ytID.isEmpty) {
        setState(() {
          isAvailable = false;
          isLoading = false;
        });
        return;
      } else {
        setState(() {
          isLoading = false;
        });
      }

      await controller.loadVideoById(videoId: ytID);

      setState(() {
        isLoading = false;
        isYtError = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isYtError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isAvailable) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Trailer not found')),
      );
    }
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SizedBox(
          child: !isYtError
              ? Column(children: [YoutubePlayer(controller: controller)])
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error in loading trailer click to retry'),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            isYtError = false;
                          });

                          _loadTrailer();
                        },
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class SimilarMovies extends StatefulWidget {
  final String movieId;
  const SimilarMovies({super.key, required this.movieId});

  @override
  State<SimilarMovies> createState() => _SimilarMoviesState();
}

class _SimilarMoviesState extends State<SimilarMovies> {
  List similarMovies = [];
  @override
  void initState() {
    super.initState();
    _loadSimilarMovies();
  }

  void _loadSimilarMovies() async {
    final movies = await context.read<ApiCallManager>().getSimilarMovies(
      widget.movieId,
    );

    if (!mounted) return;

    setState(() {
      similarMovies = movies;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (similarMovies.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'See similar',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.67,
            ),
            itemCount: similarMovies.length,
            itemBuilder: (context, idx) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieDetailPage(
                        movieId: similarMovies[idx]['id'].toString(),
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: TmdbImage(path: similarMovies[idx]['poster_path']),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
