import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/app_constants.dart';
import '../core/utils/logger.dart';

enum Language { tr, en, es }

class Translations {
  static Language _currentLanguage = Language.en;

  /// True when the user has explicitly chosen a language inside the app.
  /// When false, device locale detection (via [applyDeviceLocale]) will apply.
  static bool _userExplicitlySet = false;

  static Language get currentLanguage => _currentLanguage;

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(AppConstants.prefsLanguageKey);

      if (savedCode != null) {
        // User has an explicit saved preference — honour it.
        _userExplicitlySet = true;
        if (savedCode == 'tr') {
          _currentLanguage = Language.tr;
        } else if (savedCode == 'es') {
          _currentLanguage = Language.es;
        } else {
          _currentLanguage = Language.en;
        }
        Logger.info('Saved language loaded: ${_currentLanguage.name}');
      } else {
        // No saved preference — applyDeviceLocale() will run later via
        // MaterialApp.localeResolutionCallback for reliable detection.
        _userExplicitlySet = false;
        Logger.info('No saved language preference; waiting for device locale.');
      }
    } catch (e, st) {
      Logger.error('Error initializing language', e, st);
    }
  }

  /// Called from [MaterialApp.localeResolutionCallback] where Flutter has
  /// definitely resolved the device locale.  Only applied when the user has
  /// NOT explicitly chosen a language inside the app.
  static void applyDeviceLocale(Locale? deviceLocale) {
    if (_userExplicitlySet) return;
    if (deviceLocale == null) {
      _currentLanguage = Language.en;
      Logger.info('Device locale null → defaulting to en');
      return;
    }
    final code = deviceLocale.languageCode.toLowerCase();
    if (code == 'tr') {
      _currentLanguage = Language.tr;
    } else if (code == 'es') {
      _currentLanguage = Language.es;
    } else {
      // All other languages (fr, de, etc.) → English (default).
      _currentLanguage = Language.en;
    }
    Logger.info('Device locale: $code → ${_currentLanguage.name}');
  }

  static Future<void> changeLanguage(Language lang) async {
    _currentLanguage = lang;
    _userExplicitlySet = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefsLanguageKey, lang.name);
    Logger.info('Language changed to: ${lang.name}');
  }

  static Future<Language> getPreferredLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(AppConstants.prefsLanguageKey);
    if (langCode == 'tr') return Language.tr;
    if (langCode == 'es') return Language.es;
    return Language.en;
  }

  // Format => key:TR:EN:ES
  static const List<String> _dictionary = [
    'settings:Ayarlar:Settings:Ajustes',
    'language:Dil:Language:Idioma',
    'clearData:Verileri Temizle:Clear Data:Borrar Datos',
    'rateApp:Uygulamayı Puanla:Rate the App:Calificar la App',
    'clearDataConfirm:Tüm veriler silinecek. Emin misiniz?:All data will be deleted. Are you sure?:¿Se eliminarán todos los datos. ¿Estás seguro?',
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
    'searchTitle:Dizi Film Ara:Search Movies & TV:Buscar Películas y Series',
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
    'details:Detaylar:Details:Detalles',
    'suggested:Öneri:Suggested:Sugerido',
    'addToList:Listeme Ekle:Add to List:Añadir a lista',
    'action:Aksiyon:Action:Acción',
    'adventure:Macera:Adventure:Aventura',
    'animation:Animasyon:Animation:Animación',
    'biography:Biyografi:Biography:Biografía',
    'comedy:Komedi:Comedy:Comedia',
    'crime:Suç:Crime:Crimen',
    'documentary:Belgesel:Documentary:Documental',
    'drama:Dram:Drama:Drama',
    'family:Aile:Family:Familia',
    'fantasy:Fantastik:Fantasy:Fantasía',
    'history:Tarih:History:Historia',
    'horror:Korku:Horror:Terror',
    'music:Müzik:Music:Música',
    'mystery:Gizem:Mystery:Misterio',
    'romance:Romantik:Romance:Romance',
    'sciFi:Bilim Kurgu:Sci-Fi:Ciencia Ficción',
    'sport:Spor:Sport:Deportes',
    'thriller:Gerilim:Thriller:Suspense',
    'war:Savaş:War:Guerra',
    'western:Batı:Western:Western',
    'plotDescription:Film Özeti:Movie Plot:Sinopsis',
    'movieInfoTab:Film/Dizi Bilgisi:Movie/TV Info:Información',
    'directorLabel:Yönetmen:Director:Director',
    'writerLabel:Yazar:Writer:Escritor',
    'actorsLabel:Oyuncular:Actors:Actores',
    'languageLabel:Dil:Language:Idioma',
    'countryLabel:Ülke:Country:País',
    'boxOfficeLabel:Gişe:Box Office:Recaudación',
    'ratedLabel:Sınıflandırma:Rated:Clasificación',
    'releasedLabel:Vizyon:Released:Estrenado',
    'commentLabel:Yorumunuz (Opsiyonel):Your Comment (Optional):Tu Comentario (Opcional)',
    'deleteReview:Değerlendirmeyi Sil:Delete Review:Eliminar Valoración',
    'editReview:Değerlendirmeyi Düzenle:Edit Review:Editar Valoración',
    'deleteReviewConfirm:Bu değerlendirmeyi silmek istediğinize emin misiniz?:Are you sure you want to delete this review?:¿Estás seguro de que quieres eliminar esta valoración?',
    'edit:Düzenle:Edit:Editar',
    'ratingHigher:Bu yapıma IMDb\'den {diff} puan daha yüksek verdiniz!:You rated this {diff} points HIGHER than IMDb!:¡Puntuaste esto {diff} puntos MÁS que en IMDb!',
    'ratingLower:Bu yapıma IMDb\'den {diff} puan daha düşük verdiniz.:You rated this {diff} points LOWER than IMDb.:Puntuaste esto {diff} puntos MENOS que en IMDb.',
    'ratingMatch:Puanınız IMDb ile tam olarak eşleşiyor!:Your rating matches IMDb exactly!:¡Tu puntuación coincide exactamente con IMDb!',
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
