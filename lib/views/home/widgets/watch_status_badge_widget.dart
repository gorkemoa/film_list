import 'package:flutter/material.dart';
import '../../../models/watch_status.dart';
import '../../../app/translations.dart';
import '../../../app/app_theme.dart';

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
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: color, size: 14),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            Translations.tr(labelKeyFor(status)),
            style: TextStyle(
              color: color,
              fontSize: 11,
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: WatchStatus.values.map((status) {
            final isSelected = current == status;
            final color = WatchStatusBadge.colorFor(status);
            return GestureDetector(
              onTap: () => onChanged(status),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.2)
                      : AppTheme.surfaceLightColor,
                  border: Border.all(
                    color: isSelected ? color : AppTheme.surfaceLightColor,
                    width: isSelected ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      WatchStatusBadge.iconFor(status),
                      color: isSelected ? color : AppTheme.textSecondaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      Translations.tr(WatchStatusBadge.labelKeyFor(status)),
                      style: TextStyle(
                        color: isSelected ? color : AppTheme.textSecondaryColor,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
