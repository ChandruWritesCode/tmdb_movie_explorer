import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmdb_movie_explorer/api/image_cacher.dart';
import 'package:tmdb_movie_explorer/pages/movie_detail_page.dart';
import 'package:tmdb_movie_explorer/providers/tmdb_api_call.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Timer? _debounce;
  late final SearchController searchCont;
  bool isFocus = false;

  @override
  void initState() {
    super.initState();

    searchCont = SearchController();

    searchCont.addListener(() {
      final hasText = searchCont.text.isNotEmpty;
      if (hasText != isFocus) {
        setState(() {
          isFocus = hasText;
        });
      }
    });
  }

  @override
  void dispose() {
    searchCont.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final api = context.watch<ApiCallManager>();
    return SafeArea(
      bottom: false,
      child: AnimatedAlign(
        curve: Curves.linearToEaseOut,
        alignment: isFocus ? .topCenter : .bottomCenter,
        duration: Duration(milliseconds: 500),
        child: Stack(
          // fit: .expand,
          children: [
            if (isFocus)
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 80),
                    Text('Top results'),
                    if (api.searchResults == null)
                      Center(child: const CircularProgressIndicator()),
                    if (api.searchResults != null)
                      GridView.builder(
                        clipBehavior: .antiAlias,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: api.searchResults?.length ?? 0,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: 500 / 750,
                              crossAxisCount: 2,
                            ),
                        itemBuilder: (context, idx) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => MovieDetailPage(
                                        movieId: api.searchResults![idx]['id']
                                            .toString(),
                                      ),
                                    ),
                                  );
                                },
                                child: TmdbImage(
                                  fit: .cover,
                                  path: api.searchResults?[idx]['poster_path'],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            SafeArea(
              child: Container(
                // color: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: SearchBar(
                      backgroundColor: WidgetStatePropertyAll(
                        Colors.transparent,
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          side: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      leading: const Icon(Icons.search_sharp),
                      hintText: 'explore!',
                      controller: searchCont,
                      onChanged: (value) {
                        _debounce?.cancel();
                        _debounce = Timer(
                          const Duration(milliseconds: 500),
                          () {
                            if (value.isEmpty) {
                              context.read<ApiCallManager>().startSearch();
                            } else {
                              api.searchWithQuery(value);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
