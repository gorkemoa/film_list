import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/movie.dart';
import '../models/review.dart';
import '../services/movie_cache_service.dart';
import '../services/review_service.dart';
import '../services/translation_service.dart';
import '../services/omdb_detail_service.dart';
import '../core/utils/logger.dart';

class MovieDetailViewModel extends ChangeNotifier {
  final MovieCacheService _movieCacheService;
  final ReviewService _reviewService;
  final TranslationService _translationService;
  final OmdbDetailService _omdbDetailService;

  MovieDetailViewModel({
    MovieCacheService? movieCacheService,
    ReviewService? reviewService,
    TranslationService? translationService,
    OmdbDetailService? omdbDetailService,
  }) : _movieCacheService = movieCacheService ?? MovieCacheService(),
       _reviewService = reviewService ?? ReviewService(),
       _translationService = translationService ?? TranslationService(),
       _omdbDetailService = omdbDetailService ?? OmdbDetailService();

  bool isLoading = false;
  String? errorMessage;
  List<Movie> movies = [];

  Movie? currentMovie;
  Review? currentReview;
  bool isLocal = false;

  Future<void> init() async {}

  String? translatedPlot;

  Future<void> initMovie(Movie movie) async {
    isLoading = true;
    errorMessage = null;
    currentMovie = movie;
    translatedPlot = movie.plot;
    notifyListeners();

    try {
      final localMovie = await _movieCacheService.getMovieByImdbId(
        movie.imdbId ?? '',
      );
      isLocal = localMovie != null;
      if (isLocal) {
        currentMovie = localMovie;
      }

      // If details are missing, try to fetch from OMDb
      if ((currentMovie!.director == null || currentMovie!.director == 'N/A') && currentMovie!.imdbId != null) {
        final detailedMovie = await _omdbDetailService.getMovieDetail(
          currentMovie!.imdbId!,
        );
        if (detailedMovie != null) {
          currentMovie = currentMovie!.copyWith(
            plot: detailedMovie.plot,
            director: detailedMovie.director,
            writer: detailedMovie.writer,
            actors: detailedMovie.actors,
            language: detailedMovie.language,
            country: detailedMovie.country,
            boxOffice: detailedMovie.boxOffice,
            rated: detailedMovie.rated,
            released: detailedMovie.released,
            genre: detailedMovie.genre,
            runtime: detailedMovie.runtime,
            imdbRating: detailedMovie.imdbRating,
            imdbVotes: detailedMovie.imdbVotes,
            metascore: detailedMovie.metascore,
            awards: detailedMovie.awards,
          );
          // If already local, update the cache
          if (isLocal) {
            await _movieCacheService.updateMovie(currentMovie!);
          }
        }
      }

      // Translate the plot if it exists
      if (currentMovie!.plot != null) {
        translatedPlot = await _translationService.translatePlot(
          currentMovie!.plot!,
        );
      }

      currentReview = await _reviewService.getReviewByMovieId(currentMovie!.id);
    } catch (e) {
      errorMessage = e.toString();
      Logger.error('MovieDetailViewModel init error', e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleWatched(Movie movie) async {
    try {
      if (currentMovie != null) {
        final newIsWatched = !currentMovie!.isWatched;
        int newWatchCount = currentMovie!.watchCount;

        if (newIsWatched && newWatchCount == 0) {
          newWatchCount = 1;
        } else if (!newIsWatched) {
          newWatchCount =
              0; // Or keep it if we want to remember past watches, but typically 0 if unwatched
        }

        currentMovie = currentMovie!.copyWith(
          isWatched: newIsWatched,
          watchCount: newWatchCount,
        );
        await _movieCacheService.updateMovie(currentMovie!);
        notifyListeners();
      }
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> incrementWatchCount() async {
    try {
      if (currentMovie != null && currentMovie!.isWatched) {
        currentMovie = currentMovie!.copyWith(
          watchCount: currentMovie!.watchCount + 1,
        );
        await _movieCacheService.updateMovie(currentMovie!);
        notifyListeners();
      }
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> rateMovie({
    required int story,
    required int music,
    required int acting,
    required int cinematography,
    required bool recommend,
    required bool watchAgain,
    String? comment,
  }) async {
    if (currentMovie == null) return;

    isLoading = true;
    notifyListeners();

    try {
      final overall = (story + music + acting + cinematography) / 4.0;
      final review = Review(
        id: currentReview?.id ?? const Uuid().v4(),
        movieId: currentMovie!.id,
        storyRating: story,
        musicRating: music,
        actingRating: acting,
        cinematographyRating: cinematography,
        overallRating: overall,
        recommend: recommend,
        watchAgain: watchAgain,
        reviewDate: DateTime.now(),
        comment: comment,
      );

      await _reviewService.addReview(review);
      currentReview = review;
    } catch (e) {
      errorMessage = e.toString();
      Logger.error('Failed to rate movie', e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteReview() async {
    if (currentReview == null) return;

    isLoading = true;
    notifyListeners();

    try {
      await _reviewService.deleteReview(currentReview!.id);
      currentReview = null;
    } catch (e) {
      errorMessage = e.toString();
      Logger.error('Failed to delete review', e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMovie() async {}
  Future<void> deleteMovie(String id) async {}

  Future<void> addMovieToLocalList() async {
    if (currentMovie == null || isLocal) return;

    isLoading = true;
    notifyListeners();

    try {
      // Create a fresh ID for local storage
      final localMovie = currentMovie!.copyWith(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _movieCacheService.saveMovie(localMovie);
      currentMovie = localMovie;
      isLocal = true;
      Logger.info('Suggested movie added to local list: ${localMovie.title}');
    } catch (e) {
      errorMessage = e.toString();
      Logger.error('Failed to add suggested movie to local list', e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
