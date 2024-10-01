import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'liked_movie_screen.dart';
import 'saw_movies_screen.dart';
import 'user_reviews_screen.dart';
import 'edit_profile_screen.dart'; // EditProfileScreen import

class MyPageScreen extends StatefulWidget {
  final String userId; // 유저 ID를 받아옴
  final bool isEditable; // 페이지가 수정 가능한지 여부

  MyPageScreen({required this.userId, required this.isEditable});

  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  String? profileImageUrl;
  String? displayName;
  String? major; // 사용자 학과 정보
  List<String> favoriteGenres = [];

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Firestore에서 사용자 정보 불러오기
  }

  // Firestore에서 사용자 정보를 불러오는 함수
  Future<void> _loadUserData() async {
    DocumentSnapshot userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get(); // Firestore에서 사용자 정보 가져오기
    setState(() {
      profileImageUrl = userData['profileImageUrl'];
      displayName = userData['name'];
      major = userData['major'];
      favoriteGenres = List<String>.from(userData['favoriteGenres']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${displayName ?? "No Name"}\'s Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 프로필 사진 표시
            CircleAvatar(
              radius: 50,
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl!)
                  : AssetImage('assets/default_profile.png') as ImageProvider,
            ),
            SizedBox(height: 10),
            // 유저 이름과 수정 버튼 (isEditable이 true일 때만 수정 가능)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(displayName ?? 'No Name', style: TextStyle(fontSize: 18)),
                if (widget.isEditable) // isEditable이 true일 때만 수정 버튼 표시
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
            Text(
              major ?? 'No Major',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // 좋아하는 영화 장르
            Text('My Favorite Movie Genres', style: TextStyle(fontSize: 16)),
            Wrap(
              spacing: 8.0,
              children: favoriteGenres.map((genre) {
                return Chip(
                  label: Text(genre),
                );
              }).toList(),
            ),

            // 내가 좋아하는 영화 목록 버튼
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('I Liked This Movie'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LikedMoviesScreen()),
                );
              },
            ),
            // 내가 본 영화 목록 버튼
            ListTile(
              leading: Icon(Icons.visibility),
              title: Text('I Saw This Movie'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SawMoviesScreen()),
                );
              },
            ),
            // 내가 쓴 리뷰 목록 버튼
            ListTile(
              leading: Icon(Icons.comment),
              title: Text('My Reviews'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserReviewsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
