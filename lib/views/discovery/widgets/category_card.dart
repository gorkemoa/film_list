import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_config.dart';
import '../../../core/responsive/size_tokens.dart';

/// Category card displayed in the horizontal scrollable category row.
class CategoryCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: SizeConfig.relativeSize(92),
        margin: EdgeInsets.only(right: SizeTokens.paddingSmall),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.18)
              : AppTheme.surfaceColor,
          borderRadius: SizeTokens.circularRadiusMedium,
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.surfaceLightColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        padding: EdgeInsets.symmetric(
          vertical: SizeTokens.paddingSmall,
          horizontal: SizeTokens.paddingSmall,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: SizeTokens.iconMedium,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondaryColor,
            ),
            SizedBox(height: SizeConfig.relativeSize(6)),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: SizeTokens.textSmall,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondaryColor,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
