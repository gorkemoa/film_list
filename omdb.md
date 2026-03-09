cat << 'EOF' > add_movie_cache_system.md

GÖREV

Projede mevcut bir README.md bulunmaktadır.

README tüm mimari kurallarını belirler.

AI aşağıdaki kurallara uymak zorundadır:

1. README.md dosyasını tamamen oku
2. Mimari kuralları analiz et
3. Mimariyi değiştirme
4. Kuralları ihlal etmeden yeni feature geliştir

---

AMAÇ

Uygulamaya tam bir CACHE sistemi eklenmelidir.

Cache yalnızca poster değil aşağıdaki tüm verileri saklamalıdır:

title
year
runtime
genre
awards
ratings
metascore
imdbRating
imdbVotes
poster

Bu veriler OMDb API’den alınır ve Local Database’e kaydedilir.

Kullanıcı daha sonra internet olmasa bile tüm eklediği film/dizileri görebilir.

---

CACHE MANTIĞI

Kullanıcı film/dizi eklediğinde:

1. Local DB kontrol edilir

Var mı?

YES → local veriyi kullan

NO → OMDb API çağrısı yapılır

---

API çağrısı sonrası:

1. Film detayları parse edilir
2. Poster indir
3. Poster local storage'a kaydet
4. Film verisini Local DB'ye kaydet

---

CACHE AKIŞI

User search
↓
Search API
↓
User film seçer
↓
Local DB kontrol
↓
Film var mı?

YES → Local DB'den getir

NO →
OMDb Detail API
↓
Poster indir
↓
Local DB'ye kaydet
↓
UI göster

---

OFFLINE DAVRANIŞ

İnternet yoksa:

Kullanıcı daha önce eklediği tüm film/dizileri Local DB’den görebilir.

Posterler local storage’dan yüklenir.

---

MODEL TASARIMI

Movie model aşağıdaki alanları içermelidir:

id
imdbId

title
year
runtime
genre
awards

posterUrl
posterLocalPath

imdbRating
imdbVotes
metascore

ratings (List<Rating>)

isWatched
createdAt
updatedAt

---

Rating model

source
value

---

LOCAL DATABASE TABLOSU

movies

id
imdb_id
title
year
runtime
genre
awards

poster_url
poster_local_path

imdb_rating
imdb_votes
metascore

created_at
updated_at

---

RATINGS TABLOSU

movie_ratings

id
movie_id
source
value

---

SERVICE KATMANI

movie_cache_service.dart

getMovieByImdbId()
saveMovie()
updateMovie()
deleteMovie()
getAllMovies()

---

omdb_service.dart

searchMovies(query)
getMovieDetail(title)

---

poster_service.dart

downloadPoster(url)
getLocalPosterPath()

---

CACHE STRATEJİSİ

Film Local DB’de varsa API çağrısı yapılmaz.

Poster Local DB’de varsa tekrar indirilmez.

---

ZORUNLU MİMARİ

README’de belirtilen mimari korunacaktır.

Models → Views → ViewModels → Services → Core

View içinde API çağrısı yapmak yasaktır.

Service katmanı:

API
cache
poster download

işlemlerini yönetir.

---

AI İÇİN TALİMAT

README kurallarını ihlal etmeden aşağıdaki kodları üret:

• Movie cache modeli
• Rating modeli
• OMDb service
• Poster download service
• Movie cache service
• Local DB schema
• Offline veri yükleme sistemi

Kod production seviyesinde olmalıdır.

