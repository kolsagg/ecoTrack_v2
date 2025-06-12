# -*- coding: utf-8 -*-
"""
EcoTrack FastAPI Backend Test Script

Bu script, EcoTrack API endpoint'lerini test etmek için kullanılır.
Çalıştırmadan önce:
1. `pip install requests` komutu ile requests kütüphanesini yükleyin.
2. Aşağıdaki 'CONFIGURATION' bölümünü kendi API adresiniz ve test kullanıcısı
   bilgilerinizle güncelleyin.
3. Testlere başlamadan önce FastAPI sunucunuzun çalıştığından emin olun.
"""
import requests
import json
import os
from datetime import datetime, timedelta

# --- CONFIGURATION ---
BASE_URL = "http://localhost:8000/api/v1"  # API'nizin temel adresi
TEST_USER_EMAIL = "emrekolunsag@gmail.com"    # Test kullanıcınızın e-postası
TEST_USER_PASSWORD = "123Qweasd"      # Test kullanıcınızın şifresi

# Global değişkenler
TOKEN = None
HEADERS = {"Content-Type": "application/json"}

# --- HELPERS FOR PRETTY PRINTING ---
def print_header(title):
    """Bölüm başlığı yazdırır."""
    print("\n" + "="*80)
    print(f"  🧪  {title.upper()}")
    print("="*80)

def print_request(method, endpoint):
    """Yapılan isteği yazdırır."""
    print(f"\n▶️  {method.upper()} {BASE_URL}{endpoint}")

def print_response(response):
    """API yanıtını formatlı bir şekilde yazdırır."""
    status_code = response.status_code
    color_start = ""
    color_end = "\033[0m"

    if 200 <= status_code < 300:
        color_start = "\033[92m" # Yeşil
        status = "SUCCESS"
    elif 400 <= status_code < 500:
        color_start = "\033[93m" # Sarı
        status = "CLIENT ERROR"
    else:
        color_start = "\033[91m" # Kırmızı
        status = "SERVER ERROR"

    print(f"{color_start}◀️  {status} {status_code} {response.reason}{color_end}")
    
    try:
        # Yanıtı JSON olarak formatla
        response_json = response.json()
        print(json.dumps(response_json, indent=2, ensure_ascii=False))
        return 200 <= status_code < 300
    except json.JSONDecodeError:
        # JSON değilse, metin olarak yazdır
        print(response.text)
        return False

# --- TEST FUNCTIONS ---

def test_auth():
    """Kimlik doğrulama endpoint'lerini test eder."""
    global TOKEN, HEADERS
    print_header("Authentication Tests")

    # 1. Register (opsiyonel, kullanıcı zaten varsa hata verir, bu normal)
    print_request("POST", "/auth/register")
    reg_data = {
        "email": f"new_test_{datetime.now().strftime('%f')}@example.com",
        "password": "newpassword123",
        "first_name": "New",
        "last_name": "User"
    }
    # requests.post(f"{BASE_URL}/auth/register", json=reg_data)

    # 2. Login
    print_request("POST", "/auth/login")
    login_data = {"email": TEST_USER_EMAIL, "password": TEST_USER_PASSWORD}
    response = requests.post(f"{BASE_URL}/auth/login", json=login_data)
    
    if print_response(response):
        TOKEN = response.json().get("access_token")
        HEADERS["Authorization"] = f"Bearer {TOKEN}"
        print("\n✅ Token received and stored for subsequent requests.")
    else:
        print("\n❌ Login failed. Cannot proceed with authenticated tests.")
        TOKEN = None

