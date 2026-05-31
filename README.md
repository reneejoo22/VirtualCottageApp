# VirtualCottageApp
# 🏡 Smart Virtual Cottage
> 나만의 스마트 집중 환경 iOS 앱

## 🖥 개발 환경
| 항목 | 버전 |  
|------|------|  
| Xcode | 16.x |  
| 시뮬레이터 | iPhone 17 (iOS 26.4) |  
| 언어 | Swift |  


[홈 화면 이미지]

## 📱 소개
Smart Virtual Cottage는 공부·작업 집중 환경을 제공하는 iOS 앱입니다.
PC 전용으로만 존재하던 Virtual Cottage의 감성적인 코티지 분위기에
**실시간 날씨 연동**과 **Gemini AI 기반 집중 시간 추천**을 더해,
모바일에서도 나만의 집중 공간을 경험할 수 있도록 합니다.

---

## ✨ 주요 기능

### 🌤 실시간 날씨 연동 배경
[날씨별 배경 이미지 - 맑음/비/눈/안개 4장 나란히]

현재 위치 또는 선택한 도시의 실시간 날씨에 따라 코티지 배경이 자동으로 변경됩니다.
- 맑음 → 코티지 낮 배경
- 비 → 빗속 코티지
- 눈 → 설경 코티지
- 흐림/안개 → 안개 낀 코티지

---

### 🤖 Gemini AI 집중 시간 추천
[AI 팝업 이미지]

투두리스트 항목을 Gemini AI가 분석하여 적정 집중 시간과 세션 수를 자동 추천합니다.
추천값은 수동으로 조정도 가능합니다.

---

### ⏱ 포모도로 타이머
[타이머 화면 이미지]

- 원형 프로그레스 바로 남은 시간 시각화
- 🔥 세션 카운터 표시
- +/- 버튼으로 실시간 시간 조절 (길게 누르면 빠르게 조절)
- 일시정지 / 종료 기능
- 세션 완료 시 Gemini AI 칭찬 메시지

---

### 📝 투두리스트
[투두리스트 이미지]

- 할일 추가 / 체크 / 삭제
- 토글로 접기/펼치기
- 완료 항목 취소선 표시

---

### 📊 이번 주 집중 통계
[통계 화면 이미지]

- 요일별 집중시간 막대그래프
- 총 집중시간 / 평균 / 최고 집중 요일 분석
- Gemini AI 한줄 코멘트

---

### ⚙️ 설정
[설정 화면 이미지]

- 빗소리 / 장작 / 키보드 사운드 믹서
- 세션 종료 알림 On/Off
- 날씨 지역 변경 (현재 위치 / 야쿠츠크 / 마나우스 / 두바이 / 샌프란시스코 / 서울)

---

## 🛠 기술 스택

| 분류 | 기술 |  
|------|------|  
| 개발환경 | Xcode, UIKit |  
| 데이터 | UserDefaults |  
| 위치 | CoreLocation |  
| 날씨 | OpenWeatherMap API |  
| AI | Gemini API (Google AI Studio) |  
| 사운드 | AVFoundation |  
| 알림 | UserNotifications |  

---

## 📂 프로젝트 구조
virtualCottage/  
├── HomeViewController.swift       # 홈 화면 (타이머, 투두, AI 팝업)  
├── SettingViewController.swift    # 설정 화면 (사운드, 알림, 지역)  
├── StatsViewController.swift      # 통계 화면  
├── TodoCell.swift                 # 투두 셀 커스텀  
└── resource/                      # 이미지, 사운드 리소스  

## 🎬 시연 영상
[유튜브 링크]

