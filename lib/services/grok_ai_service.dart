
import '../models/discovery_models.dart';
import '../core/utils/logger.dart';

class GrokAiService {
  /// Simulates Grok AI recommendation engine.
  /// In a real scenario, this would call an LLM API.
  Future<List<Map<String, String>>> getRecommendations(SurveyAnswers survey) async {
    Logger.info('Grok AI generating recommendations for survey: ${survey.mood}, ${survey.genre}');
    
    // Artificial delay to simulate AI processing
    await Future.delayed(const Duration(seconds: 2));

    // Logic to select movies based on survey
    // Returning Title and Reason
    if (survey.mood == 'Enerjik' || survey.mood == 'Mutlu') {
      if (survey.genre == 'Aksiyon') {
        return [
          {'title': 'Mad Max: Fury Road', 'reason': 'Yüksek enerjili aksiyonu ve görsel şöleniyle modunuzu daha da yükseltecek.'},
          {'title': 'Top Gun: Maverick', 'reason': 'Adrenalin dolu uçuş sahneleri ve ilham verici hikayesiyle tam size göre.'},
          {'title': 'John Wick', 'reason': 'Akıcı dövüş koreografileri ve hızlı temposuyla enerjinizi taze tutar.'},
        ];
      } else if (survey.genre == 'Komedi') {
        return [
          {'title': 'The Hangover', 'reason': 'Düşmeyen temposu ve kahkaha dolu anlarıyla enerjinize eşlik edecek.'},
          {'title': 'Game Night', 'reason': 'Zekice kurgulanmış mizahı ve heyecanıyla çok keyifli bir seçim.'},
          {'title': 'Superbad', 'reason': 'Samimi arkadaşlık hikayesi ve bitmeyen enerjisiyle gününüzü güzelleştirir.'},
        ];
      }
    }

    if (survey.mood == 'Duygusal' || survey.mood == 'Yorgun') {
      if (survey.genre == 'Dram' || survey.genre == 'Romantik') {
        return [
          {'title': 'The Notebook', 'reason': 'Derin duygusal bağları ve etkileyici hikayesiyle ruhunuzu dinlendirecek.'},
          {'title': 'About Time', 'reason': 'Hayatın küçük anlarının değerini hatırlatan, sıcak ve duygusal bir yapım.'},
          {'title': 'The Pursuit of Happyness', 'reason': 'Zorluklara karşı verilen mücadele ve umut dolu sonuyla size güç verecek.'},
        ];
      }
    }
    
    // Default fallback recommendations based on genre
    return _getFallbackByGenre(survey.genre ?? 'Macera');
  }

  Future<List<Map<String, String>>> getRecommendationsByCategory(String category) async {
    Logger.info('Grok AI generating recommendations for category: $category');
    await Future.delayed(const Duration(milliseconds: 1500));

    switch (category) {
      case 'Aksiyon':
        return [
          {'title': 'Die Hard', 'reason': 'Aksiyon sinemasının köşe taşlarından, her anı heyecan dolu.'},
          {'title': 'Mission: Impossible - Fallout', 'reason': 'Nefes kesen dublör sahneleriyle türünün en iyilerinden.'},
          {'title': 'The Dark Knight', 'reason': 'Sadece bir aksiyon değil, derinliği olan bir başyapıt.'},
        ];
      case 'Bilim Kurgu':
        return [
          {'title': 'Inception', 'reason': 'Zihin büken kurgusu ve eşsiz görselliğiyle bir vizyon sunuyor.'},
          {'title': 'Interstellar', 'reason': 'Zaman, uzay ve insan bağı üzerine epik bir yolculuk.'},
          {'title': 'Blade Runner 2049', 'reason': 'Atmosferik yapısı ve düşündürücü temalarıyla modern bir klasik.'},
        ];
      case 'Gerilim':
        return [
          {'title': 'Se7en', 'reason': 'Karanlık atmosferi ve şaşırtıcı finaliyle gerilimi iliklerinize kadar hissettirir.'},
          {'title': 'Parasite', 'reason': 'Sınıfsal çatışmayı gerilimle harmanlayan, sürprizlerle dolu bir hikaye.'},
          {'title': 'The Silence of the Lambs', 'reason': 'Psikolojik gerilimin doruk noktası, unutulmaz karakterler.'},
        ];
      case 'Komedi':
        return [
          {'title': 'Groundhog Day', 'reason': 'Mükemmel bir zaman döngüsü hikayesi ve harika bir mizah.'},
          {'title': 'Paddington 2', 'reason': 'Saf sevgi ve nezaket dolu, her yaştan izleyiciyi gülümseten bir yapım.'},
          {'title': 'The Nice Guys', 'reason': '70\'lerin atmosferinde geçen, uyumsuz bir ikilinin komik macerası.'},
        ];
      case 'Yüksek Puanlı':
        return [
          {'title': 'The Shawshank Redemption', 'reason': 'Umudun ve dostluğun en güzel anlatıldığı efsanevi film.'},
          {'title': 'The Godfather', 'reason': 'Sinema tarihinin en güçlü anlatılarından biri, mutlak izlenmesi gereken bir eser.'},
          {'title': 'Schindler\'s List', 'reason': 'İnsanlık onuruna dair sarsıcı ve bir o kadar da önemli bir hikaye.'},
        ];
      default:
        return _getFallbackByGenre(category);
    }
  }

  List<Map<String, String>> _getFallbackByGenre(String genre) {
    return [
      {'title': 'The Matrix', 'reason': 'Sinemanın akışını değiştiren, felsefi ve teknik bir devrim.'},
      {'title': 'Forrest Gump', 'reason': 'Hayata ve tarihe masalsı bir bakış sunan, kalbinize dokunacak bir film.'},
      {'title': 'Pulp Fiction', 'reason': 'Tarantino\'nun eşsiz diyalogları ve kurgusuyla bir kült klasik.'},
    ];
  }
}
