#!/usr/bin/env python3
"""
간단한 삭제 버튼 HTML 확인
"""

import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

BASE_URL = "http://timeplanner.kr"
SELLER_EMAIL = "muhammadsoccertj@gmail.com"
SELLER_PASSWORD = "muhammad:jon1"

def check_delete_button():
    session = requests.Session()
    session.verify = False
    
    print("=== 삭제 버튼 HTML 확인 ===")
    
    # 1. 판매자 로그인
    print("\n1. 판매자 로그인...")
    login_url = urljoin(BASE_URL, "/sellers/sign_in")
    response = session.get(login_url)
    
    # CSRF 토큰 획득
    soup = BeautifulSoup(response.text, 'html.parser')
    csrf_token = None
    csrf_meta = soup.find('meta', attrs={'name': 'csrf-token'})
    if csrf_meta:
        csrf_token = csrf_meta.get('content')
    
    # 로그인 요청
    login_data = {
        "seller[email]": SELLER_EMAIL,
        "seller[password]": SELLER_PASSWORD,
        "authenticity_token": csrf_token,
        "commit": "Log in"
    }
    
    response = session.post(login_url, data=login_data, allow_redirects=True)
    print(f"로그인 후 URL: {response.url}")
    
    # 2. 거래 상세 페이지 접근
    print("\n2. 거래 상세 페이지 접근...")
    trade_url = urljoin(BASE_URL, "/sellers/trades/1")
    response = session.get(trade_url)
    
    print(f"응답 코드: {response.status_code}")
    print(f"응답 길이: {len(response.text)} 바이트")
    
    if response.status_code == 200:
        # HTML에서 form 요소들 찾기
        soup = BeautifulSoup(response.text, 'html.parser')
        
        # 삭제 관련 요소들 찾기
        print("\n3. 삭제 관련 요소 찾기...")
        
        # form 태그들 찾기
        forms = soup.find_all('form')
        print(f"총 form 태그 개수: {len(forms)}")
        
        for i, form in enumerate(forms):
            print(f"\nForm #{i+1}:")
            print(f"  action: {form.get('action')}")
            print(f"  method: {form.get('method')}")
            
            # form 내부의 input 확인
            inputs = form.find_all('input')
            for inp in inputs:
                if inp.get('name') == '_method':
                    print(f"  _method: {inp.get('value')}")
                elif inp.get('type') == 'submit':
                    print(f"  submit button: {inp.get('value')}")
        
        # button 태그들 찾기
        buttons = soup.find_all('button')
        print(f"\n총 button 태그 개수: {len(buttons)}")
        
        for i, button in enumerate(buttons):
            button_text = button.get_text().strip()
            if '삭제' in button_text:
                print(f"\n삭제 버튼 #{i+1}:")
                print(f"  텍스트: {button_text}")
                print(f"  type: {button.get('type')}")
                print(f"  name: {button.get('name')}")
                print(f"  form action: {button.find_parent('form', {}).get('action') if button.find_parent('form') else 'None'}")
                print(f"  data-turbo-confirm: {button.get('data-turbo-confirm')}")
                
                # 부모 form 확인
                parent_form = button.find_parent('form')
                if parent_form:
                    print(f"  부모 form method: {parent_form.get('method')}")
                    method_input = parent_form.find('input', {'name': '_method'})
                    if method_input:
                        print(f"  _method input: {method_input.get('value')}")
        
        # 전체 HTML에서 삭제 관련 부분 추출
        print(f"\n4. 삭제 관련 HTML 코드:")
        delete_sections = []
        for form in forms:
            if 'delete' in str(form).lower() or '삭제' in form.get_text():
                delete_sections.append(str(form))
        
        for section in delete_sections:
            print("="*50)
            print(section)
    
    else:
        print("페이지 접근 실패")

if __name__ == "__main__":
    check_delete_button()