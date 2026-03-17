# Film List Uygulaması Özellikleri

Bu döküman, Film List mobil uygulamasında bulunan tüm özellikleri ve teknik yetkinlikleri kapsamaktadır.

## 1. Genel Özellikler
- **Tamamen Çevrimdışı (Offline) Çalışma:** Uygulama, internet bağlantısı olmadan tüm temel işlevlerini yerine getirebilir. Veriler yerel bir veritabanında saklanır.
- **MVVM Mimarisi:** Kod yapısı, sürdürülebilirlik ve test edilebilirlik için Model-View-ViewModel mimarisi üzerine kuruludur.
- **Duyarlı (Responsive) Tasarım:** Farklı ekran boyutlarına uyum sağlayan özel bir token sistemi ve dinamik boyutlandırma kullanılır.
- **Karanlık Tema:** Modern ve göz yormayan karanlık tema desteği.

## 2. Ana Sayfa (Home)
- **Tür Bazlı Kategorizasyon:** Kullanıcının listesindeki filmler türlerine göre (Action, Drama, Comedy vb.) otomatik olarak gruplandırılır.
- **İzleme Durumu Takibi:** "İzlenecekler" (Watchlist) ve "İzlenenler" (Watched) olarak ayrılmış yatay listeler.
- **Kişiselleştirilmiş Öneriler (Discovery):** Kullanıcının izlediği filmlerin türlerini analiz ederek API üzerinden benzer türde yeni film önerileri sunar.
- **Dinamik Slider:** Öne çıkan veya yeni eklenen içerikler için görsel slider.

## 3. Film Arama ve Ekleme
- **OMDb API Entegrasyonu:** Milyonlarca film ve dizi arasında başlığa göre arama yapabilme.
- **Detaylı Arama Sonuçları:** Arama sonuçlarında afiş, yıl ve tür bilgilerini görüntüleme.
- **Manuel Film Ekleme:** Veritabanında bulunmayan yapımlar için kullanıcı adı, yıl, tür ve afiş gibi bilgileri elle girerek özel kayıt oluşturabilir.
- **Afiş İndirme Servisi:** API üzerinden bulunan filmlerin afişlerini yerel cihaza indirerek çevrimdışı erişim için saklar.

## 4. Film Detay ve Değerlendirme
- **Kapsamlı Puanlama Sistemi:** Filmler için 4 farklı kriterde (Hikaye, Müzik, Oyunculuk, Sinematografi) 1-10 arası puan verme.
- **İzleme Deneyimi Sorgusu:** "Tekrar izler miyim?" ve "Tavsiye eder miyim?" gibi evet/hayır seçenekleri.
- **Yorum Ekleme:** Filmler hakkında detaylı notlar ve yorumlar yazabilme.
- **Otomatik Konu Çevirisi (Translation):** OMDb üzerinden gelen İngilizce film özetlerini, uygulamanın seçili diline (Türkçe, İspanyolca vb.) otomatik çevirme özelliği.
- **Puan Güncelleme ve Silme:** Mevcut değerlendirmeleri düzenleme veya tamamen kaldırma imkanı.

## 5. Profil ve Ayarlar
- **Çoklu Dil Desteği:** 
  - Türkçe
  - İngilizce
  - İspanyolca
- **Veri Yönetimi:** Tüm uygulama verilerini (kayıtlı filmler, puanlar, ayarlar) tek bir tuşla temizleme seçeneği.
- **Uygulama İçi İnceleme (In-App Review):** Kullanıcıyı mağaza sayfasına yönlendirmeden uygulama içinden puan verme imkanı.
- **İstatistikler:** (Planlanan veya mevcut) Kullanıcının kaç film izlediği ve ortalama puanları gibi özet bilgiler.

## 6. Teknik Servisler
- **Local Database:** Verileri cihazda kalıcı olarak saklamak için optimize edilmiş yerel veritabanı kullanımı.
- **Discovery Service:** Kullanıcı alışkanlıklarına göre dinamik anahtar kelime üretimi ve öneri algoritması.
- **Poster Download Service:** Görsel verileri cache-leyerek (önbelleğe alarak) veri tasarrufu ve hız sağlar.
- **Translation Service:** Google Translate entegrasyonu ile dinamik içerik yerelleştirme.
