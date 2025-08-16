#!/usr/bin/env python3
"""
Playwright를 사용한 실제 브라우저 테스트
"""

import asyncio
from playwright.async_api import async_playwright
import sys

BASE_URL = "http://timeplanner.kr"
SELLER_EMAIL = "muhammadsoccertj@gmail.com"
SELLER_PASSWORD = "muhammad:jon1"

async def test_delete_buttons():
    async with async_playwright() as p:
        # 브라우저 시작 (headless=False로 변경하면 브라우저 창이 보임)
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context()
        page = await context.new_page()
        
        print("=== Playwright 브라우저 테스트 시작 ===")
        
        try:
            # 1. 로그인 페이지로 이동
            print("\n1. 로그인 페이지로 이동...")
            await page.goto(f"{BASE_URL}/sellers/sign_in")
            await page.wait_for_load_state('networkidle')
            
            # 2. 로그인 수행
            print("2. 로그인 수행...")
            await page.fill('#seller_email', SELLER_EMAIL)
            await page.fill('#seller_password', SELLER_PASSWORD)
            
            # 로그인 버튼 클릭 (좀 더 구체적인 선택자 사용)
            await page.click('input[value="로그인"], button:has-text("로그인"), input[type="submit"]')
            await page.wait_for_load_state('networkidle')
            await page.wait_for_timeout(2000)  # 2초 추가 대기
            
            print(f"로그인 후 URL: {page.url}")
            
            # 3. 거래 목록 페이지 이동
            print("\n3. 거래 목록 페이지로 이동...")
            await page.goto(f"{BASE_URL}/sellers/trades")
            await page.wait_for_load_state('networkidle')
            
            # 페이지 내용 확인
            title = await page.title()
            print(f"페이지 제목: {title}")
            
            # 삭제 버튼 찾기 (index 페이지)
            delete_buttons_index = await page.query_selector_all('button:has-text("삭제")')
            print(f"index 페이지 삭제 버튼 개수: {len(delete_buttons_index)}")
            
            # 4. 상세 페이지로 이동
            print("\n4. 거래 상세 페이지로 이동...")
            await page.goto(f"{BASE_URL}/sellers/trades/1")
            await page.wait_for_load_state('networkidle')
            
            # 페이지가 제대로 로드되었는지 확인
            content = await page.content()
            if len(content) < 1000:
                print("❌ 상세 페이지가 제대로 로드되지 않음")
                print(f"응답 길이: {len(content)} 바이트")
                return
            
            print(f"✅ 상세 페이지 로드됨 ({len(content)} 바이트)")
            
            # 삭제 버튼 찾기
            delete_buttons = await page.query_selector_all('button:has-text("삭제")')
            print(f"상세 페이지 삭제 버튼 개수: {len(delete_buttons)}")
            
            if delete_buttons:
                for i, button in enumerate(delete_buttons):
                    button_text = await button.text_content()
                    button_classes = await button.get_attribute('class')
                    data_confirm = await button.get_attribute('data-turbo-confirm')
                    
                    print(f"\n삭제 버튼 #{i+1}:")
                    print(f"  텍스트: {button_text}")
                    print(f"  클래스: {button_classes}")
                    print(f"  data-turbo-confirm: {data_confirm}")
                    
                    # 부모 form 확인
                    parent_form = await button.query_selector('xpath=ancestor::form[1]')
                    if parent_form:
                        form_action = await parent_form.get_attribute('action')
                        form_method = await parent_form.get_attribute('method')
                        method_input = await parent_form.query_selector('input[name="_method"]')
                        method_value = await method_input.get_attribute('value') if method_input else None
                        
                        print(f"  Form action: {form_action}")
                        print(f"  Form method: {form_method}")
                        print(f"  _method: {method_value}")
            
            # 5. 삭제 버튼 클릭 테스트 (실제로는 취소)
            print("\n5. 삭제 버튼 클릭 테스트...")
            if delete_buttons:
                # 대화상자 이벤트 리스너 설정
                async def handle_dialog(dialog):
                    print(f"확인 대화상자: {dialog.message}")
                    await dialog.dismiss()  # 취소 클릭 (데이터 보존)
                
                page.on("dialog", handle_dialog)
                
                # 첫 번째 삭제 버튼 클릭
                await delete_buttons[0].click()
                await page.wait_for_timeout(1000)  # 1초 대기
                print("✅ 삭제 버튼 클릭 및 확인 대화상자 처리 완료")
            else:
                print("❌ 삭제 버튼을 찾을 수 없음")
            
            # 6. 거래 완료 처리 버튼 테스트
            print("\n6. 거래 완료 처리 버튼 테스트...")
            complete_links = await page.query_selector_all('a:has-text("거래 완료 처리")')
            if complete_links:
                for i, link in enumerate(complete_links):
                    href = await link.get_attribute('href')
                    method = await link.get_attribute('data-method')
                    confirm = await link.get_attribute('confirm')
                    
                    print(f"거래 완료 링크 #{i+1}:")
                    print(f"  href: {href}")
                    print(f"  data-method: {method}")
                    print(f"  confirm: {confirm}")
                    
                    if method != 'patch' and method != 'post':
                        print("  ❌ GET 방식으로 설정되어 있어 오류 발생 예상")
            else:
                print("거래 완료 처리 버튼을 찾을 수 없음")
            
            print("\n=== 테스트 완료 ===")
            
        except Exception as e:
            print(f"❌ 테스트 중 오류 발생: {e}")
            # 스크린샷 저장
            await page.screenshot(path="error_screenshot.png")
            print("오류 스크린샷 저장: error_screenshot.png")
        
        finally:
            await browser.close()

if __name__ == "__main__":
    asyncio.run(test_delete_buttons())