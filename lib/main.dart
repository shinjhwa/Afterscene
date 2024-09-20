// Flutter 앱이 시작되는 지점
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';  // Firebase 초기화를 위해 Firebase 관련 패키지 추가
import 'firebase_options.dart';  // Firebase 설정 파일을 가져옴 (이 파일은 Firebase 프로젝트와 연결되는 설정 정보)
import 'screens/home_screen.dart';  // 홈 화면 UI
import 'screens/login_screen.dart';  // 로그인 화면 UI
import 'screens/signup_screen.dart';  // 회원가입 화면 UI
import 'screens/movie_room_screen.dart';  // 영화 방 UI
import 'screens/add_movie_screen.dart';  // Add Movie 화면 UI 추가
import 'screens/my_page_screen.dart';  // My Page 화면 UI 추가

void main() async {
  // 비동기 작업을 수행하기 위해 main 함수를 async로 설정
  WidgetsFlutterBinding.ensureInitialized(); // Flutter의 위젯 시스템을 미리 초기화 (비동기 작업을 위해 필요)

  // Firebase를 앱에 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  // Firebase 옵션을 플랫폼별로 초기화 (ios, android, 웹 등)
  );

  // 앱 실행
  runApp(MyApp()); // MyApp 클래스를 호출하여 Flutter 앱 실행
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // MaterialApp은 Flutter에서 앱 전체의 기본 구조와 테마를 설정하는 위젯
    return MaterialApp(
      title: 'Afterscene',  // 앱의 제목, 주로 앱 스위처나 툴바에서 사용
      theme: ThemeData(
        primarySwatch: Colors.blue,  // 앱의 기본 색상 팔레트 설정 (파란색 계열)
        useMaterial3: true,  // Material Design 3 적용 (필요에 따라 활성화 가능)
      ),
      initialRoute: '/login',  // 앱이 시작될 때 첫 화면을 로그인 화면으로 설정
      routes: {
        // 라우팅 설정: 앱에서 페이지 간 이동을 설정하는 부분
        '/': (context) => HomeScreen(),  // 기본 화면으로 홈 화면 지정
        '/login': (context) => LoginScreen(),  // '/login' 경로로 이동 시 LoginScreen 호출
        '/register': (context) => SignUpScreen(),  // '/register' 경로로 이동 시 회원가입 화면 호출
        '/movie': (context) => MovieRoomScreen(movieTitle: ''),  // 영화 방 화면으로 이동 시 MovieRoomScreen 호출 (초기에는 빈 제목 전달)
        '/addMovie': (context) => AddMovieScreen(),  // 영화 추가 화면 경로 추가
        '/myPage': (context) => MyPageScreen(),  // 마이 페이지 화면 경로 추가
      },
    );
  }
}
