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
    // Watch Status
    'watchStatus:İzleme Durumu:Watch Status:Estado:Statut:Status:Sehstatus',
    'statusToWatch:İzlenecek:To Watch:Para Ver:À regarder:Para Assistir:Noch sehen',
    'statusWatching:İzleniyor:Watching:Viendo:En cours:Assistindo:Gerade sehen',
    'statusWatched:İzlendi:Watched:Visto:Regardé:Assistido:Gesehen',
    'statusDropped:Yarıda Bıraktı:Dropped:Abandonado:Abandonné:Abandonado:Abgebrochen',
    'statusRewatch:Tekrar İzle:Rewatch:Volver a ver:Revoir:Reassistir:Nochmal sehen',
    // Home sections
    'recentlyViewed:Son Bakılanlar:Recently Viewed:Visto Recientemente:Vus récemment:Vistos Recentemente:Zuletzt gesehen',
    'recentlyAdded:Son Eklenenler:Recently Added:Añadidos Recientemente:Ajoutés récemment:Adicionados Recentemente:Zuletzt hinzugefügt',
    'currentlyWatching:Şu An İzleniyor:Currently Watching:Viendo Ahora:En cours:Assistindo Agora:Gerade am Sehen',
    'watchAgainList:Tekrar İzlenecekler:Watch Again:Ver de Nuevo:À revoir:Para Reassistir:Nochmal ansehen',
    'droppedList:Yarıda Bırakılanlar:Dropped:Abandonados:Abandonnés:Abandonados:Abgebrochen',
    // Custom Lists
    'listsTab:Listelerim:My Lists:Mis Listas:Mes Listes:Minhas Listas:Meine Listen',
    'myLists:Listelerim:My Lists:Mis Listas:Mes Listes:Minhas Listas:Meine Listen',
    'createList:Liste Oluştur:Create List:Crear Lista:Créer une liste:Criar Lista:Liste erstellen',
    'listName:Liste Adı:List Name:Nombre de Lista:Nom de la liste:Nome da Lista:Listenname',
    'listNameHint:ör. Hafta sonu izle...:e.g. Weekend watch...:ej. Para ver el finde...:ex. À voir ce week-end...:ex. Para ver no fds...:z.B. Wochenend-Watch...',
    'addToCustomList:Listeye Ekle:Add to List:Añadir a Lista:Ajouter à la liste:Adicionar à Lista:Zur Liste hinzufügen',
    'removeFromList:Listeden Çıkar:Remove from List:Quitar de Lista:Retirer de la liste:Remover da Lista:Aus Liste entfernen',
    'deleteList:Listeyi Sil:Delete List:Eliminar Lista:Supprimer la liste:Excluir Lista:Liste löschen',
    'renameList:Listeyi Düzenle:Rename List:Renombrar Lista:Renommer la liste:Renomear Lista:Liste umbenennen',
    'emptyList:Bu liste boş.:This list is empty.:Esta lista está vacía.:Cette liste est vide.:Esta lista está vazia.:Diese Liste ist leer.',
    'noLists:Henüz liste oluşturulmadı.:No lists created yet.:Aún no se han creado listas.:Aucune liste créée.:Nenhuma lista criada ainda.:Noch keine Listen erstellt.',
    'deleteListConfirm:Bu listeyi silmek istediğinize emin misiniz?:Are you sure you want to delete this list?:¿Seguro que quieres eliminar esta lista?:Êtes-vous sûr de vouloir supprimer cette liste ?:Tem certeza que deseja excluir esta lista?:Sind Sie sicher, dass Sie diese Liste löschen möchten?',
    'suggestedListNames:Önerilen İsimler:Suggested Names:Nombres Sugeridos:Noms suggérés:Nomes Sugeridos:Vorgeschlagene Namen',
    'addMovieToList:Listeye Film Ekle:Add Movie to List:Añadir a lista:Ajouter à la liste:Adicionar à Lista:Zur Liste hinzufügen',
    'manageListMembership:Listeleri Yönet:Manage Lists:Gestionar Listas:Gérer les listes:Gerenciar Listas:Listen verwalten',
    'organizeYourMovies:İzlediğiniz her şeyi düzenli tutun:Organize everything you watch:Organiza todo lo que ves:Organisez tout ce que vous regardez:Organize tudo o que você assiste:Organisieren Sie alles, was Sie sehen',
    'customLists:Özel Listelerim:My Custom Lists:Mis Listas Personalizadas:Mes listes personnalisées:Minhas Listas Personalizadas:Meine benutzerdefinierten Listen',
    'create:Oluştur:Create:Crear:Créer:Criar:Erstellen',
    'noCustomLists:Henüz bir liste oluşturmadınız. Yeni bir liste oluşturarak içeriklerinizi kategorize etmeye başlayın.:You haven\'t created any lists yet. Start categorizing your content by creating a new list.:Aún no has creado ninguna lista. Empieza a categorizar tu contenido creando una nueva lista.:Vous n\'avez pas encore créé de liste. Commencez à catégoriser votre contenu en créant une nouvelle liste.:Você ainda não criou nenhuma lista. Comece a categorizar seu conteúdo criando uma nova lista.:Sie haben noch keine Listen erstellt. Beginnen Sie mit der Kategorisierung Ihrer Inhalte, indem Sie eine neue Liste erstellen.',
    'items:İçerik:Items:Ítems:Éléments:Itens:Elemente',
    'open:Aç:Open:Abrir:Ouvrir:Abrir:Öffnen',
    'discoveryTab:Keşfet:Discovery:Descubrir:Découverte:Descoberta:Entdecken',
    'smartDiscovery:Akıllı Keşif:Smart Discovery:Descubrimiento Inteligente:Découverte intelligente:Descoberta Inteligente:Intelligentes Entdecken',
    'whatToWatchToday:Bugün Ne İzlesem?:What to watch today?:¿Qué ver hoy?:Que regarder aujourd\'hui ?:O que assistir hoje?:Was heute schauen?',
    'quickMovie:Hızlı Film:Quick Movie:Película Rápida:Film rapide:Filme Rápido:Schneller Film',
    'highlyRatedShort:Yüksek Puanlı ama Kısa:High Rated & Short:Altas Calificaciones y Cortas:Bien noté et court:Bem avaliado e curto:Gut bewertet & kurz',
    'discoverByMood:Ruh Haline Göre:Discover by Mood:Descubrir por Estado:Découvrir par humeur:Descobrir por Humor:Nach Stimmung entdecken',
    'funMood:Eğlenceli:Fun:Divertido:Amusant:Divertido:Spaßig',
    'darkMood:Karanlık:Dark:Oscuro:Sombre:Sombrio:Dunkel',
    'mindBending:Beyin Yakan:Mind-bending:Intrigante:Cerebral:Intrigante:Gedankenspiel',
    'familyMood:Ailelik:Family:Para la Familia:Pour la famille:Para a família:Für die Familie',
    'soloMood:Tek Başıma:Solo:Para Ver Solo:Pour regarder seul:Para Assistir Sozinho:Alleine schauen',
    'shortMood:Kısa Bir Şey:Something Short:Algo Corto:Quelque chose de court:Algo Curto:Etwas Kurzes',
    'lightMood:Hafif Bir Şey:Something Light:Algo Ligero:Quelque chose de léger:Algo Leve:Etwas Leichtes',
    'collectionStats:Koleksiyon İstatistikleri:Collection Stats:Estadísticas de Colección:Stats de collection:Estatísticas da Coleção:Sammlungsstatistiken',
    'mostRatedGenre:En Çok Puan Verilen Tür:Most Rated Genre:Género Mejor Valorado:Genre le mieux noté:Gênero mais avaliado:Bestbewertetes Genre',
    'favoritesPost2020:2020 Sonrası Favoriler:Post-2020 Favorites:Favoritos Post-2020:Favoris après 2020:Favoritos pós-2020:Favoriten nach 2020',
    'watchedDirectors:İzimdeki Yönetmenler:Watched Directors:Directores Vistos:Réalisateurs vus:Diretores Assistidos:Gesehene Regisseure',
    'mostSavedActors:En Çok Kaydedilen Oyuncular:Most Saved Actors:Actores más Guardados:Acteurs les plus enregistrés:Atores mais salvos:Am häufigsten gespeicherte Schauspieler',
    'watchedThisMonth:Bu Ay İzlediklerim:Watched This Month:Visto este Mes:Vu ce mois-ci:Assistidos este Mês:Diesen Monat gesehen',
    'personalDashboard:Kişisel Dashboard:Personal Dashboard:Panel Personal:Tableau de bord personnel:Painel Pessoal:Persönliches Dashboard',
    'filterGenre:Tür:Genre:Género:Genre:Gênero:Genre',
    'filterYear:Yıl:Year:Año:Année:Ano:Jahr',
    'filterRating:Puan:Rating:Calificación:Note:Avaliação:Bewertung',
    'filterDuration:Süre:Duration:Duración:Durée:Duração:Dauer',
    'filterLanguage:Dil:Language:Idioma:Langue:Idioma:Sprache',
    'filterCountry:Ülke:Country:País:Pays:País:Land',
    'min:dk:min:min:min:min:min',
    'actors:Oyuncular:Actors:Actores:Acteurs:Atores:Schauspieler',
    'director:Yönetmen:Director:Director:Réalisateur:Diretor:Regisseur',
    'statsTab:İstatistik:Stats:Estadísticas:Stats:Estatísticas:Statistiken',
    // Discovery screen
    'discoverySubtitle:Sana uygun film önerileri:Personalized movie suggestions:Sugerencias de películas para ti:Suggestions de films pour vous:Sugestões de filmes para você:Personalisierte Filmvorschläge',
    'quizTab:Anket:Quiz:Cuestionario:Quiz:Questionário:Quiz',
    'categoriesTab:Kategoriler:Categories:Categorías:Catégories:Categorias:Kategorien',
    'quizMood:Ruh Halin:Mood:Estado de ánimo:Humeur:Humor:Stimmung',
    'quizDuration:Süre Tercihi:Duration:Duración:Durée:Duração:Dauer',
    'quizDurationShort:Kısa (< 100dk):Short (< 100min):Corto (< 100min):Court (< 100min):Curto (< 100min):Kurz (< 100min)',
    'quizDurationMedium:Orta (100-150dk):Medium (100-150min):Medio (100-150min):Moyen (100-150min):Médio (100-150min):Mittel (100-150min)',
    'quizDurationAny:Fark Etmez:Any:Cualquiera:N\'importe:Qualquer:Egal',
    'quizContext:Kimle İzleyeceksin?:Viewing Context:Contexto de visionado:Contexte de visionnage:Contexto de visualização:Betrachtungskontext',
    'quizFriends:Arkadaşlarla:With Friends:Con amigos:Avec des amis:Com amigos:Mit Freunden',
    'quizEra:Dönem:Era:Época:Époque:Época:Ära',
    'quizEraNew:Yeni (2010+):New (2010+):Nuevo (2010+):Nouveau (2010+):Novo (2010+):Neu (2010+)',
    'quizEraClassic:Klasik (< 2010):Classic (< 2010):Clásico (< 2010):Classique (< 2010):Clássico (< 2010):Klassisch (< 2010)',
    'recommendMe:Bana Öner:Recommend to Me:Recomiéndame:Recommandez-moi:Recomende-me:Empfiehl mir',
    'tryAgain:Tekrar Dene:Try Again:Intentar de nuevo:Réessayer:Tentar novamente:Erneut versuchen',
    'pickACategory:Bir kategori seç:Pick a category:Elige una categoría:Choisissez une catégorie:Escolha uma categoria:Wählen Sie eine Kategorie',
    'categoryShortRuntime:Kısa İzlenir:Short Watch:Tiempo corto:Court métrage:Tempo curto:Kurz',
    'categoryHighRated:Yüksek Puanlı:Highly Rated:Muy valoradas:Très bien noté:Muito bem avaliado:Hoch bewertet',
    'discoverySearching:Filmler aranıyor...:Searching movies...:Buscando películas...:Recherche de films...:Buscando filmes...:Filme werden gesucht...',
    'discoveryNoResults:Uygun film bulunamadı. Lütfen tekrar dene.:No matching movies found. Please try again.:No se encontraron películas. Inténtalo de nuevo.:Aucun film trouvé. Veuillez réessayer.:Nenhum filme encontrado. Tente novamente.:Keine passenden Filme gefunden. Bitte versuche es erneut.',
    'discoveryResultsFound:öneri bulundu:suggestions found:sugerencias encontradas:suggestions trouvées:sugestões encontradas:Vorschläge gefunden',
    'errorOccurred:Bir hata oluştu.:An error occurred.:Ocurrió un error.:Une erreur est survenue.:Ocorreu um erro.:Ein Fehler ist aufgetreten.',
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
