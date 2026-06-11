import 'dart:io';
import 'package:film_list/app/app_theme.dart';
import 'package:film_list/views/home/widgets/ad_banner_widget.dart';
import 'package:film_list/views/home/widgets/add_poster_widget.dart';
import 'package:film_list/views/home/widgets/slider_widget.dart';
import 'package:film_list/views/widgets/custom_poster_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/translations.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../models/movie.dart';
import '../../viewmodels/home_view_model.dart';
import '../add_movie/add_movie_view.dart';
import '../movie_detail/movie_detail_view.dart';
import 'widgets/watch_status_badge_widget.dart';
import '../discovery/discovery_view.dart';
import '../lists/lists_view.dart';
import '../stats/stats_view.dart';
import '../profile/profile_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const String _homeAdUnitId = 'ca-app-pub-3600325889588673/6060879999';
  static const String _discoveryAdUnitId =
      'ca-app-pub-3600325889588673/2584669411';
  static const String _listsAdUnitId = 'ca-app-pub-3600325889588673/7030010020';

  int _currentIndex = 0;

  double get _posterWidth => SizeConfig.relativeSize(112);
  double get _posterHeight => SizeConfig.relativeSize(170);

  String? get _currentBannerAdUnitId {
    if (_currentIndex == 0) return _homeAdUnitId;
    if (_currentIndex == 1) return _discoveryAdUnitId;
    if (_currentIndex == 3) return _listsAdUnitId;
    return null;
  }

  String get _currentBannerPlacementName {
    if (_currentIndex == 1) return 'Discovery';
    if (_currentIndex == 3) return 'Lists';
    return 'Home';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().init();
    });
  }

  Widget _buildHorizontalList(
    BuildContext context,
    String title,
    List<Movie> list,
    HomeViewModel viewModel, {
    bool showPlaceholderIfEmpty = false,
  }) {
    if (list.isEmpty && !showPlaceholderIfEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeTokens.paddingMedium,
            vertical: SizeTokens.paddingMin,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: AppTheme.textPrimaryColor,
              fontSize: SizeTokens.textLarge,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          height: _posterHeight,
          child: list.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeTokens.paddingMedium,
                  ),
                  child: AddPosterWidget(
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeTokens.paddingMedium,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final movie = list[index];
                    return Padding(
                      padding: EdgeInsets.only(right: SizeTokens.paddingSmall),
                      child: InkWell(
                        borderRadius: SizeTokens.circularRadiusSmall,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MovieDetailView(movie: movie),
                            ),
                          ).then((_) {
                            if (!context.mounted) return;
                            viewModel.init();
                          });
                        },
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: SizeTokens.circularRadiusSmall,
                              child: movie.posterLocalPath != null
                                  ? Image.file(
                                      File(movie.posterLocalPath!),
                                      width: _posterWidth,
                                      height: _posterHeight,
                                      fit: BoxFit.cover,
                                      cacheWidth: 300,
                                      cacheHeight: 444,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              CustomPosterWidget(
                                                movie: movie,
                                                width: _posterWidth,
                                                height: _posterHeight,
                                              ),
                                    )
                                  : (movie.posterUrl != null &&
                                        movie.posterUrl != 'N/A')
                                  ? Image.network(
                                      movie.posterUrl!,
                                      width: _posterWidth,
                                      height: _posterHeight,
                                      fit: BoxFit.cover,
                                      cacheWidth: 300,
                                      cacheHeight: 444,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              CustomPosterWidget(
                                                movie: movie,
                                                width: _posterWidth,
                                                height: _posterHeight,
                                              ),
                                    )
                                  : CustomPosterWidget(
                                      movie: movie,
                                      width: _posterWidth,
                                      height: _posterHeight,
                                    ),
                            ),
                            Positioned(
                              top: SizeTokens.paddingMin,
                              left: SizeTokens.paddingMin,
                              child: WatchStatusBadge(
                                status: movie.watchStatus,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        SizedBox(height: SizeTokens.paddingMedium),
      ],
    );
  }

  // Removed _fallbackPoster as we use CustomPosterWidget now

  Widget _buildHomeTab(BuildContext context, HomeViewModel viewModel) {
    final hasSlider = viewModel.sliderMovies.isNotEmpty;
    final hasMovies = viewModel.movies.isNotEmpty;
    final hasRecommended = viewModel.recommendedMovies.isNotEmpty;

    if (!hasSlider && !hasMovies && !hasRecommended) {
      return Center(
        child: Text(
          Translations.tr('emptyMovies'),
          style: TextStyle(
            fontSize: SizeTokens.textLarge,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (viewModel.sliderMovies.isNotEmpty)
            SliderWidget(movies: viewModel.sliderMovies),
          SizedBox(height: SizeTokens.paddingMedium),
          // Currently Watching
          if (viewModel.watchingMovies.isNotEmpty)
            _buildHorizontalList(
              context,
              Translations.tr('currentlyWatching'),
              viewModel.watchingMovies,
              viewModel,
            ),
          // Recently Viewed
          if (viewModel.recentlyViewed.isNotEmpty)
            _buildHorizontalList(
              context,
              Translations.tr('recentlyViewed'),
              viewModel.recentlyViewed,
              viewModel,
            ),
          // Recently Added
          _buildHorizontalList(
            context,
            Translations.tr('recentlyAdded'),
            viewModel.recentlyAdded,
            viewModel,
            showPlaceholderIfEmpty: true,
          ),
          if (viewModel.recommendedMovies.isNotEmpty)
            _buildHorizontalList(
              context,
              Translations.tr('recommended'),
              viewModel.recommendedMovies,
              viewModel,
            ),
          // Watch Again
          if (viewModel.rewatchMovies.isNotEmpty)
            _buildHorizontalList(
              context,
              Translations.tr('watchAgainList'),
              viewModel.rewatchMovies,
              viewModel,
            ),
          SizedBox(height: SizeConfig.relativeSize(64)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    String? appBarTitle;
    if (_currentIndex == 1) appBarTitle = Translations.tr('discoveryTab');
    if (_currentIndex == 2) appBarTitle = Translations.tr('addTab');
    if (_currentIndex == 3) appBarTitle = Translations.tr('listsTab');
    if (_currentIndex == 4) appBarTitle = Translations.tr('collectionStats');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: SizeTokens.heightMedium,
        title: Text(
          appBarTitle ?? 'FilmList',
          style: TextStyle(
            fontSize: SizeTokens.textLarge,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileView()),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
          SizedBox(width: SizeTokens.paddingSmall),
        ],
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Text(
                viewModel.errorMessage!,
                style: TextStyle(color: AppTheme.errorColor),
              ),
            );
          }

          return IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomeTab(context, viewModel),
              const DiscoveryView(),
              const AddMovieView(),
              const ListsView(),
              const StatsView(),
            ],
          );
        },
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentBannerAdUnitId != null)
            AdBannerWidget(
              key: ValueKey(_currentBannerAdUnitId),
              adUnitId: _currentBannerAdUnitId!,
              placementName: _currentBannerPlacementName,
            ),
          BottomAppBar(
            height: SizeConfig.relativeSize(50),
            color: AppTheme.surfaceColor,
            padding: EdgeInsets.zero,
            child: SizedBox.expand(
              child: Row(
                children: [
                  _buildNavItem(0, Icons.home_rounded, 'homeTab'),
                  _buildNavItem(1, Icons.explore_rounded, 'discoveryTab'),
                  _buildNavItem(2, Icons.add_circle_rounded, 'addTab'),
                  _buildNavItem(3, Icons.playlist_play_rounded, 'listsTab'),
                  _buildNavItem(4, Icons.insights_rounded, 'statsTab'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String labelKey) {
    final isSelected = _currentIndex == index;
    final isAddItem = index == 2;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Transform.translate(
          offset: Offset(0, isAddItem ? 0 : SizeTokens.paddingMin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(
                  horizontal: isAddItem
                      ? SizeTokens.paddingMedium
                      : SizeTokens.paddingSmall,
                  vertical: SizeTokens.paddingMin,
                ),
                decoration: BoxDecoration(
                  gradient: isAddItem
                      ? LinearGradient(
                          colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                        )
                      : null,
                  color: isAddItem
                      ? null
                      : isSelected
                      ? AppTheme.primaryColor.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: SizeTokens.circularRadiusLarge,
                  boxShadow: isAddItem
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(
                              alpha: 0.28,
                            ),
                            blurRadius: SizeTokens.radiusMedium,
                            spreadRadius: SizeTokens.paddingMin / 2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  icon,
                  color: isAddItem
                      ? Colors.white
                      : isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondaryColor,
                  size: isAddItem
                      ? SizeConfig.relativeSize(20)
                      : SizeConfig.relativeSize(18),
                ),
              ),
              SizedBox(
                height: isAddItem
                    ? SizeTokens.paddingMin / 2
                    : SizeTokens.paddingMin,
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: isAddItem
                      ? AppTheme.textPrimaryColor
                      : isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondaryColor,
                  fontSize: SizeTokens.textSmall,
                  fontWeight: isAddItem || isSelected
                      ? FontWeight.w700
                      : FontWeight.normal,
                ),
                child: Text(
                  Translations.tr(labelKey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
