import 'package:flutter/material.dart';
import '../../../app/translations.dart';
import '../../../core/responsive/size_config.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../app/app_theme.dart';

class AddPosterWidget extends StatelessWidget {
  final VoidCallback onTap;
  final String? label;

  const AddPosterWidget({super.key, required this.onTap, this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: SizeTokens.circularRadiusSmall,
      child: Container(
        width: SizeConfig.relativeSize(130),
        height: SizeConfig.relativeSize(200),
        decoration: BoxDecoration(
          borderRadius: SizeTokens.circularRadiusSmall,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.surfaceColor,
              AppTheme.surfaceLightColor,
              Colors.black,
            ],
          ),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.add_rounded,
                color: AppTheme.primaryColor,
                size: SizeTokens.iconLarge,
              ),
            ),
            SizedBox(height: SizeTokens.paddingMedium),
            Text(
              label ?? Translations.tr('addTab'),
              style: TextStyle(
                color: Colors.white70,
                fontSize: SizeTokens.textSmall,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
