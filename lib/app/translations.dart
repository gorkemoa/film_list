import 'package:shared_preferences/shared_preferences.dart';
import '../app/app_constants.dart';
import '../core/utils/logger.dart';

enum Language { tr, en, es }

class Translations {
  static Language _currentLanguage = Language.en;

  static Language get currentLanguage => _currentLanguage;

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final langCode = prefs.getString(AppConstants.prefsLanguageKey);
      if (langCode != null) {
        if (langCode == 'tr') {
          _currentLanguage = Language.tr;
        } else if (langCode == 'es') {
          _currentLanguage = Language.es;
        } else {
          _currentLanguage = Language.en;
        }
      } else {
        _currentLanguage = Language.en;
      }
      Logger.info('Language initialized: ${_currentLanguage.name}');
    } catch (e, st) {
      Logger.error('Error initializing language', e, st);
    }
  }

  static Future<void> changeLanguage(Language lang) async {
    _currentLanguage = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefsLanguageKey, lang.name);
    Logger.info('Language changed to: ${lang.name}');
  }

  // Format => key:TR:EN:ES
  static const List<String> _dictionary = [
    'appName:Çevrimdışı Film Listesi:Offline Film List:Lista de Películas Offline',
    'movies:Filmler:Movies:Películas',
    'settings:Ayarlar:Settings:Ajustes',
    'addMovie:İçerik Ekle:Add Content:Añadir Contenido',
    'title:Başlık:Title:Título',
    'type:Tür:Type:Tipo',
    'movie:Film:Movie:Película',
    'tv_show:Dizi:TV Show:Serie de TV',
    'year:Yıl:Year:Año',
    'genre:Kategori:Genre:Género',
    'poster:Afiş (URL):Poster (URL):Póster (URL)',
    'save:Kaydet:Save:Guardar',
    'cancel:İptal:Cancel:Cancelar',
    'isWatched:İzlendi mi?:Is Watched?:¿Visto?',
    'watched:İzlendi:Watched:Visto',
    'notWatched:İzlenmedi:Not Watched:No visto',
    'watchCount:İzlenme Sayısı:Watch Count:Veces Visto',
    'watchOneMoreTime:Tekrar İzledim (+1):Watched Again (+1):Visto de nuevo (+1)',
    'yes:Evet:Yes:Sí',
    'no:Hayır:No:No',
    'rateMovie:Değerlendir:Rate:Valorar',
    'storyRating:Hikaye:Story:Historia',
    'musicRating:Müzik:Music:Música',
    'actingRating:Oyunculuk:Acting:Actuación',
    'cinematographyRating:Sinematografi:Cinematography:Cinematografía',
    'recommend:Başkalarına önerir misin?:Would you recommend to others?:¿Recomendarías a otros?',
    'watchAgain:Tekrar izler misin?:Would you watch again?:¿Volverías a ver?',
    'submitReview:Puanı Kaydet:Submit Review:Enviar Valoración',
    'overallRating:Genel Puan:Overall Rating:Valoración General',
    'reviews:Değerlendirmeler:Reviews:Valoraciones',
    'delete:Sil:Delete:Eliminar',
    'emptyMovies:Henüz içerik eklenmedi.:No content added yet.:Aún no se ha añadido contenido.',
    'emptyReviews:Henüz değerlendirme yok.:No reviews yet.:Aún no hay valoraciones.',
    'requiredField:Bu alan zorunludur:This field is required:Este campo es obligatorio',
    'search:Cevrimiçi Ara:Search Online:Buscar',
    'searchPlaceholder:Film veya dizi adı...:Movie or TV show name...:Nombre...',
    'searching:Aranıyor...:Searching...:Buscando...',
    'noResults:Sonuç bulunamadı.:No results found.:No se encontraron resultados.',
    'featured:Öne Çıkanlar:Featured:Destacado',
    'recommended:Önerilen Dizi ve Filmler:Recommended Series & Movies:Series y Películas Recomendadas',
    'myList:Listem:My List:Mi Lista',
    'homeTab:Anasayfa:Home:Inicio',
    'addTab:Ekle:Add:Añadir',
    'addManually:Manuel Ekle:Add Manually:Añadir Manualmente',
    'customAddTitle:Özel İçerik Ekle:Add Custom Content:Añadir Contenido Personalizado',
    'saveCustom:Kaydet:Save:Guardar',
    'watchedTab:İzlediklerim:Watched:Visto',
    'toWatchTab:İzleyeceklerim:To Watch:Para Ver',
    'profileTab:Profilim:Profile:Perfil',
    'profileDesc:Profil detayları (Yakında):Profile details (Soon):Detalles del perfil (Pronto)',
  ];

  static String tr(String key) {
    for (final line in _dictionary) {
      final parts = line.split(':');
      if (parts.isNotEmpty && parts[0] == key) {
        if (_currentLanguage == Language.tr && parts.length > 1) {
          return parts[1];
        }
        if (_currentLanguage == Language.en && parts.length > 2) {
          return parts[2];
        }
        if (_currentLanguage == Language.es && parts.length > 3) {
          return parts[3];
        }
        return parts.length > 2 ? parts[2] : key;
      }
    }
    return key;
  }
}
