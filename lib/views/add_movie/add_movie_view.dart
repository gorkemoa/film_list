import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/translations.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../viewmodels/add_movie_view_model.dart';
import '../../app/app_theme.dart';
import 'custom_add_movie_view.dart';

class AddMovieView extends StatefulWidget {
  const AddMovieView({super.key});

  @override
  State<AddMovieView> createState() => _AddMovieViewState();
}

class _AddMovieViewState extends State<AddMovieView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<AddMovieViewModel>().searchMovies(query);
      FocusScope.of(context).unfocus(); // hide keyboard
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.tr('search'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(SizeTokens.paddingMedium),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      context.read<AddMovieViewModel>().searchMovies(val);
                    },
                    decoration: InputDecoration(
                      hintText: Translations.tr('searchPlaceholder'),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppTheme.textSecondaryColor,
                      ),
                      filled: true,
                      fillColor: AppTheme.surfaceColor,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: SizeTokens.paddingMedium,
                        horizontal: SizeTokens.paddingLarge,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(color: AppTheme.primaryColor),
                      ),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<AddMovieViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        SizedBox(height: SizeTokens.paddingMedium),
                        Text(
                          Translations.tr('searching'),
                          style: TextStyle(color: AppTheme.textSecondaryColor),
                        ),
                      ],
                    ),
                  );
                }

                if (viewModel.errorMessage != null) {
                  return Center(
                    child: Text(
                      viewModel.errorMessage!,
                      style: TextStyle(color: AppTheme.errorColor),
                    ),
                  );
                }

                if (viewModel.movies.isEmpty &&
                    _searchController.text.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Translations.tr('noResults'),
                          style: TextStyle(color: AppTheme.textSecondaryColor),
                        ),
                        SizedBox(height: SizeTokens.paddingLarge),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CustomAddMovieView(),
                              ),
                            );
                          },
                          icon: Icon(Icons.add, size: SizeTokens.iconMedium),
                          label: Text(Translations.tr('addManually')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeTokens.paddingLarge,
                              vertical: SizeTokens.paddingMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeTokens.paddingMedium,
                  ),
                  itemCount: viewModel.movies.length,
                  itemBuilder: (context, index) {
                    final movie = viewModel.movies[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: SizeTokens.paddingSmall),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: SizeTokens.circularRadiusMedium,
                          onTap: () async {
                            final success = await viewModel.selectAndSaveMovie(
                              movie,
                            );
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${movie.title} saved!'),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor,
                              borderRadius: SizeTokens.circularRadiusMedium,
                              border: Border.all(
                                color: AppTheme.surfaceLightColor,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(
                                SizeTokens.paddingSmall,
                              ),
                              leading: ClipRRect(
                                borderRadius: SizeTokens.circularRadiusSmall,
                                child:
                                    movie.posterUrl != null &&
                                        movie.posterUrl!.isNotEmpty &&
                                        movie.posterUrl != 'N/A'
                                    ? Image.network(
                                        movie.posterUrl!,
                                        width: SizeConfig.relativeSize(50),
                                        height: SizeConfig.relativeSize(75),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (
                                              context,
                                              error,
                                              stackTrace,
                                            ) => Container(
                                              width: SizeConfig.relativeSize(
                                                50,
                                              ),
                                              height: SizeConfig.relativeSize(
                                                75,
                                              ),
                                              color: AppTheme.surfaceLightColor,
                                              child: Icon(
                                                Icons.movie,
                                                size: SizeTokens.iconLarge,
                                                color:
                                                    AppTheme.textSecondaryColor,
                                              ),
                                            ),
                                      )
                                    : Container(
                                        width: SizeConfig.relativeSize(50),
                                        height: SizeConfig.relativeSize(75),
                                        color: AppTheme.surfaceLightColor,
                                        child: Icon(
                                          Icons.movie,
                                          size: SizeTokens.iconLarge,
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                              ),
                              title: Text(
                                movie.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: SizeTokens.textLarge,
                                ),
                              ),
                              subtitle: Text(
                                '${movie.year} ${movie.type != null ? '• ${movie.type}' : ''}',
                                style: TextStyle(
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                              trailing: Icon(
                                Icons.add_circle,
                                color: AppTheme.primaryColor,
                                size: SizeTokens.iconLarge,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Always show Add Manually button at the bottom of the screen
          Padding(
            padding: EdgeInsets.all(SizeTokens.paddingMedium),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomAddMovieView()),
                );
              },
              icon: Icon(Icons.edit, color: AppTheme.primaryColor),
              label: Text(
                Translations.tr('addManually'),
                style: const TextStyle(color: AppTheme.primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
