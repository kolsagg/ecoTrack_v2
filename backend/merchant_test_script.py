#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
EcoTrack Merchant Webhook Test Script

Bu script, EcoTrack'in merchant webhook endpoint'lerini test etmek için kullanılır.
Terminal üzerinden farklı senaryoları test edebilirsiniz.

Kullanım:
    python merchant_test_script.py
    
Gereksinimler:
    pip install requests python-dotenv supabase
    
Environment Variables (.env dosyasında):
    SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
"""

import os
import requests
import json
import hashlib
import secrets
import argparse
from datetime import datetime, timezone
from typing import Dict, Any, Optional
from dotenv import load_dotenv

# Environment variables'ları yükle
load_dotenv()

# --- CONFIGURATION ---
BASE_URL = "http://localhost:8000"
API_BASE = f"{BASE_URL}/api/v1"

# Test Merchant Bilgileri (Gerçek değerlerle değiştirin)
TEST_MERCHANT_ID = "249c3c2c-50e8-4502-a625-dcd5c393361e"
TEST_MERCHANT_API_KEY = "mk_18c48da1b948d44405aa304a6422819d"

# Test kullanıcı bilgileri (sistemde kayıtlı olması gereken)
REGISTERED_USER_EMAIL = "emrekolunsag@gmail.com"

# Supabase Service Role Key (Admin işlemler için)
SUPABASE_SERVICE_ROLE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY", "")

class MerchantWebhookTester:
    def __init__(self):
        self.merchant_id = TEST_MERCHANT_ID
        self.api_key = TEST_MERCHANT_API_KEY
        self.base_url = API_BASE
        self.service_role_key = SUPABASE_SERVICE_ROLE_KEY
        
    def print_header(self, title: str):
        """Bölüm başlığı yazdırır"""
        print("\n" + "="*80)
        print(f"  🏪  {title.upper()}")
        print("="*80)
    
    def print_request(self, method: str, endpoint: str):
        """Yapılan isteği yazdırır"""
        print(f"\n▶️  {method.upper()} {endpoint}")
    
    def print_response(self, response: requests.Response) -> bool:
        """API yanıtını formatlı yazdırır"""
        status_code = response.status_code
        
        if 200 <= status_code < 300:
            color = "\033[92m"  # Yeşil
            status = "SUCCESS"
        elif 400 <= status_code < 500:
            color = "\033[93m"  # Sarı
            status = "CLIENT ERROR"
        else:
            color = "\033[91m"  # Kırmızı
            status = "SERVER ERROR"
        
        print(f"{color}◀️  {status} {status_code} {response.reason}\033[0m")
        
        try:
            response_json = response.json()
            print(json.dumps(response_json, indent=2, ensure_ascii=False))
            return 200 <= status_code < 300
        except json.JSONDecodeError:
            print(response.text)
            return False
    
    def hash_card_number(self, card_number: str) -> str:
        """Kart numarasını güvenli şekilde hash'ler"""
        clean_card = card_number.replace(' ', '').replace('-', '')
        return hashlib.sha256(clean_card.encode()).hexdigest()
    
    def generate_transaction_id(self) -> str:
        """Benzersiz işlem ID'si oluşturur"""
        return f"TXN-{datetime.now().strftime('%Y%m%d')}-{secrets.token_hex(6).upper()}"
    
    def create_sample_items(self) -> list:
        """Örnek alışveriş ürünleri oluşturur"""
        return [
            {
                "description": "Americano Kahve",
                "quantity": 2,
                "unit_price": 18.50,
                "total_price": 37.00,
                "category": "beverage"
            },
            {
                "description": "Croissant",
                "quantity": 1,
                "unit_price": 25.50,
                "total_price": 25.50,
                "category": "food"
            },
            {
                "description": "Servis Ücreti",
                "quantity": 1,
                "unit_price": 5.00,
                "total_price": 5.00,
                "category": "service"
            }
        ]
    
    def create_transaction_data(self, scenario: str) -> Dict[str, Any]:
        """Senaryo'ya göre işlem verisi oluşturur"""
        items = self.create_sample_items()
        total_amount = sum(item["total_price"] for item in items)
        
        transaction_data = {
            "transaction_id": self.generate_transaction_id(),
            "merchant_transaction_id": f"POS-{secrets.token_hex(4).upper()}",
            "total_amount": total_amount,
            "currency": "TRY",
            "transaction_date": datetime.now(timezone.utc).isoformat(),
            "items": items,
            "payment_method": "credit_card",
            "receipt_number": f"RC-{datetime.now().strftime('%Y%m%d')}-{secrets.randbelow(9999):04d}",
            "cashier_id": "CASHIER_001",
            "store_location": "Kadıköy Şubesi",
            "additional_data": {
                "pos_terminal_id": "TERM_12345",
                "promotion_code": None,
                "loyalty_points_earned": 15
            }
        }
        
        # Senaryo'ya göre müşteri bilgisi
        if scenario == "registered":
            transaction_data["customer_info"] = {
                "email": REGISTERED_USER_EMAIL,
                "phone": "+905551234567",  # phone field'ını ekliyoruz
                "card_hash": self.hash_card_number("4532 1234 5678 9012"),
                "card_last_four": "9012",
                "card_type": "visa"
            }
            print("🧑‍💼 Senaryo: Kayıtlı müşteri (email ile eşleştirme bekleniyor)")
            
        elif scenario == "unregistered":
            transaction_data["customer_info"] = {
                "email": f"yeni.musteri.{secrets.token_hex(4)}@example.com",
                "phone": "+905559876543",
                "card_hash": self.hash_card_number("5555 4444 3333 2222"),
                "card_last_four": "2222",
                "card_type": "mastercard"
            }
            print("❌ Senaryo: Kayıtsız müşteri (eşleştirme başarısız olacak)")
            
        elif scenario == "no-customer-info":
            transaction_data["customer_info"] = {}
            print("📄 Senaryo: Müşteri bilgisi yok (halka açık fiş oluşturulacak)")
            
        else:
            raise ValueError(f"Geçersiz senaryo: {scenario}")
        
        return transaction_data
    
    def get_admin_headers(self) -> Dict[str, str]:
        """Admin işlemler için header'ları döndürür"""
        if not self.service_role_key:
            raise ValueError(
                "❌ SUPABASE_SERVICE_ROLE_KEY environment variable eksik!\n"
                "Lütfen .env dosyasında bu değişkeni ayarlayın:\n"
                "SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here"
            )
        
        return {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.service_role_key}",
            "User-Agent": "EcoTrack-Admin-Test/1.0"
        }
    
    def test_webhook_transaction(self, scenario: str):
        """Webhook işlemini test eder"""
        self.print_header(f"Merchant Webhook Test - {scenario.title()}")
        
        # İşlem verisi oluştur
        transaction_data = self.create_transaction_data(scenario)
        
        # Endpoint URL
        endpoint = f"/webhooks/merchant/{self.merchant_id}/transaction"
        url = f"{self.base_url}{endpoint}"
        
        # Headers
        headers = {
            "Content-Type": "application/json",
            "X-API-Key": self.api_key,
            "User-Agent": "EcoTrack-POS-System/1.0"
        }
        
        self.print_request("POST", endpoint)
        print(f"🏪 Merchant ID: {self.merchant_id}")
        print(f"💳 Toplam Tutar: {transaction_data['total_amount']} TRY")
        print(f"🛍️  Ürün Sayısı: {len(transaction_data['items'])}")
        
        # Ürünleri listele
        print("\n📦 Satın Alınan Ürünler:")
        for i, item in enumerate(transaction_data['items'], 1):
            print(f"  {i}. {item['description']} - {item['quantity']}x {item['unit_price']} TRY = {item['total_price']} TRY")
        
        # API çağrısı yap
        try:
            response = requests.post(url, json=transaction_data, headers=headers)
            success = self.print_response(response)
            
            if success:
                result = response.json()
                self.print_success_details(result)
            else:
                self.print_error_details(response.status_code, response.text)
                
        except requests.RequestException as e:
            print(f"\n❌ Bağlantı Hatası: {str(e)}")
            print("🔧 Sunucunun çalıştığından emin olun")
    
    def print_success_details(self, result: Dict[str, Any]):
        """Başarılı sonuç detaylarını yazdırır"""
        print(f"\n✅ İşlem Başarılı!")
        print(f"📄 Mesaj: {result.get('message', 'N/A')}")
        print(f"🆔 İşlem ID: {result.get('transaction_id', 'N/A')}")
        print(f"⏱️  İşlem Süresi: {result.get('processing_time_ms', 'N/A')} ms")
        
        if result.get('matched_user_id'):
            print(f"👤 Eşleşen Kullanıcı: {result['matched_user_id']}")
            print(f"🧾 Oluşturulan Fiş ID: {result.get('created_receipt_id', 'N/A')}")
            print(f"💰 Oluşturulan Masraf ID: {result.get('created_expense_id', 'N/A')}")
        elif result.get('is_public_receipt'):
            print(f"🌐 Halka Açık Fiş Oluşturuldu")
            print(f"🧾 Fiş ID: {result.get('created_receipt_id', 'N/A')}")
            print(f"🔗 Görüntüleme URL'i: {result.get('public_url', 'N/A')}")
    
    def print_error_details(self, status_code: int, error_text: str):
        """Hata detaylarını yazdırır"""
        print(f"\n❌ İşlem Başarısız!")
        print(f"🔢 HTTP Status: {status_code}")
        
        try:
            error_data = json.loads(error_text)
            print(f"📄 Hata Mesajı: {error_data.get('detail', error_text)}")
        except:
            print(f"📄 Ham Hata: {error_text}")
        
        # Yaygın hataların açıklamaları
        if status_code == 401:
            print("🔑 API anahtarınız geçersiz olabilir")
        elif status_code == 404:
            print("🏪 Merchant bulunamadı")
        elif status_code == 403:
            print("🚫 Merchant hesabı aktif değil")
        elif status_code >= 500:
            print("🔧 Sunucu hatası - logları kontrol edin")
    
    def test_webhook_logs(self):
        """Webhook loglarını test eder (Supabase Admin Client kullanarak)"""
        self.print_header("Webhook Logs Test")
        
        endpoint = f"/webhooks/merchant/{self.merchant_id}/logs"
        url = f"{self.base_url}{endpoint}"
        
        try:
            # Admin headers'ı al
            headers = self.get_admin_headers()
            
            self.print_request("GET", endpoint)
            print("🔑 Admin client (service role) kullanılıyor")
            print(f"🏪 Merchant ID: {self.merchant_id}")
            
            # Query parametreleri ekle
            params = {
                "page": 1,
                "size": 10,
                # "status": "success"  # Opsiyonel: sadece başarılı olanları göster
            }
            
            response = requests.get(url, headers=headers, params=params)
            success = self.print_response(response)
            
            if success:
                result = response.json()
                self.print_logs_details(result)
            else:
                self.print_error_details(response.status_code, response.text)
                
        except ValueError as ve:
            print(f"\n❌ Konfigürasyon Hatası: {str(ve)}")
        except requests.RequestException as e:
            print(f"\n❌ Bağlantı Hatası: {str(e)}")
            print("🔧 Sunucunun çalıştığından emin olun")
    
    def print_logs_details(self, result: Dict[str, Any]):
        """Webhook logs detaylarını yazdırır"""
        logs = result.get('logs', [])
        total = result.get('total', 0)
        page = result.get('page', 1)
        size = result.get('size', 10)
        
        print(f"\n📊 Webhook Logs Özeti:")
        print(f"📋 Toplam Log: {total}")
        print(f"📄 Sayfa: {page}")
        print(f"📊 Sayfa Boyutu: {size}")
        print(f"📈 Gösterilen: {len(logs)}")
        
        if logs:
            print(f"\n📝 Son {len(logs)} Log:")
            for i, log in enumerate(logs, 1):
                status_icon = {
                    'success': '✅',
                    'failed': '❌', 
                    'pending': '⏳',
                    'retry': '🔄'
                }.get(log.get('status', ''), '❓')
                
                print(f"\n  {i}. {status_icon} {log.get('status', 'unknown').upper()}")
                print(f"     🆔 ID: {log.get('id', 'N/A')}")
                print(f"     📝 Transaction: {log.get('transaction_id', 'N/A')}")
                print(f"     ⏱️  Süre: {log.get('processing_time_ms', 'N/A')} ms")
                print(f"     📅 Tarih: {log.get('created_at', 'N/A')}")
                if log.get('error_message'):
                    print(f"     ❌ Hata: {log['error_message']}")
        else:
            print("\n📋 Hiç webhook log bulunamadı")
    
    def test_webhook_stats(self):
        """Webhook istatistiklerini test eder (Supabase Admin Client kullanarak)"""
        self.print_header("Webhook Stats Test")
        
        endpoint = f"/webhooks/merchant/{self.merchant_id}/stats"
        url = f"{self.base_url}{endpoint}"
        
        try:
            # Admin headers'ı al
            headers = self.get_admin_headers()
            
            self.print_request("GET", endpoint)
            print("🔑 Admin client (service role) kullanılıyor")
            print(f"🏪 Merchant ID: {self.merchant_id}")
            
            response = requests.get(url, headers=headers)
            success = self.print_response(response)
            
            if success:
                result = response.json()
                self.print_stats_details(result)
            else:
                self.print_error_details(response.status_code, response.text)
                
        except ValueError as ve:
            print(f"\n❌ Konfigürasyon Hatası: {str(ve)}")
        except requests.RequestException as e:
            print(f"\n❌ Bağlantı Hatası: {str(e)}")
            print("🔧 Sunucunun çalıştığından emin olun")
    
    def print_stats_details(self, result: Dict[str, Any]):
        """Webhook stats detaylarını yazdırır"""
        print(f"\n📊 Webhook İstatistikleri:")
        print(f"🏪 Merchant ID: {result.get('merchant_id', 'N/A')}")
        print(f"📈 Toplam Webhook: {result.get('total_webhooks', 0)}")
        print(f"✅ Başarılı: {result.get('successful_webhooks', 0)}")
        print(f"❌ Başarısız: {result.get('failed_webhooks', 0)}")
        print(f"🔄 Yeniden Deneme: {result.get('retry_webhooks', 0)}")
        print(f"📊 Başarı Oranı: {result.get('success_rate_percentage', 0)}%")
        
        # İşlem süreleri
        avg_time = result.get('avg_processing_time_ms')
        max_time = result.get('max_processing_time_ms')
        min_time = result.get('min_processing_time_ms')
        
        print(f"\n⏱️  İşlem Süreleri:")
        print(f"📊 Ortalama: {avg_time} ms" if avg_time else "📊 Ortalama: N/A")
        print(f"⬆️  En Yüksek: {max_time} ms" if max_time else "⬆️  En Yüksek: N/A")
        print(f"⬇️  En Düşük: {min_time} ms" if min_time else "⬇️  En Düşük: N/A")
        
        # Performans değerlendirmesi
        success_rate = result.get('success_rate_percentage', 0)
        if success_rate >= 95:
            print(f"\n🟢 Performans: Mükemmel ({success_rate}%)")
        elif success_rate >= 85:
            print(f"\n🟡 Performans: İyi ({success_rate}%)")
        elif success_rate >= 70:
            print(f"\n🟠 Performans: Orta ({success_rate}%)")
        else:
            print(f"\n🔴 Performans: Düşük ({success_rate}%)")


