#!/usr/bin/env python3
import asyncio
import aiohttp
import time
from concurrent.futures import ThreadPoolExecutor
import threading

# 테스트 설정
BASE_URL = "https://cargolink.cc"
LOGIN_URL = f"{BASE_URL}/admin_users/sign_in"
ADMIN_URL = f"{BASE_URL}/admin"
CONCURRENT_USERS = 500
REQUESTS_PER_USER = 20

# 통계
stats = {
    'total_requests': 0,
    'successful_requests': 0,
    'failed_requests': 0,
    'response_times': [],
    'errors': []
}
stats_lock = threading.Lock()

def update_stats(success, response_time, error=None):
    with stats_lock:
        stats['total_requests'] += 1
        if success:
            stats['successful_requests'] += 1
        else:
            stats['failed_requests'] += 1
            if error:
                stats['errors'].append(str(error))
        stats['response_times'].append(response_time)

async def make_request(session, url):
    """단일 요청 수행"""
    start_time = time.time()
    try:
        async with session.get(url, timeout=aiohttp.ClientTimeout(total=10)) as response:
            await response.read()  # 전체 응답 읽기
            response_time = time.time() - start_time
            success = response.status < 400
            update_stats(success, response_time)
            return response.status, response_time
    except Exception as e:
        response_time = time.time() - start_time
        update_stats(False, response_time, e)
        return 0, response_time

async def user_simulation(user_id):
    """개별 사용자 시뮬레이션"""
    connector = aiohttp.TCPConnector(limit=100, ssl=False)
    async with aiohttp.ClientSession(connector=connector) as session:
        tasks = []
        urls = [
            BASE_URL,
            f"{BASE_URL}/sellers/sign_in",
            f"{BASE_URL}/vehicles",
            f"{BASE_URL}/trades"
        ]
        
        for _ in range(REQUESTS_PER_USER):
            for url in urls:
                task = asyncio.create_task(make_request(session, url))
                tasks.append(task)
        
        await asyncio.gather(*tasks, return_exceptions=True)

async def run_load_test():
    """부하 테스트 실행"""
    print(f"🚀 부하 테스트 시작: {CONCURRENT_USERS}명 동시 사용자, 각각 {REQUESTS_PER_USER * 4}개 요청")
    print(f"📊 총 예상 요청 수: {CONCURRENT_USERS * REQUESTS_PER_USER * 4}")
    
    start_time = time.time()
    
    # 동시 사용자 시뮬레이션
    tasks = []
    for user_id in range(CONCURRENT_USERS):
        task = asyncio.create_task(user_simulation(user_id))
        tasks.append(task)
    
    await asyncio.gather(*tasks, return_exceptions=True)
    
    end_time = time.time()
    total_time = end_time - start_time
    
    # 결과 분석
    print(f"\n📈 부하 테스트 결과:")
    print(f"⏱️  총 소요 시간: {total_time:.2f}초")
    print(f"📞 총 요청 수: {stats['total_requests']}")
    print(f"✅ 성공: {stats['successful_requests']} ({stats['successful_requests']/stats['total_requests']*100:.1f}%)")
    print(f"❌ 실패: {stats['failed_requests']} ({stats['failed_requests']/stats['total_requests']*100:.1f}%)")
    
    if stats['response_times']:
        avg_response_time = sum(stats['response_times']) / len(stats['response_times'])
        max_response_time = max(stats['response_times'])
        min_response_time = min(stats['response_times'])
        
        print(f"⚡ 평균 응답시간: {avg_response_time:.3f}초")
        print(f"🔥 최대 응답시간: {max_response_time:.3f}초")
        print(f"⚡ 최소 응답시간: {min_response_time:.3f}초")
        
        rps = stats['total_requests'] / total_time
        print(f"🚀 초당 처리 요청 수 (RPS): {rps:.1f}")
        
        # 동시 접속자 추정
        estimated_concurrent_users = int(rps * avg_response_time)
        print(f"👥 예상 최대 동시 접속자: {estimated_concurrent_users}명")
    
    if stats['errors']:
        print(f"\n🚨 주요 에러:")
        error_counts = {}
        for error in stats['errors']:
            error_counts[error] = error_counts.get(error, 0) + 1
        for error, count in sorted(error_counts.items(), key=lambda x: x[1], reverse=True)[:5]:
            print(f"   {error}: {count}회")

if __name__ == "__main__":
    asyncio.run(run_load_test())