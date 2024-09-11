import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class MyPageScreen extends StatefulWidget {
  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  String? profileImageUrl;
  String? displayName;
  List<String> favoriteGenres = [];

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Firestore에서 사용자 정보 불러오기
  }

  Future<void> _loadUserData() async {
    DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    setState(() {
      profileImageUrl = userData['profileImageUrl'];
      displayName = userData['name'];
      favoriteGenres = List<String>.from(userData['favoriteGenres']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 프로필 사진
            CircleAvatar(
              radius: 50,
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl!)
                  : AssetImage('assets/default_profile.png') as ImageProvider,
            ),
            SizedBox(height: 10),
            // 유저 이름과 수정 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(displayName ?? 'No Name', style: TextStyle(fontSize: 18)),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfileScreen()),
                    ).then((_) => _loadUserData()); // 프로필 수정 후 데이터 다시 로드
                  },
                ),
              ],
            ),
            SizedBox(height: 20),

            // 좋아하는 영화 장르
            Text('My favorite Movie', style: TextStyle(fontSize: 16)),
            Wrap(
              spacing: 8.0,
              children: favoriteGenres.map((genre) {
                return Chip(
                  label: Text(genre),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  List<String> genres = ['Action', 'Comedy', 'Drama', 'Horror', 'Sci-Fi', 'Romance'];
  List<String> selectedGenres = [];
  File? _profileImage;
  String? currentProfileImageUrl;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Firestore에서 기존 사용자 데이터 불러오기
  }

  Future<void> _loadUserData() async {
    DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    setState(() {
      nameController.text = userData['name'];
      currentProfileImageUrl = userData['profileImageUrl'];
      selectedGenres = List<String>.from(userData['favoriteGenres']);
    });
  }

  // 프로필 이미지 선택
  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  // Firebase Storage에 프로필 이미지 업로드
  Future<String?> _uploadProfileImage(String uid) async {
    if (_profileImage != null) {
      final storageRef = FirebaseStorage.instance.ref().child('profile_images/$uid.jpg');
      await storageRef.putFile(_profileImage!);
      return await storageRef.getDownloadURL();
    }
    return currentProfileImageUrl;  // 이미지가 변경되지 않았으면 기존 URL 반환
  }

  // Firestore에 사용자 정보 업데이트
  Future<void> _updateUserProfile() async {
    try {
      String? profileImageUrl = await _uploadProfileImage(user!.uid);

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'name': nameController.text,
        'profileImageUrl': profileImageUrl,
        'favoriteGenres': selectedGenres,
      });

      await user?.updateDisplayName(nameController.text);  // Firebase Auth 사용자 이름 업데이트
      await user?.reload();
      setState(() {
        user = FirebaseAuth.instance.currentUser;
      });

      Navigator.pop(context);
    } catch (e) {
      print('Error updating profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 프로필 사진 업로드 버튼
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : currentProfileImageUrl != null
                      ? NetworkImage(currentProfileImageUrl!) as ImageProvider
                      : AssetImage('assets/default_profile.png'),
                ),
              ),
              SizedBox(height: 20),

              // 이름 입력 필드
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Display Name'),
              ),
              SizedBox(height: 20),

              // 좋아하는 영화 장르 선택
              Text('Select Your Favorite Movie Genres'),
              Wrap(
                spacing: 8.0,
                children: genres.map((genre) {
                  bool isSelected = selectedGenres.contains(genre);
                  return ChoiceChip(
                    label: Text(genre),
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

              // 업데이트 버튼
              ElevatedButton(
                onPressed: _updateUserProfile,
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
