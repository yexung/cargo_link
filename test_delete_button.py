#!/usr/bin/env python3
"""
삭제 버튼 기능 테스트 (실제 삭제하지 않고 동작만 확인)
"""

import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

BASE_URL = "http://timeplanner.kr"
SELLER_EMAIL = "muhammadsoccertj@gmail.com"
SELLER_PASSWORD = "muhammad:jon1"

def test_delete_button():
    session = requests.Session()
    session.verify = False
    
    print("=== 삭제 버튼 기능 테스트 ===")
    
    # 1. 판매자 로그인
    print("\n1. 판매자 로그인...")
    login_url = urljoin(BASE_URL, "/sellers/sign_in")
    response = session.get(login_url)
    
    if response.status_code != 200:
        print(f"❌ 로그인 페이지 접근 실패: {response.status_code}")
        return
    
    # CSRF 토큰 획득
    soup = BeautifulSoup(response.text, 'html.parser')
    csrf_token = None
    csrf_meta = soup.find('meta', attrs={'name': 'csrf-token'})
    if csrf_meta:
        csrf_token = csrf_meta.get('content')
    
    if not csrf_token:
        csrf_input = soup.find('input', attrs={'name': 'authenticity_token'})
        if csrf_input:
            csrf_token = csrf_input.get('value')
    
    if not csrf_token:
        print("❌ CSRF 토큰을 찾을 수 없음")
        return
    
    # 로그인 요청
    login_data = {
        "seller[email]": SELLER_EMAIL,
        "seller[password]": SELLER_PASSWORD,
        "authenticity_token": csrf_token,
        "commit": "Log in"
    }
    
    response = session.post(login_url, data=login_data, allow_redirects=True)
    
    if "sign_in" in response.url:
        print(f"❌ 로그인 실패: {response.url}")
        return
    else:
        print(f"✅ 로그인 성공: {response.url}")
    
    # 2. 거래 상세 페이지 접근
    print("\n2. 거래 상세 페이지 접근...")
    trade_url = urljoin(BASE_URL, "/sellers/trades/1")
    response = session.get(trade_url)
    
    if response.status_code != 200:
        print(f"❌ 거래 상세 페이지 접근 실패: {response.status_code}")
        return
    
    print("✅ 거래 상세 페이지 접근 성공")
    
    # 3. 삭제 버튼 HTML 분석
    print("\n3. 삭제 버튼 HTML 분석...")
    soup = BeautifulSoup(response.text, 'html.parser')
    
    # 삭제 버튼 찾기
    delete_links = soup.find_all('a', string='삭제')
    
    if not delete_links:
        print("❌ 삭제 버튼을 찾을 수 없음")
        return
    
    print(f"✅ 삭제 버튼 {len(delete_links)}개 발견")
    
    for i, link in enumerate(delete_links):
        print(f"\n삭제 버튼 #{i+1}:")
        print(f"  href: {link.get('href')}")
        print(f"  data-turbo-method: {link.get('data-turbo-method')}")
        print(f"  data-turbo-confirm: {link.get('data-turbo-confirm')}")
        print(f"  class: {link.get('class')}")
        
        # Turbo 속성 확인
        if link.get('data-turbo-method') == 'delete':
            print("  ✅ data-turbo-method=delete 설정됨")
        else:
            print("  ❌ data-turbo-method=delete 설정 안됨")
        
        if link.get('data-turbo-confirm'):
            print("  ✅ data-turbo-confirm 설정됨")
        else:
            print("  ❌ data-turbo-confirm 설정 안됨")
    
    # 4. JavaScript 및 Turbo 로드 확인
    print("\n4. JavaScript 및 Turbo 로드 확인...")
    
    # importmap 확인
    importmap = soup.find('script', attrs={'type': 'importmap'})
    if importmap:
        print("✅ importmap 발견")
        try:
            import json
            importmap_data = json.loads(importmap.string)
            if '@hotwired/turbo-rails' in importmap_data.get('imports', {}):
                print("✅ Turbo Rails가 importmap에 포함됨")
            else:
                print("❌ Turbo Rails가 importmap에 없음")
        except:
            print("⚠️ importmap 파싱 실패")
    else:
        print("❌ importmap을 찾을 수 없음")
    
    # application.js 로드 확인
    app_js = soup.find('script', attrs={'src': lambda x: x and 'application' in x})
    if app_js:
        print("✅ application.js 로드됨")
    else:
        print("❌ application.js 로드 안됨")
    
    # 5. CSRF 토큰 확인
    print("\n5. CSRF 토큰 확인...")
    csrf_meta = soup.find('meta', attrs={'name': 'csrf-token'})
    if csrf_meta and csrf_meta.get('content'):
        print("✅ CSRF 토큰 메타 태그 존재")
    else:
        print("❌ CSRF 토큰 메타 태그 없음")
    
    print("\n=== 테스트 완료 ===")
    print("삭제 기능이 작동하지 않는 경우:")
    print("1. 브라우저 개발자 도구에서 JavaScript 오류 확인")
    print("2. Turbo Rails가 제대로 로드되는지 확인")
    print("3. 네트워크 탭에서 DELETE 요청이 전송되는지 확인")

if __name__ == "__main__":
    test_delete_button()