def test_expenses_and_categories():
    """Harcama ve kategori endpoint'lerini test eder."""
    if not TOKEN:
        print("\n❌ Skipping Expense/Category tests: No valid token.")
        return

    print_header("Expenses and Categories Tests")
    
    created_category_id = None
    created_expense_id = None
    
    try:
        # 1. Kategorileri listele
        print_request("GET", "/categories")
        response = requests.get(f"{BASE_URL}/categories", headers=HEADERS)
        print_response(response)

        # 2. Yeni bir kategori oluştur
        print_request("POST", "/categories")
        category_data = {"name": f"Test Category {datetime.now().strftime('%H%M%S')}"}
        response = requests.post(f"{BASE_URL}/categories", headers=HEADERS, json=category_data)
        if print_response(response):
            created_category_id = response.json().get("id")

        if not created_category_id:
            print("❌ Category creation failed, cannot proceed with expense tests.")
            return

        # 3. Yeni bir harcama oluştur
        print_request("POST", "/expenses")
        expense_data = {
            "merchant_name": "Test Cafe",
            "expense_date": datetime.now().isoformat(),
            "notes": "Test expense from script",
            "items": [
                {
                    "category_id": created_category_id,
                    "item_name": "Test Coffee",
                    "amount": 25.50,
                    "quantity": 1
                }
            ]
        }
        response = requests.post(f"{BASE_URL}/expenses", headers=HEADERS, json=expense_data)
        if print_response(response):
            created_expense_id = response.json().get("id")

        # 4. Harcamaları listele
        print_request("GET", "/expenses?limit=5")
        response = requests.get(f"{BASE_URL}/expenses?limit=5", headers=HEADERS)
        print_response(response)

        # 5. Tek bir harcamayı getir
        if created_expense_id:
            print_request("GET", f"/expenses/{created_expense_id}")
            response = requests.get(f"{BASE_URL}/expenses/{created_expense_id}", headers=HEADERS)
            print_response(response)

    finally:
        # 6. Temizlik: Oluşturulan harcamayı ve kategoriyi sil
        if created_expense_id:
            print_header("Cleaning up created expense")
            print_request("DELETE", f"/expenses/{created_expense_id}")
            response = requests.delete(f"{BASE_URL}/expenses/{created_expense_id}", headers=HEADERS)
            print_response(response)

        if created_category_id:
            print_header("Cleaning up created category")
            print_request("DELETE", f"/categories/{created_category_id}")
            response = requests.delete(f"{BASE_URL}/categories/{created_category_id}", headers=HEADERS)
            print_response(response)

def test_ai_analysis():
    """AI Analiz endpoint'lerini test eder."""
    if not TOKEN:
        print("\n❌ Skipping AI Analysis tests: No valid token.")
        return
    
    print_header("AI Analysis and Suggestions Tests")

    endpoints_to_test = [
        "/ai/analytics/summary",
        "/ai/suggestions/savings",
        "/ai/suggestions/budget",
        "/ai/analysis/recurring-expenses",
    ]
    
    for endpoint in endpoints_to_test:
        print_request("GET", f"{endpoint}")
        # Note the prefix difference from the router file
        response = requests.get(f"{BASE_URL}{endpoint}", headers=HEADERS)
        print_response(response)

def test_reporting():
    """Raporlama endpoint'lerini test eder."""
    if not TOKEN:
        print("\n❌ Skipping Reporting tests: No valid token.")
        return

    print_header("Reporting Tests")

    # 1. Spending Distribution
    print_request("GET", "/reports/spending-distribution?distribution_type=category")
    response = requests.get(f"{BASE_URL}/reports/spending-distribution?distribution_type=category", headers=HEADERS)
    print_response(response)
    
    # 2. Dashboard
    print_request("GET", "/reports/dashboard")
    response = requests.get(f"{BASE_URL}/reports/dashboard", headers=HEADERS)
    print_response(response)
    
    # 3. Budget vs Actual
    start_date = (datetime.now() - timedelta(days=30)).strftime('%Y-%m-%d')
    end_date = datetime.now().strftime('%Y-%m-%d')
    print_request("GET", f"/reports/budget-vs-actual?period_start={start_date}&period_end={end_date}")
    response = requests.get(f"{BASE_URL}/reports/budget-vs-actual?period_start={start_date}&period_end={end_date}", headers=HEADERS)
    print_response(response)

def main_menu():
    """Kullanıcı için test menüsünü gösterir."""
    while True:
        print("\n" + "-"*40)
        print("  EcoTrack API Test Menu")
        print("-"*40)
        print("1. Run All Tests")
        print("2. Test Authentication (Login)")
        print("3. Test Expenses & Categories (Requires Login)")
        print("4. Test AI Analysis (Requires Login)")
        print("5. Test Reporting (Requires Login)")
        print("0. Exit")
        print("-"*40)
        
        choice = input("Enter your choice: ")
        
        if choice == '1':
            test_auth()
            test_expenses_and_categories()
            test_ai_analysis()
            test_reporting()
        elif choice == '2':
            test_auth()
        elif choice == '3':
            if not TOKEN: test_auth()
            if TOKEN: test_expenses_and_categories()
        elif choice == '4':
            if not TOKEN: test_auth()
            if TOKEN: test_ai_analysis()
        elif choice == '5':
            if not TOKEN: test_auth()
            if TOKEN: test_reporting()
        elif choice == '0':
            print("Exiting test script. Goodbye!")
            break
        else:
            print("Invalid choice. Please try again.")

if __name__ == "__main__":
    # Windows'ta renk kodlarının çalışması için
    if os.name == 'nt':
        os.system('color')
    
    main_menu()