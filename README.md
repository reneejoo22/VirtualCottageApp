
# 🏡 Virtual Cottage App
> 나만의 스마트 집중 환경 iOS 앱


## 🎬 시연 영상
[유튜브 링크] https://youtu.be/DkoLfmEDAYQ?si=HimUEBRq4SHIDNj- 


## 🖥 개발 환경
| 항목 | 버전 |  
|------|------|  
| Xcode | 16.x |  
| 시뮬레이터 | iPhone 17 (iOS 26.4) |  
| 언어 | Swift |  


<img width="250" height="600" alt="Simulator Screenshot - iPhone 17 - 2026-06-05 at 23 04 28" src="https://github.com/user-attachments/assets/0f05721e-2735-4dd4-9339-2e5de452bb21" />     

[홈화면 이미지]    

## 📱 소개
Smart Virtual Cottage는 공부·작업 집중 환경을 제공하는 iOS 앱입니다.
PC 전용으로만 존재하던 Virtual Cottage의 감성적인 코티지 분위기에
**실시간 날씨 연동**과 **Gemini AI 기반 집중 시간 추천**을 더해,
모바일에서도 나만의 집중 공간을 경험할 수 있도록 합니다.

---

## ✨ 주요 기능

### 🌤 실시간 날씨 연동 배경  
<img width="250" height="600" alt="Simulator Screenshot - iPhone 17 - 2026-06-05 at 23 06 33" src="https://github.com/user-attachments/assets/cedd44e2-71bd-46cb-b2d8-6828c1f37edc" />  

[안개 낀 날씨일 때]     

[날씨별 배경 이미지 - 맑음/비/눈/안개 4장 나란히]

현재 위치 또는 선택한 도시의 실시간 날씨에 따라 코티지 배경이 자동으로 변경됩니다.
- 맑음 → 코티지 낮 배경
- 비 → 빗속 코티지
- 눈 → 설경 코티지
- 흐림/안개 → 안개 낀 코티지

---

### 🤖 Gemini AI 집중 시간 추천
<img width="250" height="650" alt="Simulator Screenshot - iPhone 17 - 2026-06-05 at 23 36 18" src="https://github.com/user-attachments/assets/1f7a3842-5568-4bc0-baba-3241007885b0" />    

[AI 팝업 이미지]  

투두리스트 항목을 Gemini AI가 분석하여 적정 집중 시간과 세션 수를 자동 추천합니다.
추천값은 수동으로 조정도 가능합니다.

---

### ⏱ 포모도로 타이머  
<img width="250" height="600" alt="Simulator Screenshot - iPhone 17 - 2026-06-05 at 23 36 56" src="https://github.com/user-attachments/assets/0ad7877d-930f-4402-87bd-d446ed296cab" />

[타이머 화면 이미지]  

- 원형 프로그레스 바로 남은 시간 시각화
- 🔥 세션 카운터 표시
- +/- 버튼으로 실시간 시간 조절 (길게 누르면 빠르게 조절)
- 일시정지 / 종료 기능
- 세션 완료 시 Gemini AI 칭찬 메시지

---

### 📝 투두리스트
<img width="250" height="600" alt="Simulator Screenshot - iPhone 17 - 2026-06-05 at 23 38 55" src="https://github.com/user-attachments/assets/7277853a-3738-457f-9561-0f75e9a9bb50" />  
<img width="250" height="600" alt="Simulator Screenshot - iPhone 17 - 2026-06-05 at 23 40 50" src="https://github.com/user-attachments/assets/25cf8358-13c4-43d8-8f6e-fed24527f6eb" />  

[투두리스트 이미지]

- 할일 추가 / 체크 / 삭제
- 완료 항목 취소선 표시

---

### 📊 이번 주 집중 통계  
<img width="250" height="600" alt="Simulator Screenshot - iPhone 17 - 2026-06-05 at 23 43 04" src="https://github.com/user-attachments/assets/90efac37-8a6a-4f11-9ea5-f924f518b696" />  

[통계 화면 이미지]  

- 요일별 집중시간 막대그래프
- 총 집중시간 / 평균 / 최고 집중 요일 분석
- Gemini AI 한줄 코멘트

---

### ⚙️ 설정
<img width="250" height="600" alt="Simulator Screenshot - iPhone 17 - 2026-06-05 at 23 43 39" src="https://github.com/user-attachments/assets/482d7c53-16fb-4e08-b1d3-62b8aa71e4fa" />  

[설정 화면 이미지]

- 빗소리 / 장작 / 키보드 사운드 믹서
- 세션 종료 알림 On/Off
- 날씨 지역 변경 (현재 위치 / 런던 / 체라푼지 / 마나우스 / 무르만스크 / 두바이 / 샌프란시스코 / 서울 / 등등)


<img width="250" height="600" alt="Simulator Screenshot - iPhone 17 - 2026-06-05 at 23 49 59" src="https://github.com/user-attachments/assets/dd55058d-ddd6-4be7-b2e7-4325d5045298" />
<img width="250" height="600" alt="Simulator Screenshot - iPhone 17 - 2026-06-05 at 23 49 55" src="https://github.com/user-attachments/assets/9285c571-1524-4992-9d69-8bea9c5036b5" />

[세션중 어플을 나가면 알림이 뜸]
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

