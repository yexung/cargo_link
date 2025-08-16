#!/usr/bin/env python3
import requests
import time
import threading
from concurrent.futures import ThreadPoolExecutor

# 테스트 설정
BASE_URL = "http://localhost:3000"
CONCURRENT_USERS = 60
REQUESTS_PER_USER = 3

# 통계
stats = {
    'total_requests': 0,
    'successful_requests': 0,
    'failed_requests': 0,
    'response_times': [],
    'errors': []
}
stats_lock = threading.Lock()

def update_stats(success, response_time, status_code=None, error=None):
    with stats_lock:
        stats['total_requests'] += 1
        if success:
            stats['successful_requests'] += 1
        else:
            stats['failed_requests'] += 1
            if error:
                stats['errors'].append(f"{status_code}: {str(error)}")
        stats['response_times'].append(response_time)

def make_request(url):
    """단일 요청 수행"""
    start_time = time.time()
    try:
        response = requests.get(url, timeout=5)
        response_time = time.time() - start_time
        success = response.status_code < 400
        update_stats(success, response_time, response.status_code)
        return response.status_code, response_time
    except Exception as e:
        response_time = time.time() - start_time
        update_stats(False, response_time, 0, e)
        return 0, response_time

def user_simulation(user_id):
    """개별 사용자 시뮬레이션"""
    urls = [
        BASE_URL,
        f"{BASE_URL}/admin_users/sign_in",
        f"{BASE_URL}/vehicles"
    ]
    
    for _ in range(REQUESTS_PER_USER):
        for url in urls:
            make_request(url)

def run_load_test():
    """부하 테스트 실행"""
    print(f"🚀 부하 테스트 시작: {CONCURRENT_USERS}명 동시 사용자, 각각 {REQUESTS_PER_USER * 3}개 요청")
    print(f"📊 총 예상 요청 수: {CONCURRENT_USERS * REQUESTS_PER_USER * 3}")
    
    start_time = time.time()
    
    # ThreadPoolExecutor 사용하여 동시 실행
    with ThreadPoolExecutor(max_workers=CONCURRENT_USERS) as executor:
        futures = []
        for user_id in range(CONCURRENT_USERS):
            future = executor.submit(user_simulation, user_id)
            futures.append(future)
        
        # 모든 작업 완료 대기
        for future in futures:
            future.result()
    
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
        
        if total_time > 0:
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
    run_load_test()