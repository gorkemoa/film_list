import 'size_config.dart';
import 'package:flutter/widgets.dart';

class SizeTokens {
  static double get paddingMin => SizeConfig.relativeSize(4);
  static double get paddingSmall => SizeConfig.relativeSize(8);
  static double get paddingMedium => SizeConfig.relativeSize(16);
  static double get paddingLarge => SizeConfig.relativeSize(24);
  static double get paddingXLarge => SizeConfig.relativeSize(32);

  static double get radiusSmall => SizeConfig.relativeSize(8);
  static double get radiusMedium => SizeConfig.relativeSize(16);
  static double get radiusLarge => SizeConfig.relativeSize(24);

  static BorderRadius get circularRadiusSmall =>
      BorderRadius.all(Radius.circular(radiusSmall));
  static BorderRadius get circularRadiusMedium =>
      BorderRadius.all(Radius.circular(radiusMedium));
  static BorderRadius get circularRadiusLarge =>
      BorderRadius.all(Radius.circular(radiusLarge));

  static double get iconSmall => SizeConfig.relativeSize(16);
  static double get iconMedium => SizeConfig.relativeSize(24);
  static double get iconLarge => SizeConfig.relativeSize(32);
  static double get iconXLarge => SizeConfig.relativeSize(48);

  static double get textSmall => SizeConfig.relativeSize(12);
  static double get textMedium => SizeConfig.relativeSize(14);
  static double get textLarge => SizeConfig.relativeSize(18);
  static double get textTitle => SizeConfig.relativeSize(24);

  static double get heightSmall => SizeConfig.relativeSize(32);
  static double get heightMedium => SizeConfig.relativeSize(48);
  static double get heightLarge => SizeConfig.relativeSize(64);
}
