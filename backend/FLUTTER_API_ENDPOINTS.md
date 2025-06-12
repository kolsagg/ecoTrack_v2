# EcoTrack API Endpoints - Flutter Kullanım Rehberi

## 📋 Mevcut Endpoint'ler

Backend'de toplam **45+ endpoint** bulunmaktadır. İşte kategorilere göre gruplandırılmış liste:

## 🏥 Health Check Endpoints

### 1. Temel Sağlık Kontrolü
```dart
// GET /health
Future<Map<String, dynamic>> checkHealth() async {
  final response = await http.get(Uri.parse('$baseUrl/health'));
  return jsonDecode(response.body);
}
```

### 2. Detaylı Sağlık Kontrolü
```dart
// GET /health/detailed
Future<Map<String, dynamic>> checkDetailedHealth() async {
  final response = await http.get(Uri.parse('$baseUrl/health/detailed'));
  return jsonDecode(response.body);
}
```

### 3. Veritabanı Sağlık Kontrolü
```dart
// GET /health/database
Future<Map<String, dynamic>> checkDatabaseHealth() async {
  final response = await http.get(Uri.parse('$baseUrl/health/database'));
  return jsonDecode(response.body);
}
```

## 🔐 Authentication Endpoints

### 1. Giriş Yap
```dart
// POST /api/v1/auth/login
Future<Map<String, dynamic>> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Login failed: ${response.body}');
  }
}

// Kullanım örneği:
try {
  final result = await login('user@example.com', 'password123');
  final token = result['access_token'];
  final user = result['user'];
  // Token'ı kaydet ve ana sayfaya yönlendir
} catch (e) {
  // Hata mesajını göster
  print('Login error: $e');
}
```

### 2. Kayıt Ol
```dart
// POST /api/v1/auth/register
Future<Map<String, dynamic>> register(String email, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/auth/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );
  
  if (response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Registration failed: ${response.body}');
  }
}
```

### 3. Şifre Sıfırlama
```dart
// POST /api/v1/auth/reset-password
Future<void> resetPassword(String email) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/auth/reset-password'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email}),
  );
  
  if (response.statusCode != 200) {
    throw Exception('Password reset failed: ${response.body}');
  }
}
```

### 4. MFA (Multi-Factor Authentication)
```dart
// GET /api/v1/auth/mfa/status
Future<Map<String, dynamic>> getMfaStatus() async {
  final token = await getAuthToken();
  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/auth/mfa/status'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  return jsonDecode(response.body);
}

// POST /api/v1/auth/mfa/totp/create
Future<Map<String, dynamic>> createTotpMfa() async {
  final token = await getAuthToken();
  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/auth/mfa/totp/create'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  return jsonDecode(response.body);
}

// POST /api/v1/auth/mfa/totp/verify
Future<Map<String, dynamic>> verifyTotpMfa(String code) async {
  final token = await getAuthToken();
  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/auth/mfa/totp/verify'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'code': code}),
  );
  return jsonDecode(response.body);
}

// DELETE /api/v1/auth/account
Future<void> deleteAccount() async {
  final token = await getAuthToken();
  final response = await http.delete(
    Uri.parse('$baseUrl/api/v1/auth/account'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode != 200) {
    throw Exception('Account deletion failed: ${response.body}');
  }
}
```

## 🧾 Receipt Endpoints

### 1. QR Kod Tarama
```dart
// POST /api/v1/receipts/scan
Future<Map<String, dynamic>> scanReceipt(String qrData) async {
  final token = await getAuthToken();
  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/receipts/scan'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'qr_data': qrData}),
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('QR scan failed: ${response.body}');
  }
}

// Kullanım örneği:
try {
  final scannedData = await scanReceipt(qrCodeResult);
  final receipt = scannedData['receipt'];
  final items = scannedData['items'];
  // Fiş verilerini UI'da göster
} catch (e) {
  // QR kod geçersiz veya hata
  showErrorDialog('QR kod okunamadı: $e');
}
```

