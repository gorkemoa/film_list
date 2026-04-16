import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/translations.dart';
import '../../app/app_theme.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../viewmodels/discovery_view_model.dart';
import '../../models/movie.dart';
import '../movie_detail/movie_detail_view.dart';
import '../widgets/custom_poster_widget.dart';

class DiscoveryView extends StatefulWidget {
  const DiscoveryView({super.key});

  @override
  State<DiscoveryView> createState() => _DiscoveryViewState();
}

class _DiscoveryViewState extends State<DiscoveryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscoveryViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final vm = context.watch<DiscoveryViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(),
          _buildDiscoveryTools(vm),
          _buildMoodSection(vm),
          _buildResultsHeader(vm),
          _buildResultsGrid(vm),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => vm.getRandomMovie(),
        backgroundColor: AppTheme.primaryColor,
        label: Text(Translations.tr('whatToWatchToday')),
        icon: const Icon(Icons.casino_rounded),
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
              Translations.tr('discoveryTab'),
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              Translations.tr('smartDiscovery'),
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

  Widget _buildDiscoveryTools(DiscoveryViewModel vm) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: SizeTokens.paddingLarge),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.surfaceLightColor),
        ),
        child: Column(
          children: [
            _buildQuickActions(vm),
            const Divider(height: 32, color: AppTheme.surfaceLightColor),
            _buildRangeSlider(
              title: Translations.tr('filterYear'),
              values: vm.yearRange,
              min: 1900,
              max: 2026,
              onChanged: (val) {
                vm.yearRange = val;
                vm.applyFilters();
              },
            ),
            _buildRangeSlider(
              title: Translations.tr('filterRating'),
              values: vm.ratingRange,
              min: 0,
              max: 10,
              divisions: 20,
              onChanged: (val) {
                vm.ratingRange = val;
                vm.applyFilters();
              },
            ),
            _buildRangeSlider(
              title: Translations.tr('filterDuration'),
              values: vm.durationRange,
              min: 0,
              max: 300,
              labelSuffix: ' ${Translations.tr('min')}',
              onChanged: (val) {
                vm.durationRange = val;
                vm.applyFilters();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(DiscoveryViewModel vm) {
    return Row(
      children: [
        _QuickActionChip(
          label: Translations.tr('quickMovie'),
          onTap: () => vm.discoverQuickMovies(),
        ),
        const SizedBox(width: 8),
        _QuickActionChip(
          label: Translations.tr('highlyRatedShort'),
          onTap: () => vm.discoverHighRatedShort(),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => vm.clearFilters(),
          icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryColor),
          tooltip: 'Clear',
        ),
      ],
    );
  }

  Widget _buildRangeSlider({
    required String title,
    required RangeValues values,
    required double min,
    required double max,
    int? divisions,
    String labelSuffix = '',
    required ValueChanged<RangeValues> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              '${values.start.round()}$labelSuffix - ${values.end.round()}$labelSuffix',
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        RangeSlider(
          values: values,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppTheme.primaryColor,
          inactiveColor: AppTheme.surfaceLightColor,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildMoodSection(DiscoveryViewModel vm) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              SizeTokens.paddingLarge,
              SizeTokens.paddingLarge,
              SizeTokens.paddingLarge,
              SizeTokens.paddingSmall,
            ),
            child: Text(
              Translations.tr('discoverByMood'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: SizeTokens.paddingLarge,
              ),
              children: [
                _MoodCard(
                  title: Translations.tr('funMood'),
                  icon: Icons.emoji_emotions_outlined,
                  color: Colors.orange,
                  onTap: () => vm.discoverByMood('fun'),
                ),
                _MoodCard(
                  title: Translations.tr('darkMood'),
                  icon: Icons.nights_stay_outlined,
                  color: Colors.deepPurple,
                  onTap: () => vm.discoverByMood('dark'),
                ),
                _MoodCard(
                  title: Translations.tr('mindBending'),
                  icon: Icons.psychology_outlined,
                  color: Colors.teal,
                  onTap: () => vm.discoverByMood('mind-bending'),
                ),
                _MoodCard(
                  title: Translations.tr('familyMood'),
                  icon: Icons.family_restroom_outlined,
                  color: Colors.blue,
                  onTap: () => vm.discoverByMood('family'),
                ),
                _MoodCard(
                  title: Translations.tr('soloMood'),
                  icon: Icons.person_outline_rounded,
                  color: Colors.pink,
                  onTap: () => vm.discoverByMood('solo'),
                ),
                _MoodCard(
                  title: Translations.tr('lightMood'),
                  icon: Icons.wb_sunny_outlined,
                  color: Colors.amber,
                  onTap: () => vm.discoverByMood('light'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader(DiscoveryViewModel vm) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(SizeTokens.paddingLarge),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${vm.filteredMovies.length} ${Translations.tr('items')}',
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsGrid(DiscoveryViewModel vm) {
    if (vm.isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (vm.filteredMovies.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.movie_filter_rounded,
                size: 64,
                color: AppTheme.surfaceLightColor,
              ),
              const SizedBox(height: 16),
              Text(
                Translations.tr('noResults'),
                style: const TextStyle(color: AppTheme.textSecondaryColor),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: SizeTokens.paddingLarge),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final movie = vm.filteredMovies[index];
          return _DiscoveryMovieCard(movie: movie);
        }, childCount: vm.filteredMovies.length),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _MoodCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MoodCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoveryMovieCard extends StatelessWidget {
  final Movie movie;

  const _DiscoveryMovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MovieDetailView(movie: movie)),
        ).then((_) {
          if (context.mounted) {
            context.read<DiscoveryViewModel>().init();
          }
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: movie.posterLocalPath != null
                  ? Image.file(
                      File(movie.posterLocalPath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                          CustomPosterWidget(movie: movie),
                    )
                  : (movie.posterUrl != null && movie.posterUrl != 'N/A')
                  ? Image.network(
                      movie.posterUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                          CustomPosterWidget(movie: movie),
                    )
                  : CustomPosterWidget(movie: movie, width: double.infinity),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            movie.year,
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
