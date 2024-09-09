import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyPageScreen extends StatefulWidget {
  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  User? user = FirebaseAuth.instance.currentUser;

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
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop();
              },
              child: Text('Logout'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen()),
                ).then((_) async {
                  // 프로필 수정 후 사용자 정보를 다시 로드
                  await FirebaseAuth.instance.currentUser?.reload();
                  setState(() {
                    user = FirebaseAuth.instance.currentUser;
                  });
                });
              },
              child: Text('Edit Profile'),
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
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    nameController.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  print('Attempting to update display name to: ${nameController.text}');

                  // 사용자 이름 업데이트
                  await user?.updateDisplayName(nameController.text);
                  print('Display name update successful');

                  // 사용자 정보 다시 불러오기
                  await user?.reload();
                  setState(() {
                    user = FirebaseAuth.instance.currentUser;
                  });

                  print('User info reloaded');
                  print('Final Display Name: ${user?.displayName}');

                  Navigator.pop(context);
                } catch (e) {
                  print('Error occurred: $e');
                }
              },
              child: Text('Update Name'),
            ),
          ],
        ),
      ),
    );
  }
}