### 2. Fişleri Listele
```dart
// GET /api/v1/receipts
Future<List<Map<String, dynamic>>> getReceipts({
  int? limit,
  int? offset,
}) async {
  final token = await getAuthToken();
  String url = '$baseUrl/api/v1/receipts?';
  
  if (limit != null) url += 'limit=$limit&';
  if (offset != null) url += 'offset=$offset&';
  
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['receipts']);
  } else {
    throw Exception('Failed to load receipts: ${response.body}');
  }
}

// Kullanım örneği:
final receipts = await getReceipts(limit: 20, offset: 0);
// ListView'da göster
```

### 3. Fiş Detayı
```dart
// GET /api/v1/receipts/{receipt_id}
Future<Map<String, dynamic>> getReceiptDetail(String receiptId) async {
  final token = await getAuthToken();
  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/receipts/$receiptId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load receipt: ${response.body}');
  }
}
```

## 💰 Expense Endpoints

### 1. Harcama Oluştur
```dart
// POST /api/v1/expenses
Future<Map<String, dynamic>> createExpense({
  required String description,
  required double amount,
  required String categoryId,
  String? merchantId,
  String? receiptId,
  Map<String, dynamic>? metadata,
}) async {
  final token = await getAuthToken();
  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/expenses'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'description': description,
      'amount': amount,
      'category_id': categoryId,
      if (merchantId != null) 'merchant_id': merchantId,
      if (receiptId != null) 'receipt_id': receiptId,
      if (metadata != null) 'metadata': metadata,
    }),
  );
  
  if (response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to create expense: ${response.body}');
  }
}

// Kullanım örneği:
try {
  final expense = await createExpense(
    description: 'Market alışverişi',
    amount: 125.50,
    categoryId: 'cat_food_123',
    merchantId: 'merchant_migros_456',
  );
  showSuccessMessage('Harcama kaydedildi');
} catch (e) {
  showErrorMessage('Harcama kaydedilemedi: $e');
}
```

### 2. Harcamaları Listele
```dart
// GET /api/v1/expenses
Future<List<Map<String, dynamic>>> getExpenses({
  int? limit,
  int? offset,
  String? category,
  String? startDate,
  String? endDate,
}) async {
  final token = await getAuthToken();
  String url = '$baseUrl/api/v1/expenses?';
  
  if (limit != null) url += 'limit=$limit&';
  if (offset != null) url += 'offset=$offset&';
  if (category != null) url += 'category=$category&';
  if (startDate != null) url += 'start_date=$startDate&';
  if (endDate != null) url += 'end_date=$endDate&';
  
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['expenses']);
  } else {
    throw Exception('Failed to load expenses: ${response.body}');
  }
}
```

### 3. Harcama Güncelle
```dart
// PUT /api/v1/expenses/{expense_id}
Future<Map<String, dynamic>> updateExpense(
  String expenseId,
  Map<String, dynamic> updates,
) async {
  final token = await getAuthToken();
  final response = await http.put(
    Uri.parse('$baseUrl/api/v1/expenses/$expenseId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(updates),
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to update expense: ${response.body}');
  }
}
```

### 4. Harcama Sil
```dart
// DELETE /api/v1/expenses/{expense_id}
Future<void> deleteExpense(String expenseId) async {
  final token = await getAuthToken();
  final response = await http.delete(
    Uri.parse('$baseUrl/api/v1/expenses/$expenseId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode != 204) {
    throw Exception('Failed to delete expense: ${response.body}');
  }
}
```

## 📂 Category Endpoints

### 1. Kategorileri Listele
```dart
// GET /api/v1/categories
Future<List<Map<String, dynamic>>> getCategories() async {
  final token = await getAuthToken();
  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/categories'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['categories']);
  } else {
    throw Exception('Failed to load categories: ${response.body}');
  }
}

// Kullanım örneği:
final categories = await getCategories();
// Dropdown'da göster
```

### 2. Kategori Oluştur
```dart
// POST /api/v1/categories
Future<Map<String, dynamic>> createCategory({
  required String name,
  String? description,
  String? color,
  String? icon,
}) async {
  final token = await getAuthToken();
  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/categories'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'name': name,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
    }),
  );
  
  if (response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to create category: ${response.body}');
  }
}
```

## 🤖 AI Analysis Endpoints

