import 'dart:io';
import 'dart:ui';
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: EdgeInsets.all(SizeTokens.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppTheme.textTertiaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
                alignment: Alignment.center,
              ),
              Text(
                Translations.tr('createList'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeTokens.textTitle,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: Translations.tr('listNameHint'),
                  hintStyle: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                  ),
                  filled: true,
                  fillColor: AppTheme.surfaceLightColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                Translations.tr('suggestedListNames'),
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestedNames().map((name) {
                  return GestureDetector(
                    onTap: () => controller.text = name,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLightColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      context.read<CustomListViewModel>().createList(
                        controller.text.trim(),
                      );
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    Translations.tr('save'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _suggestedNames() {
    final lang = Translations.currentLanguage;
    switch (lang) {
      case Language.tr:
        return [
          'Hafta sonu',
          'Korku gecesi',
          'Oscar adayları',
          'Aile ile izlenecekler',
          'Favorilerim',
          '90dk altı',
        ];
      case Language.es:
        return [
          'Finde semana',
          'Noche de terror',
          'Oscars',
          'Familia',
          'Favoritos',
          'Cortos',
        ];
      default:
        return [
          'Weekend',
          'Horror Night',
          'Oscars',
          'Watch with Family',
          'Favorites',
          'Under 90min',
        ];
    }
  }

  void _showDeleteConfirm(BuildContext context, CustomList list) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            Translations.tr('deleteList'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
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
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final homeVm = context.watch<HomeViewModel>();

    return Consumer<CustomListViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Header Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(SizeTokens.paddingLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Translations.tr('myLists'),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              Translations.tr('organizeYourMovies'),
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.textSecondaryColor,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Smart Categories Grid
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeTokens.paddingLarge,
                      ),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.5,
                            ),
                        delegate: SliverChildListDelegate([
                          _SmartCategoryCard(
                            title: Translations.tr('statusToWatch'),
                            icon: Icons.bookmark_outline_rounded,
                            count: homeVm.toWatchMovies.length,
                            color: const Color(0xFF607D8B),
                            movies: homeVm.toWatchMovies,
                          ),
                          _SmartCategoryCard(
                            title: Translations.tr('currentlyWatching'),
                            icon: Icons.play_circle_outline_rounded,
                            count: homeVm.watchingMovies.length,
                            color: const Color(0xFF2196F3),
                            movies: homeVm.watchingMovies,
                          ),
                          _SmartCategoryCard(
                            title: Translations.tr('watchAgainList'),
                            icon: Icons.replay_rounded,
                            count: homeVm.rewatchMovies.length,
                            color: const Color(0xFFFF9800),
                            movies: homeVm.rewatchMovies,
                          ),
                          _SmartCategoryCard(
                            title: Translations.tr('droppedList'),
                            icon: Icons.cancel_outlined,
                            count: homeVm.droppedMovies.length,
                            color: const Color(0xFFFF5722),
                            movies: homeVm.droppedMovies,
                          ),
                        ]),
                      ),
                    ),

                    // Custom Lists Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          SizeTokens.paddingLarge,
                          SizeTokens.paddingXLarge,
                          SizeTokens.paddingLarge,
                          SizeTokens.paddingMedium,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Translations.tr('customLists'),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            GestureDetector(
                              onTap: _showCreateListDialog,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppTheme.primaryColor.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.add,
                                      color: AppTheme.primaryColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      Translations.tr('create'),
                                      style: const TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Custom Lists Content
                    if (vm.lists.isEmpty)
                      SliverToBoxAdapter(
                        child: Container(
                          margin: EdgeInsets.all(SizeTokens.paddingLarge),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.surfaceLightColor,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.playlist_add_rounded,
                                size: 48,
                                color: AppTheme.textTertiaryColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                Translations.tr('noCustomLists'),
                                style: const TextStyle(
                                  color: AppTheme.textSecondaryColor,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeTokens.paddingLarge,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final list = vm.lists[index];
                            final movies = vm.moviesForList(list);
                            return _CustomListCard(
                              list: list,
                              movies: movies,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CustomListDetailView(customList: list),
                                  ),
                                ).then((_) {
                                  if (context.mounted) vm.init();
                                });
                              },
                              onDelete: () => _showDeleteConfirm(context, list),
                            );
                          }, childCount: vm.lists.length),
                        ),
                      ),

                    // Bottom Spacer
                    SliverToBoxAdapter(
                      child: SizedBox(height: SizeConfig.relativeSize(100)),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _SmartCategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int count;
  final Color color;
  final List<Movie> movies;

  const _SmartCategoryCard({
    required this.title,
    required this.icon,
    required this.count,
    required this.color,
    required this.movies,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _StatusMovieListView(title: title, movies: movies),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -10,
                child: Icon(
                  icon,
                  size: 64,
                  color: color.withValues(alpha: 0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '$count ${Translations.tr('items')}',
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomListCard extends StatelessWidget {
  final CustomList list;
  final List<Movie> movies;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CustomListCard({
    required this.list,
    required this.movies,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 100,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.surfaceLightColor),
        ),
        child: Row(
          children: [
            // Preview Stack
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLightColor,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
              ),
              child: movies.isEmpty
                  ? const Icon(
                      Icons.movie_filter_rounded,
                      color: AppTheme.textTertiaryColor,
                    )
                  : Stack(
                      children: movies.take(3).toList().asMap().entries.map((
                        entry,
                      ) {
                        final i = entry.key;
                        final movie = entry.value;
                        return Positioned(
                          left: i * 8.0 + 8.0,
                          top: i * 4.0 + 10.0,
                          child: Transform.rotate(
                            angle: (i - 1) * 0.05,
                            child: Container(
                              width: 50,
                              height: 75,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                    offset: const Offset(4, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: _miniPoster(movie),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${list.movieIds.length} ${Translations.tr('items')}',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppTheme.textSecondaryColor,
              ),
              onPressed: () {
                _showListOptions(context);
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  void _showListOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textTertiaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.open_in_new_rounded, color: Colors.white),
            title: Text(
              Translations.tr('open'),
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(ctx);
              onTap();
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.red,
            ),
            title: Text(
              Translations.tr('delete'),
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(ctx);
              onDelete();
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _miniPoster(Movie movie) {
    if (movie.posterLocalPath != null) {
      return Image.file(
        File(movie.posterLocalPath!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    if (movie.posterUrl != null && movie.posterUrl != 'N/A') {
      return Image.network(
        movie.posterUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      color: AppTheme.surfaceLightColor,
      child: const Icon(
        Icons.movie_outlined,
        size: 20,
        color: AppTheme.textTertiaryColor,
      ),
    );
  }
}

class _StatusMovieListView extends StatelessWidget {
  final String title;
  final List<Movie> movies;

  const _StatusMovieListView({required this.title, required this.movies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: movies.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.movie_filter_rounded,
                    size: 80,
                    color: AppTheme.textTertiaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Translations.tr('emptyMovies'),
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.all(SizeTokens.paddingLarge),
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
                  child: Hero(
                    tag: 'movie_poster_${movie.id}_$title',
                    child: ClipRRect(
                      borderRadius: SizeTokens.circularRadiusSmall,
                      child: _buildPoster(movie),
                    ),
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
