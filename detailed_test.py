#!/usr/bin/env python3
"""
Cargo Link 중고차 수출 경매 플랫폼 상세 기능 테스트
실제 라우팅 정보를 반영한 정확한 테스트
"""

import requests
import json
import re
from bs4 import BeautifulSoup
import time
from urllib.parse import urljoin
import sys

# 기본 설정
BASE_URL = "http://localhost:3000"
ADMIN_EMAIL = "yesung012929@naver.com"
ADMIN_PASSWORD = "yesung129$"
SELLER_EMAIL = "muhammadsoccertj@gmail.com"
SELLER_PASSWORD = "muhammad:jon1"

class CargoLinkDetailedTester:
    def __init__(self):
        self.session = requests.Session()
        self.session.verify = False
        import urllib3
        urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
        self.csrf_token = None
        self.test_results = []
        
    def log_result(self, test_name, status, details=""):
        result = {
            "test": test_name,
            "status": status,
            "details": details,
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")
        }
        self.test_results.append(result)
        status_emoji = "✅" if status == "PASS" else "❌" if status == "FAIL" else "⚠️"
        print(f"{status_emoji} {test_name}: {status}")
        if details:
            print(f"   └─ {details}")
    
    def get_csrf_token(self, html_content):
        """HTML에서 CSRF 토큰 추출"""
        soup = BeautifulSoup(html_content, 'html.parser')
        csrf_meta = soup.find('meta', attrs={'name': 'csrf-token'})
        if csrf_meta:
            return csrf_meta.get('content')
        
        csrf_input = soup.find('input', attrs={'name': 'authenticity_token'})
        if csrf_input:
            return csrf_input.get('value')
        
        return None
    
    def test_basic_pages(self):
        """기본 페이지 접근성 테스트"""
        print("\n=== 기본 페이지 접근성 테스트 ===")
        
        basic_pages = [
            ("/", "홈페이지"),
            ("/up", "헬스체크"),
            ("/vehicles", "차량 목록"),
            ("/auctions", "경매 목록"),
            ("/trades", "거래 목록"),
        ]
        
        for path, name in basic_pages:
            try:
                response = self.session.get(urljoin(BASE_URL, path), timeout=10)
                if response.status_code == 200:
                    self.log_result(f"{name} 접근", "PASS")
                    if path == "/":
                        self.csrf_token = self.get_csrf_token(response.text)
                elif response.status_code == 302:
                    self.log_result(f"{name} 접근", "PASS", f"리다이렉트: {response.headers.get('Location', 'Unknown')}")
                else:
                    self.log_result(f"{name} 접근", "FAIL", f"응답 코드: {response.status_code}")
            except Exception as e:
                self.log_result(f"{name} 접근", "FAIL", str(e))
    
    def test_devise_pages(self):
        """Devise 인증 페이지 테스트"""
        print("\n=== 인증 페이지 테스트 ===")
        
        auth_pages = [
            ("/admin_users/sign_in", "관리자 로그인 페이지"),
            ("/admin_users/sign_up", "관리자 회원가입 페이지"),
            ("/buyers/sign_in", "구매자 로그인 페이지"),
            ("/buyers/sign_up", "구매자 회원가입 페이지"),
            ("/sellers/sign_in", "판매자 로그인 페이지"),
            ("/sellers/sign_up", "판매자 회원가입 페이지"),
            ("/users/sign_in", "일반 사용자 로그인 페이지"),
            ("/users/sign_up", "일반 사용자 회원가입 페이지"),
        ]
        
        for path, name in auth_pages:
            try:
                response = self.session.get(urljoin(BASE_URL, path), timeout=10)
                if response.status_code == 200:
                    self.log_result(f"{name} 접근", "PASS")
                elif response.status_code == 302:
                    self.log_result(f"{name} 접근", "WARN", "리다이렉트됨 (이미 로그인?)")
                elif response.status_code == 404:
                    self.log_result(f"{name} 접근", "WARN", "페이지 없음 (회원가입 비활성화?)")
                else:
                    self.log_result(f"{name} 접근", "FAIL", f"응답 코드: {response.status_code}")
            except Exception as e:
                self.log_result(f"{name} 접근", "FAIL", str(e))
    
    def test_admin_login(self):
        """관리자 로그인 테스트"""
        print("\n=== 관리자 로그인 테스트 ===")
        
        try:
            # 로그아웃
            try:
                self.session.get(urljoin(BASE_URL, "/admin_users/sign_out"))
            except:
                pass
            
            # 로그인 페이지 접근
            login_url = urljoin(BASE_URL, "/admin_users/sign_in")
            response = self.session.get(login_url)
            
            if response.status_code != 200:
                self.log_result("관리자 로그인 페이지 접근", "FAIL", f"응답 코드: {response.status_code}")
                return False
            
            # CSRF 토큰 획득
            self.csrf_token = self.get_csrf_token(response.text)
            if not self.csrf_token:
                self.log_result("관리자 CSRF 토큰 획득", "FAIL", "토큰 없음")
                return False
            
            # 로그인 요청
            login_data = {
                "admin_user[email]": ADMIN_EMAIL,
                "admin_user[password]": ADMIN_PASSWORD,
                "authenticity_token": self.csrf_token,
                "commit": "Log in"
            }
            
            response = self.session.post(login_url, data=login_data, allow_redirects=True)
            
            # 로그인 성공 확인
            if "/admin" in response.url and response.status_code == 200:
                self.log_result("관리자 로그인", "PASS", f"리다이렉트: {response.url}")
                return True
            elif "sign_in" not in response.url and response.status_code == 200:
                self.log_result("관리자 로그인", "PASS", f"로그인 후 URL: {response.url}")
                return True
            else:
                # 로그인 실패 원인 분석
                if "sign_in" in response.url:
                    soup = BeautifulSoup(response.text, 'html.parser')
                    error_msg = soup.find('div', class_='alert-danger') or soup.find('div', class_='flash-error')
                    error_text = error_msg.get_text().strip() if error_msg else "알 수 없는 오류"
                    self.log_result("관리자 로그인", "FAIL", f"로그인 실패: {error_text}")
                else:
                    self.log_result("관리자 로그인", "FAIL", f"예상치 못한 리다이렉트: {response.url}")
                return False
                
        except Exception as e:
            self.log_result("관리자 로그인", "FAIL", str(e))
            return False
    
    def test_admin_features(self):
        """관리자 기능 테스트"""
        print("\n=== 관리자 기능 테스트 ===")
        
        admin_pages = [
            ("/admin", "관리자 대시보드"),
            ("/admin/dashboard", "관리자 대시보드2"),
            ("/admin/users", "사용자 관리"),
            ("/admin/vehicles", "차량 관리"),
            ("/admin/auctions", "경매 관리"),
            ("/admin/trades", "거래 관리"),
            ("/admin/payments", "결제 관리"),
            ("/admin/withdrawal_requests", "환전 신청 관리"),
            ("/admin/settings", "설정 관리"),
        ]
        
        for path, name in admin_pages:
            try:
                response = self.session.get(urljoin(BASE_URL, path), timeout=10)
                if response.status_code == 200:
                    self.log_result(f"{name} 접근", "PASS")
                elif response.status_code == 302:
                    self.log_result(f"{name} 접근", "WARN", "리다이렉트됨")
                elif response.status_code == 403:
                    self.log_result(f"{name} 접근", "FAIL", "접근 권한 없음")
                elif response.status_code == 404:
                    self.log_result(f"{name} 접근", "WARN", "페이지 없음")
                else:
                    self.log_result(f"{name} 접근", "FAIL", f"응답 코드: {response.status_code}")
            except Exception as e:
                self.log_result(f"{name} 접근", "FAIL", str(e))
    
    def test_seller_login(self):
        """판매자 로그인 테스트"""
        print("\n=== 판매자 로그인 테스트 ===")
        
        try:
            # 로그아웃
            try:
                self.session.get(urljoin(BASE_URL, "/sellers/sign_out"))
            except:
                pass
            
            # 로그인 페이지 접근
            login_url = urljoin(BASE_URL, "/sellers/sign_in")
            response = self.session.get(login_url)
            
            if response.status_code != 200:
                self.log_result("판매자 로그인 페이지 접근", "FAIL", f"응답 코드: {response.status_code}")
                return False
            
            # CSRF 토큰 획득
            self.csrf_token = self.get_csrf_token(response.text)
            
            # 로그인 요청
            login_data = {
                "seller[email]": SELLER_EMAIL,
                "seller[password]": SELLER_PASSWORD,
                "authenticity_token": self.csrf_token,
                "commit": "Log in"
            }
            
            response = self.session.post(login_url, data=login_data, allow_redirects=True)
            
            # 로그인 성공 확인
            if "/sellers" in response.url and response.status_code == 200:
                self.log_result("판매자 로그인", "PASS", f"리다이렉트: {response.url}")
                return True
            elif "sign_in" not in response.url and response.status_code == 200:
                self.log_result("판매자 로그인", "PASS", f"로그인 후 URL: {response.url}")
                return True
            else:
                soup = BeautifulSoup(response.text, 'html.parser')
                error_msg = soup.find('div', class_='alert-danger') or soup.find('div', class_='flash-error')
                error_text = error_msg.get_text().strip() if error_msg else "로그인 실패"
                self.log_result("판매자 로그인", "FAIL", f"{error_text} (URL: {response.url})")
                return False
                
        except Exception as e:
            self.log_result("판매자 로그인", "FAIL", str(e))
            return False
    
    def test_seller_features(self):
        """판매자 기능 테스트"""
        print("\n=== 판매자 기능 테스트 ===")
        
        seller_pages = [
            ("/sellers", "판매자 대시보드"),
            ("/sellers/dashboard", "판매자 대시보드2"),
            ("/sellers/vehicles/new", "차량 등록"),
            ("/sellers/auctions/new", "경매 생성"),
            ("/sellers/trades", "판매자 거래"),
        ]
        
        for path, name in seller_pages:
            try:
                response = self.session.get(urljoin(BASE_URL, path), timeout=10)
                if response.status_code == 200:
                    self.log_result(f"{name} 접근", "PASS")
                elif response.status_code == 302:
                    self.log_result(f"{name} 접근", "WARN", "리다이렉트됨")
                else:
                    self.log_result(f"{name} 접근", "FAIL", f"응답 코드: {response.status_code}")
            except Exception as e:
                self.log_result(f"{name} 접근", "FAIL", str(e))
    
    def test_buyer_login(self):
        """구매자 로그인 테스트 (판매자와 동일 계정)"""
        print("\n=== 구매자 로그인 테스트 ===")
        
        try:
            # 로그아웃
            try:
                self.session.get(urljoin(BASE_URL, "/buyers/sign_out"))
            except:
                pass
            
            # 로그인 페이지 접근
            login_url = urljoin(BASE_URL, "/buyers/sign_in")
            response = self.session.get(login_url)
            
            if response.status_code != 200:
                self.log_result("구매자 로그인 페이지 접근", "FAIL", f"응답 코드: {response.status_code}")
                return False
            
            # CSRF 토큰 획득
            self.csrf_token = self.get_csrf_token(response.text)
            
            # 로그인 요청
            login_data = {
                "buyer[email]": SELLER_EMAIL,  # 구매자와 판매자가 동일하다고 함
                "buyer[password]": SELLER_PASSWORD,
                "authenticity_token": self.csrf_token,
                "commit": "Log in"
            }
            
            response = self.session.post(login_url, data=login_data, allow_redirects=True)
            
            # 로그인 성공 확인
            if "/buyers" in response.url and response.status_code == 200:
                self.log_result("구매자 로그인", "PASS", f"리다이렉트: {response.url}")
                return True
            elif "sign_in" not in response.url and response.status_code == 200:
                self.log_result("구매자 로그인", "PASS", f"로그인 후 URL: {response.url}")
                return True
            else:
                soup = BeautifulSoup(response.text, 'html.parser')
                error_msg = soup.find('div', class_='alert-danger') or soup.find('div', class_='flash-error')
                error_text = error_msg.get_text().strip() if error_msg else "로그인 실패"
                self.log_result("구매자 로그인", "FAIL", f"{error_text} (URL: {response.url})")
                return False
                
        except Exception as e:
            self.log_result("구매자 로그인", "FAIL", str(e))
            return False
    
    def test_buyer_features(self):
        """구매자 기능 테스트"""
        print("\n=== 구매자 기능 테스트 ===")
        
        buyer_pages = [
            ("/buyers", "구매자 대시보드"),
            ("/buyers/dashboard", "구매자 대시보드2"),
            ("/buyers/bids", "입찰 내역"),
            ("/buyers/payments", "결제 내역"),
            ("/buyers/trades", "구매자 거래"),
        ]
        
        for path, name in buyer_pages:
            try:
                response = self.session.get(urljoin(BASE_URL, path), timeout=10)
                if response.status_code == 200:
                    self.log_result(f"{name} 접근", "PASS")
                elif response.status_code == 302:
                    self.log_result(f"{name} 접근", "WARN", "리다이렉트됨")
                else:
                    self.log_result(f"{name} 접근", "FAIL", f"응답 코드: {response.status_code}")
            except Exception as e:
                self.log_result(f"{name} 접근", "FAIL", str(e))
    
    def test_api_endpoints(self):
        """API 엔드포인트 테스트"""
        print("\n=== API 엔드포인트 테스트 ===")
        
        api_endpoints = [
            ("/api/v1/auctions", "경매 API"),
            ("/api/v1/messages", "메시지 API"),
        ]
        
        for path, name in api_endpoints:
            try:
                response = self.session.get(urljoin(BASE_URL, path), timeout=10)
                if response.status_code == 200:
                    self.log_result(f"{name} 테스트", "PASS")
                elif response.status_code == 404:
                    self.log_result(f"{name} 테스트", "WARN", "엔드포인트 없음")
                else:
                    self.log_result(f"{name} 테스트", "FAIL", f"응답 코드: {response.status_code}")
            except Exception as e:
                self.log_result(f"{name} 테스트", "FAIL", str(e))
    
    def test_withdrawal_requests(self):
        """환전 신청 기능 테스트"""
        print("\n=== 환전 신청 기능 테스트 ===")
        
        wr_pages = [
            ("/withdrawal_requests", "환전 신청 목록"),
            ("/withdrawal_requests/new", "환전 신청 생성"),
        ]
        
        for path, name in wr_pages:
            try:
                response = self.session.get(urljoin(BASE_URL, path), timeout=10)
                if response.status_code == 200:
                    self.log_result(f"{name} 접근", "PASS")
                elif response.status_code == 302:
                    self.log_result(f"{name} 접근", "WARN", "로그인 필요")
                else:
                    self.log_result(f"{name} 접근", "FAIL", f"응답 코드: {response.status_code}")
            except Exception as e:
                self.log_result(f"{name} 접근", "FAIL", str(e))
    
    def generate_report(self):
        """테스트 결과 보고서 생성"""
        print("\n" + "="*80)
        print("Cargo Link 중고차 수출 경매 플랫폼 - 테스트 결과 요약")
        print("="*80)
        
        total_tests = len(self.test_results)
        passed_tests = len([r for r in self.test_results if r["status"] == "PASS"])
        failed_tests = len([r for r in self.test_results if r["status"] == "FAIL"])
        warning_tests = len([r for r in self.test_results if r["status"] == "WARN"])
        
        print(f"총 테스트: {total_tests}")
        print(f"성공: {passed_tests} ✅")
        print(f"실패: {failed_tests} ❌")
        print(f"경고: {warning_tests} ⚠️")
        print(f"성공률: {(passed_tests/total_tests*100):.1f}%")
        
        if failed_tests > 0:
            print("\n🔴 실패한 테스트:")
            for result in self.test_results:
                if result["status"] == "FAIL":
                    print(f"❌ {result['test']}: {result['details']}")
        
        if warning_tests > 0:
            print("\n🟡 경고가 있는 테스트:")
            for result in self.test_results:
                if result["status"] == "WARN":
                    print(f"⚠️ {result['test']}: {result['details']}")
        
        print("\n🟢 성공한 테스트:")
        for result in self.test_results:
            if result["status"] == "PASS":
                print(f"✅ {result['test']}")
    
    def run_comprehensive_test(self):
        """종합 테스트 실행"""
        print("Cargo Link 중고차 수출 경매 플랫폼 - 상세 기능 테스트 시작")
        print("="*80)
        
        # 1. 기본 페이지 접근성 테스트
        self.test_basic_pages()
        
        # 2. 인증 페이지 테스트
        self.test_devise_pages()
        
        # 3. 관리자 기능 테스트
        if self.test_admin_login():
            self.test_admin_features()
        
        # 4. 판매자 기능 테스트
        if self.test_seller_login():
            self.test_seller_features()
        
        # 5. 구매자 기능 테스트
        if self.test_buyer_login():
            self.test_buyer_features()
        
        # 6. API 엔드포인트 테스트
        self.test_api_endpoints()
        
        # 7. 환전 신청 기능 테스트
        self.test_withdrawal_requests()
        
        # 8. 결과 보고서 생성
        self.generate_report()

if __name__ == "__main__":
    tester = CargoLinkDetailedTester()
    tester.run_comprehensive_test()