### 1. Harcama Özeti
```dart
// GET /api/v1/ai/analytics/summary
Future<Map<String, dynamic>> getSpendingSummary({
  String period = 'month',
}) async {
  final token = await getAuthToken();
  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/ai/analytics/summary?period=$period'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to get spending summary: ${response.body}');
  }
}

// Kullanım örneği:
final summary = await getSpendingSummary(period: 'month');
final totalSpent = summary['total_spent'];
final categoryBreakdown = summary['category_breakdown'];
// Dashboard'da göster
```

### 2. Tasarruf Önerileri
```dart
// GET /api/v1/ai/suggestions/savings
Future<List<Map<String, dynamic>>> getSavingSuggestions() async {
  final token = await getAuthToken();
  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/ai/suggestions/savings'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['suggestions']);
  } else {
    throw Exception('Failed to get saving suggestions: ${response.body}');
  }
}

// Kullanım örneği:
final suggestions = await getSavingSuggestions();
// ListView'da önerileri göster
```

### 3. Bütçe Önerileri
```dart
// GET /api/v1/ai/suggestions/budget
Future<Map<String, dynamic>> getBudgetSuggestions() async {
  final token = await getAuthToken();
  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/ai/suggestions/budget'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to get budget suggestions: ${response.body}');
  }
}
```

### 4. Harcama Kalıpları Analizi
```dart
// POST /api/v1/ai/analysis/spending-patterns
Future<Map<String, dynamic>> analyzeSpendingPatterns({
  String period = 'month',
}) async {
  final token = await getAuthToken();
  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/ai/analysis/spending-patterns'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'period': period}),
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to analyze spending patterns: ${response.body}');
  }
}

### 5. Gelişmiş AI Analizi
```dart
// GET /api/v1/ai/analysis/advanced
Future<Map<String, dynamic>> getAdvancedAnalysis() async {
  final token = await getAuthToken();
  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/ai/analysis/advanced'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to get advanced analysis: ${response.body}');
  }
}

### 6. Tekrarlayan Harcama Analizi
```dart
// GET /api/v1/ai/analysis/recurring-expenses
Future<Map<String, dynamic>> getRecurringExpenses() async {
  final token = await getAuthToken();
  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/ai/analysis/recurring-expenses'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to get recurring expenses: ${response.body}');
  }
}
```

## 📊 Reports Endpoints

### 1. Dashboard Verileri
```dart
// GET /api/v1/reports/dashboard
Future<Map<String, dynamic>> getDashboardData({
  String period = 'month',
}) async {
  final token = await getAuthToken();
  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/reports/dashboard?period=$period'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to get dashboard data: ${response.body}');
  }
}

// Kullanım örneği:
final dashboardData = await getDashboardData(period: 'month');
final totalExpenses = dashboardData['total_expenses'];
final topCategories = dashboardData['top_categories'];
final monthlyTrend = dashboardData['monthly_trend'];
```

### 2. Harcama Dağılımı
```dart
// GET /api/v1/reports/spending-distribution
// POST /api/v1/reports/spending-distribution (with filters)
Future<Map<String, dynamic>> getSpendingDistribution({
  String? startDate,
  String? endDate,
  String groupBy = 'category',
  List<String>? categories,
  double? minAmount,
  double? maxAmount,
}) async {
  final token = await getAuthToken();
  
  if (startDate != null || endDate != null || categories != null || minAmount != null || maxAmount != null) {
    // POST request for complex filtering
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/reports/spending-distribution'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'group_by': groupBy,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        if (categories != null) 'categories': categories,
        if (minAmount != null) 'min_amount': minAmount,
        if (maxAmount != null) 'max_amount': maxAmount,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get spending distribution: ${response.body}');
    }
  } else {
    // GET request for simple filtering
    String url = '$baseUrl/api/v1/reports/spending-distribution?group_by=$groupBy';
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get spending distribution: ${response.body}');
    }
  }
}
```

### 3. Harcama Trendleri
```dart
// GET /api/v1/reports/spending-trends
Future<Map<String, dynamic>> getSpendingTrends({
  String period = 'month',
  int months = 6,
}) async {
  final token = await getAuthToken();
  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/reports/spending-trends?period=$period&months=$months'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to get spending trends: ${response.body}');
  }
}

### 4. Kategori Bazlı Zaman Analizi
```dart
// GET /api/v1/reports/category-spending-over-time
Future<Map<String, dynamic>> getCategorySpendingOverTime({
  String? categoryId,
  String period = 'month',
  int months = 12,
}) async {
  final token = await getAuthToken();
  String url = '$baseUrl/api/v1/reports/category-spending-over-time?period=$period&months=$months';
  
  if (categoryId != null) url += '&category_id=$categoryId';
  
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to get category spending over time: ${response.body}');
  }
}

