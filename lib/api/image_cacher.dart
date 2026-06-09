import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

enum TmdbImageSize { w185, w342, w500, w780, original }

class TmdbImage extends StatelessWidget {
  final String? path;
  final BoxFit fit;
  final TmdbImageSize size;
  final Widget? placeholder;

  const TmdbImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.size = TmdbImageSize.w500,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return _errorWidget(icon: Icons.image_not_supported, text: 'No image');
    }

    final imageUrl = 'https://image.tmdb.org/t/p/${size.name}$path';

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 250),
      placeholder: (context, url) => placeholder ?? _loadingWidget(),
      errorWidget: (context, url, error) =>
          _errorWidget(icon: Icons.broken_image, text: 'Failed to load'),
    );
  }

  Widget _loadingWidget() {
    return SizedBox(
      width: 24,
      height: 24,
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _errorWidget({required IconData icon, required String text}) {
    return Container(
      color: Colors.grey.shade800,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey, size: 40),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
