import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddMovieScreen extends StatefulWidget {
  @override
  _AddMovieScreenState createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  final ImagePicker _picker = ImagePicker(); // 이미지 선택을 위한 ImagePicker 초기화
  XFile? _posterImage; // 영화 포스터 이미지
  final TextEditingController _movieTitleController = TextEditingController();
  final TextEditingController _directorController = TextEditingController();
  final TextEditingController _actorsController = TextEditingController();
  final TextEditingController _releaseYearController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _ageLimitController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<String> _selectedGenres = []; // 선택된 장르 리스트

  final List<String> genres = ['액션', '범죄', 'SF', '코미디', '로맨스 코미디', '스릴러', '공포', '전쟁', '스포츠', '판타지', '음악', '뮤지컬', '멜로'];

  // 이미지 선택 함수
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _posterImage = pickedFile;
    });
  }

  // 이미지 업로드 함수
  Future<String> _uploadPosterImage(XFile posterImage) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('posters/${DateTime.now().millisecondsSinceEpoch}.jpg');
      UploadTask uploadTask = storageRef.putFile(File(posterImage.path));
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL(); // 업로드된 이미지의 URL 반환
    } catch (e) {
      throw Exception('이미지 업로드 중 오류 발생: $e');
    }
  }

  // Firestore에 영화 데이터 저장
  void _submitMovieData() async {
    try {
      String posterUrl = '';
      if (_posterImage != null) {
        posterUrl = await _uploadPosterImage(_posterImage!); // 포스터 업로드 후 URL 저장
      }
      await FirebaseFirestore.instance.collection('movies').add({
        'title': _movieTitleController.text,
        'posterUrl': posterUrl,
        'director': _directorController.text,
        'actors': _actorsController.text,
        'releaseYear': _releaseYearController.text,
        'duration': _durationController.text,
        'ageLimit': _ageLimitController.text,
        'genres': _selectedGenres,
        'date': _selectedDate,
      });
      Navigator.pop(context); // 영화 추가 후 화면 닫기
    } catch (e) {
      print('영화 추가 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Movie'),
        automaticallyImplyLeading: false, // 뒤로 가기 버튼을 없앰
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _movieTitleController,
              decoration: InputDecoration(labelText: 'Movie Title'),
            ),
            SizedBox(height: 8),
            _posterImage == null
                ? Text('No image selected.')
                : Image.file(
              File(_posterImage!.path),
              height: 150,
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Upload Poster'),
            ),
            TextField(
              controller: _directorController,
              decoration: InputDecoration(labelText: 'Director'),
            ),
            TextField(
              controller: _actorsController,
              decoration: InputDecoration(labelText: 'Actors (comma separated)'),
            ),
            TextField(
              controller: _releaseYearController,
              decoration: InputDecoration(labelText: 'Release Year'),
            ),
            TextField(
              controller: _durationController,
              decoration: InputDecoration(labelText: 'Duration (in minutes)'),
            ),
            TextField(
              controller: _ageLimitController,
              decoration: InputDecoration(labelText: 'Age Limit'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null && picked != _selectedDate) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              child: Text('Select Date'),
            ),
            SizedBox(height: 8),
            Text('Genres', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8.0,
              children: genres.map((genre) {
                return ChoiceChip(
                  label: Text(genre),
                  selected: _selectedGenres.contains(genre),
                  onSelected: (selected) {
                    setState(() {
                      selected ? _selectedGenres.add(genre) : _selectedGenres.remove(genre);
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _submitMovieData,
              child: Text('Add Movie'),
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
        currentIndex: 1, // 현재 선택된 네비게이션 바 인덱스
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/');
              break;
            case 1:
            // 현재 Add Movie 페이지, 아무 동작도 하지 않음
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/myPage');
              break;
          }
        },
      ),
    );
  }
}
