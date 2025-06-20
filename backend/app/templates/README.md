# Email Doğrulama Şablonları

Bu klasör EcoTrack uygulaması için email doğrulama ve diğer web sayfası şablonlarını içerir.

## Mevcut Şablonlar

### 1. email_confirmation.html
- **Amaç**: Kullanıcılar email doğrulama linkine tıkladığında gösterilen sayfa
- **URL**: `/api/v1/auth/confirm` veya `/api/v1/auth/verify-email`
- **Özellikler**:
  - Modern, mobil uyumlu tasarım
  - Loading, success ve error durumları
  - Progress bar animasyonu
  - Deep link ile mobil uygulama açma
  - Responsive tasarım
  - Türkçe kullanıcı arayüzü

### 2. receipt.html
- **Amaç**: QR kod taraması sonucu oluşturulan fiş görüntüleme sayfası

## Kurulum ve Yapılandırma

### Supabase Email Ayarları

1. Supabase Dashboard'da **Authentication > Settings** bölümüne gidin
2. **Email Templates** kısmında:
   - **Confirm signup** template'ini seçin
   - **Email redirect URL** kısmına şunu yazın: `http://localhost:8000/api/v1/auth/confirm`
   - Production için: `https://yourdomain.com/api/v1/auth/confirm`

### FastAPI Yapılandırması

Gerekli paketler:
```bash
pip install jinja2
```

## URL Yapısı

- **Development**: `http://localhost:8000/api/v1/auth/confirm`
- **Production**: `https://yourdomain.com/api/v1/auth/confirm`

## Özelleştirme

### Frontend URL'lerini Değiştirme

`email_confirmation.html` dosyasında bu satırı bulun:
```javascript
const FRONTEND_URL = 'http://localhost:8080'; // Flutter app URL
```

Kendi Flutter uygulamanızın URL'si ile değiştirin.

### Deep Link Yapılandırması

Mobil uygulama için deep link:
```javascript
const deepLink = `ecotrack://auth/verified?token=${accessToken}`;
```

Kendi uygulamanızın scheme'ini kullanın.

## Test Etme

1. Kullanıcı kaydı yapın:
```bash
POST /api/v1/auth/register
{
  "email": "test@example.com",
  "password": "password123",
  "first_name": "Test",
  "last_name": "User"
}
```

2. Email kutunuzu kontrol edin
3. Doğrulama linkine tıklayın
4. Email doğrulama sayfasının açıldığını göreceksiniz

## Güvenlik

- Sayfa, URL parametrelerinden gelen token'ları otomatik olarak işler
- Hatalı durumlar için güvenli hata mesajları gösterir
- Console'da debug bilgileri görüntüler

## Sorun Giderme

### Sayfa Açılmıyor
- FastAPI sunucusunun çalıştığından emin olun
- URL'nin doğru olduğunu kontrol edin
- CORS ayarlarını kontrol edin

### Email Gelmiyor
- Supabase SMTP ayarlarını kontrol edin
- Spam klasörünü kontrol edin
- Email template ayarlarını kontrol edin

### Token Hatası
- URL'deki parametreleri kontrol edin
- Supabase auth ayarlarını kontrol edin
- Console'daki debug bilgilerini kontrol edin 