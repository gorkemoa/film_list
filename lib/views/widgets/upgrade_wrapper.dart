import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import '../../app/app_theme.dart';
import '../../core/responsive/size_tokens.dart';

/// Uygulama güncelleme kontrolcüsü.
/// [testMode] = true iken her açılışta güncelleme dialogunu gösterir.
/// Production'a geçişte [testMode] = false yapın ve
/// [debugDisplayAlways] = false olacak şekilde Upgrader'ı konfigüre edin.
class UpgradeWrapper extends StatefulWidget {
  final Widget child;

  const UpgradeWrapper({super.key, required this.child});

  @override
  State<UpgradeWrapper> createState() => _UpgradeWrapperState();
}

class _UpgradeWrapperState extends State<UpgradeWrapper> {
  // ── Test modu ──────────────────────────────────────────────────────────────
  // true: dialog her seferinde gösterilir (geliştirme/test için)
  // false: yalnızca gerçek güncelleme varsa gösterilir
  static const bool _testMode = true;
  // ──────────────────────────────────────────────────────────────────────────

  late final Upgrader _upgrader;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _upgrader = Upgrader(
      debugLogging: _testMode,
      debugDisplayAlways: _testMode,
      durationUntilAlertAgain: Duration.zero,
    );
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    await _upgrader.initialize();
    if (!mounted || _dialogShown) return;

    final bool shouldShow = _testMode || _upgrader.isUpdateAvailable();

    if (shouldShow) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showUpgradeDialog();
      });
    }
  }

  void _showUpgradeDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _UpgradeDialog(
        upgrader: _upgrader,
        testMode: _testMode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ─────────────────────────────────────────────────────────────────────────────
// Güncelleme Dialogu
// ─────────────────────────────────────────────────────────────────────────────

class _UpgradeDialog extends StatelessWidget {
  final Upgrader upgrader;
  final bool testMode;

  const _UpgradeDialog({required this.upgrader, required this.testMode});

  @override
  Widget build(BuildContext context) {
    final String installedVersion =
        upgrader.currentInstalledVersion ?? '1.0.0';
    final String newVersion =
        testMode ? '2.0.0' : (upgrader.currentAppStoreVersion ?? '');

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeTokens.radiusLarge),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeTokens.paddingLarge,
            vertical: SizeTokens.paddingXLarge,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── İkon ─────────────────────────────────────────────────────
              Container(
                padding: EdgeInsets.all(SizeTokens.paddingMedium),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.system_update_rounded,
                  color: AppTheme.primaryColor,
                  size: SizeTokens.iconXLarge,
                ),
              ),
              SizedBox(height: SizeTokens.paddingMedium),

              // ── Başlık ───────────────────────────────────────────────────
              Text(
                'Güncelleme Mevcut',
                style: TextStyle(
                  color: AppTheme.textPrimaryColor,
                  fontSize: SizeTokens.textTitle,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              // ── Versiyon bilgisi ─────────────────────────────────────────
              if (newVersion.isNotEmpty) ...[
                SizedBox(height: SizeTokens.paddingSmall),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeTokens.paddingMedium,
                    vertical: SizeTokens.paddingMin,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLightColor,
                    borderRadius: SizeTokens.circularRadiusSmall,
                  ),
                  child: Text(
                    'v$installedVersion  →  v$newVersion',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: SizeTokens.textMedium,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],

              SizedBox(height: SizeTokens.paddingMedium),

              // ── Açıklama ─────────────────────────────────────────────────
              Text(
                'Uygulamanın yeni bir sürümü yayınlandı.\nDevam edebilmek için lütfen güncelleyin.',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: SizeTokens.textMedium,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: SizeTokens.paddingXLarge),

              // ── Güncelle butonu ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: SizeTokens.heightMedium,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: SizeTokens.circularRadiusMedium,
                    ),
                  ),
                  onPressed: () async {
                    await upgrader.sendUserToAppStore();
                  },
                  child: Text(
                    'Şimdi Güncelle',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeTokens.textLarge,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
