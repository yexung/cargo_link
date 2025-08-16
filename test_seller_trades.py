#!/usr/bin/env python3
"""
판매자 거래 페이지 접근 테스트 (실제 도메인)
"""

import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

BASE_URL = "http://timeplanner.kr"
SELLER_EMAIL = "muhammadsoccertj@gmail.com"
SELLER_PASSWORD = "muhammad:jon1"

def test_seller_trades():
    session = requests.Session()
    session.verify = False
    
    print("=== 판매자 거래 페이지 상세 테스트 ===")
    
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
        # 오류 메시지 확인
        soup = BeautifulSoup(response.text, 'html.parser')
        error_div = soup.find('div', class_=['alert-danger', 'flash-error', 'error'])
        if error_div:
            print(f"   오류 메시지: {error_div.get_text().strip()}")
        return
    else:
        print(f"✅ 로그인 성공: {response.url}")
    
    # 2. /sellers/trades 접근 (index - 실패 예상)
    print("\n2. /sellers/trades 접근 테스트...")
    trades_url = urljoin(BASE_URL, "/sellers/trades")
    response = session.get(trades_url)
    print(f"응답 코드: {response.status_code}")
    
    if response.status_code == 404:
        print("❌ /sellers/trades (index) - 라우팅에서 제외됨")
    elif response.status_code == 200:
        print("✅ /sellers/trades (index) - 접근 가능")
    else:
        print(f"⚠️ /sellers/trades - 예상치 못한 응답: {response.status_code}")
    
    # 3. 개별 거래 ID로 테스트 (1~10번까지)
    print("\n3. 개별 거래 페이지 접근 테스트...")
    
    for trade_id in range(1, 11):
        trade_url = urljoin(BASE_URL, f"/sellers/trades/{trade_id}")
        response = session.get(trade_url)
        
        if response.status_code == 200:
            print(f"✅ /sellers/trades/{trade_id} - 접근 성공")
            
            # 페이지 내용 간단히 확인
            soup = BeautifulSoup(response.text, 'html.parser')
            title = soup.find('title')
            if title:
                print(f"   페이지 제목: {title.get_text().strip()}")
                
            # 거래 정보가 있는지 확인
            if "trade" in response.text.lower() or "거래" in response.text:
                print(f"   거래 정보 포함: ✅")
            else:
                print(f"   거래 정보 포함: ❌")
                
        elif response.status_code == 404:
            print(f"❌ /sellers/trades/{trade_id} - 거래가 존재하지 않음")
        elif response.status_code == 302:
            print(f"⚠️ /sellers/trades/{trade_id} - 리다이렉트 (권한 없음?)")
        else:
            print(f"⚠️ /sellers/trades/{trade_id} - 응답 코드: {response.status_code}")
    
    # 4. 라우팅에서 허용되는 다른 경로들 확인
    print("\n4. 기타 판매자 거래 관련 경로 테스트...")
    
    other_paths = [
        "/sellers/trades/new",      # new action
        "/sellers/trades/1/edit",   # edit action  
        "/sellers/trades/1/complete_trade",  # custom member action
    ]
    
    for path in other_paths:
        url = urljoin(BASE_URL, path)
        response = session.get(url)
        
        if response.status_code == 200:
            print(f"✅ {path} - 접근 가능")
        elif response.status_code == 404:
            print(f"❌ {path} - 404 오류")
        elif response.status_code == 302:
            print(f"⚠️ {path} - 리다이렉트")
        else:
            print(f"⚠️ {path} - 응답 코드: {response.status_code}")

if __name__ == "__main__":
    test_seller_trades()