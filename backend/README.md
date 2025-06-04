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

3.  **Ortam Değişkenlerinin Ayarlanması:**
    Supabase proje URL'nizi ve Anon (public) API anahtarınızı içeren ortam değişkenlerini veya bir yapılandırma dosyasını ayarlayın. (Örnek: `.env` dosyası veya Flutter'da `lib/config.dart`).

4.  **Bağımlılıkların Yüklenmesi:**
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

5.  **Veritabanı Kurulumu:**
    Supabase projenizde `schema.sql` (veya ilgili dosya) içerisindeki tabloları ve gerekli RLS (Row Level Security) politikalarını ayarlayın.

6.  **Uygulamayı Çalıştırma:**
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

# EcoTrack Backend API

QR-Based Digital Expense Tracking Application API

## Kurulum

1. Python 3.9+ ve pip yüklü olmalıdır.

2. Sanal ortam oluşturun ve aktifleştirin:

```bash
python -m venv ecoTrack
source ecoTrack/bin/activate  # Unix/MacOS
# veya
ecoTrack\Scripts\activate     # Windows
```

3. Gerekli paketleri yükleyin:

```bash
pip install -r requirements.txt
```

4. `.env` dosyasını oluşturun ve aşağıdaki değişkenleri ayarlayın:

```
# Supabase API anahtarları
SUPABASE_URL=https://<project_id>.supabase.co
SUPABASE_KEY=<anon_key>
SUPABASE_SERVICE_KEY=<service_role_key>

# JWT Ayarları
JWT_SECRET=<güvenli_bir_anahtar>
JWT_ALGORITHM=HS256
JWT_EXPIRATION_MINUTES=60

# Uygulama ayarları
APP_NAME=EcoTrack
APP_DEBUG=True
ENVIRONMENT=development

# Loglama
LOG_LEVEL=INFO
LOG_FILE=logs/app.log
```

5. Supabase veritabanı tablolarını oluşturun:

- Supabase Dashboard'a giriş yapın
- SQL Editor'e gidin
- `docs/supabase_schema.sql` dosyasındaki SQL komutlarını kopyalayıp yapıştırın
- "Run" düğmesine basarak SQL komutlarını çalıştırın

6. API'yi başlatın:

```bash
python main.py
```

API varsayılan olarak `http://localhost:8000` adresinde çalışacaktır.

## API Endpoints

### Sağlık Kontrolü

- GET `/`: API sağlık kontrolü

### Kimlik Doğrulama Endpoints

- POST `/api/auth/register`: Yeni kullanıcı kaydı
- POST `/api/auth/login`: Kullanıcı girişi ve JWT token alma
- GET `/api/auth/me`: Oturum açmış kullanıcının bilgilerini alma
- POST `/api/auth/reset-password`: Şifre sıfırlama isteği
- POST `/api/auth/reset-password-confirm`: Şifre sıfırlama doğrulama

### Fiş Endpoints

- GET `/api/receipts`: Kullanıcının tüm fişlerini listeler
- GET `/api/receipts/{id}`: Belirli bir fişin detaylarını getirir
- POST `/api/receipts`: Yeni fiş ekler
- PUT `/api/receipts/{id}`: Mevcut fişi günceller
- DELETE `/api/receipts/{id}`: Fişi siler

### Gider Endpoints

- GET `/api/expenses`: Kullanıcının tüm giderlerini listeler
- GET `/api/expenses/{id}`: Belirli bir giderin detaylarını getirir
- POST `/api/expenses`: Yeni gider ekler
- PUT `/api/expenses/{id}`: Mevcut gideri günceller
- DELETE `/api/expenses/{id}`: Gideri siler

### Kategori Endpoints

- GET `/api/categories`: Tüm kategorileri listeler
- GET `/api/categories/{id}`: Belirli bir kategorinin detaylarını getirir
- POST `/api/categories`: Yeni kategori ekler (admin)
- PUT `/api/categories/{id}`: Mevcut kategoriyi günceller (admin)
- DELETE `/api/categories/{id}`: Kategoriyi siler (admin)

### Sadakat Programı Endpoints

- GET `/api/loyalty`: Kullanıcının tüm sadakat programlarını listeler
- GET `/api/loyalty/{id}`: Belirli bir sadakat programının detaylarını getirir
- POST `/api/loyalty`: Yeni sadakat programı ekler
- PUT `/api/loyalty/{id}`: Mevcut sadakat programını günceller
- DELETE `/api/loyalty/{id}`: Sadakat programını siler

### Öneriler Endpoints

- GET `/api/suggestions`: Kullanıcının tüm önerilerini listeler
- GET `/api/suggestions/{id}`: Belirli bir önerinin detaylarını getirir
- POST `/api/suggestions`: Yeni öneri ekler
- PUT `/api/suggestions/{id}`: Mevcut öneriyi günceller
- DELETE `/api/suggestions/{id}`: Öneriyi siler

### Veritabanı Endpoints

- GET `/migrate`: Veritabanı tablo kontrollerini çalıştırır
- POST `/api/db/run-migrations`: Veritabanı tablolarını oluşturur (kimlik doğrulama gerektirir)

## Notlar

- API, FastAPI ve Supabase kullanılarak geliştirilmiştir.
- Tüm endpoint'ler JSON formatında yanıt verir.
- Kimlik doğrulama JWT token tabanlıdır.