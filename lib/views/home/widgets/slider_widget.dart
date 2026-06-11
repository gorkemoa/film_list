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

  double get _sliderHeight => SizeConfig.relativeHeight(46);

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
          height: _sliderHeight,
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
        SizedBox(height: SizeTokens.paddingMin),
        _buildIndicator(),
      ],
    );
  }

  Widget _buildSlide(BuildContext context, Movie movie) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeTokens.paddingMedium),
      child: InkWell(
        borderRadius: SizeTokens.circularRadiusMedium,
        onTap: () => _openDetail(context, movie),
        child: ClipRRect(
          borderRadius: SizeTokens.circularRadiusMedium,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildPoster(movie),
              _buildGradientOverlay(),
              Positioned(
                left: SizeTokens.paddingMedium,
                right: SizeTokens.paddingMedium,
                bottom: SizeTokens.paddingMedium,
                child: _buildNetflixContent(context, movie),
              ),
              if (movie.id.startsWith('suggested_'))
                Positioned(
                  top: SizeTokens.paddingMedium,
                  right: SizeTokens.paddingMedium,
                  child: _buildSuggestedPill(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoster(Movie movie) {
    if (movie.posterLocalPath != null) {
      return Image.file(
        File(movie.posterLocalPath!),
        fit: BoxFit.cover,
        cacheWidth: 800,
        cacheHeight: 1200,
        errorBuilder: (context, error, stackTrace) => CustomPosterWidget(
          movie: movie,
          width: double.infinity,
          height: _sliderHeight,
        ),
      );
    }

    if (movie.posterUrl != null && movie.posterUrl != 'N/A') {
      return Image.network(
        movie.posterUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => CustomPosterWidget(
          movie: movie,
          width: double.infinity,
          height: _sliderHeight,
        ),
      );
    }

    return CustomPosterWidget(
      movie: movie,
      width: double.infinity,
      height: _sliderHeight,
    );
  }

  Widget _buildGradientOverlay() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.78),
            Colors.black.withValues(alpha: 0.24),
            AppTheme.backgroundColor.withValues(alpha: 0.92),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.48, 1.0],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              AppTheme.backgroundColor.withValues(alpha: 0.96),
            ],
            begin: Alignment.center,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  Widget _buildNetflixContent(BuildContext context, Movie movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (movie.imdbRating != null && movie.imdbRating != 'N/A') ...[
              _buildRatingPill(movie.imdbRating!),
              SizedBox(width: SizeTokens.paddingSmall),
            ],
            if (movie.type != null && movie.type!.isNotEmpty)
              _buildTypePill(movie.type!),
          ],
        ),
        SizedBox(height: SizeTokens.paddingSmall),
        SizedBox(
          width: SizeConfig.relativeWidth(78),
          child: Text(
            movie.title,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: AppTheme.textPrimaryColor,
              fontSize: SizeTokens.textTitle * 1.18,
              fontWeight: FontWeight.w900,
              height: 1.02,
              letterSpacing: -0.4,
              shadows: const [Shadow(color: Colors.black, blurRadius: 6)],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (movie.genre.isNotEmpty) ...[
          SizedBox(height: SizeTokens.paddingSmall),
          Text(
            movie.genre.split(',').take(3).map((e) => e.trim()).join(' • '),
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: SizeTokens.textSmall,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        SizedBox(height: SizeTokens.paddingMedium),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
            padding: EdgeInsets.symmetric(
              horizontal: SizeTokens.paddingMedium,
              vertical: SizeTokens.paddingSmall,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: SizeTokens.circularRadiusSmall,
            ),
          ),
          onPressed: () => _openDetail(context, movie),
          icon: Icon(Icons.info_outline, size: SizeTokens.iconSmall),
          label: Text(
            Translations.tr('details'),
            style: TextStyle(
              fontSize: SizeTokens.textSmall,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingPill(String rating) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.paddingSmall,
        vertical: SizeTokens.paddingMin,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        borderRadius: SizeTokens.circularRadiusSmall,
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            color: Colors.amber,
            size: SizeTokens.iconSmall,
          ),
          SizedBox(width: SizeTokens.paddingMin),
          Text(
            'IMDb $rating',
            style: TextStyle(
              color: AppTheme.textPrimaryColor,
              fontSize: SizeTokens.textSmall,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypePill(String type) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.paddingSmall,
        vertical: SizeTokens.paddingMin,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.82),
        borderRadius: SizeTokens.circularRadiusSmall,
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: SizeTokens.textSmall,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildSuggestedPill() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.paddingSmall,
        vertical: SizeTokens.paddingMin,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: SizeTokens.circularRadiusSmall,
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.45),
        ),
      ),
      child: Text(
        Translations.tr('suggested'),
        style: TextStyle(
          color: Colors.white,
          fontSize: SizeTokens.textSmall,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MovieDetailView(movie: movie)),
    ).then((_) {
      if (!context.mounted) return;
      context.read<HomeViewModel>().init();
    });
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.movies.length,
        (index) => Container(
          width: _currentPage == index
              ? SizeTokens.paddingMedium
              : SizeTokens.paddingSmall,
          height: SizeTokens.paddingMin,
          margin: EdgeInsets.symmetric(horizontal: SizeTokens.paddingMin / 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeTokens.radiusSmall),
            color: _currentPage == index
                ? AppTheme.primaryColor
                : AppTheme.textSecondaryColor,
          ),
        ),
      ),
    );
  }
}
