import 'dart:io';
import 'package:film_list/core/responsive/size_config.dart';
import 'package:film_list/core/responsive/size_tokens.dart';
import 'package:film_list/models/movie.dart';
import 'package:film_list/viewmodels/custom_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/translations.dart';
import '../../../app/app_theme.dart';

class AddMovieToListSheet extends StatelessWidget {
  final String listId;
  final List<Movie> allMovies;

  const AddMovieToListSheet({
    super.key,
    required this.listId,
    required this.allMovies,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Consumer<CustomListViewModel>(
      builder: (context, vm, _) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLightColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: SizeTokens.paddingMedium),
                    child: Text(
                      Translations.tr('addMovieToList'),
                      style: TextStyle(
                        fontSize: SizeTokens.textLarge,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: allMovies.isEmpty
                        ? Center(
                            child: Text(
                              Translations.tr('emptyMovies'),
                              style: const TextStyle(
                                  color: AppTheme.textSecondaryColor),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: allMovies.length,
                            itemBuilder: (context, index) {
                              final movie = allMovies[index];
                              final inList =
                                  vm.isMovieInList(listId, movie.id);
                              return ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: SizeTokens.paddingMedium,
                                  vertical: 4,
                                ),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: _miniPoster(movie),
                                ),
                                title: Text(
                                  movie.title,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  movie.year,
                                  style: const TextStyle(
                                      color: AppTheme.textSecondaryColor,
                                      fontSize: 12),
                                ),
                                trailing: inList
                                    ? IconButton(
                                        icon: const Icon(Icons.check_circle,
                                            color: Color(0xFF4CAF50)),
                                        onPressed: () =>
                                            vm.removeMovieFromList(
                                                listId, movie.id),
                                      )
                                    : IconButton(
                                        icon: const Icon(
                                            Icons.add_circle_outline,
                                            color:
                                                AppTheme.textSecondaryColor),
                                        onPressed: () =>
                                            vm.addMovieToList(
                                                listId, movie.id),
                                      ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _miniPoster(Movie movie) {
    if (movie.posterLocalPath != null) {
      return Image.file(
        File(movie.posterLocalPath!),
        width: 36,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    if (movie.posterUrl != null && movie.posterUrl != 'N/A') {
      return Image.network(
        movie.posterUrl!,
        width: 36,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: 36,
      height: 50,
      color: AppTheme.surfaceLightColor,
      child: const Icon(Icons.movie_outlined,
          size: 16, color: AppTheme.textTertiaryColor),
    );
  }
}
