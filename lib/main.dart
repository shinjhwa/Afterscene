import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';  // Firebase 초기화를 위해 추가
import 'firebase_options.dart';  // Firebase 옵션 파일을 가져옴
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/movie_room_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Firebase 초기화를 위해 Flutter의 위젯 시스템 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  // Firebase 설정 사용
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Afterscene',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true, // 필요에 따라 Material 3을 사용할 수 있습니다.
      ),
      initialRoute: '/login', // 앱 실행 시 로그인 화면으로 시작
      routes: {
        '/': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => SignUpScreen(),
        '/movie': (context) => MovieRoomScreen(movieTitle: ''),
      },
    );
  }
}
