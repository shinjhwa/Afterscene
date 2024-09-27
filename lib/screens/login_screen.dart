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
        content: Text('Login failed: ${e.message}'),  // 실패 메시지 출력
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 30,),
            const Text(
              'Afterscene',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5),
            // 이메일 입력 필드
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            // 비밀번호 입력 필드
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,  // 비밀번호 입력 시 텍스트가 숨겨짐
            ),
            // 로딩 상태일 때 로딩 인디케이터 표시
            if (isLoading)
              CircularProgressIndicator(),
            SizedBox(height: 10),
            // 로그인 버튼
            ElevatedButton(
              onPressed: isLoading ? null : _login,  // 로딩 중에는 버튼 비활성화
              child: Text('Login'),
            ),
            // 회원가입 화면으로 이동 버튼
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text('Don\'t have an account? Sign Up'),
            ),
            // 예시 이미지 (앱 로고 등)
            Image.asset(
              'assets/image.jpg',
              height: 100,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
