import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../app/translations.dart';
import '../../../core/responsive/size_config.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../models/movie.dart';
import '../../../app/app_theme.dart';
import '../../widgets/custom_poster_widget.dart';
import '../../movie_detail/movie_detail_view.dart';
import '../../../viewmodels/home_view_model.dart';
import 'package:provider/provider.dart';

class SliderWidget extends StatefulWidget {
  final List<Movie> movies;

  const SliderWidget({super.key, required this.movies});

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.movies.isNotEmpty) {
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (_currentPage < widget.movies.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox();

    return Column(
      children: [
        SizedBox(
          height: SizeConfig.relativeSize(500),
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.movies.length,
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
              return _buildSlide(context, movie);
            },
          ),
        ),
        SizedBox(height: SizeTokens.paddingSmall),
        _buildIndicator(),
      ],
    );
  }

  Widget _buildSlide(BuildContext context, Movie movie) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MovieDetailView(movie: movie)),
        ).then((_) {
          if (!context.mounted) return;
          context.read<HomeViewModel>().init();
        });
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Background Image
          SizedBox(
            height: SizeConfig.relativeSize(500),
            width: double.infinity,
            child: movie.posterLocalPath != null
                ? Image.file(
                    File(movie.posterLocalPath!),
                    fit: BoxFit.fill,
                    cacheWidth: 300,
                    cacheHeight: 444,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: AppTheme.surfaceLightColor),
                  )
                : (movie.posterUrl != null && movie.posterUrl != 'N/A')
                ? Image.network(
                    movie.posterUrl!,
                    fit: BoxFit.contain,
                    cacheWidth: 300,
                    cacheHeight: 444,
                    errorBuilder: (context, error, stackTrace) =>
                        CustomPosterWidget(movie: movie),
                  )
                : CustomPosterWidget(movie: movie),
          ),
          // Gradient
          Container(
            height: SizeConfig.relativeSize(500),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, AppTheme.backgroundColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.3, 1.0],
              ),
            ),
          ),
          // Content
          Positioned(
            top: SizeTokens.paddingMedium,
            right: SizeTokens.paddingMedium,
            child: movie.id.startsWith('suggested_')
                ? Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeTokens.paddingSmall,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(
                        SizeTokens.radiusSmall,
                      ),
                    ),
                    child: Text(
                      Translations.tr('suggested'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
          Positioned(
            bottom: SizeTokens.paddingLarge,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  alignment: Alignment.center,
                  child: Text(
                    movie.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: SizeTokens.textLarge * 1.5,
                      fontWeight: FontWeight.bold,
                      shadows: const [
                        Shadow(color: Colors.black, blurRadius: 4),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (movie.genre.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: SizeTokens.paddingSmall,
                    ),
                    child: Text(
                      movie.genre.split(',').take(3).join(' • '),
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: SizeTokens.textMedium,
                      ),
                    ),
                  ),
                if (movie.imdbRating != null && movie.imdbRating != 'N/A')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        movie.imdbRating!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: SizeTokens.paddingMedium),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeTokens.paddingLarge,
                      vertical: SizeTokens.paddingMedium,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailView(movie: movie),
                      ),
                    ).then((_) {
                      if (!context.mounted) return;
                      context.read<HomeViewModel>().init();
                    });
                  },
                  icon: const Icon(Icons.info_outline),
                  label: Text(
                    Translations.tr('details'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.movies.length,
        (index) => Container(
          width: _currentPage == index ? 12.0 : 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            color: _currentPage == index
                ? AppTheme.primaryColor
                : AppTheme.textSecondaryColor,
          ),
        ),
      ),
    );
  }
}
