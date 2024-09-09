import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyPageScreen extends StatelessWidget {
  final User? user;

  MyPageScreen({this.user});

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
            Text('User Name: ${user?.displayName ?? 'No Name'}'),
            Text('Email: ${user?.email ?? 'No Email'}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 로그아웃 기능 추가
                FirebaseAuth.instance.signOut();
              },
              child: Text('Logout'),
            ),
            ElevatedButton(
              onPressed: () {
                // 사용자 정보 수정 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen(user: user)),
                );
              },
              child: Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

// 사용자 정보 수정 화면
class EditProfileScreen extends StatelessWidget {
  final User? user;
  final TextEditingController nameController = TextEditingController();

  EditProfileScreen({this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Display Name'),
            ),
            ElevatedButton(
              onPressed: () {
                // Firebase에 사용자 이름 업데이트
                user?.updateDisplayName(nameController.text);
                Navigator.pop(context);
              },
              child: Text('Update Name'),
            ),
          ],
        ),
      ),
    );
  }
}
