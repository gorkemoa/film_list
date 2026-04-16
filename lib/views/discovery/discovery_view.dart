import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/discovery_view_model.dart';
import '../../app/app_theme.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/responsive/size_config.dart';
import '../../models/discovery_models.dart';
import '../../models/movie.dart';
import '../movie_detail/movie_detail_view.dart';
import 'dart:ui';

class DiscoveryView extends StatelessWidget {
  const DiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DiscoveryViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(body: _buildBody(context, viewModel));
      },
    );
  }

  Widget _buildBody(BuildContext context, DiscoveryViewModel viewModel) {
    switch (viewModel.state) {
      case DiscoveryState.Initial:
        return _buildInitialState(context, viewModel);
      case DiscoveryState.Survey:
        return _buildSurveyState(context, viewModel);
      case DiscoveryState.Loading:
        return _buildLoadingState();
      case DiscoveryState.Results:
        return _buildResultsState(context, viewModel);
      case DiscoveryState.Error:
        return _buildErrorState(viewModel);
    }
  }

  Widget _buildInitialState(
    BuildContext context,
    DiscoveryViewModel viewModel,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(SizeTokens.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keşfet',
                  style: TextStyle(
                    fontSize: SizeTokens.textTitle * 1.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                SizedBox(height: SizeTokens.paddingSmall),
                Text(
                  'Sana uygun film önerileri',
                  style: TextStyle(
                    fontSize: SizeTokens.textLarge,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                SizedBox(height: SizeTokens.paddingXLarge),

                // AI Recommendation Card
                _buildActionCard(
                  title: 'Bana Öner',
                  subtitle: 'Anket ile sana en uygun filmi bulalım.',
                  icon: Icons.auto_awesome_rounded,
                  onTap: viewModel.startSurvey,
                  isPrimary: true,
                ),

                SizedBox(height: SizeTokens.paddingXLarge),

                Text(
                  'Kategoriler',
                  style: TextStyle(
                    fontSize: SizeTokens.textLarge,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                SizedBox(height: SizeTokens.paddingMedium),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: SizeTokens.paddingMedium),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: SizeTokens.paddingMedium,
              crossAxisSpacing: SizeTokens.paddingMedium,
              childAspectRatio: 1.5,
            ),
            delegate: SliverChildListDelegate([
              _buildCategoryCard(
                context,
                'Aksiyon',
                Icons.flash_on_rounded,
                viewModel,
              ),
              _buildCategoryCard(
                context,
                'Bilim Kurgu',
                Icons.rocket_launch_rounded,
                viewModel,
              ),
              _buildCategoryCard(
                context,
                'Gerilim',
                Icons.visibility_rounded,
                viewModel,
              ),
              _buildCategoryCard(
                context,
                'Komedi',
                Icons.sentiment_very_satisfied_rounded,
                viewModel,
              ),
              _buildCategoryCard(
                context,
                'Romantik',
                Icons.favorite_rounded,
                viewModel,
              ),
              _buildCategoryCard(
                context,
                'Aile',
                Icons.family_restroom_rounded,
                viewModel,
              ),
              _buildCategoryCard(
                context,
                'Kısa Sürede İzlenir',
                Icons.timer_rounded,
                viewModel,
              ),
              _buildCategoryCard(
                context,
                'Yüksek Puanlı',
                Icons.star_rounded,
                viewModel,
              ),
            ]),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: SizeTokens.paddingXLarge)),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(SizeTokens.paddingLarge),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPrimary
                ? [AppTheme.primaryColor, AppTheme.primaryDark]
                : [AppTheme.surfaceColor, AppTheme.surfaceLightColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: SizeTokens.circularRadiusLarge,
          boxShadow: [
            BoxShadow(
              color: isPrimary
                  ? AppTheme.primaryColor.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.textPrimaryColor,
                      fontSize: SizeTokens.textLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: SizeTokens.paddingSmall),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.textPrimaryColor.withValues(alpha: 0.8),
                      fontSize: SizeTokens.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              icon,
              color: AppTheme.textPrimaryColor,
              size: SizeTokens.iconXLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
    DiscoveryViewModel viewModel,
  ) {
    return GestureDetector(
      onTap: () => viewModel.findByCategory(title),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: SizeTokens.circularRadiusMedium,
          border: Border.all(color: AppTheme.surfaceLightColor, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: SizeTokens.iconLarge,
            ),
            SizedBox(height: SizeTokens.paddingSmall),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textPrimaryColor,
                fontWeight: FontWeight.w600,
                fontSize: SizeTokens.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurveyState(BuildContext context, DiscoveryViewModel viewModel) {
    final steps = [
      {
        'question': 'Şu anki ruh halin nasıl?',
        'options': ['Enerjik', 'Mutlu', 'Duygusal', 'Yorgun', 'Maceracı'],
      },
      {
        'question': 'Hangi tür filmler seni cezbeder?',
        'options': ['Aksiyon', 'Komedi', 'Dram', 'Bilim Kurgu', 'Gerilim'],
      },
      {
        'question': 'Ne kadar vaktin var?',
        'options': [
          'Kısa ( < 90 dk)',
          'Standart (90-120 dk)',
          'Destansı ( > 120 dk)',
        ],
      },
      {
        'question': 'Kiminle izleyeceksin?',
        'options': [
          'Tek başıma',
          'Arkadaşlarla',
          'Aileyle',
          'Eşimle/Sevgilimle',
        ],
      },
      {
        'question': 'Nasıl bir tercih yapalım?',
        'options': ['Yeni Çıkanlar', 'Klasikler', 'Fark etmez'],
      },
    ];

    final currentStep = steps[viewModel.currentSurveyStep];

    return Padding(
      padding: EdgeInsets.all(SizeTokens.paddingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Film Asistanı',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: SizeTokens.textMedium,
            ),
          ),
          SizedBox(height: SizeTokens.paddingMedium),
          Text(
            currentStep['question'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: SizeTokens.textTitle,
            ),
          ),
          SizedBox(height: SizeTokens.paddingXLarge),
          ...(currentStep['options'] as List<String>).map(
            (option) => Padding(
              padding: EdgeInsets.only(bottom: SizeTokens.paddingMedium),
              child: ElevatedButton(
                onPressed: () => viewModel.updateSurvey(option),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(SizeTokens.paddingLarge),
                  backgroundColor: AppTheme.surfaceColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: SizeTokens.circularRadiusMedium,
                    side: BorderSide(color: AppTheme.surfaceLightColor),
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: AppTheme.textPrimaryColor,
                    fontSize: SizeTokens.textLarge,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: viewModel.reset,
            child: Text(
              'İptal Et',
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryColor),
          SizedBox(height: SizeTokens.paddingLarge),
          Text(
            'Grok AI sana en uygun filmleri seçiyor...',
            style: TextStyle(color: AppTheme.textSecondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsState(
    BuildContext context,
    DiscoveryViewModel viewModel,
  ) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 120,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: viewModel.reset,
          ),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Önerilen Filmler',
              style: TextStyle(
                color: AppTheme.textPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: SizeTokens.textLarge,
              ),
            ),
            centerTitle: true,
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.all(SizeTokens.paddingMedium),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = viewModel.results[index];
              return _buildResultCard(context, item);
            }, childCount: viewModel.results.length),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(SizeTokens.paddingLarge),
            child: ElevatedButton(
              onPressed: viewModel.reset,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: EdgeInsets.all(SizeTokens.paddingLarge),
                shape: RoundedRectangleBorder(
                  borderRadius: SizeTokens.circularRadiusMedium,
                ),
              ),
              child: const Text(
                'Tekrar Dene',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(BuildContext context, DiscoveryMovie item) {
    final movie = item.movie;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MovieDetailView(movie: movie)),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: SizeTokens.paddingLarge),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: SizeTokens.circularRadiusLarge,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(SizeTokens.radiusLarge),
              ),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: movie.posterUrl != null && movie.posterUrl != 'N/A'
                        ? Image.network(movie.posterUrl!, fit: BoxFit.cover)
                        : Container(color: AppTheme.surfaceLightColor),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: SizeTokens.textLarge,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${movie.year} • ${movie.genre} • ${movie.runtime ?? ''}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: SizeTokens.textSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            movie.imdbRating ?? 'N/A',
                            style: const TextStyle(
                              color: Colors.white,
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
            Padding(
              padding: EdgeInsets.all(SizeTokens.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: AppTheme.primaryColor,
                        size: 16,
                      ),
                      SizedBox(width: SizeTokens.paddingSmall),
                      Text(
                        'Neden bu film?',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: SizeTokens.textMedium,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: SizeTokens.paddingSmall),
                  Text(
                    item.recommendationReason,
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: SizeTokens.textMedium,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(DiscoveryViewModel viewModel) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(SizeTokens.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppTheme.errorColor,
              size: 64,
            ),
            SizedBox(height: SizeTokens.paddingLarge),
            Text(
              viewModel.errorMessage ?? 'Bir hata oluştu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textPrimaryColor,
                fontSize: SizeTokens.textLarge,
              ),
            ),
            SizedBox(height: SizeTokens.paddingXLarge),
            ElevatedButton(
              onPressed: viewModel.reset,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}
