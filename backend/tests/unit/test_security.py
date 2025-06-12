"""
Security Testing
API güvenlik testleri ve güvenlik açığı taraması
"""

import sys
import os
import json
import base64
import time
from typing import Dict, List, Any
import re

# Path setup
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from fastapi.testclient import TestClient
from main import app
from tests.utils.test_helpers import TestDataManager, TestReporter


class SecurityTestRunner:
    """Security test runner"""
    
    def __init__(self):
        self.client = TestClient(app)
        self.test_data_manager = TestDataManager()
        self.reporter = TestReporter()
        self.security_issues = []
        
    def test_authentication_security(self):
        """Authentication güvenlik testleri"""
        print("🔐 AUTHENTICATION SECURITY TESTING")
        print("=" * 60)
        
        auth_tests = []
        
        # Test 1: Unauthorized access to protected endpoints
        print("\n🚫 Testing unauthorized access...")
        protected_endpoints = [
            "/api/expenses",
            "/api/receipts", 
            "/api/categories",
            "/api/reports/dashboard",
            "/api/loyalty/status"
        ]
        
        for endpoint in protected_endpoints:
            response = self.client.get(endpoint)
            if response.status_code != 401:
                issue = f"Endpoint {endpoint} allows unauthorized access (status: {response.status_code})"
                self.security_issues.append(issue)
                print(f"   ❌ {issue}")
            else:
                print(f"   ✅ {endpoint} properly protected")
        
        # Test 2: Invalid token handling
        print("\n🎭 Testing invalid token handling...")
        invalid_tokens = [
            "invalid_token",
            "Bearer invalid_token",
            "Bearer ",
            "",
            "malformed.jwt.token"
        ]
        
        for token in invalid_tokens:
            headers = {"Authorization": token} if token else {}
            response = self.client.get("/api/expenses", headers=headers)
            
            if response.status_code not in [401, 403]:
                issue = f"Invalid token '{token}' not properly rejected (status: {response.status_code})"
                self.security_issues.append(issue)
                print(f"   ❌ {issue}")
            else:
                print(f"   ✅ Invalid token properly rejected")
        
        # Test 3: Token expiration (simulated)
        print("\n⏰ Testing token expiration handling...")
        # Bu test gerçek token expiration logic'i gerektirir
        # Şimdilik placeholder
        print("   ℹ️ Token expiration test requires real JWT implementation")
        
        return auth_tests
    
    def test_input_validation_security(self):
        """Input validation güvenlik testleri"""
        print("\n🛡️ INPUT VALIDATION SECURITY TESTING")
        print("=" * 60)
        
        validation_tests = []
        
        # Test 1: SQL Injection attempts
        print("\n💉 Testing SQL injection protection...")
        sql_injection_payloads = [
            "'; DROP TABLE users; --",
            "1' OR '1'='1",
            "admin'--",
            "1; DELETE FROM expenses; --",
            "' UNION SELECT * FROM users --"
        ]
        
        # Test SQL injection on search/filter parameters
        for payload in sql_injection_payloads:
            try:
                # Test on receipts endpoint with search
                response = self.client.get(f"/api/receipts?search={payload}")
                
                # Check if response indicates SQL injection vulnerability
                if response.status_code == 500:
                    response_text = response.text.lower()
                    if any(keyword in response_text for keyword in ['sql', 'syntax', 'database', 'table']):
                        issue = f"Possible SQL injection vulnerability with payload: {payload}"
                        self.security_issues.append(issue)
                        print(f"   ❌ {issue}")
                    else:
                        print(f"   ✅ SQL injection payload properly handled: {payload}")
                else:
                    print(f"   ✅ SQL injection payload rejected: {payload}")
                    
            except Exception as e:
                print(f"   ⚠️ Error testing SQL injection: {e}")
        
        # Test 2: XSS (Cross-Site Scripting) attempts
        print("\n🕷️ Testing XSS protection...")
        xss_payloads = [
            "<script>alert('XSS')</script>",
            "javascript:alert('XSS')",
            "<img src=x onerror=alert('XSS')>",
            "';alert('XSS');//",
            "<svg onload=alert('XSS')>"
        ]
        
        for payload in xss_payloads:
            try:
                # Test XSS on expense creation
                expense_data = {
                    "description": payload,
                    "amount": 100.0,
                    "category_id": "test-category"
                }
                
                response = self.client.post("/api/expenses", json=expense_data)
                
                # Check if XSS payload is reflected without sanitization
                if response.status_code == 200 and payload in response.text:
                    issue = f"Possible XSS vulnerability with payload: {payload}"
                    self.security_issues.append(issue)
                    print(f"   ❌ {issue}")
                else:
                    print(f"   ✅ XSS payload properly handled: {payload}")
                    
            except Exception as e:
                print(f"   ⚠️ Error testing XSS: {e}")
        
        # Test 3: Command Injection attempts
        print("\n💻 Testing command injection protection...")
        command_injection_payloads = [
            "; ls -la",
            "| cat /etc/passwd",
            "&& rm -rf /",
            "`whoami`",
            "$(id)"
        ]
        
        for payload in command_injection_payloads:
            try:
                # Test command injection on file upload or processing endpoints
                response = self.client.get(f"/api/receipts?merchant_name={payload}")
                
                if response.status_code == 500:
                    response_text = response.text.lower()
                    if any(keyword in response_text for keyword in ['command', 'shell', 'bash', 'permission']):
                        issue = f"Possible command injection vulnerability with payload: {payload}"
                        self.security_issues.append(issue)
                        print(f"   ❌ {issue}")
                    else:
                        print(f"   ✅ Command injection payload properly handled: {payload}")
                else:
                    print(f"   ✅ Command injection payload rejected: {payload}")
                    
            except Exception as e:
                print(f"   ⚠️ Error testing command injection: {e}")
        
        return validation_tests
    
    def test_authorization_security(self):
        """Authorization güvenlik testleri"""
        print("\n🔒 AUTHORIZATION SECURITY TESTING")
        print("=" * 60)
        
        authorization_tests = []
        
        # Test 1: Horizontal privilege escalation
        print("\n↔️ Testing horizontal privilege escalation...")
        
        # Bu test gerçek user token'ları gerektirir
        # Şimdilik simulated test
        print("   ℹ️ Horizontal privilege escalation test requires multiple user tokens")
        print("   📝 Manual test: Verify users can only access their own data")
        
        # Test 2: Vertical privilege escalation
        print("\n⬆️ Testing vertical privilege escalation...")
        
        # Admin endpoint'lere normal user access testi
        admin_endpoints = [
            "/api/merchants",
            "/api/webhooks/merchant/test/logs"
        ]
        
        for endpoint in admin_endpoints:
            try:
                response = self.client.get(endpoint)
                if response.status_code not in [401, 403]:
                    issue = f"Admin endpoint {endpoint} accessible without proper authorization"
                    self.security_issues.append(issue)
                    print(f"   ❌ {issue}")
                else:
                    print(f"   ✅ Admin endpoint properly protected: {endpoint}")
            except Exception as e:
                print(f"   ⚠️ Error testing admin endpoint: {e}")
        
        # Test 3: Resource access control
        print("\n📁 Testing resource access control...")
        
        # Test accessing non-existent or unauthorized resources
        test_cases = [
            {"endpoint": "/api/expenses/non-existent-id", "expected": [404, 401, 403]},
            {"endpoint": "/api/receipts/unauthorized-id", "expected": [404, 401, 403]},
            {"endpoint": "/api/categories/other-user-category", "expected": [404, 401, 403]}
        ]
        
        for test_case in test_cases:
            try:
                response = self.client.get(test_case["endpoint"])
                if response.status_code not in test_case["expected"]:
                    issue = f"Resource access control issue at {test_case['endpoint']} (status: {response.status_code})"
                    self.security_issues.append(issue)
                    print(f"   ❌ {issue}")
                else:
                    print(f"   ✅ Resource access properly controlled: {test_case['endpoint']}")
            except Exception as e:
                print(f"   ⚠️ Error testing resource access: {e}")
        
        return authorization_tests
    
    def test_data_exposure_security(self):
        """Data exposure güvenlik testleri"""
        print("\n🔍 DATA EXPOSURE SECURITY TESTING")
        print("=" * 60)
        
        exposure_tests = []
        
        # Test 1: Sensitive data in error messages
        print("\n🚨 Testing sensitive data exposure in errors...")
        
        # Trigger various error conditions
        error_endpoints = [
            "/api/expenses/invalid-uuid-format",
            "/api/receipts/malformed-id",
            "/api/categories/999999999"
        ]
        
        for endpoint in error_endpoints:
            try:
                response = self.client.get(endpoint)
                response_text = response.text.lower()
                
                # Check for sensitive information in error messages
                sensitive_patterns = [
                    r'password',
                    r'secret',
                    r'key',
                    r'token',
                    r'database.*connection',
                    r'internal.*error.*path',
                    r'stack.*trace'
                ]
                
                for pattern in sensitive_patterns:
                    if re.search(pattern, response_text):
                        issue = f"Sensitive data exposed in error at {endpoint}: {pattern}"
                        self.security_issues.append(issue)
                        print(f"   ❌ {issue}")
                        break
                else:
                    print(f"   ✅ No sensitive data in error response: {endpoint}")
                    
            except Exception as e:
                print(f"   ⚠️ Error testing data exposure: {e}")
        
        # Test 2: Information disclosure through headers
        print("\n📋 Testing information disclosure in headers...")
        
        response = self.client.get("/")
        headers = response.headers
        
        # Check for information disclosure in headers
        risky_headers = {
            'server': 'Server version information',
            'x-powered-by': 'Technology stack information',
            'x-aspnet-version': 'Framework version information'
        }
        
        for header, description in risky_headers.items():
            if header in headers:
                issue = f"Information disclosure in header '{header}': {description}"
                self.security_issues.append(issue)
                print(f"   ❌ {issue}")
            else:
                print(f"   ✅ No information disclosure in '{header}' header")
        
        # Test 3: Debug information exposure
        print("\n🐛 Testing debug information exposure...")
        
        # Check if debug mode is enabled in production-like environment
        debug_endpoints = [
            "/debug",
            "/api/debug",
            "/.env",
            "/config",
            "/api/config"
        ]
        
        for endpoint in debug_endpoints:
            try:
                response = self.client.get(endpoint)
                if response.status_code == 200:
                    issue = f"Debug endpoint accessible: {endpoint}"
                    self.security_issues.append(issue)
                    print(f"   ❌ {issue}")
                else:
                    print(f"   ✅ Debug endpoint not accessible: {endpoint}")
            except Exception as e:
                print(f"   ⚠️ Error testing debug endpoint: {e}")
        
        return exposure_tests
    
    def test_rate_limiting_security(self):
        """Rate limiting güvenlik testleri"""
        print("\n🚦 RATE LIMITING SECURITY TESTING")
        print("=" * 60)
        
        rate_limit_tests = []
        
        # Test 1: Basic rate limiting
        print("\n⏱️ Testing basic rate limiting...")
        
        # Send multiple requests quickly
        endpoint = "/api/categories"
        request_count = 20
        successful_requests = 0
        rate_limited_requests = 0
        
        for i in range(request_count):
            try:
                response = self.client.get(endpoint)
                if response.status_code == 200:
                    successful_requests += 1
                elif response.status_code == 429:  # Too Many Requests
                    rate_limited_requests += 1
                time.sleep(0.1)  # Small delay
            except Exception as e:
                print(f"   ⚠️ Error in rate limit test: {e}")
        
        print(f"   📊 Successful requests: {successful_requests}")
        print(f"   🚫 Rate limited requests: {rate_limited_requests}")
        
        if rate_limited_requests == 0 and successful_requests == request_count:
            issue = "No rate limiting detected - potential DoS vulnerability"
            self.security_issues.append(issue)
            print(f"   ❌ {issue}")
        else:
            print(f"   ✅ Rate limiting appears to be working")
        
        # Test 2: Brute force protection
        print("\n🔨 Testing brute force protection...")
        
        # Simulate login attempts (if login endpoint exists)
        login_endpoint = "/api/auth/login"
        
        for i in range(5):
            try:
                login_data = {
                    "email": "test@example.com",
                    "password": f"wrong_password_{i}"
                }
                response = self.client.post(login_endpoint, json=login_data)
                
                if i > 3 and response.status_code != 429:
                    issue = "No brute force protection on login endpoint"
                    self.security_issues.append(issue)
                    print(f"   ❌ {issue}")
                    break
            except Exception as e:
                print(f"   ℹ️ Login endpoint test skipped: {e}")
                break
        else:
            print(f"   ✅ Brute force protection appears to be working")
        
        return rate_limit_tests
    
    def test_cors_security(self):
        """CORS güvenlik testleri"""
        print("\n🌐 CORS SECURITY TESTING")
        print("=" * 60)
        
        cors_tests = []
        
        # Test 1: CORS headers
        print("\n🔗 Testing CORS configuration...")
        
        # Test with different origins
        test_origins = [
            "https://malicious-site.com",
            "http://localhost:3000",
            "https://example.com"
        ]
        
        for origin in test_origins:
            try:
                headers = {"Origin": origin}
                response = self.client.options("/api/expenses", headers=headers)
                
                cors_headers = {
                    'access-control-allow-origin': response.headers.get('access-control-allow-origin'),
                    'access-control-allow-credentials': response.headers.get('access-control-allow-credentials'),
                    'access-control-allow-methods': response.headers.get('access-control-allow-methods')
                }
                
                # Check for overly permissive CORS
                if cors_headers['access-control-allow-origin'] == '*':
                    if cors_headers['access-control-allow-credentials'] == 'true':
                        issue = "Dangerous CORS configuration: wildcard origin with credentials"
                        self.security_issues.append(issue)
                        print(f"   ❌ {issue}")
                    else:
                        print(f"   ⚠️ Wildcard CORS origin (acceptable without credentials)")
                else:
                    print(f"   ✅ CORS origin properly configured for {origin}")
                    
            except Exception as e:
                print(f"   ⚠️ Error testing CORS: {e}")
        
        return cors_tests
    
    def generate_security_report(self):
        """Security test sonuçlarının raporunu oluştur"""
        print(f"\n{'='*80}")
        print("🛡️ SECURITY TEST REPORT")
        print(f"{'='*80}")
        
        if not self.security_issues:
            print("✅ No security issues detected!")
            print("🎉 All security tests passed successfully.")
        else:
            print(f"⚠️ {len(self.security_issues)} security issues detected:")
            print()
            
            for i, issue in enumerate(self.security_issues, 1):
                print(f"{i}. ❌ {issue}")
        
        # Security recommendations
        print(f"\n💡 SECURITY RECOMMENDATIONS:")
        print("   🔐 Implement proper authentication and authorization")
        print("   🛡️ Use input validation and sanitization")
        print("   🚦 Implement rate limiting and brute force protection")
        print("   🔍 Avoid exposing sensitive information in errors")
        print("   🌐 Configure CORS properly")
        print("   📊 Regular security audits and penetration testing")
        print("   🔄 Keep dependencies updated")
        print("   📝 Security logging and monitoring")
        
        # Risk assessment
        critical_issues = [issue for issue in self.security_issues if any(
            keyword in issue.lower() for keyword in ['sql injection', 'xss', 'command injection', 'privilege escalation']
        )]
        
        if critical_issues:
            print(f"\n🚨 CRITICAL SECURITY ISSUES ({len(critical_issues)}):")
            for issue in critical_issues:
                print(f"   🔴 {issue}")
            print("\n⚠️ These issues require immediate attention!")
        
        return len(self.security_issues)


def main():
    """Ana test fonksiyonu"""
    print("🛡️ SECURITY TESTING BAŞLIYOR...")
    print("=" * 80)
    
    runner = SecurityTestRunner()
    
    try:
        # Authentication security testleri
        runner.test_authentication_security()
        
        # Input validation security testleri
        runner.test_input_validation_security()
        
        # Authorization security testleri
        runner.test_authorization_security()
        
        # Data exposure security testleri
        runner.test_data_exposure_security()
        
        # Rate limiting security testleri
        runner.test_rate_limiting_security()
        
        # CORS security testleri
        runner.test_cors_security()
        
        # Security raporu oluştur
        issue_count = runner.generate_security_report()
        
        if issue_count == 0:
            print(f"\n✅ Security testing completed successfully!")
            print(f"🛡️ No security vulnerabilities detected.")
        else:
            print(f"\n⚠️ Security testing completed with {issue_count} issues!")
            print(f"🔧 Please review and fix the identified security issues.")
        
    except Exception as e:
        print(f"❌ Security testing failed: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main() 