import 'dart:io'; // 파일 관련 라이브러리
import 'package:flutter/material.dart'; // Flutter UI 위젯
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage
import 'package:image_picker/image_picker.dart'; // 이미지 선택 라이브러리

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController(); // 이름 입력 컨트롤러
  List<String> genres = ['액션', '범죄', 'SF', '코미디', '로맨스 코미디', '스릴러', '공포', '전쟁', '스포츠', '판타지', '음악', '뮤지컬', '멜로']; // 영화 장르 목록
  List<String> selectedGenres = []; // 선택된 장르
  File? _profileImage; // 프로필 이미지 파일
  String? currentProfileImageUrl; // 현재 프로필 이미지 URL
  User? user = FirebaseAuth.instance.currentUser; // 현재 로그인된 사용자

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Firestore에서 사용자 정보 불러오기
  }

  // Firestore에서 사용자 정보를 불러오는 함수
  Future<void> _loadUserData() async {
    DocumentSnapshot userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get(); // Firestore에서 사용자 정보 가져오기
    setState(() {
      nameController.text = userData['name']; // 사용자 이름 로드
      currentProfileImageUrl = userData['profileImageUrl']; // 프로필 이미지 URL 로드
      selectedGenres = List<String>.from(userData['favoriteGenres']); // 선택된 영화 장르 로드
    });
  }

  // 프로필 이미지 선택 함수
  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery); // 갤러리에서 이미지 선택
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path); // 선택한 이미지를 File로 저장
      });
    }
  }

  // Firebase Storage에 프로필 이미지 업로드
  Future<String?> _uploadProfileImage(String uid) async {
    if (_profileImage != null) {
      final storageRef = FirebaseStorage.instance.ref().child('profile_images/$uid.jpg'); // 저장 경로 설정
      await storageRef.putFile(_profileImage!); // 이미지 업로드
      return await storageRef.getDownloadURL(); // 업로드한 이미지의 다운로드 URL 가져오기
    }
    return currentProfileImageUrl; // 프로필 이미지가 변경되지 않았다면 기존 이미지 URL 반환
  }

  // Firestore에 사용자 정보 업데이트
  Future<void> _updateUserProfile() async {
    try {
      String? profileImageUrl = await _uploadProfileImage(user!.uid); // 프로필 이미지 업로드

      // Firestore에 사용자 정보 업데이트
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'name': nameController.text, // 이름 업데이트
        'profileImageUrl': profileImageUrl, // 프로필 이미지 URL 업데이트
        'favoriteGenres': selectedGenres, // 선택한 영화 장르 업데이트
      });

      // Firebase Authentication에서 사용자 이름 업데이트
      await user?.updateDisplayName(nameController.text);
      await user?.reload(); // 사용자 정보 다시 로드

      Navigator.pop(context); // 프로필 수정 후 이전 화면으로 돌아가기
    } catch (e) {
      print('Error updating profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'), // 페이지 제목
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 프로필 사진 선택 버튼
              GestureDetector(
                onTap: _pickImage, // 이미지 선택 함수 호출
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!) // 선택한 이미지 표시
                      : currentProfileImageUrl != null
                      ? NetworkImage(currentProfileImageUrl!) as ImageProvider // 기존 프로필 이미지 표시
                      : AssetImage('assets/default_profile.png'), // 기본 프로필 이미지
                ),
              ),
              SizedBox(height: 20),

              // 사용자 이름 입력 필드
              TextField(
                controller: nameController, // 이름 입력 컨트롤러
                decoration: InputDecoration(labelText: 'Display Name'), // 입력 필드 라벨
              ),
              SizedBox(height: 20),

              // 좋아하는 영화 장르 선택
              Text('Select Your Favorite Movie Genres'),
              Wrap(
                spacing: 8.0,
                children: genres.map((genre) {
                  bool isSelected = selectedGenres.contains(genre); // 선택 여부 확인
                  return ChoiceChip(
                    label: Text(genre), // 장르 이름 표시
                    selected: isSelected, // 선택된 상태 표시
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedGenres.add(genre); // 선택된 장르 추가
                        } else {
                          selectedGenres.remove(genre); // 선택 해제된 장르 제거
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 20),

              // 프로필 업데이트 버튼
              ElevatedButton(
                onPressed: _updateUserProfile, // 프로필 업데이트 함수 호출
                child: Text('Update Profile'), // 버튼 텍스트
              ),
            ],
          ),
        ),
      ),
    );
  }
}
