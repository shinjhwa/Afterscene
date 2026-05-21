# 🎬 Afterscene (애프터씬)
> **2024-2학기 다학제 캡스톤디자인 프로젝트**
> 영화 동아리 'Afterscene'의 연계 수요와 필요성에 기반하여 개발된 크로스 플랫폼 영화 리뷰 및 네트워킹 애플리케이션

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=Flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=Firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=Dart&logoColor=white)

---

## 📌 프로젝트 개요
* **수행 기간:** 2024학년도 2학기 (다학제 캡스톤디자인)
* **개발 환경:** Flutter (Dart), Firebase (Authentication, Firestore)
* **기획 배경:** 영화 감상 후의 여운을 기록하고, 동아리 부원들과 깊이 있는 감상을 교류할 수 있는 통합 공간의 필요성 대두. 기존의 단편적인 소통 방식을 탈피하여 영화별 '방(Room)' 중심의 아카이빙 및 소통 플랫폼을 구축하고자 함.

---

## ✨ 핵심 기능

### 🔐 1. 인증 및 사용자 관리 (`/login`, `/register`)
* **Firebase Auth 기반 보안 시스템:** 안전한 사용자 회원가입 및 로그인 처리.
* **사용자 상태 동기화:** 앱 전반에서 현재 로그인된 유저 세션(`uid`)을 유지하여 보안 및 개인화 서비스 제공.

### 🏠 2. 홈 화면 및 메인 구조 (`HomeScreen`, `MainScreen`)
* **Bottom Navigation Bar 탑재:** 한 화면에서 홈, 영화 추가, 마이페이지를 직관적으로 탭 전환할 수 있는 하이브리드 라우팅 구현.
* **다크 모드 기본 적용:** 영화 커뮤니티의 특성을 살려 시각적 몰입감을 극대화하는 `Brightness.dark` 테마 커스텀.

### 🎬 3. 영화 아카이빙 및 소통 공간 (`AddMovieScreen`, `MovieRoomScreen`)
* **기록 관리:** 유저가 직접 관람한 영화를 플랫폼에 등록하고 관리할 수 있는 기능.
* **영화별 개별 룸 생성:** 영화를 중심으로 부원들이 모여 깊이 있는 리뷰를 나눌 수 있는 전용 스크린 제공.

### 💬 4. 평론 및 댓글 연동 시스템 (`ReplyScreen`, `UserReviewsScreen`)
* **실시간 피드백:** 특정 영화 룸 내에서 타 사용자의 리뷰에 댓글(`Reply`)을 달아 쌍방향 소통 채널 확보.
* **유저 리뷰 모아보기:** 개인이 작성한 평론들을 타임라인 형태로 축적.

### 👤 5. 개인화 스페이스 (`MyPageScreen`, `EditProfileScreen`, `Liked/Saw Movie`)
* **프로필 커스텀:** 선호하는 영화 장르를 다이나믹하게 추가하고 개인 프로필을 수정하는 기능.
* **히스토리 분리:** 내가 '좋아요 한 영화(`LikedMovieScreen`)'와 '이미 본 영화(`SawMoviesScreen`)'를 직관적으로 분류하여 개인 데이터 대시보드화.

---

## 🛠 기술 스택 및 아키텍처

### Frontend
* **Framework:** Flutter (Android / iOS / Web / Desktop 멀티 플랫폼 대응)

### Backend & Infrastructure
* **Baas:** Firebase
  * **Firebase Core & Auth:** 멀티 플랫폼 호환 인프라 구성 및 사용자 인증.
  * **Firebase Options (Cross-Platform):** `FlutterFire CLI`를 통해 Web, Android, iOS, macOS, Windows 환경에 따른 맞춤형 API 키 및 앱 자격증명 동적 인젝션 환경 구축.

---

## 📂 프로젝트 구조 (디렉토리 아키텍처)

```text
lib/
├── firebase_options.dart      # FlutterFire CLI로 자동 생성된 멀티플랫폼 파이어베이스 설정
├── main.dart                  # 앱 진입점, 글로벌 테마 설정 및 Route 정의
└── screens/                   # 도메인별 화면 UI 레이어
    ├── home_screen.dart           # 메인 홈 피드 화면
    ├── login_screen.dart          # 사용자 인증 로그인 화면
    ├── signup_screen.dart         # 회원가입 화면
    ├── add_movie_screen.dart      # 새 영화 등록 및 아카이빙 화면
    ├── movie_room_screen.dart     # 영화별 상세 소통 룸
    ├── reply_screen.dart          # 리뷰 댓글 및 토론 스크린
    ├── my_page_screen.dart        # 유저 대시보드 프로필 화면
    ├── edit_profile_screen.dart   # 프로필 및 선호 장르 수정 화면
    ├── liked_movie_screen.dart    # 좋아요 한 영화 리스트
    ├── saw_movies_screen.dart     # 관람 완료한 영화 리스트
    └── user_reviews_screen.dart   # 작성한 유저 리뷰 아카이브