### 5. Bütçe vs Gerçek Harcama
```dart
// GET /api/v1/reports/budget-vs-actual
Future<Map<String, dynamic>> getBudgetVsActual({
  String period = 'month',
}) async {
  final token = await getAuthToken();
  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/reports/budget-vs-actual?period=$period'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to get budget vs actual: ${response.body}');
  }
}

### 6. Rapor Dışa Aktarma
```dart
// GET /api/v1/reports/export
Future<String> exportReport({
  required String format, // 'pdf', 'excel', 'csv'
  String? startDate,
  String? endDate,
  List<String>? categories,
}) async {
  final token = await getAuthToken();
  String url = '$baseUrl/api/v1/reports/export?format=$format';
  
  if (startDate != null) url += '&start_date=$startDate';
  if (endDate != null) url += '&end_date=$endDate';
  if (categories != null) url += '&categories=${categories.join(',')}';
  
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['download_url']; // Download URL'ini döndür
  } else {
    throw Exception('Failed to export report: ${response.body}');
  }
}
```

## 🏆 Loyalty Program Endpoints

### 1. Sadakat Durumu
```dart
// GET /api/v1/loyalty/status
Future<Map<String, dynamic>> getLoyaltyStatus() async {
  final token = await getAuthToken();
  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/loyalty/status'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to get loyalty status: ${response.body}');
  }
}

// Kullanım örneği:
final loyaltyStatus = await getLoyaltyStatus();
final currentPoints = loyaltyStatus['points'];
final level = loyaltyStatus['level'];
final nextLevelPoints = loyaltyStatus['next_level_points'];
```

### 2. Puan Hesaplama
```dart
// GET /api/v1/loyalty/calculate-points
Future<Map<String, dynamic>> calculatePoints() async {
  final token = await getAuthToken();
  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/loyalty/calculate-points'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to calculate points: ${response.body}');
  }
}

### 3. Puan Geçmişi
```dart
// GET /api/v1/loyalty/history
Future<List<Map<String, dynamic>>> getPointsHistory({
  int? limit,
  int? offset,
}) async {
  final token = await getAuthToken();
  String url = '$baseUrl/api/v1/loyalty/history?';
  
  if (limit != null) url += 'limit=$limit&';
  if (offset != null) url += 'offset=$offset&';
  
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['history']);
  } else {
    throw Exception('Failed to get points history: ${response.body}');
  }
}

### 4. Sadakat Seviyeleri
```dart
// GET /api/v1/loyalty/levels
Future<List<Map<String, dynamic>>> getLoyaltyLevels() async {
  final token = await getAuthToken();
  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/loyalty/levels'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['levels']);
  } else {
    throw Exception('Failed to get loyalty levels: ${response.body}');
  }
}
```

## 📱 Device Management Endpoints

### 1. Cihaz Kaydet
```dart
// POST /api/v1/devices/register
Future<Map<String, dynamic>> registerDevice({
  required String deviceId,
  required String deviceType,
  String? fcmToken,
  Map<String, dynamic>? metadata,
}) async {
  final token = await getAuthToken();
  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/devices/register'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'device_id': deviceId,
      'device_type': deviceType,
      if (fcmToken != null) 'fcm_token': fcmToken,
      if (metadata != null) 'metadata': metadata,
    }),
  );
  
  if (response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to register device: ${response.body}');
  }
}

