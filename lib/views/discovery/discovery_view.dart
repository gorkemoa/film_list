import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_theme.dart';
import '../../app/translations.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../models/movie.dart';
import '../../services/discovery_catalog_service.dart';
import '../../viewmodels/discovery_view_model.dart';
import '../movie_detail/movie_detail_view.dart';
import '../widgets/custom_poster_widget.dart';

class DiscoveryView extends StatefulWidget {
  const DiscoveryView({super.key});

  @override
  State<DiscoveryView> createState() => _DiscoveryViewState();
}

class _DiscoveryViewState extends State<DiscoveryView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscoveryViewModel>().init();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = SizeConfig.relativeSize(420);
    final remaining =
        _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    if (remaining < threshold) {
      context.read<DiscoveryViewModel>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Consumer<DiscoveryViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: viewModel.refresh,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context, viewModel)),
              if (viewModel.errorMessage != null && viewModel.movies.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildErrorState(viewModel),
                )
              else if (viewModel.movies.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                _buildGrid(viewModel),
              SliverToBoxAdapter(child: _buildBottomLoader(viewModel)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, DiscoveryViewModel viewModel) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        SizeTokens.paddingMedium,
        SizeTokens.paddingSmall,
        SizeTokens.paddingMedium,
        SizeTokens.paddingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Translations.tr('discoveryTopTitle'),
            style: TextStyle(
              color: AppTheme.textPrimaryColor,
              fontSize: SizeTokens.textTitle,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: SizeTokens.paddingMin),
          Text(
            Translations.tr('discoveryTopSubtitle'),
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: SizeTokens.textSmall,
            ),
          ),
          SizedBox(height: SizeTokens.paddingMedium),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  viewModel,
                  DiscoveryCatalogFilter.all,
                  Translations.tr('discoveryAll'),
                ),
                SizedBox(width: SizeTokens.paddingSmall),
                _buildFilterChip(
                  viewModel,
                  DiscoveryCatalogFilter.movies,
                  Translations.tr('discoveryMovies'),
                ),
                SizedBox(width: SizeTokens.paddingSmall),
                _buildFilterChip(
                  viewModel,
                  DiscoveryCatalogFilter.series,
                  Translations.tr('discoverySeries'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    DiscoveryViewModel viewModel,
    DiscoveryCatalogFilter filter,
    String label,
  ) {
    final isSelected = viewModel.filter == filter;
    return GestureDetector(
      onTap: () => viewModel.setFilter(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.paddingMedium,
          vertical: SizeTokens.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : AppTheme.surfaceLightColor,
          borderRadius: SizeTokens.circularRadiusLarge,
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppTheme.textPrimaryColor
                : AppTheme.textSecondaryColor,
            fontSize: SizeTokens.textSmall,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(DiscoveryViewModel viewModel) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: SizeTokens.paddingMedium),
      sliver: SliverGrid.builder(
        itemCount: viewModel.movies.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.56,
          crossAxisSpacing: SizeTokens.paddingSmall,
          mainAxisSpacing: SizeTokens.paddingMedium,
        ),
        itemBuilder: (context, index) {
          return _DiscoveryMovieCard(
            movie: viewModel.movies[index],
            rank: index + 1,
            onTap: () => _openDetail(context, viewModel.movies[index]),
          );
        },
      ),
    );
  }

  Widget _buildBottomLoader(DiscoveryViewModel viewModel) {
    if (!viewModel.isLoadingMore) {
      return SizedBox(height: SizeConfig.relativeSize(92));
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: SizeTokens.paddingLarge),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState(DiscoveryViewModel viewModel) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(SizeTokens.paddingLarge),
        child: Text(
          viewModel.errorMessage ?? Translations.tr('errorOccurred'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.errorColor,
            fontSize: SizeTokens.textMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        Translations.tr('discoveryEmpty'),
        style: TextStyle(
          color: AppTheme.textSecondaryColor,
          fontSize: SizeTokens.textMedium,
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MovieDetailView(movie: movie)),
    );
  }
}

class _DiscoveryMovieCard extends StatelessWidget {
  final Movie movie;
  final int rank;
  final VoidCallback onTap;

  const _DiscoveryMovieCard({
    required this.movie,
    required this.rank,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: SizeTokens.circularRadiusSmall,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: SizeTokens.circularRadiusSmall,
                    child: _buildPoster(),
                  ),
                ),
                Positioned(
                  top: SizeTokens.paddingMin,
                  left: SizeTokens.paddingMin,
                  child: _buildRankBadge(),
                ),
                if (movie.imdbRating != null && movie.imdbRating != 'N/A')
                  Positioned(
                    right: SizeTokens.paddingMin,
                    bottom: SizeTokens.paddingMin,
                    child: _buildRatingBadge(),
                  ),
              ],
            ),
          ),
          SizedBox(height: SizeTokens.paddingSmall),
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppTheme.textPrimaryColor,
              fontSize: SizeTokens.textSmall,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          SizedBox(height: SizeTokens.paddingMin),
          Text(
            _metaText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppTheme.textTertiaryColor,
              fontSize: SizeTokens.textSmall,
            ),
          ),
        ],
      ),
    );
  }

  String get _metaText {
    final type = movie.type == 'series'
        ? Translations.tr('discoverySeries')
        : Translations.tr('discoveryMovies');
    if (movie.year.isEmpty) return type;
    return '${movie.year} • $type';
  }

  Widget _buildPoster() {
    if (movie.posterLocalPath != null) {
      return Image.file(File(movie.posterLocalPath!), fit: BoxFit.cover);
    }

    if (movie.posterUrl != null && movie.posterUrl != 'N/A') {
      return Image.network(
        movie.posterUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            CustomPosterWidget(movie: movie, width: double.infinity),
      );
    }

    return CustomPosterWidget(movie: movie, width: double.infinity);
  }

  Widget _buildRankBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.paddingSmall,
        vertical: SizeTokens.paddingMin,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.68),
        borderRadius: SizeTokens.circularRadiusSmall,
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        '#$rank',
        style: TextStyle(
          color: Colors.white,
          fontSize: SizeTokens.textSmall,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildRatingBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.paddingSmall,
        vertical: SizeTokens.paddingMin,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: SizeTokens.circularRadiusSmall,
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
            movie.imdbRating!,
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeTokens.textSmall,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
