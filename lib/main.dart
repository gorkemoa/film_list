import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app_theme.dart';
import 'app/translations.dart';
import 'core/database/local_db.dart';
import 'services/movie_cache_service.dart';
import 'services/omdb_search_service.dart';
import 'services/omdb_detail_service.dart';
import 'services/poster_download_service.dart';
import 'services/review_service.dart';
import 'viewmodels/home_view_model.dart';
import 'viewmodels/add_movie_view_model.dart';
import 'viewmodels/movie_detail_view_model.dart';
import 'views/home/home_view.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalDb.init();
  await Translations.init();

  final movieCacheService = MovieCacheService();
  final omdbSearchService = OmdbSearchService();
  final omdbDetailService = OmdbDetailService();
  final posterDownloadService = PosterDownloadService();
  final reviewService = ReviewService();

  Logger.info('App starting...');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(movieCacheService: movieCacheService),
        ),
        ChangeNotifierProvider(
          create: (_) => AddMovieViewModel(
            movieCacheService: movieCacheService,
            omdbSearchService: omdbSearchService,
            omdbDetailService: omdbDetailService,
            posterDownloadService: posterDownloadService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => MovieDetailViewModel(
            movieCacheService: movieCacheService,
            reviewService: reviewService,
          ),
        ),
      ],
      child: const FilmListApp(),
    ),
  );
}

class FilmListApp extends StatelessWidget {
  const FilmListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Offline Film List',
      theme: AppTheme.lightTheme,
      home: const HomeView(),
    );
  }
}
