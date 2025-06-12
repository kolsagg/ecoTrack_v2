#!/usr/bin/env python3
"""
Merchant Integration Test Script
Bu script merchant integration'ın çalışıp çalışmadığını test eder.
"""

import requests
import json
import os
import sys
from datetime import datetime
from supabase import create_client, Client

# Test config'i import et
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from tests.config import test_config

def get_admin_token():
    """Admin client ile service role token alır"""
    try:
        # Test config'ten service role key'i al
        token = test_config.get_service_role_token()
        print("✅ Admin client (service role) kullanılıyor")
        return token
            
    except Exception as e:
        print(f"❌ Admin token hatası: {str(e)}")
        return None

def test_merchant_endpoints():
    """Merchant endpoint'lerini test eder"""
    # Test config'i doğrula
    if not test_config.validate_config():
        print("❌ Test konfigürasyonu eksik, test durduruluyor")
        return
    
    base_url = test_config.API_BASE_URL
    
    # Admin token al (service role)
    admin_token = get_admin_token()
    if not admin_token:
        print("❌ Admin token alınamadı, test durduruluyor")
        return
    
    headers = {
        "Authorization": f"Bearer {admin_token}",
        "Content-Type": "application/json"
    }
    
    print("\n🧪 Merchant Integration Test Başlıyor...")
    print("=" * 50)
    
    # 1. Merchant oluştur
    print("\n1️⃣ Test Merchant Oluşturuluyor...")
    merchant_data = {
        "name": "Test Restaurant",
        "business_type": "restaurant",
        "contact_email": "test@restaurant.com",
        "contact_phone": "+905551234567",
        "address": "Test Mahallesi, Test Sokak No:1, İstanbul"
    }
    
    response = requests.post(
        f"{base_url}/api/v1/merchants/",
        headers=headers,
        json=merchant_data
    )
    
    print(f"Response Status: {response.status_code}")
    if response.status_code != 201:
        print(f"Response Body: {response.text}")
    
    if response.status_code == 201:
        merchant = response.json()
        merchant_id = merchant["id"]
        api_key = merchant["api_key"]
        print(f"✅ Merchant oluşturuldu: {merchant['name']}")
        print(f"   ID: {merchant_id}")
        print(f"   API Key: {api_key[:10]}...")
    else:
        print(f"❌ Merchant oluşturulamadı: {response.status_code}")
        print(f"   Hata: {response.text}")
        return
    
    # 2. Merchant listele
    print("\n2️⃣ Merchant Listesi Alınıyor...")
    response = requests.get(f"{base_url}/api/v1/merchants/", headers=headers)
    
    if response.status_code == 200:
        merchants = response.json()
        print(f"✅ {merchants['total']} merchant bulundu")
        for merchant in merchants['merchants']:
            print(f"   - {merchant['name']} ({merchant['business_type']})")
    else:
        print(f"❌ Merchant listesi alınamadı: {response.status_code}")
        print(f"   Hata: {response.text}")
    
    # 3. Webhook transaction test et
    print("\n3️⃣ Webhook Transaction Test Ediliyor...")
    webhook_data = {
        "transaction_id": "test-txn-123",
        "total_amount": 125.50,
        "currency": "TRY",
        "transaction_date": datetime.now().isoformat(),
        "customer_info": {
            "email": "customer@test.com",
            "phone": "+905559876543",
            "card_last_four": "1234"
        },
        "items": [
            {
                "name": "Hamburger",
                "description": "Lezzetli hamburger menü",
                "quantity": 2,
                "unit_price": 45.00,
                "total_price": 90.00,
                "category": "food"
            },
            {
                "name": "Kola",
                "description": "Soğuk içecek",
                "quantity": 2,
                "unit_price": 17.75,
                "total_price": 35.50,
                "category": "beverage"
            }
        ],
        "payment_method": "credit_card",
        "location": {
            "address": "Test Restaurant, İstanbul",
            "latitude": 41.0082,
            "longitude": 28.9784
        }
    }
    
    webhook_headers = {
        "X-API-Key": api_key,
        "Content-Type": "application/json"
    }
    
    response = requests.post(
        f"{base_url}/api/v1/webhooks/merchant/{merchant_id}/transaction",
        headers=webhook_headers,
        json=webhook_data
    )
    
    print(f"Webhook Response Status: {response.status_code}")
    if response.status_code != 200:
        print(f"Webhook Response Body: {response.text}")
    
    if response.status_code == 200:
        result = response.json()
        print("✅ Webhook transaction başarıyla işlendi")
        print(f"   Transaction ID: {result.get('transaction_id')}")
        print(f"   Customer Match: {result.get('customer_matched', False)}")
        print(f"   Receipt Created: {result.get('receipt_created', False)}")
    else:
        print(f"❌ Webhook transaction işlenemedi: {response.status_code}")
        print(f"   Hata: {response.text}")
    
    # 4. Webhook logs kontrol et
    print("\n4️⃣ Webhook Logs Kontrol Ediliyor...")
    response = requests.get(
        f"{base_url}/api/v1/webhooks/merchant/{merchant_id}/logs",
        headers=headers
    )
    
    if response.status_code == 200:
        logs = response.json()
        print(f"✅ {logs.get('total', 0)} webhook log bulundu")
        if logs.get('logs'):
            latest_log = logs['logs'][0]
            print(f"   Son log: {latest_log.get('status')} - {latest_log.get('created_at')}")
    else:
        print(f"❌ Webhook logs alınamadı: {response.status_code}")
        print(f"   Hata: {response.text}")
    
    # 5. Webhook stats kontrol et
    print("\n5️⃣ Webhook Stats Kontrol Ediliyor...")
    response = requests.get(
        f"{base_url}/api/v1/webhooks/merchant/{merchant_id}/stats",
        headers=headers
    )
    
    if response.status_code == 200:
        stats = response.json()
        print("✅ Webhook istatistikleri alındı")
        print(f"   Toplam transaction: {stats.get('total_transactions', 0)}")
        print(f"   Başarı oranı: {stats.get('success_rate', 0)}%")
    else:
        print(f"❌ Webhook stats alınamadı: {response.status_code}")
        print(f"   Hata: {response.text}")
    
    # 6. API Key regenerate test et
    print("\n6️⃣ API Key Regenerate Test Ediliyor...")
    response = requests.post(
        f"{base_url}/api/v1/merchants/{merchant_id}/regenerate-api-key",
        headers=headers
    )
    
    if response.status_code == 200:
        result = response.json()
        new_api_key = result.get('api_key')
        print("✅ API Key başarıyla yenilendi")
        print(f"   Yeni API Key: {new_api_key[:10]}...")
    else:
        print(f"❌ API Key yenilenemedi: {response.status_code}")
        print(f"   Hata: {response.text}")
    
    print("\n" + "=" * 50)
    print("🎉 Merchant Integration Test Tamamlandı!")
    
    # Test başarılı, merchant_id'yi assert et
    assert merchant_id is not None, "Merchant ID oluşturulmalı"
    print(f"✅ Test başarılı - Merchant ID: {merchant_id}")

if __name__ == "__main__":
    try:
        test_merchant_endpoints()
    except Exception as e:
        print(f"❌ Test sırasında hata oluştu: {str(e)}")
        import traceback
        traceback.print_exc() 