#!/usr/bin/env python3
"""
Cargo Link 애플리케이션 종합 기능 테스트
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

class CargoLinkTester:
    def __init__(self):
        self.session = requests.Session()
        self.session.verify = False  # SSL 검증 비활성화
        # SSL 경고 메시지 비활성화
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
        
        # form에서 authenticity_token 찾기
        csrf_input = soup.find('input', attrs={'name': 'authenticity_token'})
        if csrf_input:
            return csrf_input.get('value')
        
        return None
    
    def test_basic_connectivity(self):
        """기본 연결성 테스트"""
        print("\n=== 기본 연결성 테스트 ===")
        
        try:
            # 메인 페이지 접근
            response = self.session.get(BASE_URL, timeout=10)
            if response.status_code == 200:
                self.log_result("메인 페이지 접근", "PASS", f"응답 코드: {response.status_code}")
                self.csrf_token = self.get_csrf_token(response.text)
                if self.csrf_token:
                    self.log_result("CSRF 토큰 획득", "PASS")
                else:
                    self.log_result("CSRF 토큰 획득", "WARN", "CSRF 토큰을 찾을 수 없음")
            else:
                self.log_result("메인 페이지 접근", "FAIL", f"응답 코드: {response.status_code}")
                
        except Exception as e:
            self.log_result("메인 페이지 접근", "FAIL", str(e))
        
        # 주요 페이지들 확인
        test_pages = [
            ("/users/sign_in", "로그인 페이지"),
            ("/users/sign_up", "회원가입 페이지"),
            ("/products", "상품 목록 페이지"),
        ]
        
        for path, name in test_pages:
            try:
                response = self.session.get(urljoin(BASE_URL, path), timeout=10)
                if response.status_code == 200:
                    self.log_result(f"{name} 접근", "PASS")
                else:
                    self.log_result(f"{name} 접근", "FAIL", f"응답 코드: {response.status_code}")
            except Exception as e:
                self.log_result(f"{name} 접근", "FAIL", str(e))
    
    def test_admin_login(self):
        """관리자 로그인 테스트"""
        print("\n=== 관리자 로그인 테스트 ===")
        
        try:
            # 로그인 페이지 접근
            login_url = urljoin(BASE_URL, "/users/sign_in")
            response = self.session.get(login_url)
            
            if response.status_code != 200:
                self.log_result("로그인 페이지 접근", "FAIL", f"응답 코드: {response.status_code}")
                return False
            
            # CSRF 토큰 업데이트
            self.csrf_token = self.get_csrf_token(response.text)
            
            # 로그인 요청
            login_data = {
                "user[email]": ADMIN_EMAIL,
                "user[password]": ADMIN_PASSWORD,
                "authenticity_token": self.csrf_token,
                "commit": "로그인"
            }
            
            response = self.session.post(login_url, data=login_data, allow_redirects=True)
            
            # 로그인 성공 확인 (대시보드나 관리자 페이지로 리다이렉트되었는지 확인)
            if "sign_in" not in response.url and response.status_code == 200:
                self.log_result("관리자 로그인", "PASS", f"리다이렉트: {response.url}")
                return True
            else:
                self.log_result("관리자 로그인", "FAIL", f"로그인 실패, URL: {response.url}")
                return False
                
        except Exception as e:
            self.log_result("관리자 로그인", "FAIL", str(e))
            return False
    
    def test_admin_features(self):
        """관리자 기능 테스트"""
        print("\n=== 관리자 기능 테스트 ===")
        
        # 관리자 페이지들 테스트
        admin_pages = [
            ("/admin", "관리자 대시보드"),
            ("/admin/users", "사용자 관리"),
            ("/admin/products", "상품 관리"),
            ("/admin/orders", "주문 관리"),
            ("/admin/categories", "카테고리 관리"),
        ]
        
        for path, name in admin_pages:
            try:
                response = self.session.get(urljoin(BASE_URL, path), timeout=10)
                if response.status_code == 200:
                    self.log_result(f"{name} 접근", "PASS")
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
        
        # 먼저 로그아웃
        try:
            self.session.get(urljoin(BASE_URL, "/users/sign_out"))
        except:
            pass
        
        try:
            # 로그인 페이지 접근
            login_url = urljoin(BASE_URL, "/users/sign_in")
            response = self.session.get(login_url)
            
            if response.status_code != 200:
                self.log_result("로그인 페이지 접근", "FAIL", f"응답 코드: {response.status_code}")
                return False
            
            # CSRF 토큰 업데이트
            self.csrf_token = self.get_csrf_token(response.text)
            
            # 로그인 요청
            login_data = {
                "user[email]": SELLER_EMAIL,
                "user[password]": SELLER_PASSWORD,
                "authenticity_token": self.csrf_token,
                "commit": "로그인"
            }
            
            response = self.session.post(login_url, data=login_data, allow_redirects=True)
            
            # 로그인 성공 확인
            if "sign_in" not in response.url and response.status_code == 200:
                self.log_result("판매자/구매자 로그인", "PASS", f"리다이렉트: {response.url}")
                return True
            else:
                self.log_result("판매자/구매자 로그인", "FAIL", f"로그인 실패, URL: {response.url}")
                return False
                
        except Exception as e:
            self.log_result("판매자/구매자 로그인", "FAIL", str(e))
            return False
    
    def test_user_features(self):
        """사용자 기능 테스트 (판매자/구매자 공통)"""
        print("\n=== 사용자 기능 테스트 ===")
        
        # 사용자 페이지들 테스트
        user_pages = [
            ("/products", "상품 목록"),
            ("/products/new", "상품 등록"),
            ("/cart", "장바구니"),
            ("/orders", "주문 내역"),
            ("/profile", "프로필"),
            ("/dashboard", "대시보드"),
        ]
        
        for path, name in user_pages:
            try:
                response = self.session.get(urljoin(BASE_URL, path), timeout=10)
                if response.status_code == 200:
                    self.log_result(f"{name} 접근", "PASS")
                elif response.status_code == 404:
                    self.log_result(f"{name} 접근", "WARN", "페이지 없음")
                else:
                    self.log_result(f"{name} 접근", "FAIL", f"응답 코드: {response.status_code}")
            except Exception as e:
                self.log_result(f"{name} 접근", "FAIL", str(e))
    
    def test_api_endpoints(self):
        """API 엔드포인트 테스트"""
        print("\n=== API 엔드포인트 테스트 ===")
        
        api_endpoints = [
            ("/api/products", "상품 API"),
            ("/api/categories", "카테고리 API"),
            ("/api/users", "사용자 API"),
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
    
    def test_error_pages(self):
        """오류 페이지 테스트"""
        print("\n=== 오류 페이지 테스트 ===")
        
        try:
            # 존재하지 않는 페이지 테스트
            response = self.session.get(urljoin(BASE_URL, "/nonexistent-page"))
            if response.status_code == 404:
                self.log_result("404 페이지 처리", "PASS")
            else:
                self.log_result("404 페이지 처리", "WARN", f"응답 코드: {response.status_code}")
        except Exception as e:
            self.log_result("404 페이지 처리", "FAIL", str(e))
    
    def generate_report(self):
        """테스트 결과 보고서 생성"""
        print("\n" + "="*60)
        print("테스트 결과 요약")
        print("="*60)
        
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
            print("\n실패한 테스트:")
            for result in self.test_results:
                if result["status"] == "FAIL":
                    print(f"❌ {result['test']}: {result['details']}")
        
        if warning_tests > 0:
            print("\n경고가 있는 테스트:")
            for result in self.test_results:
                if result["status"] == "WARN":
                    print(f"⚠️ {result['test']}: {result['details']}")
    
    def run_all_tests(self):
        """모든 테스트 실행"""
        print("Cargo Link 애플리케이션 종합 기능 테스트 시작")
        print("="*60)
        
        # 기본 연결성 테스트
        self.test_basic_connectivity()
        
        # 관리자 기능 테스트
        if self.test_admin_login():
            self.test_admin_features()
        
        # 판매자/구매자 기능 테스트
        if self.test_seller_login():
            self.test_user_features()
        
        # API 및 오류 페이지 테스트
        self.test_api_endpoints()
        self.test_error_pages()
        
        # 결과 보고서 생성
        self.generate_report()

if __name__ == "__main__":
    tester = CargoLinkTester()
    tester.run_all_tests()