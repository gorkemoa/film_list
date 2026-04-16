import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/translations.dart';
import '../../app/app_theme.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../models/custom_list.dart';
import '../../models/movie.dart';
import '../../models/watch_status.dart';
import '../../viewmodels/custom_list_view_model.dart';
import '../../viewmodels/home_view_model.dart';
import '../movie_detail/movie_detail_view.dart';
import '../widgets/custom_poster_widget.dart';
import 'custom_list_detail_view.dart';

class ListsView extends StatefulWidget {
  const ListsView({super.key});

  @override
  State<ListsView> createState() => _ListsViewState();
}

class _ListsViewState extends State<ListsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomListViewModel>().init();
    });
  }

  void _showCreateListDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          Translations.tr('createList'),
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: Translations.tr('listNameHint'),
                hintStyle:
                    const TextStyle(color: AppTheme.textSecondaryColor),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: AppTheme.surfaceLightColor,
              ),
            ),
            SizedBox(height: SizeTokens.paddingMedium),
            Text(
              Translations.tr('suggestedListNames'),
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _suggestedNames().map((name) {
                return GestureDetector(
                  onTap: () => controller.text = name,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLightColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      name,
                      style: const TextStyle(
                          color: AppTheme.textSecondaryColor, fontSize: 12),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
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
              if (controller.text.trim().isNotEmpty) {
                context
                    .read<CustomListViewModel>()
                    .createList(controller.text.trim());
                Navigator.pop(ctx);
              }
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

  List<String> _suggestedNames() {
    final lang = Translations.currentLanguage;
    switch (lang) {
      case Language.tr:
        return [
          'Hafta sonu izle',
          'Korku gecesi',
          'Oscar adayları',
          'Babamla izlenecekler',
          '90 dakika altı',
          'Tekrar izlenecekler',
        ];
      case Language.es:
        return [
          'Ver el fin de semana',
          'Noche de terror',
          'Candidatos al Oscar',
          'Con papá',
          'Menos de 90 min',
          'Para volver a ver',
        ];
      default:
        return [
          'Weekend Watch',
          'Horror Night',
          'Oscar Nominees',
          'Watch with Dad',
          'Under 90 min',
          'Rewatch List',
        ];
    }
  }

  void _showDeleteConfirm(BuildContext context, CustomList list) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          Translations.tr('deleteList'),
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          Translations.tr('deleteListConfirm'),
          style: const TextStyle(color: AppTheme.textSecondaryColor),
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
              context.read<CustomListViewModel>().deleteList(list.id);
              Navigator.pop(ctx);
            },
            child: Text(
              Translations.tr('delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToWatchSection(BuildContext context) {
    final homeVm = context.watch<HomeViewModel>();
    final toWatchMovies = homeVm.toWatchMovies;
    if (toWatchMovies.isEmpty) return const SizedBox();
    return _ListSectionCard(
      title: Translations.tr('statusToWatch'),
      icon: Icons.bookmark_outline_rounded,
      iconColor: const Color(0xFF607D8B),
      count: toWatchMovies.length,
      previewMovies: toWatchMovies.take(3).toList(),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _StatusMovieListView(
              title: Translations.tr('statusToWatch'),
              movies: toWatchMovies,
            ),
          ),
        ).then((_) {
          if (!context.mounted) return;
          homeVm.init();
        });
      },
    );
  }

  Widget _buildWatchingSection(BuildContext context) {
    final homeVm = context.watch<HomeViewModel>();
    final watchingMovies = homeVm.watchingMovies;
    if (watchingMovies.isEmpty) return const SizedBox();
    return _ListSectionCard(
      title: Translations.tr('currentlyWatching'),
      icon: Icons.play_circle_outline_rounded,
      iconColor: const Color(0xFF2196F3),
      count: watchingMovies.length,
      previewMovies: watchingMovies.take(3).toList(),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _StatusMovieListView(
              title: Translations.tr('currentlyWatching'),
              movies: watchingMovies,
            ),
          ),
        ).then((_) {
          if (!context.mounted) return;
          homeVm.init();
        });
      },
    );
  }

  Widget _buildDroppedSection(BuildContext context) {
    final homeVm = context.watch<HomeViewModel>();
    final droppedMovies = homeVm.droppedMovies;
    if (droppedMovies.isEmpty) return const SizedBox();
    return _ListSectionCard(
      title: Translations.tr('droppedList'),
      icon: Icons.cancel_outlined,
      iconColor: const Color(0xFFFF5722),
      count: droppedMovies.length,
      previewMovies: droppedMovies.take(3).toList(),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _StatusMovieListView(
              title: Translations.tr('droppedList'),
              movies: droppedMovies,
            ),
          ),
        ).then((_) {
          if (!context.mounted) return;
          homeVm.init();
        });
      },
    );
  }

  Widget _buildRewatchSection(BuildContext context) {
    final homeVm = context.watch<HomeViewModel>();
    final rewatchMovies = homeVm.rewatchMovies;
    if (rewatchMovies.isEmpty) return const SizedBox();
    return _ListSectionCard(
      title: Translations.tr('watchAgainList'),
      icon: Icons.replay_rounded,
      iconColor: const Color(0xFFFF9800),
      count: rewatchMovies.length,
      previewMovies: rewatchMovies.take(3).toList(),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _StatusMovieListView(
              title: Translations.tr('watchAgainList'),
              movies: rewatchMovies,
            ),
          ),
        ).then((_) {
          if (!context.mounted) return;
          homeVm.init();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Consumer<CustomListViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          SizeTokens.paddingMedium,
                          SizeTokens.paddingMedium,
                          SizeTokens.paddingMedium,
                          SizeTokens.paddingSmall,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Translations.tr('myLists'),
                              style: TextStyle(
                                fontSize: SizeTokens.textTitle,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: _showCreateListDialog,
                              icon: const Icon(Icons.add_circle_outline,
                                  color: AppTheme.primaryColor),
                              tooltip: Translations.tr('createList'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Status-based built-in lists
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeTokens.paddingMedium),
                        child: Column(
                          children: [
                            _buildToWatchSection(context),
                            _buildWatchingSection(context),
                            _buildDroppedSection(context),
                            _buildRewatchSection(context),
                          ],
                        ),
                      ),
                    ),
                    // Divider + custom lists header
                    if (vm.lists.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            SizeTokens.paddingMedium,
                            SizeTokens.paddingLarge,
                            SizeTokens.paddingMedium,
                            SizeTokens.paddingSmall,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.playlist_play_rounded,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                Translations.tr('createList'),
                                style: TextStyle(
                                  fontSize: SizeTokens.textLarge,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Custom lists
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final list = vm.lists[index];
                          final movies = vm.moviesForList(list);
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeTokens.paddingMedium,
                              vertical: SizeTokens.paddingSmall / 2,
                            ),
                            child: _ListSectionCard(
                              title: list.name,
                              icon: Icons.list_alt_rounded,
                              iconColor: AppTheme.primaryColor,
                              count: list.movieIds.length,
                              previewMovies: movies.take(3).toList(),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CustomListDetailView(
                                        customList: list),
                                  ),
                                ).then((_) {
                                  if (!context.mounted) return;
                                  vm.init();
                                });
                              },
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: AppTheme.textSecondaryColor,
                                    size: 20),
                                onPressed: () =>
                                    _showDeleteConfirm(context, list),
                              ),
                            ),
                          );
                        },
                        childCount: vm.lists.length,
                      ),
                    ),
                    // Empty state
                    if (vm.lists.isEmpty &&
                        context.watch<HomeViewModel>().toWatchMovies.isEmpty &&
                        context.watch<HomeViewModel>().watchingMovies.isEmpty &&
                        context.watch<HomeViewModel>().droppedMovies.isEmpty &&
                        context.watch<HomeViewModel>().rewatchMovies.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.playlist_add_rounded,
                                size: 64,
                                color: AppTheme.textTertiaryColor,
                              ),
                              SizedBox(height: SizeTokens.paddingMedium),
                              Text(
                                Translations.tr('noLists'),
                                style: const TextStyle(
                                  color: AppTheme.textSecondaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: SizeTokens.paddingLarge),
                              ElevatedButton.icon(
                                onPressed: _showCreateListDialog,
                                icon: const Icon(Icons.add),
                                label:
                                    Text(Translations.tr('createList')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                        child: SizedBox(
                            height: SizeConfig.relativeSize(80))),
                  ],
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showCreateListDialog,
            backgroundColor: AppTheme.primaryColor,
            mini: true,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}

