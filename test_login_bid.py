#!/usr/bin/env python3
import requests
from bs4 import BeautifulSoup
import re

# 세션 생성
session = requests.Session()

# 1. 로그인 페이지에서 CSRF 토큰 가져오기
print("1. 로그인 페이지 접속 중...")
login_page = session.get('http://localhost:3000/buyers/sign_in')
soup = BeautifulSoup(login_page.text, 'html.parser')
csrf_token = soup.find('input', {'name': 'authenticity_token'})['value']
print(f"CSRF 토큰: {csrf_token[:20]}...")

# 2. 로그인 시도
print("2. 구매자 로그인 중...")
login_data = {
    'buyer[email]': 'buyer1@test.com',
    'buyer[password]': 'password',
    'authenticity_token': csrf_token
}

login_response = session.post('http://localhost:3000/buyers/sign_in', data=login_data)
if login_response.status_code == 200 and 'sign_in' not in login_response.url:
    print("✅ 로그인 성공!")
else:
    print(f"❌ 로그인 실패: {login_response.status_code}")
    print(f"리다이렉트: {login_response.url}")

# 3. 경매 페이지 접속
print("3. 경매 페이지 접속 중...")
auction_page = session.get('http://localhost:3000/auctions/8')
soup = BeautifulSoup(auction_page.text, 'html.parser')

# 입찰 폼 확인
bid_form = soup.find('form', action=re.compile(r'/auctions/8/place_bid'))
if bid_form:
    print("✅ 입찰 폼 발견!")
    csrf_token = bid_form.find('input', {'name': 'authenticity_token'})['value']
    
    # 현재가 확인
    current_price_elem = soup.find('div', string=re.compile(r'₩[\d,]+'))
    if current_price_elem:
        print(f"현재가 표시: {current_price_elem.text}")
    
    # 4. 입찰 시도
    print("4. 입찰 시도 중...")
    bid_data = {
        'bid[amount]': '15,400,000',  # 콤마 포함 테스트
        'authenticity_token': csrf_token
    }
    
    bid_response = session.post('http://localhost:3000/auctions/8/place_bid', data=bid_data)
    
    if bid_response.status_code == 200 or bid_response.status_code == 302:
        print("✅ 입찰 요청 성공!")
        print(f"응답 상태: {bid_response.status_code}")
        
        # 성공 메시지 확인
        if '입찰이 성공적으로' in bid_response.text:
            print("✅ 입찰 성공 메시지 확인!")
    else:
        print(f"❌ 입찰 실패: {bid_response.status_code}")
        
    # 5. 입찰 후 히스토리 확인
    print("5. 입찰 후 페이지 확인 중...")
    auction_page_after = session.get('http://localhost:3000/auctions/8')
    soup_after = BeautifulSoup(auction_page_after.text, 'html.parser')
    
    # 입찰 히스토리 확인
    history_section = soup_after.find('h2', string='입찰 히스토리')
    if history_section:
        history_div = history_section.find_next('div', class_='space-y-3')
        if history_div:
            bid_items = history_div.find_all('div', class_='flex justify-between items-center')
            print(f"입찰 히스토리 항목 수: {len(bid_items)}")
            for i, item in enumerate(bid_items[:3]):  # 최근 3개만 표시
                price_elem = item.find('span', class_='font-bold text-blue-600')
                name_elem = item.find('span', class_='font-medium text-gray-900')
                if price_elem and name_elem:
                    print(f"  {i+1}. {name_elem.text} - {price_elem.text}")
        else:
            print("입찰 히스토리 데이터 없음")
    else:
        print("입찰 히스토리 섹션 없음")
        
else:
    print("❌ 입찰 폼을 찾을 수 없음")
    # 로그인 상태 확인
    if 'sign_in' in auction_page.url:
        print("로그인이 안된 것 같음")