import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/translations.dart';
import '../../app/app_theme.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../models/custom_list.dart';
import '../../models/movie.dart';
import '../../viewmodels/custom_list_view_model.dart';
import '../../viewmodels/home_view_model.dart';
import '../movie_detail/movie_detail_view.dart';
import '../widgets/custom_poster_widget.dart';
import 'widgets/add_movie_to_list_sheet.dart';

class CustomListDetailView extends StatefulWidget {
  final CustomList customList;

  const CustomListDetailView({super.key, required this.customList});

  @override
  State<CustomListDetailView> createState() => _CustomListDetailViewState();
}

class _CustomListDetailViewState extends State<CustomListDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomListViewModel>().init();
    });
  }

  void _showRenameDialog(BuildContext context, CustomList list) {
    final controller = TextEditingController(text: list.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          Translations.tr('renameList'),
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: Translations.tr('listName'),
            hintStyle: const TextStyle(color: AppTheme.textSecondaryColor),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: AppTheme.surfaceLightColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              Translations.tr('cancel'),
              style: const TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<CustomListViewModel>()
                  .renameList(list.id, controller.text);
              Navigator.pop(ctx);
            },
            child: Text(
              Translations.tr('save'),
              style: const TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Consumer<CustomListViewModel>(
      builder: (context, vm, _) {
        final currentList = vm.lists.firstWhere(
          (l) => l.id == widget.customList.id,
          orElse: () => widget.customList,
        );
        final movies = vm.moviesForList(currentList);

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            title: Text(
              currentList.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: Translations.tr('renameList'),
                onPressed: () => _showRenameDialog(context, currentList),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: Translations.tr('addMovieToList'),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: AppTheme.surfaceColor,
                    isScrollControlled: true,
                    builder: (_) => ChangeNotifierProvider.value(
                      value: vm,
                      child: AddMovieToListSheet(
                        listId: currentList.id,
                        allMovies:
                            context.read<HomeViewModel>().movies,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: movies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.list_alt_rounded,
                        size: 64,
                        color: AppTheme.textTertiaryColor,
                      ),
                      SizedBox(height: SizeTokens.paddingMedium),
                      Text(
                        Translations.tr('emptyList'),
                        style: const TextStyle(
                            color: AppTheme.textSecondaryColor),
                      ),
                      SizedBox(height: SizeTokens.paddingLarge),
                      ElevatedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: AppTheme.surfaceColor,
                            isScrollControlled: true,
                            builder: (_) => ChangeNotifierProvider.value(
                              value: vm,
                              child: AddMovieToListSheet(
                                listId: currentList.id,
                                allMovies:
                                    context.read<HomeViewModel>().movies,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: Text(Translations.tr('addMovieToList')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
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
                    return Stack(
                      children: [
                        InkWell(
                          borderRadius: SizeTokens.circularRadiusSmall,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MovieDetailView(movie: movie),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: SizeTokens.circularRadiusSmall,
                            child: _buildPoster(movie),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => vm.removeMovieFromList(
                                currentList.id, movie.id),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildPoster(Movie movie) {
    if (movie.posterLocalPath != null) {
      return Image.file(
        File(movie.posterLocalPath!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            CustomPosterWidget(movie: movie, width: double.infinity),
      );
    }
    if (movie.posterUrl != null && movie.posterUrl != 'N/A') {
      return Image.network(
        movie.posterUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            CustomPosterWidget(movie: movie, width: double.infinity),
      );
    }
    return CustomPosterWidget(movie: movie, width: double.infinity);
  }
}
