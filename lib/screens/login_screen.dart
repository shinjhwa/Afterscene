import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();  // 이메일 입력 필드 컨트롤러
  final TextEditingController passwordController = TextEditingController();  // 비밀번호 입력 필드 컨트롤러
  bool isLoading = false;  // 로딩 상태를 추적하는 변수

  // 로그인 처리 함수
  void _login() async {
    setState(() {
      isLoading = true;  // 로딩 상태 시작
    });
    try {
      // Firebase Authentication을 사용한 이메일-비밀번호 로그인 처리
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),  // 이메일 값 트리밍 후 전달
        password: passwordController.text.trim(),  // 비밀번호 값 트리밍 후 전달
      );
      Navigator.pushReplacementNamed(context, '/'); // 로그인 성공 시 홈 화면으로 이동
    } on FirebaseAuthException catch (e) {
      // Firebase 인증 실패 시 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('로그인 실패: ${e.message}'),  // 실패 메시지 출력
      ));
    } finally {
      setState(() {
        isLoading = false;  // 로딩 상태 종료
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,  // 중앙에 배치
          crossAxisAlignment: CrossAxisAlignment.stretch,  // 가로로 꽉 채움
          children: [
            // 상단 이미지 로고
            Image.asset(
              'assets/image.jpg',  // 이미지 경로
              height: 100,  // 이미지 크기
              fit: BoxFit.contain,  // 이미지 비율 유지
            ),
            SizedBox(height: 20),  // 이미지와 텍스트 사이 여백
            // 앱 이름 텍스트
            const Text(
              'Afterscene',
              style: TextStyle(
                fontSize: 28,  // 텍스트 크기
                fontWeight: FontWeight.bold,  // 굵은 텍스트
                color: Colors.white,  // 텍스트 색상 흰색
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),  // 앱 이름과 입력 필드 사이 여백
            // 이메일 입력 필드 (밑줄 스타일 적용)
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: '이메일',  // 라벨을 한글로 변경
                labelStyle: TextStyle(color: Colors.white),  // 라벨 색상 흰색
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),  // 기본 밑줄 색상 흰색
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),  // 포커스 시 밑줄 색상 파란색
                ),
              ),
              style: TextStyle(color: Colors.white),  // 입력된 텍스트 색상 흰색
            ),
            SizedBox(height: 20),  // 이메일과 비밀번호 입력 칸 사이 여백
            // 비밀번호 입력 필드 (밑줄 스타일 적용)
            TextField(
              controller: passwordController,
              obscureText: true,  // 비밀번호 입력 시 텍스트 숨김 처리
              decoration: InputDecoration(
                labelText: '비밀번호',  // 라벨을 한글로 변경
                labelStyle: TextStyle(color: Colors.white),  // 라벨 색상 흰색
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),  // 기본 밑줄 색상 흰색
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),  // 포커스 시 밑줄 색상 파란색
                ),
              ),
              style: TextStyle(color: Colors.white),  // 입력된 텍스트 색상 흰색
            ),
            SizedBox(height: 40),  // 입력 필드와 버튼 사이 여백
            // 로그인 버튼
            ElevatedButton(
              onPressed: isLoading ? null : _login,  // 로딩 중에는 버튼 비활성화
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,  // 버튼 배경색을 파란색으로 설정
                padding: EdgeInsets.symmetric(vertical: 15),  // 버튼 패딩 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),  // 둥근 모서리 설정
                ),
              ),
              child: Text('로그인', style: TextStyle(color: Colors.white)),  // 한글로 로그인 버튼 텍스트
            ),
            SizedBox(height: 20),  // 로그인 버튼과 텍스트 사이 여백
            // 하단에 회원가입 텍스트 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '계정이 없으신가요?',  // 설명 텍스트
                  style: TextStyle(color: Colors.white),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');  // 회원가입 화면으로 이동
                  },
                  child: Text(
                    '회원가입',  // 텍스트 버튼
                    style: TextStyle(color: Colors.blue),  // 파란색 링크 텍스트
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
