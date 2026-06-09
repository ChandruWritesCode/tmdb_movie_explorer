import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tmdb_movie_explorer/api/image_cacher.dart';
import 'package:tmdb_movie_explorer/providers/tmdb_api_call.dart';
import 'package:tmdb_movie_explorer/providers/yt_trailer.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class MovieDetailPage extends StatefulWidget {
  final String movieId;

  const MovieDetailPage({super.key, required this.movieId});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

bool isYtError = false;
bool isDetailsError = false;

class _MovieDetailPageState extends State<MovieDetailPage> {
  late YoutubePlayerController controller;
  @override
  void initState() {
    super.initState();
    controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        enableJavaScript: false,
        playsInline: false,
        showVideoAnnotations: false,
        mute: false,
        showControls: true,
        strictRelatedVideos: true,
        showFullscreenButton: true,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrailer();
      _loadDetails();
    });
  }

  Future<void> _loadTrailer() async {
    try {
      final videoId = await context.read<YtTrailer>().fetchYtId(widget.movieId);

      if (videoId.isNotEmpty) {
        await controller.cueVideoById(videoId: videoId);
      }
    } catch (e) {
      setState(() {});
      isYtError = true;
      debugPrint('Trailer loading error: $e');
    }
  }

  Future<void> _loadDetails() async {
    try {
      await context.read<ApiCallManager>().getDetails(widget.movieId);
    } catch (e) {
      setState(() {});
      isDetailsError = true;
      debugPrint('Details loading error: $e');
    }
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movieDetails = context.watch<ApiCallManager>().movieDetails;
    // ignore: unused_local_variable
    final myYoutubePlayerWidget = SizedBox(
      width: double.infinity,
      child: !isYtError
          ? YoutubePlayer(controller: controller, aspectRatio: 16 / 9)
          : Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _loadTrailer();
                    isYtError = false;
                  });
                },
                child: Text('Retry'),
              ),
            ),
    );

    if (context.watch<ApiCallManager>().movieDetails.isEmpty) {
      return PopScope(
        onPopInvokedWithResult: (didPop, result) {
          context.read<ApiCallManager>().setMovieDetails = {};
        },
        child: Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (isDetailsError) {
      return PopScope(
        onPopInvokedWithResult: (didPop, result) {
          context.read<ApiCallManager>().setMovieDetails = {};
        },
        child: Scaffold(
          appBar: AppBar(),
          body: Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _loadDetails();
                  isDetailsError = false;
                });
              },
              child: Text('Retry'),
            ),
          ),
        ),
      );
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        context.read<ApiCallManager>().setMovieDetails = {};
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 300,
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                  context.read<ApiCallManager>().setMovieDetails = {};
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
                      textBaseline: TextBaseline.alphabetic,
                    ),
                    overflow: TextOverflow.ellipsis,
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
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadiusGeometry.all(
                          Radius.circular(10),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: movieDetails['genres'].length,
                        itemBuilder: (context, idx) {
                          if (idx == movieDetails['genres'].length - 1) {
                            return Text(
                              '${movieDetails['genres'][idx]['name']}',
                            );
                          }
                          return Text(
                            '${movieDetails['genres'][idx]['name']} • ',
                          );
                        },
                      ),
                    ),
                  ),
                  Container(
                    height: 2000,
                    padding: const EdgeInsets.all(8),
                    child: Text(movieDetails['overview'] ?? ''),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
