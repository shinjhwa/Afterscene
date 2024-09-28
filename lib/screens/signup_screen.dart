import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController majorController = TextEditingController();
  final List<String> selectedGenres = [];
  File? _profileImage;
  final List<String> genres = ['액션', '범죄', 'SF', '코미디', '로맨스 코미디', '스릴러', '공포', '전쟁', '스포츠', '판타지', '음악', '뮤지컬', '멜로'];
  bool isLoading = false;

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  Future<String?> _uploadProfileImage(String uid) async {
    if (_profileImage != null) {
      final storageRef = FirebaseStorage.instance.ref().child('profile_images/$uid.jpg');
      await storageRef.putFile(_profileImage!);
      return await storageRef.getDownloadURL();
    }
    return null;
  }


  void _signUp() async {
    setState(() {
      isLoading = true;  // 로딩 상태 시작
    });
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;
      String? profileImageUrl = await _uploadProfileImage(uid);

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': emailController.text.trim(),
        'name': nameController.text.trim(),
        'major': majorController.text.trim(),
        'profileImageUrl': profileImageUrl,
        'favoriteGenres': selectedGenres,
      });

      Navigator.pushReplacementNamed(context, '/'); // 회원가입 후 홈 화면으로 이동
    } on FirebaseAuthException catch (e) {
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
        title: Text('Create Account Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Afterscene Logo (Letter)',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                    ? Icon(Icons.add_a_photo, size: 50)
                    :null,
                ),
              ),

              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),

              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Enter your name'),
              ),

              // 전공 입력 필드
              TextField(
                controller: majorController,
                decoration: InputDecoration(labelText: 'Enter your major'),
              ),

              SizedBox(height: 20),

              // 영화 장르 선택
              Text('What kind of Movie do you like..?'),
              SizedBox(height: 10),

              Wrap(
                spacing: 8.0,
                children: genres.map((genre) {
                  bool isSelected = selectedGenres.contains(genre);
                  return ChoiceChip(label: Text(genre),
                      selected: isSelected,
                      onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedGenres.add(genre);
                      } else {
                        selectedGenres.remove(genre);
                      }
                    });
                      },
                  );
                }).toList(),
              ),

              SizedBox(height: 20),

              if (isLoading)
                CircularProgressIndicator(),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _signUp,  // 로딩 중에는 버튼 비활성화
                child: Text('Sign Up'),

              ),
            ],
          ),
        ),
      ),
    );
  }
}
