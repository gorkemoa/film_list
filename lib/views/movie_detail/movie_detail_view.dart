import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/translations.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../models/movie.dart';
import '../../viewmodels/movie_detail_view_model.dart';
import '../widgets/custom_poster_widget.dart';
import '../../app/app_theme.dart';

class MovieDetailView extends StatefulWidget {
  final Movie movie;

  const MovieDetailView({super.key, required this.movie});

  @override
  State<MovieDetailView> createState() => _MovieDetailViewState();
}

class _MovieDetailViewState extends State<MovieDetailView> {
  int story = 1;
  int music = 1;
  int acting = 1;
  int cinematography = 1;
  bool recommend = true;
  bool watchAgain = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieDetailViewModel>().initMovie(widget.movie);
    });
  }

  void _submitReview(BuildContext context) {
    context.read<MovieDetailViewModel>().rateMovie(
      story: story,
      music: music,
      acting: acting,
      cinematography: cinematography,
      recommend: recommend,
      watchAgain: watchAgain,
    );
  }

  Widget _buildSliverBackground(BuildContext context, Movie movie) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (movie.posterLocalPath != null)
          Image.file(
            File(movie.posterLocalPath!),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                CustomPosterWidget(movie: movie),
          )
        else if (movie.posterUrl != null && movie.posterUrl != 'N/A')
          Image.network(
            movie.posterUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                CustomPosterWidget(movie: movie),
          )
        else
          CustomPosterWidget(movie: movie),
        // Gradient overlay for smooth transition to background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black26,
                Colors.transparent,
                AppTheme.backgroundColor,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  // _fallbackIcon removed in favor of CustomPosterWidget

  Widget _buildStarRater(String label, int value, ValueChanged<int> onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: SizeTokens.paddingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: SizeTokens.textMedium,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  index < value ? Icons.star : Icons.star_border,
                  color: index < value
                      ? Colors.amber
                      : AppTheme.textTertiaryColor,
                  size: SizeTokens.iconLarge,
                ),
                onPressed: () => onChanged(index + 1),
              );
            }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MovieDetailViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.currentMovie == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final movie = viewModel.currentMovie ?? widget.movie;
          final review = viewModel.currentReview;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: SizeConfig.relativeSize(400),
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    movie.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                  ),
                  background: _buildSliverBackground(context, movie),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(SizeTokens.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Additional Detail Fields
                      if (movie.genre.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: SizeTokens.paddingSmall,
                          ),
                          child: Text(
                            movie.genre,
                            style: TextStyle(
                              fontSize: SizeTokens.textMedium,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ),
                      if (movie.runtime != null && movie.runtime!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: SizeTokens.paddingSmall,
                          ),
                          child: Text(
                            movie.runtime!,
                            style: TextStyle(
                              fontSize: SizeTokens.textMedium,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ),
                      if (movie.imdbRating != null &&
                          movie.imdbRating!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: SizeTokens.paddingSmall,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: SizeTokens.iconMedium,
                              ),
                              SizedBox(width: 4),
                              Text(
                                movie.imdbRating!,
                                style: TextStyle(
                                  fontSize: SizeTokens.textLarge,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: SizeTokens.paddingLarge),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: SizeTokens.circularRadiusMedium,
                          border: Border.all(color: AppTheme.surfaceLightColor),
                        ),
                        child: !viewModel.isLocal
                            ? Padding(
                                padding: EdgeInsets.all(
                                  SizeTokens.paddingMedium,
                                ),
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.add),
                                  label: Text(Translations.tr('addToList')),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      vertical: SizeTokens.paddingMedium,
                                    ),
                                  ),
                                  onPressed: () =>
                                      viewModel.addMovieToLocalList(),
                                ),
                              )
                            : Column(
                                children: [
                                  SwitchListTile(
                                    title: Text(
                                      Translations.tr('isWatched'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    value: movie.isWatched,
                                    activeThumbColor: AppTheme.primaryColor,
                                    onChanged: (val) {
                                      viewModel.toggleWatched(movie);
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          SizeTokens.circularRadiusMedium,
                                    ),
                                  ),
                                  if (movie.isWatched) ...[
                                    const Divider(height: 1),
                                    Padding(
                                      padding: EdgeInsets.all(
                                        SizeTokens.paddingMedium,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${Translations.tr('watchCount')}: ${movie.watchCount}',
                                            style: TextStyle(
                                              fontSize: SizeTokens.textMedium,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  AppTheme.textSecondaryColor,
                                            ),
                                          ),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              viewModel.incrementWatchCount();
                                            },
                                            icon: Icon(
                                              Icons.add,
                                              size: SizeTokens.iconSmall,
                                            ),
                                            label: Text(
                                              Translations.tr(
                                                'watchOneMoreTime',
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    SizeTokens.paddingMedium,
                                                vertical:
                                                    SizeTokens.paddingSmall,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                      ),

                      if (viewModel.isLocal) ...[
                        SizedBox(height: SizeTokens.paddingXLarge),

                        if (movie.isWatched) ...[
                          Text(
                            Translations.tr('rateMovie'),
                            style: TextStyle(
                              fontSize: SizeTokens.textTitle,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: SizeTokens.paddingMedium),

                          if (review != null) ...[
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor,
                                borderRadius: SizeTokens.circularRadiusMedium,
                                border: Border.all(
                                  color: AppTheme.surfaceLightColor,
                                ),
                              ),
                              padding: EdgeInsets.all(SizeTokens.paddingLarge),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: SizeTokens.iconLarge,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        review.overallRating.toStringAsFixed(1),
                                        style: TextStyle(
                                          fontSize: SizeTokens.textTitle,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: SizeTokens.paddingMedium),
                                  Text(
                                    '${Translations.tr('storyRating')}: ${review.storyRating}/5',
                                    style: TextStyle(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                  ),
                                  Text(
                                    '${Translations.tr('musicRating')}: ${review.musicRating}/5',
                                    style: TextStyle(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                  ),
                                  Text(
                                    '${Translations.tr('actingRating')}: ${review.actingRating}/5',
                                    style: TextStyle(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                  ),
                                  Text(
                                    '${Translations.tr('cinematographyRating')}: ${review.cinematographyRating}/5',
                                    style: TextStyle(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                  ),
                                  SizedBox(height: SizeTokens.paddingSmall),
                                  Text(
                                    '${Translations.tr('recommend')}: ${Translations.tr(review.recommend ? 'yes' : 'no')}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor,
                                borderRadius: SizeTokens.circularRadiusMedium,
                                border: Border.all(
                                  color: AppTheme.surfaceLightColor,
                                ),
                              ),
                              padding: EdgeInsets.all(SizeTokens.paddingMedium),
                              child: Column(
                                children: [
                                  _buildStarRater(
                                    Translations.tr('storyRating'),
                                    story,
                                    (val) => setState(() => story = val),
                                  ),
                                  _buildStarRater(
                                    Translations.tr('musicRating'),
                                    music,
                                    (val) => setState(() => music = val),
                                  ),
                                  _buildStarRater(
                                    Translations.tr('actingRating'),
                                    acting,
                                    (val) => setState(() => acting = val),
                                  ),
                                  _buildStarRater(
                                    Translations.tr('cinematographyRating'),
                                    cinematography,
                                    (val) =>
                                        setState(() => cinematography = val),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: SizeTokens.paddingMedium),
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor,
                                borderRadius: SizeTokens.circularRadiusMedium,
                                border: Border.all(
                                  color: AppTheme.surfaceLightColor,
                                ),
                              ),
                              child: Column(
                                children: [
                                  SwitchListTile(
                                    title: Text(
                                      Translations.tr('recommend'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    value: recommend,
                                    activeThumbColor: AppTheme.primaryColor,
                                    onChanged: (val) =>
                                        setState(() => recommend = val),
                                  ),
                                  Divider(
                                    height: 1,
                                    color: AppTheme.surfaceLightColor,
                                  ),
                                  SwitchListTile(
                                    title: Text(
                                      Translations.tr('watchAgain'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    value: watchAgain,
                                    activeThumbColor: AppTheme.primaryColor,
                                    onChanged: (val) =>
                                        setState(() => watchAgain = val),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: SizeTokens.paddingLarge),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: SizeTokens.paddingMedium,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: SizeTokens.circularRadiusMedium,
                                ),
                              ),
                              onPressed: () => _submitReview(context),
                              child: Text(
                                Translations.tr('submitReview'),
                                style: TextStyle(
                                  fontSize: SizeTokens.textLarge,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
