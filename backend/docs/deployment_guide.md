# EcoTrack Backend Deployment Guide

Bu rehber EcoTrack Backend API'sinin production ortamına deploy edilmesi için gerekli adımları içerir.

## 📋 Ön Gereksinimler

### Sistem Gereksinimleri
- Docker ve Docker Compose
- Python 3.11+
- 2GB+ RAM
- 10GB+ disk alanı

### Servis Gereksinimleri
- Supabase projesi (PostgreSQL veritabanı)
- Ollama AI servisi (opsiyonel)
- Firebase Cloud Messaging (push notifications için)

## 🚀 Hızlı Başlangıç

### 1. Repository'yi Klonlayın
```bash
git clone <repository-url>
cd ecotrack-backend
```

### 2. Environment Variables Ayarlayın
```bash
cp .env.example .env
# .env dosyasını düzenleyin
```

### 3. Docker ile Çalıştırın
```bash
# Development ortamı
docker-compose up -d

# Production ortamı (Nginx ile)
docker-compose --profile production up -d

# Cache ile (Redis)
docker-compose --profile cache up -d
```

## 🔧 Detaylı Konfigürasyon

### Environment Variables

#### Temel Ayarlar
```env
ENVIRONMENT=production
DEBUG=false
FORCE_HTTPS=true
```

#### Güvenlik Ayarları
```env
RATE_LIMIT_CALLS=100
RATE_LIMIT_PERIOD=60
JWT_SECRET_KEY=güçlü-secret-key-buraya
```

#### Supabase Ayarları
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

#### AI Ayarları
```env
OLLAMA_ENABLED=true
OLLAMA_HOST=http://ollama:11434
OLLAMA_MODEL=qwen2.5:3b
```

#### Logging Ayarları
```env
LOG_LEVEL=INFO
LOG_FILE=/app/logs/app.log
```

### Supabase Kurulumu

1. **Supabase Projesi Oluşturun**
   - https://supabase.com adresinde proje oluşturun
   - Database URL ve API keys'leri alın

2. **Veritabanı Schema'sını Kurun**
   ```bash
   # SQL migration dosyalarını çalıştırın
   # (Supabase dashboard'dan SQL editor kullanın)
   ```

3. **Row Level Security (RLS) Politikalarını Aktifleştirin**
   ```sql
   -- Her tablo için RLS politikalarını aktifleştirin
   ALTER TABLE users ENABLE ROW LEVEL SECURITY;
   ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
   -- ... diğer tablolar
   ```

### Ollama AI Kurulumu

1. **Ollama Container'ını Başlatın**
   ```bash
   docker-compose up ollama -d
   ```

2. **TinyLlama Modelini İndirin**
   ```bash
   docker exec -it ecotrack-ollama ollama pull qwen2.5:3b
   ```

3. **Model Testini Yapın**
   ```bash
   curl http://localhost:11434/api/generate -d '{
     "model": "qwen2.5:3b",
     "prompt": "Test"
   }'
   ```

## 🔒 Güvenlik Konfigürasyonu

### HTTPS Kurulumu

1. **SSL Sertifikası Alın**
   ```bash
   # Let's Encrypt ile
   certbot certonly --standalone -d your-domain.com
   ```

2. **Nginx Konfigürasyonu**
   ```nginx
   server {
       listen 443 ssl;
       server_name your-domain.com;
       
       ssl_certificate /etc/nginx/ssl/cert.pem;
       ssl_certificate_key /etc/nginx/ssl/key.pem;
       
       location / {
           proxy_pass http://ecotrack-api:8000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   }
   ```

### Firewall Ayarları
```bash
# Sadece gerekli portları açın
ufw allow 22    # SSH
ufw allow 80    # HTTP
ufw allow 443   # HTTPS
ufw enable
```

## 📊 Monitoring ve Logging

### Health Check Endpoints
- `GET /health` - Temel sağlık kontrolü
- `GET /health/detailed` - Detaylı sistem durumu
- `GET /health/database` - Veritabanı durumu
- `GET /health/ai` - AI servisi durumu

### Log Dosyaları
```bash
# Uygulama logları
tail -f logs/app.log

# Error logları
tail -f logs/app_error.log

# Docker logları
docker-compose logs -f ecotrack-api
```

### Sistem Metrikleri
```bash
# Container durumları
docker-compose ps

# Kaynak kullanımı
docker stats

# Disk kullanımı
df -h
```

## 🔄 Backup ve Maintenance

### Veritabanı Backup
```bash
# Supabase'den backup alın
# (Supabase dashboard'dan export özelliğini kullanın)
```

### Log Rotation
```bash
# Logrotate konfigürasyonu
cat > /etc/logrotate.d/ecotrack << EOF
/app/logs/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 644 appuser appuser
}
EOF
```

### Güncelleme Prosedürü
```bash
# 1. Yeni kodu çekin
git pull origin main

# 2. Container'ları yeniden build edin
docker-compose build

# 3. Servisleri yeniden başlatın
docker-compose up -d
```

## 🚨 Troubleshooting

### Yaygın Sorunlar

1. **Supabase Bağlantı Hatası**
   ```bash
   # Environment variables'ları kontrol edin
   echo $SUPABASE_URL
   echo $SUPABASE_KEY
   ```

2. **Ollama Model Yükleme Hatası**
   ```bash
   # Model'i manuel olarak yükleyin
   docker exec -it ecotrack-ollama ollama pull qwen2.5:3b
   ```

3. **Port Çakışması**
   ```bash
   # Kullanılan portları kontrol edin
   netstat -tulpn | grep :8000
   ```

4. **Memory Yetersizliği**
   ```bash
   # Container memory limitlerini artırın
   # docker-compose.yml'de memory ayarlarını güncelleyin
   ```

### Log Analizi
```bash
# Error loglarını filtreleyin
grep "ERROR" logs/app.log

# Belirli bir kullanıcının loglarını bulun
grep "user_id: 123" logs/app.log

# Son 1 saatin loglarını görün
tail -n 1000 logs/app.log | grep "$(date -d '1 hour ago' '+%Y-%m-%d %H')"
```

## 📞 Destek

Sorun yaşadığınızda:
1. Health check endpoint'lerini kontrol edin
2. Log dosyalarını inceleyin
3. Container durumlarını kontrol edin
4. Environment variables'ları doğrulayın

## 🔄 Scaling

### Horizontal Scaling
```yaml
# docker-compose.yml'de replica sayısını artırın
services:
  ecotrack-api:
    deploy:
      replicas: 3
```

### Load Balancer
```nginx
upstream ecotrack_backend {
    server ecotrack-api-1:8000;
    server ecotrack-api-2:8000;
    server ecotrack-api-3:8000;
}
```

Bu rehber EcoTrack Backend'in güvenli ve stabil bir şekilde production ortamında çalıştırılması için gerekli tüm adımları içermektedir. 