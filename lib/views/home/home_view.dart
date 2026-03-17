import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/translations.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../models/movie.dart';
import '../../viewmodels/home_view_model.dart';
import '../add_movie/add_movie_view.dart';
import '../movie_detail/movie_detail_view.dart';
import '../profile/profile_view.dart';
import '../widgets/custom_poster_widget.dart';
import '../../app/app_theme.dart';
import 'widgets/slider_widget.dart';
import 'widgets/add_poster_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

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
            vertical: SizeTokens.paddingSmall,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: SizeTokens.textTitle,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: SizeConfig.relativeSize(200),
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
                      padding: EdgeInsets.only(right: SizeTokens.paddingMedium),
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
                        child: ClipRRect(
                          borderRadius: SizeTokens.circularRadiusSmall,
                          child: movie.posterLocalPath != null
                              ? Image.file(
                                  File(movie.posterLocalPath!),
                                  width: SizeConfig.relativeSize(130),
                                  fit: BoxFit.cover,
                                  cacheWidth: 300,
                                  cacheHeight: 444,
                                  errorBuilder: (context, error, stackTrace) =>
                                      CustomPosterWidget(
                                        movie: movie,
                                        width: SizeConfig.relativeSize(130),
                                      ),
                                )
                              : (movie.posterUrl != null &&
                                    movie.posterUrl != 'N/A')
                              ? Image.network(
                                  movie.posterUrl!,
                                  width: SizeConfig.relativeSize(130),
                                  fit: BoxFit.cover,
                                  cacheWidth: 300,
                                  cacheHeight: 444,
                                  errorBuilder: (context, error, stackTrace) =>
                                      CustomPosterWidget(
                                        movie: movie,
                                        width: SizeConfig.relativeSize(130),
                                      ),
                                )
                              : CustomPosterWidget(
                                  movie: movie,
                                  width: SizeConfig.relativeSize(130),
                                ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        SizedBox(height: SizeTokens.paddingLarge),
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
          SizedBox(height: SizeTokens.paddingLarge),
          if (viewModel.recommendedMovies.isNotEmpty)
            _buildHorizontalList(
              context,
              Translations.tr('recommended'),
              viewModel.recommendedMovies,
              viewModel,
            ),
          // Always show To Watch and Watched lists on home
          _buildHorizontalList(
            context,
            Translations.tr('toWatchTab'),
            viewModel.toWatchMovies,
            viewModel,
            showPlaceholderIfEmpty: true,
          ),
          _buildHorizontalList(
            context,
            Translations.tr('watchedTab'),
            viewModel.watchedMovies,
            viewModel,
            showPlaceholderIfEmpty: true,
          ),
          SizedBox(height: SizeConfig.relativeSize(80)), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildMovieListTab(
    BuildContext context,
    HomeViewModel viewModel,
    List<Movie> movies,
  ) {
    if (movies.isEmpty) {
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
    return GridView.builder(
      padding: EdgeInsets.all(SizeTokens.paddingMedium),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        crossAxisSpacing: SizeTokens.paddingMedium,
        mainAxisSpacing: SizeTokens.paddingMedium,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return InkWell(
          borderRadius: SizeTokens.circularRadiusSmall,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MovieDetailView(movie: movie)),
            ).then((_) {
              if (!context.mounted) return;
              viewModel.init();
            });
          },
          child: ClipRRect(
            borderRadius: SizeTokens.circularRadiusSmall,
            child: movie.posterLocalPath != null
                ? Image.file(
                    File(movie.posterLocalPath!),
                    fit: BoxFit.cover,
                    cacheWidth: 300,
                    cacheHeight: 444,
                    errorBuilder: (context, error, stackTrace) =>
                        CustomPosterWidget(
                          movie: movie,
                          width: double.infinity,
                        ),
                  )
                : (movie.posterUrl != null && movie.posterUrl != 'N/A')
                ? Image.network(
                    movie.posterUrl!,
                    fit: BoxFit.cover,
                    cacheWidth: 300,
                    cacheHeight: 444,
                    errorBuilder: (context, error, stackTrace) =>
                        CustomPosterWidget(
                          movie: movie,
                          width: double.infinity,
                        ),
                  )
                : CustomPosterWidget(movie: movie, width: double.infinity),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    // Dynamic Title based on tab
    String? appBarTitle;
    if (_currentIndex == 1) appBarTitle = Translations.tr('watchedTab');
    if (_currentIndex == 2) appBarTitle = Translations.tr('addTab');
    if (_currentIndex == 3) appBarTitle = Translations.tr('toWatchTab');
    if (_currentIndex == 4) appBarTitle = Translations.tr('profileTab');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appBarTitle != null
          ? AppBar(
              title: Text(
                appBarTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
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
              _buildMovieListTab(context, viewModel, viewModel.watchedMovies),
              const AddMovieView(),
              _buildMovieListTab(context, viewModel, viewModel.toWatchMovies),
              const ProfileView(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _currentIndex = 2),
        backgroundColor: AppTheme.primaryColor,
        elevation: 8,
        shape: const CircleBorder(),
        child: Icon(Icons.add, color: Colors.white, size: SizeTokens.iconLarge),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: AppTheme.surfaceColor,
        padding: EdgeInsets.zero,
        height: SizeConfig.relativeSize(70) + MediaQuery.of(context).padding.bottom,
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Side
              Row(
                children: [
                  _buildNavItem(0, Icons.home, 'homeTab'),
                  _buildNavItem(1, Icons.visibility, 'watchedTab'),
                ],
              ),
              // Right Side
              Row(
                children: [
                  _buildNavItem(3, Icons.visibility_off, 'toWatchTab'),
                  _buildNavItem(4, Icons.person, 'profileTab'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String labelKey) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeTokens.paddingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondaryColor,
              size: SizeTokens.iconMedium,
            ),
            Text(
              Translations.tr(labelKey),
              style: TextStyle(
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondaryColor,
                fontSize: SizeTokens.textSmall,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
