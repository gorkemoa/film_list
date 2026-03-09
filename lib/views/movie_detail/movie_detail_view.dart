import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/translations.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../models/movie.dart';
import '../../models/review.dart';
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
  int storyRating = 1;
  int musicRating = 1;
  int actingRating = 1;
  int cinematographyRating = 1;
  bool recommend = true;
  bool watchAgain = true;
  bool _isEditingReview = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieDetailViewModel>().initMovie(widget.movie);
    });
  }

  void _submitReview() {
    context.read<MovieDetailViewModel>().rateMovie(
      story: storyRating * 2,
      music: musicRating * 2,
      acting: actingRating * 2,
      cinematography: cinematographyRating * 2,
      recommend: recommend,
      watchAgain: watchAgain,
      comment: _commentController.text.trim(),
    );
    _commentController.clear();
    setState(() => _isEditingReview = false);
    FocusScope.of(context).unfocus();
  }

  void _editReview(Review review) {
    setState(() {
      storyRating = review.storyRating ~/ 2;
      musicRating = review.musicRating ~/ 2;
      actingRating = review.actingRating ~/ 2;
      cinematographyRating = review.cinematographyRating ~/ 2;
      recommend = review.recommend;
      watchAgain = review.watchAgain;
      _commentController.text = review.comment ?? '';
      _isEditingReview = true;
    });
  }

  Future<void> _deleteReview() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          Translations.tr('deleteReview'),
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          Translations.tr('deleteReviewConfirm'),
          style: const TextStyle(color: AppTheme.textSecondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              Translations.tr('cancel'),
              style: const TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              Translations.tr('delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (mounted) {
        await context.read<MovieDetailViewModel>().deleteReview();
      }
    }
  }

  Widget _buildSliverBackground(BuildContext context, Movie movie) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        if (movie.posterLocalPath != null)
          Image.file(
            File(movie.posterLocalPath!),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                CustomPosterWidget(movie: movie),
          )
        else if (movie.posterUrl != null && movie.posterUrl != 'N/A')
          Image.network(
            movie.posterUrl!,
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) =>
                CustomPosterWidget(movie: movie),
          )
        else
          CustomPosterWidget(movie: movie),
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

  Widget _buildStarRater(String label, int value, ValueChanged<int> onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: SizeTokens.paddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: SizeTokens.textSmall,
              color: AppTheme.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
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

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value == 'N/A' || value.isEmpty)
      return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              Translations.tr(label),
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaDataItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: SizeTokens.textSmall,
                color: AppTheme.textSecondaryColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: SizeTokens.textMedium,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildWatchCountRow(MovieDetailViewModel viewModel) {
    final movie = viewModel.currentMovie!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${Translations.tr('watchCount')}: ${movie.watchCount}',
          style: TextStyle(
            fontSize: SizeTokens.textMedium,
            fontWeight: FontWeight.bold,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        ElevatedButton.icon(
          onPressed: viewModel.incrementWatchCount,
          icon: const Icon(Icons.add, size: 16),
          label: Text(Translations.tr('watchOneMoreTime')),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.surfaceLightColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewDetailRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondaryColor),
          ),
          Text(
            '$value / 10',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer<MovieDetailViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.currentMovie == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final movie = viewModel.currentMovie ?? widget.movie;
          final review = viewModel.currentReview;

          Widget buildPlotSection() {
            if (viewModel.isLoading && viewModel.translatedPlot == null) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            if (viewModel.translatedPlot != null &&
                viewModel.translatedPlot!.isNotEmpty &&
                viewModel.translatedPlot != 'N/A') {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Translations.tr('plotDescription'),
                    style: TextStyle(
                      fontSize: SizeTokens.textTitle,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.translatedPlot!,
                    style: TextStyle(
                      fontSize: SizeTokens.textMedium,
                      color: AppTheme.textSecondaryColor,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }
            return const SizedBox();
          }

          Widget buildInfoSection() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Translations.tr('movieInfoTab'),
                  style: TextStyle(
                    fontSize: SizeTokens.textTitle,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: SizeTokens.circularRadiusMedium,
                    border: Border.all(color: AppTheme.surfaceLightColor),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow('directorLabel', movie.director),
                      _buildInfoRow('writerLabel', movie.writer),
                      _buildInfoRow('actorsLabel', movie.actors),
                      _buildInfoRow('languageLabel', movie.language),
                      _buildInfoRow('countryLabel', movie.country),
                      _buildInfoRow('boxOfficeLabel', movie.boxOffice),
                      _buildInfoRow('ratedLabel', movie.rated),
                      _buildInfoRow('releasedLabel', movie.released),
                      if (movie.ratings.isNotEmpty) ...[
                        const Divider(
                          color: AppTheme.surfaceLightColor,
                          height: 20,
                        ),
                        ...movie.ratings.map(
                          (r) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  r.source,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  r.value,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: SizeConfig.relativeSize(450),
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    movie.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                    ),
                  ),
                  background: _buildSliverBackground(context, movie),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Metadata
                      Row(
                        children: [
                          _buildMetaDataItem(
                            Icons.category_outlined,
                            movie.genre.split(',').first,
                          ),
                          _buildMetaDataItem(
                            Icons.timer_outlined,
                            movie.runtime ?? 'N/A',
                          ),
                          _buildMetaDataItem(
                            Icons.star_rounded,
                            movie.imdbRating ?? 'N/A',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Layout logic: Plot/Info location
                      if (!movie.isWatched) ...[
                        buildPlotSection(),
                        buildInfoSection(),
                      ],

                      // Watch / Rate Section
                      if (viewModel.isLocal) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Translations.tr('isWatched'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Switch(
                              value: movie.isWatched,
                              onChanged: (_) => viewModel.toggleWatched(movie),
                              activeColor: AppTheme.primaryColor,
                            ),
                          ],
                        ),
                        if (movie.isWatched) ...[
                          const SizedBox(height: 8),
                          _buildWatchCountRow(viewModel),
                          const SizedBox(height: 24),

                          // Display User Review if exists AND not editing
                          if (review != null && !_isEditingReview) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  Translations.tr('rateMovie'),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => _editReview(review),
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: AppTheme.primaryColor,
                                      ),
                                      tooltip: Translations.tr('edit'),
                                    ),
                                    IconButton(
                                      onPressed: _deleteReview,
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                      ),
                                      tooltip: Translations.tr('delete'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor,
                                borderRadius: SizeTokens.circularRadiusMedium,
                                border: Border.all(
                                  color: AppTheme.surfaceLightColor,
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            color: Colors.amber,
                                            size: 28,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            review.overallRating
                                                .toStringAsFixed(1),
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Text(
                                            ' / 10',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color:
                                                  AppTheme.textSecondaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (movie.imdbRating != null &&
                                          movie.imdbRating != 'N/A')
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: Colors.amber.withOpacity(
                                                0.5,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Text(
                                                'IMDb: ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.amber,
                                                ),
                                              ),
                                              Text(
                                                movie.imdbRating!,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Comparison Statement
                                  if (movie.imdbRating != null &&
                                      movie.imdbRating != 'N/A') ...[
                                    Builder(
                                      builder: (context) {
                                        final imdb =
                                            double.tryParse(
                                              movie.imdbRating!,
                                            ) ??
                                            0;
                                        final diff =
                                            review.overallRating - imdb;
                                        final isHigher = diff > 0;
                                        return Container(
                                          padding: const EdgeInsets.all(10),
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color:
                                                (isHigher
                                                        ? Colors.green
                                                        : Colors.red)
                                                    .withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            isHigher
                                                ? Translations.tr('ratingHigher').replaceFirst('{diff}', diff.abs().toStringAsFixed(1))
                                                : diff == 0
                                                ? Translations.tr('ratingMatch')
                                                : Translations.tr('ratingLower').replaceFirst('{diff}', diff.abs().toStringAsFixed(1)),
                                            style: TextStyle(
                                              color: isHigher
                                                  ? Colors.green
                                                  : (diff == 0
                                                        ? Colors.blue
                                                        : Colors.red),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                  ],

                                  _buildReviewDetailRow(
                                    Translations.tr('storyRating'),
                                    review.storyRating,
                                  ),
                                  _buildReviewDetailRow(
                                    Translations.tr('musicRating'),
                                    review.musicRating,
                                  ),
                                  _buildReviewDetailRow(
                                    Translations.tr('actingRating'),
                                    review.actingRating,
                                  ),
                                  _buildReviewDetailRow(
                                    Translations.tr('cinematographyRating'),
                                    review.cinematographyRating,
                                  ),

                                  if (review.comment != null &&
                                      review.comment!.isNotEmpty) ...[
                                    const Divider(
                                      height: 24,
                                      color: AppTheme.surfaceLightColor,
                                    ),
                                    Text(
                                      Translations.tr('commentLabel'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textSecondaryColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      review.comment!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        height: 1.4,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ] else ...[
                            // Rate Movie Form (New or Editing)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  Translations.tr(
                                    _isEditingReview
                                        ? 'editReview'
                                        : 'rateMovie',
                                  ),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_isEditingReview)
                                  TextButton(
                                    onPressed: () => setState(
                                      () => _isEditingReview = false,
                                    ),
                                    child: Text(
                                      Translations.tr('cancel'),
                                      style: const TextStyle(
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor,
                                borderRadius: SizeTokens.circularRadiusMedium,
                                border: Border.all(
                                  color: AppTheme.surfaceLightColor,
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _buildStarRater(
                                    Translations.tr('storyRating'),
                                    storyRating,
                                    (v) => setState(() => storyRating = v),
                                  ),
                                  _buildStarRater(
                                    Translations.tr('musicRating'),
                                    musicRating,
                                    (v) => setState(() => musicRating = v),
                                  ),
                                  _buildStarRater(
                                    Translations.tr('actingRating'),
                                    actingRating,
                                    (v) => setState(() => actingRating = v),
                                  ),
                                  _buildStarRater(
                                    Translations.tr('cinematographyRating'),
                                    cinematographyRating,
                                    (v) => setState(
                                      () => cinematographyRating = v,
                                    ),
                                  ),
                                  const Divider(height: 32),
                                  _buildSwitchRow(
                                    Translations.tr('recommend'),
                                    recommend,
                                    (v) => setState(() => recommend = v),
                                  ),
                                  _buildSwitchRow(
                                    Translations.tr('watchAgain'),
                                    watchAgain,
                                    (v) => setState(() => watchAgain = v),
                                  ),
                                  const Divider(height: 32),

                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      Translations.tr('commentLabel'),
                                      style: const TextStyle(
                                        color: AppTheme.textSecondaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _commentController,
                                    maxLines: 3,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppTheme.surfaceLightColor
                                          .withOpacity(0.2),
                                      hintText: '...',
                                      hintStyle: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _submitReview,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        Translations.tr('submitReview'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ],
                      ] else ...[
                        // Suggested view: Show add button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: viewModel.addMovieToLocalList,
                            icon: const Icon(Icons.add),
                            label: Text(Translations.tr('addToList')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Layout logic: Plot/Info at bottom
                      if (movie.isWatched) ...[
                        const SizedBox(height: 32),
                        buildPlotSection(),
                        buildInfoSection(),
                      ],
                      const SizedBox(height: 40),
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
