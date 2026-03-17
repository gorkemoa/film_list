import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import '../../app/translations.dart';
import '../../app/app_theme.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../viewmodels/profile_view_model.dart';
import '../../viewmodels/home_view_model.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  void _showClearDataConfirmation(
    BuildContext context,
    ProfileViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Translations.tr('clearData')),
        content: Text(Translations.tr('clearDataConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Translations.tr('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await viewModel.clearAllData();
              if (context.mounted) {
                // Refresh home view model to reflect cleared data
                context.read<HomeViewModel>().init();
              }
            },
            child: Text(
              Translations.tr('yes'),
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, ProfileViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Translations.tr('language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(context, viewModel, Language.tr, 'Türkçe'),
            _buildLanguageOption(context, viewModel, Language.en, 'English'),
            _buildLanguageOption(context, viewModel, Language.es, 'Español'),
            _buildLanguageOption(context, viewModel, Language.fr, 'Français'),
            _buildLanguageOption(context, viewModel, Language.pt, 'Português'),
            _buildLanguageOption(context, viewModel, Language.de, 'Deutsch'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    ProfileViewModel viewModel,
    Language lang,
    String label,
  ) {
    final isSelected = viewModel.currentLanguage == lang;
    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check, color: AppTheme.primaryColor)
          : null,
      onTap: () {
        viewModel.changeLanguage(lang);
        Navigator.pop(context);
      },
    );
  }

  String _getLanguageName(Language lang) {
    switch (lang) {
      case Language.tr:
        return 'Türkçe';
      case Language.en:
        return 'English';
      case Language.es:
        return 'Español';
      case Language.fr:
        return 'Français';
      case Language.pt:
        return 'Português';
      case Language.de:
        return 'Deutsch';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(SizeTokens.paddingLarge),
            child: Column(
              children: [
                SizedBox(height: SizeTokens.paddingLarge),
                Icon(
                  Icons.account_circle,
                  size: SizeConfig.relativeSize(100),
                  color: AppTheme.textSecondaryColor,
                ),
                SizedBox(height: SizeTokens.paddingLarge),
                Text(
                  Translations.tr('profileTab'),
                  style: TextStyle(
                    fontSize: SizeTokens.textLarge * 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: SizeTokens.paddingLarge * 2),

                // Settings Card
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: SizeTokens.circularRadiusMedium,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Language Selection
                      ListTile(
                        leading: Icon(
                          Icons.language,
                          color: AppTheme.primaryColor,
                        ),
                        title: Text(Translations.tr('language')),
                        subtitle: Text(
                          _getLanguageName(viewModel.currentLanguage),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showLanguageDialog(context, viewModel),
                      ),
                      Divider(height: 1, indent: SizeTokens.paddingLarge),
                      // Rate App
                      ListTile(
                        leading: Icon(
                          Icons.star_rate,
                          color: AppTheme.primaryColor,
                        ),
                        title: Text(Translations.tr('rateApp')),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final inAppReview = InAppReview.instance;
                          // Gerçek Mod: Doğrudan sistemin native puanlama diyaloğunu açar
                          if (await inAppReview.isAvailable()) {
                            await inAppReview.requestReview();
                          } else {
                            // Desteklenmeyen durumlarda mağaza sayfasını açar
                            await inAppReview.openStoreListing();
                          }
                        },
                      ),
                      Divider(height: 1, indent: SizeTokens.paddingLarge),
                      // Clear Data
                      ListTile(
                        leading: Icon(
                          Icons.delete_forever,
                          color: AppTheme.errorColor,
                        ),
                        title: Text(
                          Translations.tr('clearData'),
                          style: TextStyle(color: AppTheme.errorColor),
                        ),
                        onTap: () =>
                            _showClearDataConfirmation(context, viewModel),
                      ),
                    ],
                  ),
                ),

                if (viewModel.isLoading) ...[
                  SizedBox(height: SizeTokens.paddingLarge),
                  const CircularProgressIndicator(),
                ],

                if (viewModel.errorMessage != null) ...[
                  SizedBox(height: SizeTokens.paddingMedium),
                  Text(
                    viewModel.errorMessage!,
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
