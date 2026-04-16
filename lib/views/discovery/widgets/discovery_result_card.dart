import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_config.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../models/discovery_preference.dart';

class DiscoveryResultCard extends StatelessWidget {
  final DiscoveryResult result;
  final VoidCallback onTap;

  const DiscoveryResultCard({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final posterWidth = SizeConfig.relativeSize(100);
    final cardHeight = SizeConfig.relativeSize(152);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: SizeTokens.paddingMedium),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: SizeTokens.circularRadiusMedium,
          border: Border.all(color: AppTheme.surfaceLightColor, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Poster ─────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(SizeTokens.radiusMedium),
                bottomLeft: Radius.circular(SizeTokens.radiusMedium),
              ),
              child: SizedBox(
                width: posterWidth,
                height: cardHeight,
                child: result.posterUrl != null
                    ? Image.network(
                        result.posterUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) =>
                            _fallbackPoster(),
                      )
                    : _fallbackPoster(),
              ),
            ),

            // ── Info ────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(SizeTokens.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      result.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: SizeTokens.textMedium,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: SizeConfig.relativeSize(4)),

                    // Year · Genre
                    Text(
                      '${result.year}  ·  ${result.genre.split(',').first.trim()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: SizeTokens.textSmall,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    SizedBox(height: SizeConfig.relativeSize(8)),

                    // Meta row: IMDb + Runtime
                    Row(
                      children: [
                        if (result.imdbRating != null &&
                            result.imdbRating != 'N/A') ...[
                          _MetaBadge(
                            icon: Icons.star_rounded,
                            label: result.imdbRating!,
                            color: const Color(0xFFF5C518),
                          ),
                          SizedBox(width: SizeConfig.relativeSize(8)),
                        ],
                        if (result.runtime != null &&
                            result.runtime != 'N/A')
                          _MetaBadge(
                            icon: Icons.timer_outlined,
                            label: result.runtime!,
                            color: AppTheme.textSecondaryColor,
                          ),
                      ],
                    ),
                    SizedBox(height: SizeConfig.relativeSize(10)),

                    // Why recommended
                    _ReasonChip(reason: result.reason),
                  ],
                ),
              ),
            ),

            // ── Chevron ─────────────────────────────────────
            Padding(
              padding: EdgeInsets.only(
                right: SizeTokens.paddingSmall,
                top: SizeConfig.relativeSize(cardHeight / 2 - 12),
              ),
              child: Icon(
                Icons.chevron_right,
                color: AppTheme.textTertiaryColor,
                size: SizeTokens.iconMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackPoster() {
    return Container(
      color: AppTheme.surfaceLightColor,
      child: Center(
        child: Icon(
          Icons.movie_outlined,
          color: AppTheme.textTertiaryColor,
          size: SizeTokens.iconXLarge,
        ),
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ReasonChip extends StatelessWidget {
  final String reason;

  const _ReasonChip({required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 11,
            color: AppTheme.primaryColor.withValues(alpha: 0.85),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              reason,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondaryColor,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