// Kullanım örneği:
try {
  final deviceInfo = await DeviceInfoPlugin().androidInfo;
  await registerDevice(
    deviceId: deviceInfo.id,
    deviceType: 'android',
    fcmToken: await FirebaseMessaging.instance.getToken(),
  );
} catch (e) {
  print('Device registration failed: $e');
}
```

### 2. Cihazları Listele
```dart
// GET /api/v1/devices/
Future<List<Map<String, dynamic>>> getDevices({
  int? limit,
  int? offset,
}) async {
  final token = await getAuthToken();
  String url = '$baseUrl/api/v1/devices/?';
  
  if (limit != null) url += 'limit=$limit&';
  if (offset != null) url += 'offset=$offset&';
  
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['devices']);
  } else {
    throw Exception('Failed to get devices: ${response.body}');
  }
}
```

### 3. Cihazı Deaktif Et
```dart
// PUT /api/v1/devices/{device_id}/deactivate
Future<void> deactivateDevice(String deviceId) async {
  final token = await getAuthToken();
  final response = await http.put(
    Uri.parse('$baseUrl/api/v1/devices/$deviceId/deactivate'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode != 200) {
    throw Exception('Failed to deactivate device: ${response.body}');
  }
}
```

### 4. Cihazı Sil
```dart
// DELETE /api/v1/devices/{device_id}
Future<void> deleteDevice(String deviceId) async {
  final token = await getAuthToken();
  final response = await http.delete(
    Uri.parse('$baseUrl/api/v1/devices/$deviceId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode != 204) {
    throw Exception('Failed to delete device: ${response.body}');
  }
}
```

## 🏪 Merchant Endpoints

### 1. Mağaza Listesi
```dart
// GET /api/v1/merchants/
Future<List<Map<String, dynamic>>> getMerchants({
  int? limit,
  int? offset,
  String? category,
}) async {
  final token = await getAuthToken();
  String url = '$baseUrl/api/v1/merchants/?';
  
  if (limit != null) url += 'limit=$limit&';
  if (offset != null) url += 'offset=$offset&';
  if (category != null) url += 'category=$category&';
  
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['merchants']);
  } else {
    throw Exception('Failed to load merchants: ${response.body}');
  }
}

### 2. Mağaza Detayı
```dart
// GET /api/v1/merchants/{merchant_id}
Future<Map<String, dynamic>> getMerchantDetail(String merchantId) async {
  final token = await getAuthToken();
  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/merchants/$merchantId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load merchant detail: ${response.body}');
  }
}

### 3. Mağaza Oluştur
```dart
// POST /api/v1/merchants/
Future<Map<String, dynamic>> createMerchant({
  required String name,
  required String category,
  String? description,
  String? website,
  String? phone,
  Map<String, dynamic>? address,
}) async {
  final token = await getAuthToken();
  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/merchants/'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'name': name,
      'category': category,
      if (description != null) 'description': description,
      if (website != null) 'website': website,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
    }),
  );
  
  if (response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to create merchant: ${response.body}');
  }
}
```

## ⭐ Review Endpoints

### 1. Mağaza Değerlendirmesi Yap
```dart
// POST /api/v1/reviews/merchants/{merchant_id}/reviews
Future<Map<String, dynamic>> reviewMerchant({
  required String merchantId,
  required int rating,
  String? comment,
  String? visitDate,
}) async {
  final token = await getAuthToken();
  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/reviews/merchants/$merchantId/reviews'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'rating': rating,
      if (comment != null) 'comment': comment,
      if (visitDate != null) 'visit_date': visitDate,
    }),
  );
  
  if (response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to submit review: ${response.body}');
  }
}

### 2. Mağaza Değerlendirmelerini Listele
```dart
// GET /api/v1/reviews/merchants/{merchant_id}/reviews
Future<Map<String, dynamic>> getMerchantReviews(
  String merchantId, {
  int? limit,
  int? offset,
}) async {
  final token = await getAuthToken();
  String url = '$baseUrl/api/v1/reviews/merchants/$merchantId/reviews?';
  
  if (limit != null) url += 'limit=$limit&';
  if (offset != null) url += 'offset=$offset&';
  
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to get merchant reviews: ${response.body}');
  }
}

### 3. Mağaza Puanı
```dart
// GET /api/v1/reviews/merchants/{merchant_id}/rating
Future<Map<String, dynamic>> getMerchantRating(String merchantId) async {
  final token = await getAuthToken();
  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/reviews/merchants/$merchantId/rating'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to get merchant rating: ${response.body}');
  }
}

