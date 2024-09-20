import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 추가

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController(); // 이메일 입력 컨트롤러
  final TextEditingController passwordController = TextEditingController(); // 비밀번호 입력 컨트롤러
  final TextEditingController majorController = TextEditingController(); // 전공 입력 컨트롤러
  bool isLoading = false;
  List<String> selectedGenres = []; // 선택된 장르를 저장하는 리스트

  // Firebase를 이용한 회원가입 처리 함수
  void _signUp() async {
    setState(() {
      isLoading = true;  // 로딩 상태 시작
    });
    try {
      // Firebase Authentication을 사용한 회원가입 처리
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;

      // Firestore에 사용자 정보 저장
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'email': user.email,
        'major': majorController.text.trim(), // 전공 정보 저장
        'genres': selectedGenres, // 선택한 장르 저장
        'displayName': user.displayName ?? '',
      });

      Navigator.pushReplacementNamed(context, '/'); // 회원가입 후 홈 화면으로 이동
    } on FirebaseAuthException catch (e) {
      // Firebase 인증 실패 시 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Sign up failed: ${e.message}'),
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
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
            // 전공 입력 필드
            TextField(
              controller: majorController,
              decoration: InputDecoration(labelText: 'Enter your major (ends with ~과)'),
            ),
            // 장르 선택 (다중 선택 가능)
            Wrap(
              spacing: 8.0,
              children: ['액션', '범죄', 'SF', '코미디', '로맨스 코미디', '스릴러', '공포', '전쟁', '스포츠', '판타지', '음악', '뮤지컬', '멜로'].map((genre) {
                return ChoiceChip(
                  label: Text(genre),
                  selected: selectedGenres.contains(genre),
                  onSelected: (selected) {
                    setState(() {
                      selected ? selectedGenres.add(genre) : selectedGenres.remove(genre);
                    });
                  },
                );
              }).toList(),
            ),
            if (isLoading)
              CircularProgressIndicator(),
            SizedBox(height: 20),
            // 회원가입 버튼
            ElevatedButton(
              onPressed: isLoading ? null : _signUp,  // 로딩 중에는 버튼 비활성화
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
