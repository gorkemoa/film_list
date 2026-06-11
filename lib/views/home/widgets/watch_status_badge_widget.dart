import 'package:flutter/material.dart';
import '../../../models/watch_status.dart';
import '../../../app/translations.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_tokens.dart';

class WatchStatusBadge extends StatelessWidget {
  final WatchStatus status;
  final bool showLabel;

  const WatchStatusBadge({
    super.key,
    required this.status,
    this.showLabel = false,
  });

  static Color colorFor(WatchStatus s) {
    switch (s) {
      case WatchStatus.toWatch:
        return const Color(0xFF607D8B);
      case WatchStatus.watching:
        return const Color(0xFF2196F3);
      case WatchStatus.watched:
        return const Color(0xFF4CAF50);
      case WatchStatus.dropped:
        return const Color(0xFFFF5722);
      case WatchStatus.rewatch:
        return const Color(0xFFFF9800);
    }
  }

  static IconData iconFor(WatchStatus s) {
    switch (s) {
      case WatchStatus.toWatch:
        return Icons.bookmark_outline_rounded;
      case WatchStatus.watching:
        return Icons.play_circle_outline_rounded;
      case WatchStatus.watched:
        return Icons.check_circle_outline_rounded;
      case WatchStatus.dropped:
        return Icons.cancel_outlined;
      case WatchStatus.rewatch:
        return Icons.replay_rounded;
    }
  }

  static String labelKeyFor(WatchStatus s) {
    switch (s) {
      case WatchStatus.toWatch:
        return 'statusToWatch';
      case WatchStatus.watching:
        return 'statusWatching';
      case WatchStatus.watched:
        return 'statusWatched';
      case WatchStatus.dropped:
        return 'statusDropped';
      case WatchStatus.rewatch:
        return 'statusRewatch';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(status);
    final icon = iconFor(status);

    if (!showLabel) {
      return Container(
        padding: EdgeInsets.all(SizeTokens.paddingMin),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.65),
          borderRadius: SizeTokens.circularRadiusSmall,
        ),
        child: Icon(icon, color: color, size: SizeTokens.textSmall),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.paddingSmall,
        vertical: SizeTokens.paddingMin,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: SizeTokens.circularRadiusLarge,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: SizeTokens.textSmall),
          SizedBox(width: SizeTokens.paddingMin),
          Text(
            Translations.tr(labelKeyFor(status)),
            style: TextStyle(
              color: color,
              fontSize: SizeTokens.textSmall,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class WatchStatusPicker extends StatelessWidget {
  final WatchStatus current;
  final ValueChanged<WatchStatus> onChanged;

  const WatchStatusPicker({
    super.key,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Translations.tr('watchStatus'),
          style: TextStyle(
            fontSize: SizeTokens.textMedium,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: SizeTokens.paddingSmall),
        Wrap(
          spacing: SizeTokens.paddingSmall,
          runSpacing: SizeTokens.paddingSmall,
          children: WatchStatus.values.map((status) {
            final isSelected = current == status;
            final color = WatchStatusBadge.colorFor(status);
            return GestureDetector(
              onTap: () => onChanged(status),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: SizeTokens.paddingSmall,
                  vertical: SizeTokens.paddingMin,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.2)
                      : AppTheme.surfaceLightColor,
                  border: Border.all(
                    color: isSelected ? color : AppTheme.surfaceLightColor,
                    width: isSelected ? 1.5 : 1,
                  ),
                  borderRadius: SizeTokens.circularRadiusLarge,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      WatchStatusBadge.iconFor(status),
                      color: isSelected ? color : AppTheme.textSecondaryColor,
                      size: SizeTokens.iconSmall,
                    ),
                    SizedBox(width: SizeTokens.paddingMin),
                    Text(
                      Translations.tr(WatchStatusBadge.labelKeyFor(status)),
                      style: TextStyle(
                        color: isSelected ? color : AppTheme.textSecondaryColor,
                        fontSize: SizeTokens.textSmall,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
