import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 추가

class MyPageScreen extends StatefulWidget {
  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData; // Firestore에서 가져온 사용자 데이터를 저장

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Firestore에서 사용자 데이터 불러오기
  void _loadUserData() async {
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      setState(() {
        userData = doc.data() as Map<String, dynamic>?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Page'),
        automaticallyImplyLeading: false, // 뒤로 가기 버튼 비활성화
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('User Name: ${user?.displayName ?? 'No Name'}'),
            Text('Email: ${user?.email ?? 'No Email'}'),
            if (userData != null) ...[
              Text('Major: ${userData!['major'] ?? 'No Major'}'),
              Text('Favorite Genres: ${userData!['genres']?.join(', ') ?? 'No Genres'}'),
            ],
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
                  await FirebaseAuth.instance.currentUser?.reload();
                  setState(() {
                    user = FirebaseAuth.instance.currentUser;
                    _loadUserData();  // 사용자 정보 새로고침
                  });
                });
              },
              child: Text('Edit Profile'),
            ),
          ],
        ),
      ),
      // 하단 네비게이션 바 추가
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
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
        currentIndex: 2, // My Page 화면일 때 인덱스 2로 설정
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/'); // 홈으로 이동
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/addMovie'); // 영화 추가 화면으로 이동
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/myPage'); // My Page로 이동
              break;
          }
        },
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
        automaticallyImplyLeading: false, // 뒤로 가기 버튼 비활성화
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
                  // 사용자 이름 업데이트
                  await user?.updateDisplayName(nameController.text);

                  // Firestore에서 displayName 필드 업데이트
                  await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
                    'displayName': nameController.text,
                  });

                  // 사용자 정보 다시 불러오기
                  await user?.reload();
                  setState(() {
                    user = FirebaseAuth.instance.currentUser;
                  });

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
      // 하단 네비게이션 바 추가
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
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
        currentIndex: 2, // My Page 화면일 때 인덱스 2로 설정
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/'); // 홈으로 이동
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/addMovie'); // 영화 추가 화면으로 이동
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/myPage'); // My Page로 이동
              break;
          }
        },
      ),
    );
  }
}
