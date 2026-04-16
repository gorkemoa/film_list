import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../app/translations.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../viewmodels/discovery_view_model.dart';
import '../../services/discovery_service.dart';
import '../movie_detail/movie_detail_view.dart';
import 'widgets/category_card.dart';
import 'widgets/discovery_result_card.dart';
import 'widgets/quiz_option_row.dart';

class DiscoveryView extends StatefulWidget {
  const DiscoveryView({super.key});

  @override
  State<DiscoveryView> createState() => _DiscoveryViewState();
}

class _DiscoveryViewState extends State<DiscoveryView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Category definitions ─────────────────────────────────────────────────
  final List<_CategoryDef> _categories = const [
    _CategoryDef('action', Icons.local_fire_department_rounded),
    _CategoryDef('sciFi', Icons.rocket_launch_rounded),
    _CategoryDef('thriller', Icons.visibility_rounded),
    _CategoryDef('comedy', Icons.sentiment_very_satisfied_rounded),
    _CategoryDef('romance', Icons.favorite_rounded),
    _CategoryDef('family', Icons.family_restroom_rounded),
    _CategoryDef('shortRuntime', Icons.timer_rounded),
    _CategoryDef('highRated', Icons.star_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Consumer<DiscoveryViewModel>(
      builder: (context, vm, _) {
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildQuizTab(context, vm),
                    _buildCategoryTab(context, vm),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        SizeTokens.paddingMedium,
        SizeTokens.paddingMedium,
        SizeTokens.paddingMedium,
        SizeTokens.paddingSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Translations.tr('discoveryTab'),
            style: TextStyle(
              fontSize: SizeTokens.textTitle,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: SizeConfig.relativeSize(4)),
          Text(
            Translations.tr('discoverySubtitle'),
            style: TextStyle(
              fontSize: SizeTokens.textSmall,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab bar ───────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeTokens.paddingMedium),
      child: Container(
        height: SizeConfig.relativeSize(40),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: SizeTokens.circularRadiusMedium,
        ),
        child: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: SizeTokens.circularRadiusMedium,
          ),
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.textSecondaryColor,
          labelStyle: TextStyle(
            fontSize: SizeTokens.textSmall,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(fontSize: SizeTokens.textSmall),
          tabs: [
            Tab(text: Translations.tr('quizTab')),
            Tab(text: Translations.tr('categoriesTab')),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // QUIZ TAB
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildQuizTab(BuildContext context, DiscoveryViewModel vm) {
    // If results are shown, display them
    if (vm.mode == DiscoveryMode.quiz && !vm.isIdle) {
      return _buildResultsSection(context, vm);
    }
    return SingleChildScrollView(
      padding: EdgeInsets.all(SizeTokens.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: SizeTokens.paddingSmall),

          // ── Mood ──────────────────────────────────────────
          QuizOptionRow(
            label: Translations.tr('quizMood'),
            selectedValue: vm.selectedMood,
            onSelected: vm.setMood,
            options: buildQuizOptions([
              (Translations.tr('funMood'), 'fun', Icons.mood_rounded),
              (Translations.tr('darkMood'), 'dark', Icons.nights_stay_rounded),
              (Translations.tr('mindBending'), 'mind-bending', Icons.psychology_rounded),
              (Translations.tr('lightMood'), 'light', Icons.wb_sunny_rounded),
              (Translations.tr('familyMood'), 'family', Icons.family_restroom_rounded),
            ]),
          ),

          // ── Genre ─────────────────────────────────────────
          QuizOptionRow(
            label: Translations.tr('genre'),
            selectedValue: vm.selectedGenre,
            onSelected: vm.setGenre,
            options: buildQuizOptions([
              (Translations.tr('action'), 'Action', Icons.local_fire_department_rounded),
              (Translations.tr('sciFi'), 'Sci-Fi', Icons.rocket_launch_rounded),
              (Translations.tr('thriller'), 'Thriller', Icons.visibility_rounded),
              (Translations.tr('comedy'), 'Comedy', Icons.sentiment_very_satisfied_rounded),
              (Translations.tr('romance'), 'Romance', Icons.favorite_rounded),
              (Translations.tr('drama'), 'Drama', Icons.theater_comedy_rounded),
              (Translations.tr('horror'), 'Horror', Icons.warning_amber_rounded),
              (Translations.tr('animation'), 'Animation', Icons.animation_rounded),
            ]),
          ),

          // ── Duration ──────────────────────────────────────
          QuizOptionRow(
            label: Translations.tr('quizDuration'),
            selectedValue: vm.selectedDuration,
            onSelected: vm.setDuration,
            options: buildQuizOptions([
              (Translations.tr('quizDurationShort'), 'short', Icons.timelapse_rounded),
              (Translations.tr('quizDurationMedium'), 'medium', Icons.timer_rounded),
              (Translations.tr('quizDurationAny'), 'any', Icons.all_inclusive_rounded),
            ]),
          ),

          // ── Viewing context ───────────────────────────────
          QuizOptionRow(
            label: Translations.tr('quizContext'),
            selectedValue: vm.selectedViewingContext,
            onSelected: vm.setViewingContext,
            options: buildQuizOptions([
              (Translations.tr('soloMood'), 'solo', Icons.person_rounded),
              (Translations.tr('quizFriends'), 'friends', Icons.group_rounded),
              (Translations.tr('familyMood'), 'family', Icons.family_restroom_rounded),
            ]),
          ),

          // ── Era ───────────────────────────────────────────
          QuizOptionRow(
            label: Translations.tr('quizEra'),
            selectedValue: vm.selectedEra,
            onSelected: vm.setEra,
            options: buildQuizOptions([
              (Translations.tr('quizEraNew'), 'new', Icons.new_releases_rounded),
              (Translations.tr('quizEraClassic'), 'classic', Icons.history_rounded),
              (Translations.tr('quizDurationAny'), 'any', Icons.all_inclusive_rounded),
            ]),
          ),

          SizedBox(height: SizeTokens.paddingSmall),

          // ── CTA button ────────────────────────────────────
          _buildCtaButton(
            label: Translations.tr('recommendMe'),
            enabled: vm.quizIsReady,
            onTap: () => vm.fetchFromQuiz(),
          ),

          SizedBox(height: SizeConfig.relativeSize(80)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CATEGORY TAB
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildCategoryTab(BuildContext context, DiscoveryViewModel vm) {
    if (vm.mode == DiscoveryMode.category && !vm.isIdle) {
      return _buildResultsSection(context, vm);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(SizeTokens.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: SizeTokens.paddingSmall),
          Text(
            Translations.tr('pickACategory'),
            style: TextStyle(
              fontSize: SizeTokens.textSmall,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          SizedBox(height: SizeTokens.paddingMedium),

          // ── Category grid ─────────────────────────────────
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: SizeTokens.paddingSmall,
            mainAxisSpacing: SizeTokens.paddingSmall,
            childAspectRatio: 0.85,
            children: _categories
                .map(
                  (cat) => CategoryCard(
                    label: _categoryLabel(cat.key),
                    icon: cat.icon,
                    isSelected: vm.selectedCategoryKey == cat.key,
                    onTap: () {
                      // Mark selection visually, then fetch
                      context.read<DiscoveryViewModel>().selectedCategoryKey =
                          cat.key;
                      vm.fetchFromCategory(cat.key);
                    },
                  ),
                )
                .toList(),
          ),

          SizedBox(height: SizeConfig.relativeSize(80)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RESULTS SECTION (shared by both tabs)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildResultsSection(BuildContext context, DiscoveryViewModel vm) {
    if (vm.isLoading) return _buildLoadingState();
    if (vm.hasError) return _buildErrorState(context, vm);
    if (vm.hasResults) return _buildResultsList(context, vm);
    return const SizedBox();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: SizeConfig.relativeSize(48),
            height: SizeConfig.relativeSize(48),
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: SizeTokens.paddingMedium),
          Text(
            Translations.tr('discoverySearching'),
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: SizeTokens.textSmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, DiscoveryViewModel vm) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(SizeTokens.paddingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: SizeConfig.relativeSize(56),
              color: AppTheme.textTertiaryColor,
            ),
            SizedBox(height: SizeTokens.paddingMedium),
            Text(
              Translations.tr('discoveryNoResults'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SizeTokens.textMedium,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            SizedBox(height: SizeTokens.paddingLarge),
            _buildCtaButton(
              label: Translations.tr('tryAgain'),
              enabled: true,
              onTap: vm.reset,
              secondary: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, DiscoveryViewModel vm) {
    final discoveryService = DiscoveryService();
    return Column(
      children: [
        // ── Results header + "Try Again" ─────────────────
        Padding(
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
                '${vm.results.length} ${Translations.tr('discoveryResultsFound')}',
                style: TextStyle(
                  fontSize: SizeTokens.textSmall,
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: vm.reset,
                child: Row(
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: SizeTokens.iconSmall,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      Translations.tr('tryAgain'),
                      style: TextStyle(
                        fontSize: SizeTokens.textSmall,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Result cards ─────────────────────────────────
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: SizeTokens.paddingMedium,
            ),
            itemCount: vm.results.length,
            itemBuilder: (context, index) {
              final result = vm.results[index];
              return DiscoveryResultCard(
                result: result,
                onTap: () {
                  final movie = discoveryService.discoveryResultToMovie(result);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieDetailView(movie: movie),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ── CTA Button ────────────────────────────────────────────────────────────
  Widget _buildCtaButton({
    required String label,
    required bool enabled,
    required VoidCallback onTap,
    bool secondary = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: SizeTokens.heightMedium,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.45,
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton(
          onPressed: enabled ? onTap : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                secondary ? AppTheme.surfaceColor : AppTheme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: SizeTokens.circularRadiusMedium,
              side: secondary
                  ? const BorderSide(color: AppTheme.surfaceLightColor)
                  : BorderSide.none,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: SizeTokens.textMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _categoryLabel(String key) {
    final map = {
      'action': Translations.tr('action'),
      'sciFi': Translations.tr('sciFi'),
      'thriller': Translations.tr('thriller'),
      'comedy': Translations.tr('comedy'),
      'romance': Translations.tr('romance'),
      'family': Translations.tr('family'),
      'shortRuntime': Translations.tr('categoryShortRuntime'),
      'highRated': Translations.tr('categoryHighRated'),
    };
    return map[key] ?? key;
  }
}

// ── Small data class for category definitions ─────────────────────────────
class _CategoryDef {
  final String key;
  final IconData icon;

  const _CategoryDef(this.key, this.icon);
}
