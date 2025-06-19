# QR-Based Digital Expense Tracking Application

## Proje Genel Bakış

Bu proje, kullanıcıların harcamalarını ve finansal durumlarını dijital olarak takip etmelerini sağlayan yenilikçi bir mobil uygulamadır. Alışveriş fişlerindeki QR kodlarını tarayarak manuel veri girişine olan ihtiyacı ortadan kaldırır. Uygulama, yapay zeka (AI) destekli finansal içgörüler sunar ve çevre dostu bir yaklaşım benimser.

İstanbul Aydın Üniversitesi Mühendislik Fakültesi'nden Emre Kolunsağ (Yazılım Mühendisliği), Ali Ata Haktan Çetinkol (Yazılım Mühendisliği) ve Alaz İlhan (Bilgisayar Mühendisliği) tarafından bir mezuniyet projesi olarak geliştirilmektedir. Proje, Ekim 2024 - Haziran 2025 tarihleri arasında yürütülmektedir.

## Projenin Amaçları

*   Kullanıcıların harcamalarını dijital olarak kaydetmelerini ve yönetmelerini kolaylaştırmak.
*   Yapay zeka ile desteklenen kişiselleştirilmiş finansal öneriler ve bütçe planlama araçları sunmak.
*   QR kod entegrasyonu ve anlaşılır görselleştirmelerle kullanıcı dostu bir deneyim sağlamak.
*   Dijital fişler ve israf önleme önerileriyle sürdürülebilirliğe katkıda bulunmak.

## Temel Özellikler

*   **QR Kod ile Dijital Fişler:** Alışveriş fişlerindeki QR kodlarını tarayarak fiş verilerini otomatik olarak dijitalleştirme, kategorize etme ve arşivleme.
*   **AI Tabanlı Öneriler:** Harcama alışkanlıkları analizi ile kişiselleştirilmiş tasarruf önerileri, bütçe planlama ve kampanya bildirimleri sunma.
*   **Son Kullanma Tarihi (EOL) Takibi:** Ürünlerin son kullanma tarihlerini AI ile takip etme ve bozulmadan önce kullanıcıları bilgilendirme, tüketim planları sunma.
*   **Enflasyon Analizi:** Belirli ürünlerin fiyat değişimlerini zaman içinde takip etme ve grafiksel olarak görselleştirerek enflasyonun harcamalara etkisini gösterme.
*   **Grafiksel Görselleştirme:** Harcama verilerini ve finansal durumu anlaşılır grafikler ve tablolarla sunma.
*   **Sadakat Programı:** Bütçe yönetimi tutarlılığına dayalı puan kazanma ve ödül sistemi ile kullanıcı katılımını teşvik etme.

## Teknik Mimari

Uygulama, modüler ve ölçeklenebilir bir katmanlı mimari kullanılarak tasarlanmıştır:

*   **Sunum Katmanı (Presentation Layer):** Kullanıcı arayüzü (Flutter).
*   **Uygulama Katmanı (Application Layer):** İş mantığı ve API yönetimi (Flutter & Python).
*   **Alan Katmanı (Domain Layer):** Temel iş kuralları ve varlıklar.
*   **Altyapı/Veri Katmanı (Infrastructure/Data Layer):** Veri depolama ve erişim (Supabase - PostgreSQL tabanlı).

Başlangıçta Firebase düşünülmüş olsa da, bütçe kısıtlamaları ve fiyatlandırma değişiklikleri nedeniyle **Supabase** (PostgreSQL tabanlı) ücretsiz katmanı ve sağlam altyapısı tercih edilmiştir.

## Veritabanı Şeması

Veriler JSON formatında saklanır ve temel olarak şu tabloları içerir:

*   `users`: Kullanıcı bilgileri (e-posta, şifre, 2FA ayarları vb.)
*   `categories`: Harcama kategorileri
*   `receipts`: Dijitalleştirilmiş fiş verileri
*   `expenses`: Bireysel harcama işlemleri
*   `loyalty_status`: Sadakat programı bilgileri
*   `suggestions`: AI tarafından oluşturulan öneriler

## Geliştirme Süreci

Proje, Agile (Scrum) metodolojisi kullanılarak geliştirilmektedir. Süreç, sprintler halinde ve düzenli geri bildirimlerle ilerlemektedir.

*   **Planlama:** Ekim - Kasım 2024
*   **Tasarım:** Aralık 2024 - Şubat 2025
*   **Geliştirme:** Mart - Nisan 2025
*   **Test:** Nisan - Mayıs 2025
*   **Dağıtım:** Haziran 2025

## Kullanılan Teknolojiler

*   **Mobil Geliştirme:** Flutter SDK
*   **Backend/AI:** Python 3+, TensorFlow Lite
*   **Veritabanı:** Supabase (PostgreSQL)
*   **API Testi:** Postman
*   **Versiyon Kontrol:** Git
*   **UI/UX Tasarım:** Figma
*   **Bulut Barındırma:** DigitalOcean (Gerektiğinde)

