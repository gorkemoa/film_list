import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/translations.dart';
import '../../app/app_theme.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../viewmodels/stats_view_model.dart';
import '../widgets/custom_poster_widget.dart';
import '../movie_detail/movie_detail_view.dart';

class StatsView extends StatefulWidget {
  const StatsView({super.key});

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final vm = context.watch<StatsViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(),
          if (vm.isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (vm.errorMessage != null)
            SliverFillRemaining(child: Center(child: Text(vm.errorMessage!)))
          else ...[
            _buildQuickStats(vm),
            _buildSectionHeader(Translations.tr('favoritesPost2020')),
            _buildFavoritesPost2020(vm),
            _buildSectionHeader(Translations.tr('watchedThisMonth')),
            _buildWatchedThisMonth(vm),
            _buildSectionHeader(Translations.tr('watchedDirectors')),
            _buildListStats(vm.directorCounts, Icons.movie_creation_outlined),
            _buildSectionHeader(Translations.tr('mostSavedActors')),
            _buildListStats(vm.actorCounts, Icons.people_outline_rounded),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ]
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          SizeTokens.paddingLarge,
          SizeTokens.paddingXLarge * 2,
          SizeTokens.paddingLarge,
          SizeTokens.paddingMedium,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Translations.tr('collectionStats'),
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              Translations.tr('personalDashboard'),
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(StatsViewModel vm) {
    return SliverToBoxAdapter(
      child: Container(
        height: 120,
        margin: EdgeInsets.symmetric(vertical: SizeTokens.paddingMedium),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: SizeTokens.paddingLarge),
          children: [
            _StatCard(
              title: Translations.tr('mostRatedGenre'),
              value: vm.mostRatedGenre,
              icon: Icons.auto_awesome_rounded,
              color: Colors.amber,
            ),
            _StatCard(
              title: Translations.tr('watchedThisMonth'),
              value: vm.watchedThisMonth.length.toString(),
              icon: Icons.calendar_month_rounded,
              color: Colors.blue,
            ),
            _StatCard(
              title: Translations.tr('watchedDirectors'),
              value: vm.directorCounts.length.toString(),
              icon: Icons.movie_filter_rounded,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          SizeTokens.paddingLarge,
          SizeTokens.paddingLarge,
          SizeTokens.paddingLarge,
          SizeTokens.paddingSmall,
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesPost2020(StatsViewModel vm) {
    if (vm.favoritesPost2020.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState());
    }
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: SizeTokens.paddingLarge),
          itemCount: vm.favoritesPost2020.length,
          itemBuilder: (context, index) {
            final movie = vm.favoritesPost2020[index];
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MovieDetailView(movie: movie)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      CustomPosterWidget(movie: movie, width: 130),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 12),
                              const SizedBox(width: 2),
                              Text(
                                movie.imdbRating ?? '0',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildWatchedThisMonth(StatsViewModel vm) {
    if (vm.watchedThisMonth.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState());
    }
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: SizeTokens.paddingLarge),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final movie = vm.watchedThisMonth[index];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MovieDetailView(movie: movie)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomPosterWidget(movie: movie, width: double.infinity),
              ),
            );
          },
          childCount: vm.watchedThisMonth.length > 6 ? 6 : vm.watchedThisMonth.length,
        ),
      ),
    );
  }

  Widget _buildListStats(Map<String, int> counts, IconData icon) {
    final sortedEntries = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final displayEntries = sortedEntries.take(5).toList();

    if (displayEntries.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState());
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: SizeTokens.paddingLarge),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final entry = displayEntries[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.surfaceLightColor),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppTheme.primaryColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLightColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${entry.value}',
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          childCount: displayEntries.length,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Text(
          Translations.tr('emptyMovies'),
          style: const TextStyle(color: AppTheme.textTertiaryColor),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
