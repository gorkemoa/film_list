PROJE: Offline Film / Dizi Liste ve Değerlendirme Mobil Uygulaması

AMAÇ
Kullanıcıların izlediği film ve dizileri listeleyebildiği, izledikten sonra çok kriterli puanlama yapabildiği tamamen OFFLINE çalışan bir Flutter uygulaması geliştir.

Uygulama backend kullanmaz.
Tüm veriler cihaz içinde saklanır.

KULLANILACAK TEKNOLOJİLER

Flutter
MVVM mimarisi
Local database (Isar veya Hive)
Responsive token sistemi

---

DEĞİŞTİRİLEMEZ KURALLAR

1. Offline veri sistemi

Uygulama tamamen offline çalışacaktır.

Tüm veriler Local DB’de saklanacaktır.

View içinde hardcoded veri kullanmak YASAK.

Örnek YASAK:

Text("Interstellar")
Text("Breaking Bad")

Veri akışı:

Service → Model → ViewModel → View

---

2. Kurumsal disiplin

AI aşağıdakileri yapamaz:

• Yeni feature ekleyemez
• Model dışı field üretemez
• Mimari değiştiremez
• View içinde veri üretemez

Emin değilse sormak zorundadır.

---

ZORUNLU MİMARİ

Models → Views → ViewModels → Services → Core

Aşağıdaki mimariler yasaktır:

Clean Architecture
Redux
Bloc-first
MVC

---

KLASÖR YAPISI

lib/

app/
app_constants.dart
app_theme.dart

core/

database/
local_db.dart
db_tables.dart

responsive/
size_config.dart
size_tokens.dart

utils/
logger.dart
validators.dart

models/

movie.dart
review.dart

services/

movie_service.dart
review_service.dart

viewmodels/

home_view_model.dart
add_movie_view_model.dart
movie_detail_view_model.dart

views/

home/
home_view.dart
widgets/

add_movie/
add_movie_view.dart
widgets/

movie_detail/
movie_detail_view.dart
widgets/

---

GLOBAL WIDGET KLASÖRÜ YASAK

Aşağıdaki klasörler kullanılamaz:

core/widgets
common/widgets
shared/widgets

Widgetlar sadece ilgili ekranın içinde bulunur.

views/{screen}/widgets/

---

RESPONSIVE SİSTEM

Sabit pixel kullanımı yasaktır.

Örnek yasak:

padding: 16
fontSize: 14
radius: 12
height: 52

Tüm ölçüler şu dosyalardan gelir:

core/responsive/size_config.dart
core/responsive/size_tokens.dart

---

THEME YÖNETİMİ

Renk ve tipografi sadece şu dosyalardan gelir:

app/app_theme.dart
core/responsive/size_tokens.dart

View içinde inline stil minimum tutulur.

---

MVVM AKIŞI

View → ViewModel → Service → LocalDB

---

VIEW

View yalnızca:

• UI render eder
• ViewModel state dinler
• event tetikler

View içinde aşağıdakiler yasaktır:

• database erişimi
• business logic
• model üretimi

---

VIEWMODEL

Her ekranın kendi ViewModel’i vardır.

Mega ViewModel yasaktır.

Standart state:

bool isLoading
String? errorMessage
List<Movie> movies

Zorunlu metodlar:

init()
addMovie()
deleteMovie()
rateMovie()
toggleWatched()

---

SERVICE

Service görevleri:

• Local DB’den veri çekmek
• Model map etmek
• ViewModel’e model döndürmek

Service içinde UI state bulunamaz.

---

MODEL

Her model şu metodları içerir:

fromJson(Map<String,dynamic>)
toJson()

---

MOVIE MODEL

id
title
type
year
genre
poster
isWatched
createdAt

---

REVIEW MODEL

movieId
storyRating
musicRating
actingRating
cinematographyRating
overallRating
recommend
watchAgain
reviewDate

---

UYGULAMA ÖZELLİKLERİ

Kullanıcı şunları yapabilir:

Film eklemek
Dizi eklemek
İzledim olarak işaretlemek
Çok kriterli puan vermek
Başkalarına önerip önermeyeceğini belirtmek
Tekrar izleyip izlemeyeceğini belirtmek

---

PUANLAMA SİSTEMİ

Her içerik şu kriterlere göre değerlendirilir:

story_rating (1-5)
music_rating (1-5)
acting_rating (1-5)
cinematography_rating (1-5)

Genel puan otomatik hesaplanır:

overall_rating =
(story + music + acting + cinematography) / 4

---

KULLANICI SORULARI

Başkalarına önerir misin?

yes / no

Tekrar izler misin?

yes / no

---

VERİ TABANI TABLOLARI

movies

id
title
type
year
genre
poster
is_watched
created_at

reviews

id
movie_id
story_rating
music_rating
acting_rating
cinematography_rating
overall_rating
recommend
watch_again
review_date

---

LOGLAMA

print kullanımı yasaktır.

core/utils/logger.dart kullanılacaktır.

Log seviyeleri:

INFO
DEBUG
ERROR

---

DOSYA İSİMLENDİRME

Dosyalar:

snake_case.dart

Sınıflar:

PascalCase

Örnek:

movie_service.dart
movie_view_model.dart
movie_detail_view.dart

---

ÇOKLU DİL DESTEĞİ (EN ÖNEMLİ VE ZORUNLU KURAL)

Uygulama 3 dili destekleyecektir:
- Türkçe
- İngilizce
- İspanyolca

Kurallar:
- Eğer kullanıcı bir dil seçtiyse (Türkçe, İngilizce, İspanyolca vb.), uygulama sorunsuz şekilde doğrudan seçili dilde açılmalıdır.
- Diğer durumlarda veya varsayılan (tercih edilen) dil KESİNLİKLE İngilizce olmalıdır.
- Tüm dil çevirileri ve metinleri TEK BİR DOSYADA tanımlanacaktır.
- Örnek format: `giris:login:...` (tüm dillerin anahtarları aynı satırda/yapıda tek dosyada tutulacak).

---

AI İÇİN TALİMAT

Bu projeyi tamamen üret:

• Flutter projesi
• MVVM yapı
• Local database entegrasyonu
• Tüm modeller
• Tüm viewlar
• Tüm viewmodel'ler
• responsive sistem
• theme yönetimi
• logger sistemi

Kod production seviyesinde olmalıdır.