## Kurulum ve Çalıştırma

Projenin yerel ortamınızda çalıştırılması için aşağıdaki adımları izlemeniz gerekmektedir:

1.  **Ön Koşullar:**
    *   Flutter SDK kurulumu
    *   Python 3+ kurulumu
    *   Git kurulumu
    *   Supabase projesi kurulumu ve gerekli API anahtarlarının alınması. (Supabase ücretsiz katman yeterlidir.)

2.  **Depoyu Klonlama:**
    ```bash
    git clone [REPO_URL_BURAYA_GELECEK]
    cd [KLONLANAN_KLASÖR_ADİ]
    ```

3.  **Firebase Konfigürasyonu (Güvenlik):**
    **ÖNEMLİ:** Firebase konfigürasyon dosyaları güvenlik nedeniyle repository'de bulunmamaktadır.
    
    Aşağıdaki dosyaları kendi Firebase projenizden alarak oluşturmanız gerekmektedir:
    
    ```bash
    # Firebase options dosyasını oluşturun
    cp lib/firebase_options.dart.example lib/firebase_options.dart
    
    # Android Google Services dosyasını oluşturun
    cp android/app/google-services.json.example android/app/google-services.json
    ```
    
    Ardından bu dosyaları kendi Firebase projenizin bilgileriyle güncelleyin:
    - Firebase Console'dan projenizi seçin
    - Android app konfigürasyonundan `google-services.json` dosyasını indirin
    - FlutterFire CLI ile `firebase_options.dart` dosyasını yeniden oluşturun:
      ```bash
      flutterfire configure
      ```

4.  **Ortam Değişkenlerinin Ayarlanması:**
    Supabase proje URL'nizi ve Anon (public) API anahtarınızı içeren ortam değişkenlerini veya bir yapılandırma dosyasını ayarlayın. (Örnek: `.env` dosyası veya Flutter'da `lib/config.dart`).

5.  **Bağımlılıkların Yüklenmesi:**
    *   Flutter (Frontend):
        ```bash
        cd frontend
        flutter pub get
        ```
    *   Python (Backend/AI - eğer ayrı bir servis olarak çalışıyorsa):
        ```bash
        cd backend # veya ilgili klasör
        pip install -r requirements.txt
        ```

6.  **Veritabanı Kurulumu:**
    Supabase projenizde `schema.sql` (veya ilgili dosya) içerisindeki tabloları ve gerekli RLS (Row Level Security) politikalarını ayarlayın.

7.  **Uygulamayı Çalıştırma:**
    *   Flutter (Frontend):
        ```bash
        cd frontend
        flutter run
        ```
    *   Python Backend (eğer ayrı bir servis olarak çalışıyorsa):
        ```bash
        cd backend # veya ilgili klasör
        python app.py # veya başlangıç dosyanız
        ```

*Not:* Detaylı kurulum adımları ve yapılandırma bilgileri proje içerisindeki `SETUP.md` veya `docs/` klasöründe bulunabilir.

## Test

Proje, birim, entegrasyon ve fonksiyonel testlerle titizlikle test edilmektedir. Test stratejisi ve kapsamı hakkında daha fazla bilgi için ilgili test dokümanlarına bakabilirsiniz.

*   **Manuel Testler:** UI/UX, QR tarama, kullanıcı akışları.
*   **Otomatik Testler:** Backend API testleri, veri doğruluğu.
*   **Performans Testleri:** QR tarama ve AI işleme hızı.

## Güvenlik ve Uyumluluk

Veri güvenliği ve kullanıcı gizliliği önceliklidir.

*   **Şifreleme:** Veri depolama için AES-256, veri iletimi için HTTPS.
*   **Kimlik Doğrulama:** 2FA (İki Faktörlü Kimlik Doğrulama) ve JWT (JSON Web Tokens).
*   **Uyumluluk:** KVKK ve GDPR mevzuatlarına uyumluluk hedeflenmektedir.

## Katkıda Bulunma

Bu proje bir mezuniyet projesi olduğundan, büyük ölçekli topluluk katkıları şu an için ana odak noktası değildir. Ancak, geliştirme aşamasında karşılaşılan hatalar veya potansiyel iyileştirmeler için geri bildirimler değerlidir. Lütfen bir issue açarak bizimle paylaşın.

## Lisans

Lisans bilgisi daha sonra belirlenecektir. (Mezuniyet projeleri genellikle özel şartlara tabi olabilir).

## Ekip

*   Emre Kolunsağ (Yazılım Mühendisliği)
*   Ali Ata Haktan Çetinkol (Yazılım Mühendisliği)
*   Alaz İlhan (Bilgisayar Mühendisliği)

İstanbul Aydın Üniversitesi Mühendislik Fakültesi - 2025 Mezuniyet Projesi