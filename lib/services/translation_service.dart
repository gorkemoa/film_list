import 'package:translator/translator.dart';
import '../app/translations.dart';
import '../core/utils/logger.dart';

class TranslationService {
  final _translator = GoogleTranslator();

  Future<String> translatePlot(String text) async {
    if (text.isEmpty) return text;

    final Language currentLang = Translations.currentLanguage;

    // If English, return as is (already in English from OMDb usually)
    if (currentLang == Language.en) return text;

    try {
      final targetLang = currentLang.name; // 'tr' or 'es'
      final translation = await _translator.translate(text, to: targetLang);
      Logger.info('Translated plot to $targetLang');
      return translation.text;
    } catch (e, st) {
      Logger.error('Plot translation failed', e, st);
      return text; // Fallback to original
    }
  }
}