class _ListSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final int count;
  final List<Movie> previewMovies;
  final VoidCallback onTap;
  final Widget? trailing;

  const _ListSectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.previewMovies,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: SizeTokens.circularRadiusMedium,
          border: Border.all(color: AppTheme.surfaceLightColor),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$count',
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (previewMovies.isNotEmpty) ...[
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                height: 40,
                child: Stack(
                  children: previewMovies
                      .take(3)
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) {
                    final i = entry.key;
                    final movie = entry.value;
                    return Positioned(
                      left: i * 16.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: _miniPoster(movie),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            if (trailing != null)
              trailing!
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondaryColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _miniPoster(Movie movie) {
    if (movie.posterLocalPath != null) {
      return Image.file(
        File(movie.posterLocalPath!),
        width: 28,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _fallback(movie),
      );
    }
    if (movie.posterUrl != null && movie.posterUrl != 'N/A') {
      return Image.network(
        movie.posterUrl!,
        width: 28,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _fallback(movie),
      );
    }
    return _fallback(movie);
  }

  Widget _fallback(Movie movie) {
    return Container(
      width: 28,
      height: 40,
      color: AppTheme.surfaceLightColor,
      child: const Icon(Icons.movie_outlined,
          size: 12, color: AppTheme.textTertiaryColor),
    );
  }
}

/// Reusable screen that shows movies filtered by watch status.
class _StatusMovieListView extends StatelessWidget {
  final String title;
  final List<Movie> movies;

  const _StatusMovieListView({
    required this.title,
    required this.movies,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: movies.isEmpty
          ? Center(
              child: Text(
                Translations.tr('emptyMovies'),
                style: const TextStyle(color: AppTheme.textSecondaryColor),
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
                return InkWell(
                  borderRadius: SizeTokens.circularRadiusSmall,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailView(movie: movie),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: SizeTokens.circularRadiusSmall,
                    child: _buildPoster(movie),
                  ),
                );
              },
            ),
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
