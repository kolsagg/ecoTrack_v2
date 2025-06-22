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

def test_monthly_budget_system():
    """Yeni aylık bütçe sistemini test eder."""
    if not TOKEN:
        print("\n❌ Skipping Budget tests: No valid token.")
        return

    print_header("Monthly Budget System Tests")
    
    current_year = datetime.now().year
    current_month = datetime.now().month
    test_year = current_year
    test_month = current_month
    
    try:
        # 1. Mevcut ayın bütçesini kontrol et
        print_request("GET", f"/budget?year={test_year}&month={test_month}")
        response = requests.get(f"{BASE_URL}/budget?year={test_year}&month={test_month}", headers=HEADERS)
        print_response(response)
        
        # 2. Yeni aylık bütçe oluştur
        print_request("POST", "/budget")
        budget_data = {
            "total_monthly_budget": 5000.0,
            "currency": "TRY",
            "auto_allocate": True,
            "year": test_year,
            "month": test_month
        }
        response = requests.post(f"{BASE_URL}/budget", headers=HEADERS, json=budget_data)
        success = print_response(response)
        
        if not success:
            print("❌ Budget creation failed, trying without year/month (current month)")
            budget_data = {
                "total_monthly_budget": 5000.0,
                "currency": "TRY",
                "auto_allocate": False
            }
            response = requests.post(f"{BASE_URL}/budget", headers=HEADERS, json=budget_data)
            print_response(response)
        
        # 3. Bütçe listesini getir
        print_request("GET", "/budget/list")
        response = requests.get(f"{BASE_URL}/budget/list", headers=HEADERS)
        print_response(response)
        
        # 4. Bütçe özetini getir
        print_request("GET", f"/budget/summary?year={test_year}&month={test_month}")
        response = requests.get(f"{BASE_URL}/budget/summary?year={test_year}&month={test_month}", headers=HEADERS)
        print_response(response)
        
        # 5. Kategorileri listele (kategori bütçesi için)
        print_request("GET", "/categories")
        response = requests.get(f"{BASE_URL}/categories", headers=HEADERS)
        categories_response = print_response(response)
        
        if categories_response:
            categories = response.json()  # Doğrudan liste dönüyor
            if categories:
                # İlk kategoriyi kullan
                category_id = categories[0]["id"]
                
                # 6. Kategori bütçesi oluştur
                print_request("POST", f"/budget/categories?year={test_year}&month={test_month}")
                category_budget_data = {
                    "category_id": category_id,
                    "monthly_limit": 500.0,
                    "is_active": True
                }
                response = requests.post(f"{BASE_URL}/budget/categories?year={test_year}&month={test_month}", 
                                       headers=HEADERS, json=category_budget_data)
                print_response(response)
                
                # 7. Kategori bütçelerini listele
                print_request("GET", f"/budget/categories?year={test_year}&month={test_month}")
                response = requests.get(f"{BASE_URL}/budget/categories?year={test_year}&month={test_month}", headers=HEADERS)
                print_response(response)
        
        # 8. Otomatik bütçe dağılımı uygula
        print_request("POST", "/budget/apply-allocation")
        allocation_data = {
            "total_budget": 4000.0,
            "year": test_year,
            "month": test_month
        }
        response = requests.post(f"{BASE_URL}/budget/apply-allocation", headers=HEADERS, json=allocation_data)
        print_response(response)
        
        # 9. Son bütçe özetini getir
        print_request("GET", f"/budget/summary?year={test_year}&month={test_month}")
        response = requests.get(f"{BASE_URL}/budget/summary?year={test_year}&month={test_month}", headers=HEADERS)
        print_response(response)
        
        # 10. Gelecek ay için bütçe oluştur
        next_month = test_month + 1 if test_month < 12 else 1
        next_year = test_year if test_month < 12 else test_year + 1
        
        print_request("POST", "/budget")
        future_budget_data = {
            "total_monthly_budget": 6000.0,
            "currency": "TRY",
            "auto_allocate": False,
            "year": next_year,
            "month": next_month
        }
        response = requests.post(f"{BASE_URL}/budget", headers=HEADERS, json=future_budget_data)
        print_response(response)
        
        # 11. Tüm bütçeleri listele
        print_request("GET", "/budget/list")
        response = requests.get(f"{BASE_URL}/budget/list", headers=HEADERS)
        print_response(response)
        
        print("\n✅ Monthly Budget System test completed!")
        
    except Exception as e:
        print(f"\n❌ Error during budget testing: {e}")

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
        print("2. Test Authentication Only")
        print("3. Test Monthly Budget System Only")
        print("4. Test Expenses & Categories Only")
        print("5. Test Reporting Only")
        print("6. Test Budget Health Check")
        print("0. Exit")
        print("-"*40)
        
        choice = input("Select an option (0-6): ").strip()
        
        if choice == "0":
            print("👋 Goodbye!")
            break
        elif choice == "1":
            test_auth()
            test_monthly_budget_system()
            test_expenses_and_categories()
            test_reporting()
        elif choice == "2":
            test_auth()
        elif choice == "3":
            if not TOKEN:
                test_auth()
            test_monthly_budget_system()
        elif choice == "4":
            if not TOKEN:
                test_auth()
            test_expenses_and_categories()
        elif choice == "5":
            if not TOKEN:
                test_auth()
            test_reporting()
        elif choice == "6":
            print_header("Budget Health Check")
            print_request("GET", "/budget/health")
            response = requests.get(f"{BASE_URL}/budget/health")
            print_response(response)
        else:
            print("❌ Invalid choice. Please try again.")

if __name__ == "__main__":
    print("🚀 EcoTrack API Test Script")
    print("📋 Make sure your FastAPI server is running on http://localhost:8000")
    print("🔑 Update TEST_USER_EMAIL and TEST_USER_PASSWORD in the script if needed")
    
    main_menu()