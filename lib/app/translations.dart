import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/app_constants.dart';
import '../core/utils/logger.dart';

enum Language { tr, en, es, fr, pt, de }

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
        } else if (savedCode == 'fr') {
          _currentLanguage = Language.fr;
        } else if (savedCode == 'pt') {
          _currentLanguage = Language.pt;
        } else if (savedCode == 'de') {
          _currentLanguage = Language.de;
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
    } else if (code == 'fr') {
      _currentLanguage = Language.fr;
    } else if (code == 'pt') {
      _currentLanguage = Language.pt;
    } else if (code == 'de') {
      _currentLanguage = Language.de;
    } else {
      // All other languages → English (default).
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
    if (langCode == 'fr') return Language.fr;
    if (langCode == 'pt') return Language.pt;
    if (langCode == 'de') return Language.de;
    return Language.en;
  }

  // Format => key:TR:EN:ES:FR:PT:DE
  static const List<String> _dictionary = [
    'settings:Ayarlar:Settings:Ajustes:Paramètres:Configurações:Einstellungen',
    'language:Dil:Language:Idioma:Langue:Idioma:Sprache',
    'clearData:Verileri Temizle:Clear Data:Borrar Datos:Effacer les données:Limpar Dados:Daten löschen',
    'rateApp:Uygulamayı Puanla:Rate the App:Calificar la App:Évaluer l\'app:Avaliar o App:App bewerten',
    'clearDataConfirm:Tüm veriler silinecek. Emin misiniz?:All data will be deleted. Are you sure?:¿Se eliminarán todos los datos. ¿Estás seguro?:Toutes les données seront supprimées. Êtes-vous sûr ?:Todos os dados serão apagados. Tem certeza?:Alle Daten werden gelöscht. Sind Sie sicher?',
    'addMovie:İçerik Ekle:Add Content:Añadir Contenido:Ajouter du contenu:Adicionar Conteúdo:Inhalt hinzufügen',
    'title:Başlık:Title:Título:Titre:Título:Titel',
    'type:Tür:Type:Tipo:Type:Tipo:Typ',
    'movie:Film:Movie:Película:Film:Filme:Film',
    'tv_show:Dizi:TV Show:Serie de TV:Série TV:Série de TV:TV-Serie',
    'year:Yıl:Year:Año:Année:Ano:Jahr',
    'genre:Kategori:Genre:Género:Genre:Gênero:Genre',
    'poster:Afiş (URL):Poster (URL):Póster (URL):Affiche (URL):Pôster (URL):Poster (URL)',
    'save:Kaydet:Save:Guardar:Enregistrer:Salvar:Speichern',
    'cancel:İptal:Cancel:Cancelar:Annuler:Cancelar:Abbrechen',
    'isWatched:İzlendi mi?:Is Watched?:¿Visto?:Est regardé ?:Assistido?:Gesehen?',
    'watched:İzlendi:Watched:Visto:Regardé:Assistido:Gesehen',
    'notWatched:İzlenmedi:Not Watched:No visto:Non regardé:Não assistido:Nicht gesehen',
    'watchCount:İzlenme Sayısı:Watch Count:Veces Visto:Nombre de vues:Vezes Assistido:Anzahl gesehen',
    'watchOneMoreTime:Tekrar İzledim (+1):Watched Again (+1):Visto de nuevo (+1):Revu (+1):Assistido novamente (+1):Nochmal gesehen (+1)',
    'yes:Evet:Yes:Sí:Oui:Sim:Ja',
    'no:Hayır:No:No:Non:Não:Nein',
    'rateMovie:Değerlendir:Rate:Valorar:Évaluer:Avaliar:Bewerten',
    'storyRating:Hikaye:Story:Historia:Histoire:História:Geschichte',
    'musicRating:Müzik:Music:Música:Musique:Música:Musik',
    'actingRating:Oyunculuk:Acting:Actuación:Jeu d\'acteur:Atuação:Schauspiel',
    'cinematographyRating:Sinematografi:Cinematography:Cinematografía:Cinématographie:Cinematografia:Kameraführung',
    'recommend:Başkalarına önerir misin?:Would you recommend to others?:¿Recomendarías a otros?:Le recommanderiez-vous ?:Você recomendaria a outros?:Würden Sie es weiterempfehlen?',
    'watchAgain:Tekrar izler misin?:Would you watch again?:¿Volverías a ver?:Regarderiez-vous à nouveau ?:Você assistiria novamente?:Würden Sie es nochmal sehen?',
    'submitReview:Puanı Kaydet:Submit Review:Enviar Valoración:Soumettre l\'avis:Enviar Avaliação:Bewertung speichern',
    'overallRating:Genel Puan:Overall Rating:Valoración General:Note globale:Avaliação Geral:Gesamtbewertung',
    'reviews:Değerlendirmeler:Reviews:Valoraciones:Avis:Avaliações:Bewertungen',
    'delete:Sil:Delete:Eliminar:Supprimer:Excluir:Löschen',
    'emptyMovies:Henüz içerik eklenmedi.:No content added yet.:Aún no se ha añadido contenido.:Aucun contenu ajouté.:Nenhum conteúdo adicionado.:Noch kein Inhalt hinzugefügt.',
    'emptyReviews:Henüz değerlendirme yok.:No reviews yet.:Aún no hay valoraciones.:Aucun avis pour l\'instant.:Nenhuma avaliação ainda.:Noch keine Bewertungen.',
    'requiredField:Bu alan zorunludur:This field is required:Este campo es obligatorio:Ce champ est obligatoire:Este campo é obrigatório:Dieses Feld ist erforderlich',
    'search:Cevrimiçi Ara:Search Online:Buscar:Rechercher en ligne:Pesquisar Online:Online suchen',
    'searchPlaceholder:Film veya dizi adı...:Movie or TV show name...:Nombre...:Nom du film ou série...:Nome do filme ou série...:Film- oder Serienname...',
    'searchTitle:Dizi Film Ara:Search Movies & TV:Buscar Películas y Series:Rechercher films et séries:Pesquisar Filmes e Séries:Filme & Serien suchen',
    'searching:Aranıyor...:Searching...:Buscando...:Recherche en cours...:Pesquisando...:Suche läuft...',
    'noResults:Sonuç bulunamadı.:No results found.:No se encontraron resultados.:Aucun résultat trouvé.:Nenhum resultado encontrado.:Keine Ergebnisse gefunden.',
    'featured:Öne Çıkanlar:Featured:Destacado:À la une:Destaque:Hervorgehoben',
    'recommended:Önerilen Dizi ve Filmler:Recommended Series & Movies:Series y Películas Recomendadas:Séries et films recommandés:Séries e Filmes Recomendados:Empfohlene Serien & Filme',
    'myList:Listem:My List:Mi Lista:Ma liste:Minha Lista:Meine Liste',
    'homeTab:Anasayfa:Home:Inicio:Accueil:Início:Startseite',
    'addTab:Ekle:Add:Añadir:Ajouter:Adicionar:Hinzufügen',
    'addManually:Manuel Ekle:Add Manually:Añadir Manualmente:Ajouter manuellement:Adicionar Manualmente:Manuell hinzufügen',
    'customAddTitle:Özel İçerik Ekle:Add Custom Content:Añadir Contenido Personalizado:Ajouter contenu personnalisé:Adicionar Conteúdo Personalizado:Eigenen Inhalt hinzufügen',
    'saveCustom:Kaydet:Save:Guardar:Enregistrer:Salvar:Speichern',
    'watchedTab:İzlediklerim:Watched:Visto:Regardés:Assistidos:Gesehen',
    'toWatchTab:İzleyeceklerim:To Watch:Para Ver:À regarder:Para Assistir:Noch zu sehen',
    'profileTab:Profilim:Profile:Perfil:Profil:Perfil:Profil',
    'profileDesc:Profil detayları (Yakında):Profile details (Soon):Detalles del perfil (Pronto):Détails du profil (Bientôt):Detalhes do perfil (Em breve):Profildetails (Demnächst)',
    'details:Detaylar:Details:Detalles:Détails:Detalhes:Details',
    'suggested:Öneri:Suggested:Sugerido:Suggestion:Sugerido:Empfehlung',
    'addToList:Listeme Ekle:Add to List:Añadir a lista:Ajouter à la liste:Adicionar à lista:Zur Liste hinzufügen',
    'action:Aksiyon:Action:Acción:Action:Ação:Action',
    'adventure:Macera:Adventure:Aventura:Aventure:Aventura:Abenteuer',
    'animation:Animasyon:Animation:Animación:Animation:Animação:Animation',
    'biography:Biyografi:Biography:Biografía:Biographie:Biografia:Biografie',
    'comedy:Komedi:Comedy:Comedia:Comédie:Comédia:Komödie',
    'crime:Suç:Crime:Crimen:Crime:Crime:Kriminalität',
    'documentary:Belgesel:Documentary:Documental:Documentaire:Documentário:Dokumentation',
    'drama:Dram:Drama:Drama:Drame:Drama:Drama',
    'family:Aile:Family:Familia:Famille:Família:Familie',
    'fantasy:Fantastik:Fantasy:Fantasía:Fantastique:Fantasia:Fantasy',
    'history:Tarih:History:Historia:Histoire:História:Geschichte',
    'horror:Korku:Horror:Terror:Horreur:Terror:Horror',
    'music:Müzik:Music:Música:Musique:Música:Musik',
    'mystery:Gizem:Mystery:Misterio:Mystère:Mistério:Mysterium',
    'romance:Romantik:Romance:Romance:Romance:Romance:Romantik',
    'sciFi:Bilim Kurgu:Sci-Fi:Ciencia Ficción:Science-Fiction:Ficção Científica:Science-Fiction',
    'sport:Spor:Sport:Deportes:Sport:Esporte:Sport',
    'thriller:Gerilim:Thriller:Suspense:Thriller:Suspense:Thriller',
    'war:Savaş:War:Guerra:Guerre:Guerra:Krieg',
    'western:Batı:Western:Western:Western:Faroeste:Western',
    'plotDescription:Film Özeti:Movie Plot:Sinopsis:Synopsis du film:Sinopse do Filme:Filmhandlung',
    'movieInfoTab:Film/Dizi Bilgisi:Movie/TV Info:Información:Info Film/Série:Info Filme/Série:Film/Serien-Info',
    'directorLabel:Yönetmen:Director:Director:Réalisateur:Diretor:Regisseur',
    'writerLabel:Yazar:Writer:Escritor:Scénariste:Roteirista:Drehbuchautor',
    'actorsLabel:Oyuncular:Actors:Actores:Acteurs:Atores:Schauspieler',
    'languageLabel:Dil:Language:Idioma:Langue:Idioma:Sprache',
    'countryLabel:Ülke:Country:País:Pays:País:Land',
    'boxOfficeLabel:Gişe:Box Office:Recaudación:Box-office:Bilheteria:Einspielergebnis',
    'ratedLabel:Sınıflandırma:Rated:Clasificación:Classification:Classificação:Einstufung',
    'releasedLabel:Vizyon:Released:Estrenado:Sortie:Estreia:Erschienen',
    'commentLabel:Yorumunuz (Opsiyonel):Your Comment (Optional):Tu Comentario (Opcional):Votre commentaire (Optionnel):Seu Comentário (Opcional):Ihr Kommentar (Optional)',
    'deleteReview:Değerlendirmeyi Sil:Delete Review:Eliminar Valoración:Supprimer l\'avis:Excluir Avaliação:Bewertung löschen',
    'editReview:Değerlendirmeyi Düzenle:Edit Review:Editar Valoración:Modifier l\'avis:Editar Avaliação:Bewertung bearbeiten',
    'deleteReviewConfirm:Bu değerlendirmeyi silmek istediğinize emin misiniz?:Are you sure you want to delete this review?:¿Estás seguro de que quieres eliminar esta valoración?:Êtes-vous sûr de vouloir supprimer cet avis ?:Tem certeza que deseja excluir esta avaliação?:Sind Sie sicher, dass Sie diese Bewertung löschen möchten?',
    'edit:Düzenle:Edit:Editar:Modifier:Editar:Bearbeiten',
    'ratingHigher:Bu yapıma IMDb\'den {diff} puan daha yüksek verdiniz!:You rated this {diff} points HIGHER than IMDb!:¡Puntuaste esto {diff} puntos MÁS que en IMDb!:Vous avez noté ceci {diff} points PLUS qu\'IMDb !:Você avaliou isso {diff} pontos ACIMA do IMDb!:Sie haben das {diff} Punkte HÖHER als IMDb bewertet!',
    'ratingLower:Bu yapıma IMDb\'den {diff} puan daha düşük verdiniz.:You rated this {diff} points LOWER than IMDb.:Puntuaste esto {diff} puntos MENOS que en IMDb.:Vous avez noté ceci {diff} points MOINS qu\'IMDb.:Você avaliou isso {diff} pontos ABAIXO do IMDb.:Sie haben das {diff} Punkte NIEDRIGER als IMDb bewertet.',
    'ratingMatch:Puanınız IMDb ile tam olarak eşleşiyor!:Your rating matches IMDb exactly!:¡Tu puntuación coincide exactamente con IMDb!:Votre note correspond exactement à IMDb !:Sua avaliação corresponde exatamente ao IMDb!:Ihre Bewertung stimmt genau mit IMDb überein!',
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
        if (_currentLanguage == Language.fr && parts.length > 4) {
          return parts[4];
        }
        if (_currentLanguage == Language.pt && parts.length > 5) {
          return parts[5];
        }
        if (_currentLanguage == Language.de && parts.length > 6) {
          return parts[6];
        }
        return parts.length > 2 ? parts[2] : key;
      }
    }
    return key;
  }
}