### 4. Fiş Değerlendirmesi
```dart
// POST /api/v1/reviews/receipts/{receipt_id}/review
Future<Map<String, dynamic>> reviewReceipt({
  required String receiptId,
  required int rating,
  String? comment,
}) async {
  final token = await getAuthToken();
  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/reviews/receipts/$receiptId/review'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'rating': rating,
      if (comment != null) 'comment': comment,
    }),
  );
  
  if (response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to submit receipt review: ${response.body}');
  }
}
```

## 🔧 Yardımcı Fonksiyonlar

### Auth Token Alma
```dart
Future<String> getAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  if (token == null || token.isEmpty) {
    throw Exception('No auth token found');
  }
  return token;
}
```

### Error Handling
```dart
void handleApiError(dynamic error) {
  if (error.toString().contains('401')) {
    // Token expired, redirect to login
    Navigator.pushReplacementNamed(context, '/login');
  } else if (error.toString().contains('Network')) {
    showErrorDialog('İnternet bağlantısını kontrol edin');
  } else {
    showErrorDialog('Bir hata oluştu: $error');
  }
}
```

### Loading State Management
```dart
class ApiState<T> {
  final bool isLoading;
  final T? data;
  final String? error;
  
  ApiState({this.isLoading = false, this.data, this.error});
  
  ApiState<T> loading() => ApiState<T>(isLoading: true);
  ApiState<T> success(T data) => ApiState<T>(data: data);
  ApiState<T> failure(String error) => ApiState<T>(error: error);
}
```

## 🔗 Webhook Endpoints

### 1. Mağaza İşlem Webhook'u
```dart
// POST /api/v1/webhooks/merchant/{merchant_id}/transaction
// Bu endpoint genellikle backend-to-backend kullanılır
// Flutter'da webhook dinleme için WebSocket kullanabilirsiniz

Future<void> setupWebhookListener() async {
  // WebSocket bağlantısı kurma örneği
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:8000/ws/transactions'),
  );
  
  channel.stream.listen((data) {
    final transaction = jsonDecode(data);
    // Yeni işlem bildirimi
    showNotification('Yeni işlem: ${transaction['amount']} TL');
  });
}
```

### 2. Test İşlemi
```dart
// POST /api/v1/webhooks/merchant/{merchant_id}/test-transaction
Future<Map<String, dynamic>> testMerchantWebhook(String merchantId) async {
  final token = await getAuthToken();
  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/webhooks/merchant/$merchantId/test-transaction'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to test webhook: ${response.body}');
  }
}
```

### 3. Webhook Logları
```dart
// GET /api/v1/webhooks/merchant/{merchant_id}/logs
Future<List<Map<String, dynamic>>> getWebhookLogs(
  String merchantId, {
  int? limit,
  int? offset,
}) async {
  final token = await getAuthToken();
  String url = '$baseUrl/api/v1/webhooks/merchant/$merchantId/logs?';
  
  if (limit != null) url += 'limit=$limit&';
  if (offset != null) url += 'offset=$offset&';
  
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['logs']);
  } else {
    throw Exception('Failed to get webhook logs: ${response.body}');
  }
}
```

## 🔧 Yardımcı Fonksiyonlar

### Auth Token Alma
```dart
Future<String> getAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  if (token == null || token.isEmpty) {
    throw Exception('No auth token found');
  }
  return token;
}
```

### Error Handling
```dart
void handleApiError(dynamic error) {
  if (error.toString().contains('401')) {
    // Token expired, redirect to login
    Navigator.pushReplacementNamed(context, '/login');
  } else if (error.toString().contains('Network')) {
    showErrorDialog('İnternet bağlantısını kontrol edin');
  } else {
    showErrorDialog('Bir hata oluştu: $error');
  }
}
```

### Loading State Management
```dart
class ApiState<T> {
  final bool isLoading;
  final T? data;
  final String? error;
  
  ApiState({this.isLoading = false, this.data, this.error});
  
  ApiState<T> loading() => ApiState<T>(isLoading: true);
  ApiState<T> success(T data) => ApiState<T>(data: data);
  ApiState<T> failure(String error) => ApiState<T>(error: error);
}
```

Bu rehber, EcoTrack backend'indeki tüm endpoint'lerin Flutter'da nasıl kullanılacağını detaylı olarak göstermektedir. Her endpoint için örnek kod ve kullanım senaryoları verilmiştir. 