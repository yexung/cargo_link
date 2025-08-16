#!/usr/bin/env python3
"""
로그인 문제 디버깅
"""

import asyncio
from playwright.async_api import async_playwright

BASE_URL = "http://timeplanner.kr"
SELLER_EMAIL = "muhammadsoccertj@gmail.com"
SELLER_PASSWORD = "muhammad:jon1"

async def debug_login():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context()
        page = await context.new_page()
        
        try:
            print("=== 로그인 디버깅 ===")
            
            # 1. 로그인 페이지로 이동
            print("\n1. 로그인 페이지로 이동...")
            await page.goto(f"{BASE_URL}/sellers/sign_in")
            await page.wait_for_load_state('networkidle')
            
            # 페이지 제목 확인
            title = await page.title()
            print(f"페이지 제목: {title}")
            
            # 폼 요소 확인
            email_input = await page.query_selector('#seller_email')
            password_input = await page.query_selector('#seller_password')
            submit_button = await page.query_selector('input[type="submit"]')
            
            print(f"이메일 입력 필드 존재: {email_input is not None}")
            print(f"비밀번호 입력 필드 존재: {password_input is not None}")
            print(f"제출 버튼 존재: {submit_button is not None}")
            
            if submit_button:
                submit_value = await submit_button.get_attribute('value')
                print(f"제출 버튼 값: {submit_value}")
            
            # 2. 폼 데이터 입력
            print("\n2. 폼 데이터 입력...")
            await page.fill('#seller_email', SELLER_EMAIL)
            await page.fill('#seller_password', SELLER_PASSWORD)
            
            # 입력된 값 확인
            email_value = await page.input_value('#seller_email')
            password_value = await page.input_value('#seller_password')
            print(f"입력된 이메일: {email_value}")
            print(f"입력된 비밀번호: {'*' * len(password_value) if password_value else 'None'}")
            
            # 3. 로그인 시도
            print("\n3. 로그인 시도...")
            
            # 네트워크 응답 모니터링
            async def handle_response(response):
                if '/sellers/sign_in' in response.url and response.request.method == 'POST':
                    print(f"로그인 POST 요청 응답: {response.status}")
                    print(f"리다이렉트 위치: {response.headers.get('location', 'None')}")
            
            page.on('response', handle_response)
            
            # 폼 제출
            await page.click('input[type="submit"]')
            await page.wait_for_load_state('networkidle')
            await page.wait_for_timeout(3000)
            
            # 최종 URL 확인
            final_url = page.url
            print(f"\n최종 URL: {final_url}")
            
            # 로그인 성공 여부 판단
            if final_url == f"{BASE_URL}/sellers/sign_in":
                print("❌ 로그인 실패 - 로그인 페이지에 머물러 있음")
                
                # 오류 메시지 확인
                error_messages = await page.query_selector_all('.alert-danger, .flash-error, .error')
                if error_messages:
                    for msg in error_messages:
                        text = await msg.text_content()
                        print(f"오류 메시지: {text}")
                else:
                    print("표시된 오류 메시지 없음")
                    
                # 페이지 내용 확인
                content = await page.content()
                if 'Invalid' in content or '잘못된' in content or '오류' in content:
                    print("페이지에서 로그인 오류 관련 텍스트 발견")
                    
            else:
                print("✅ 로그인 성공")
                
                # 현재 사용자 정보 확인 (네비게이션 바에서)
                user_info = await page.query_selector('text=muhammadsoccertj')
                if user_info:
                    print("사용자 정보가 네비게이션에 표시됨")
                
        except Exception as e:
            print(f"❌ 오류 발생: {e}")
            await page.screenshot(path="login_debug_error.png")
            
        finally:
            await browser.close()

if __name__ == "__main__":
    asyncio.run(debug_login())