def main():
    """Ana menü"""
    tester = MerchantWebhookTester()
    
    # Başlangıç kontrolü
    print("🚀 EcoTrack Merchant Webhook Test Script")
    print("📋 Sunucunun http://localhost:8000 adresinde çalıştığından emin olun")
    print("🔧 TEST_MERCHANT_ID ve TEST_MERCHANT_API_KEY değerlerini güncelleyin")
    
    # Service role key kontrolü
    if not SUPABASE_SERVICE_ROLE_KEY:
        print("\n⚠️  UYARI: SUPABASE_SERVICE_ROLE_KEY environment variable eksik!")
        print("🔑 Logs ve Stats testleri için .env dosyasında bu key'i ayarlayın")
        print("   SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here")
    else:
        print(f"\n✅ Admin client hazır (service role key: {SUPABASE_SERVICE_ROLE_KEY[:20]}...)")
    
    parser = argparse.ArgumentParser(description="EcoTrack Merchant Webhook Test Script")
    parser.add_argument("--scenario", choices=["registered", "unregistered", "no-customer-info"], 
                       help="Test senaryosu seçin")
    parser.add_argument("--all", action="store_true", help="Tüm senaryoları test et")
    parser.add_argument("--logs", action="store_true", help="Webhook loglarını test et")
    parser.add_argument("--stats", action="store_true", help="Webhook istatistiklerini test et")
    
    args = parser.parse_args()
    
    # Komut satırı argümanları varsa onları çalıştır
    if args.scenario:
        tester.test_webhook_transaction(args.scenario)
        return
    
    if args.all:
        for scenario in ["registered", "unregistered", "no-customer-info"]:
            tester.test_webhook_transaction(scenario)
            print("\n" + "-"*40)
        return
    
    if args.logs:
        tester.test_webhook_logs()
        return
    
    if args.stats:
        tester.test_webhook_stats()
        return
    
    # Etkileşimli menü
    while True:
        print("\n" + "-"*50)
        print("  🏪 EcoTrack Merchant Webhook Test Menu")
        print("-"*50)
        print("1. Test Kayıtlı Müşteri Senaryosu")
        print("2. Test Kayıtsız Müşteri Senaryosu") 
        print("3. Test Müşteri Bilgisi Yok Senaryosu")
        print("4. Tüm Senaryoları Test Et")
        print("5. Webhook Loglarını Görüntüle (Admin)")
        print("6. Webhook İstatistiklerini Görüntüle (Admin)")
        print("7. Konfigürasyon Bilgilerini Göster")
        print("0. Çıkış")
        print("-"*50)
        
        choice = input("Seçenek (0-7): ").strip()
        
        if choice == "0":
            print("👋 Görüşürüz!")
            break
        elif choice == "1":
            tester.test_webhook_transaction("registered")
        elif choice == "2":
            tester.test_webhook_transaction("unregistered")
        elif choice == "3":
            tester.test_webhook_transaction("no-customer-info")
        elif choice == "4":
            for scenario in ["registered", "unregistered", "no-customer-info"]:
                tester.test_webhook_transaction(scenario)
                print("\n" + "-"*40)
        elif choice == "5":
            tester.test_webhook_logs()
        elif choice == "6":
            tester.test_webhook_stats()
        elif choice == "7":
            print(f"\n📋 Konfigürasyon:")
            print(f"🔗 Base URL: {BASE_URL}")
            print(f"🏪 Merchant ID: {TEST_MERCHANT_ID}")
            print(f"🔑 API Key: {TEST_MERCHANT_API_KEY[:20]}...")
            print(f"👤 Test User Email: {REGISTERED_USER_EMAIL}")
            
            if SUPABASE_SERVICE_ROLE_KEY:
                print(f"🔑 Service Role Key: {SUPABASE_SERVICE_ROLE_KEY[:20]}...")
                print("✅ Admin işlemler mevcut")
            else:
                print("❌ Service Role Key eksik - Admin işlemler kullanılamaz")
        else:
            print("❌ Geçersiz seçenek. Tekrar deneyin.")


if __name__ == "__main__":
    main() 