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
import '../widgets/custom_poster_widget.dart';
import '../../app/app_theme.dart';

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

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(Translations.tr('language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Türkçe'),
                onTap: () async {
                  await Translations.changeLanguage(Language.tr);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
              ListTile(
                title: const Text('English'),
                onTap: () async {
                  await Translations.changeLanguage(Language.en);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
              ListTile(
                title: const Text('Español'),
                onTap: () async {
                  await Translations.changeLanguage(Language.es);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHero(
    BuildContext context,
    Movie movie,
    HomeViewModel viewModel,
  ) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Background Image
        SizedBox(
          height: SizeConfig.relativeSize(500),
          width: double.infinity,
          child: movie.posterLocalPath != null
              ? Image.file(
                  File(movie.posterLocalPath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: AppTheme.surfaceLightColor),
                )
              : (movie.posterUrl != null && movie.posterUrl != 'N/A')
              ? Image.network(
                  movie.posterUrl!,
                  fit: BoxFit.cover,
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
              stops: [0.5, 1.0],
            ),
          ),
        ),
        // Content
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
                    shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
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
              SizedBox(height: SizeTokens.paddingSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                        viewModel.init();
                      });
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text(
                      'Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: SizeTokens.paddingMedium),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeTokens.paddingLarge,
                        vertical: SizeTokens.paddingMedium,
                      ),
                    ),
                    onPressed: () => viewModel.deleteMovie(movie.id),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalList(
    BuildContext context,
    String title,
    List<Movie> list,
    HomeViewModel viewModel,
  ) {
    if (list.isEmpty) return const SizedBox();
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
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: SizeTokens.paddingMedium),
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
                            errorBuilder: (context, error, stackTrace) =>
                                CustomPosterWidget(
                                  movie: movie,
                                  width: SizeConfig.relativeSize(130),
                                ),
                          )
                        : (movie.posterUrl != null && movie.posterUrl != 'N/A')
                        ? Image.network(
                            movie.posterUrl!,
                            width: SizeConfig.relativeSize(130),
                            fit: BoxFit.cover,
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
    if (viewModel.movies.isEmpty) {
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
          if (viewModel.featuredMovie != null)
            _buildHero(context, viewModel.featuredMovie!, viewModel),
          SizedBox(height: SizeTokens.paddingLarge),
          if (viewModel.recommendedMovies.isNotEmpty)
            _buildHorizontalList(
              context,
              Translations.tr('recommended'),
              viewModel.recommendedMovies,
              viewModel,
            ),
          if (viewModel.latestMovies.isNotEmpty)
            _buildHorizontalList(
              context,
              Translations.tr('myList'),
              viewModel.latestMovies,
              viewModel,
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

  Widget _buildProfileTab(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle,
            size: SizeConfig.relativeSize(100),
            color: AppTheme.textSecondaryColor,
          ),
          SizedBox(height: SizeTokens.paddingLarge),
          Text(
            Translations.tr('profileTab'),
            style: TextStyle(
              fontSize: SizeTokens.textLarge * 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: SizeTokens.paddingMedium),
          Text(
            Translations.tr('profileDesc'),
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: SizeTokens.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    // Dynamic Title based on tab
    String appBarTitle = Translations.tr('appName');
    if (_currentIndex == 1) appBarTitle = Translations.tr('watchedTab');
    if (_currentIndex == 2) appBarTitle = Translations.tr('toWatchTab');
    if (_currentIndex == 3) appBarTitle = Translations.tr('addTab');
    if (_currentIndex == 4) appBarTitle = Translations.tr('profileTab');

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle, style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            iconSize: SizeTokens.iconMedium,
            onPressed: _showLanguageDialog,
          ),
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
              _buildMovieListTab(context, viewModel, viewModel.watchedMovies),
              _buildMovieListTab(context, viewModel, viewModel.toWatchMovies),
              const AddMovieView(), // Added inline AddMovieView for the "Add" tab
              _buildProfileTab(context),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.surfaceColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: Translations.tr('homeTab'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.visibility),
            label: Translations.tr('watchedTab'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.visibility_off),
            label: Translations.tr('toWatchTab'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_circle_outline),
            label: Translations.tr('addTab'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: Translations.tr('profileTab'),
          ),
        ],
      ),
    );
  }
}
