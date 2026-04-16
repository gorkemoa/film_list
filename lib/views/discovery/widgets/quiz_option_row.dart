import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_config.dart';
import '../../../core/responsive/size_tokens.dart';

/// A single selectable chip used in quiz / option rows.
class SelectableChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const SelectableChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.paddingMedium,
          vertical: SizeTokens.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(SizeConfig.relativeSize(20)),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.surfaceLightColor,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: SizeTokens.iconSmall,
                color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
              ),
              SizedBox(width: SizeConfig.relativeSize(6)),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: SizeTokens.textSmall,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                color:
                    isSelected ? Colors.white : AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────
/// Represents a single option in a quiz row.
class QuizOption {
  final String label;
  final String value;
  final IconData? icon;

  const QuizOption(this.label, this.value, [this.icon]);
}

/// Factory helper — converts a list of (label, value, icon?) records to QuizOptions.
List<QuizOption> buildQuizOptions(
  List<(String, String, IconData?)> data,
) {
  return data.map((e) => QuizOption(e.$1, e.$2, e.$3)).toList();
}

// ── Compound widget ───────────────────────────────────────────────────────────
/// A labelled row containing a horizontal scroll of [SelectableChip]s.
class QuizOptionRow extends StatelessWidget {
  final String label;
  final List<QuizOption> options;
  final String? selectedValue;
  final void Function(String value) onSelected;

  const QuizOptionRow({
    super.key,
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: SizeTokens.textSmall,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondaryColor,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: SizeConfig.relativeSize(8)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options
                .map(
                  (opt) => Padding(
                    padding: EdgeInsets.only(right: SizeConfig.relativeSize(8)),
                    child: SelectableChip(
                      label: opt.label,
                      isSelected: selectedValue == opt.value,
                      onTap: () => onSelected(opt.value),
                      icon: opt.icon,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        SizedBox(height: SizeTokens.paddingMedium),
      ],
    );
  }
}
