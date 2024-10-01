import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';  // Firebase 초기화를 위해 Firebase 관련 패키지 추가
import 'firebase_options.dart';  // Firebase 설정 파일을 가져옴
import 'screens/home_screen.dart';  // 홈 화면 UI
import 'screens/login_screen.dart';  // 로그인 화면 UI
import 'screens/signup_screen.dart';  // 회원가입 화면 UI
import 'screens/movie_room_screen.dart';  // 영화 방 UI
import 'screens/add_movie_screen.dart';  // Add Movie 화면 UI 추가
import 'screens/my_page_screen.dart';  // My Page 화면 UI 추가
import 'screens/reply_screen.dart';  // Reply 화면 UI 추가
import 'package:firebase_auth/firebase_auth.dart';  // Firebase Auth 관련 패키지 추가

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Afterscene',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => MainScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => SignUpScreen(),
        '/addMovie': (context) => AddMovieScreen(),
        '/myPage': (context) => MyPageScreen(
          userId: FirebaseAuth.instance.currentUser?.uid ?? '', // 현재 로그인된 사용자 ID 전달
          isEditable: true, // 자신의 페이지이므로 수정 가능하게 설정
        ),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final Widget? child; // 새로운 화면을 전달할 수 있도록 child 추가

  MainScreen({this.child}); // 생성자에서 child 전달 가능하게 설정

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // 로그인한 사용자의 userId
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  // 화면 선택에 따른 위젯 리스트
  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    AddMovieScreen(),
    MyPageScreen(
      userId: FirebaseAuth.instance.currentUser?.uid ?? '', // 로그인된 사용자 ID 전달
      isEditable: true, // 본인 페이지이므로 수정 가능
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child ?? _widgetOptions[_selectedIndex], // 만약 child가 있으면 해당 화면을 보여줌
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Movie',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Page',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
