# EcoTrack Backend Test Suite

Bu klasör EcoTrack backend uygulaması için kapsamlı test suite'ini içerir.

## 📁 Test Klasör Yapısı

```
tests/
├── unit/                    # Unit testler
│   ├── test_services.py     # Service layer testleri
│   ├── test_database.py     # Database layer testleri
│   └── test_merchant_services.py  # Merchant service testleri
├── integration/             # Integration testler
│   ├── test_expenses_integration.py    # Expenses API testleri
│   ├── test_receipts_integration.py    # Receipts API testleri
│   ├── test_auth_integration.py        # Auth API testleri
│   ├── test_ai_integration.py          # AI API testleri
│   ├── test_merchant_integration.py    # Merchant API testleri
│   └── test_*.py           # Diğer endpoint testleri
├── e2e/                    # End-to-End testler
│   └── test_complete_workflow.py  # Tam iş akışı testleri
├── utils/                  # Test utilities
│   └── test_helpers.py     # Test yardımcı fonksiyonları
├── fixtures/               # Test fixtures ve mock data
└── run_all_tests.py       # Ana test runner
```

## 🚀 Test Çalıştırma

### Tüm Testleri Çalıştır
```bash
python tests/run_all_tests.py
```

### Test Türüne Göre Çalıştır
```bash
# Sadece unit testler
python tests/run_all_tests.py unit

# Sadece integration testler
python tests/run_all_tests.py integration

# Sadece e2e testler
python tests/run_all_tests.py e2e

# Hızlı testler (sadece çalışan endpoint'ler)
python tests/run_all_tests.py quick
```

### Tek Test Dosyası Çalıştır
```bash
# Merchant integration testi
python tests/integration/test_merchant_integration.py

# E2E workflow testi
python tests/e2e/test_complete_workflow.py
```

## 🧪 Test Türleri

### Unit Tests
- **Amaç**: Service layer ve business logic testleri
- **Kapsam**: Database bağımlılıkları olmadan pure function testleri
- **Hız**: Çok hızlı (< 1 saniye)

### Integration Tests
- **Amaç**: API endpoint'leri ve sistem entegrasyonu testleri
- **Kapsam**: HTTP request/response, authentication, validation
- **Hız**: Orta (1-5 saniye per test)

### E2E Tests
- **Amaç**: Tam iş akışı ve kullanıcı senaryoları testleri
- **Kapsam**: Merchant'tan expense'e kadar tam workflow
- **Hız**: Yavaş (5-30 saniye per test)

## 🛠️ Test Utilities

### TestClient
HTTP istekleri için wrapper class:
```python
from tests.utils.test_helpers import TestClient, AuthHelper

client = AuthHelper.get_admin_client()
response = client.get("/api/v1/merchants/")
```

### DataFactory
Test data oluşturmak için factory:
```python
from tests.utils.test_helpers import DataFactory

merchant_data = DataFactory.create_merchant_data("Test Restaurant")
expense_data = DataFactory.create_expense_data(100.0)
```

### AssertionHelper
Test assertion'ları için helper:
```python
from tests.utils.test_helpers import AssertionHelper

AssertionHelper.assert_response_success(response, 201)
AssertionHelper.assert_has_fields(data, ["id", "name"])
```

## 📊 Test Raporlama

Test sonuçları otomatik olarak raporlanır:
- ✅ Başarılı testler
- ❌ Başarısız testler  
- ⚠️ Skip edilen testler
- 📈 Başarı oranı
- ⏱️ Çalışma süresi

## 🔧 Test Konfigürasyonu

### Environment Variables
```bash
# .env dosyasında
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

### Authentication
Testler service role key kullanarak admin yetkisi ile çalışır:
```python
# Service role token otomatik olarak kullanılır
client = AuthHelper.get_admin_client()
```

## 📝 Test Yazma Rehberi

### Yeni Integration Test Ekleme
```python
from tests.utils.test_helpers import TestClient, AuthHelper, DataFactory, AssertionHelper, TestReporter

class NewEndpointIntegrationTest:
    def __init__(self):
        self.client = AuthHelper.get_admin_client()
        self.reporter = TestReporter()
    
    def test_create_resource(self):
        try:
            data = DataFactory.create_test_data()
            response = self.client.post("/api/v1/resource/", data)
            
            AssertionHelper.assert_response_success(response, 201)
            result = response.json()
            
            self.reporter.add_result("Create Resource", "PASS")
        except Exception as e:
            self.reporter.add_result("Create Resource", "FAIL", str(e))
```

## 🎯 Mevcut Test Durumu

### ✅ Çalışan Testler
- **Merchant Integration**: Tam çalışır durumda (6/6 endpoint)
- **Webhook Integration**: Tam çalışır durumda (5/5 endpoint)
- **Unit Tests**: Service layer testleri

### ⚠️ Bekleyen Testler
- **Expenses Integration**: Endpoint'ler implement edilmeli
- **Receipts Integration**: Endpoint'ler implement edilmeli  
- **Auth Integration**: Auth endpoint'leri implement edilmeli
- **AI Integration**: AI endpoint'leri implement edilmeli

## 🚨 Test Gereksinimleri

1. **Server Running**: Tests çalıştırılmadan önce server'ın localhost:8000'de çalışıyor olması gerekir
2. **Database Access**: Supabase bağlantısı ve service role key gerekli
3. **Clean State**: Testler kendi cleanup'larını yapar ama bazen manuel temizlik gerekebilir

## 📞 Destek

Test ile ilgili sorunlar için:
1. Test output'unu kontrol edin
2. Server loglarını kontrol edin  
3. Database bağlantısını kontrol edin
4. Environment variables'ları kontrol edin 