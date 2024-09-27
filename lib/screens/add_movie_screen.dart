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
  final TextEditingController _movieTitleController = TextEditingController(); // 영화 제목 입력 필드 컨트롤러
  final TextEditingController _directorController = TextEditingController(); // 감독 입력 필드 컨트롤러
  final TextEditingController _actorsController = TextEditingController(); // 배우 입력 필드 컨트롤러
  final TextEditingController _releaseYearController = TextEditingController(); // 개봉 연도 입력 필드 컨트롤러
  final TextEditingController _durationController = TextEditingController(); // 상영 시간 입력 필드 컨트롤러
  final TextEditingController _ageLimitController = TextEditingController(); // 관람 등급 입력 필드 컨트롤러
  DateTime _selectedDate = DateTime.now(); // 영화 상영 날짜 기본값
  List<String> _selectedGenres = []; // 선택된 장르 리스트

  final List<String> genres = ['액션', '범죄', 'SF', '코미디', '로맨스 코미디', '스릴러', '공포', '전쟁', '스포츠', '판타지', '음악', '뮤지컬', '멜로'];

  // 이미지 선택 함수
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery); // 갤러리에서 이미지 선택
    setState(() {
      _posterImage = pickedFile;
    });
  }

  // 이미지 업로드 함수
  Future<String> _uploadPosterImage(XFile posterImage) async {
    try {
      // Firebase Storage에 이미지 업로드 경로 설정 (현재 시간 기반 파일명 사용)
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

  // Firestore에 영화 데이터 저장 (제목을 문서 ID로 사용)
  void _submitMovieData() async {
    try {
      String posterUrl = '';
      if (_posterImage != null) {
        // 포스터 이미지 업로드 후 다운로드 URL 저장
        posterUrl = await _uploadPosterImage(_posterImage!);
      }

      String movieTitle = _movieTitleController.text; // 영화 제목
      // Firestore에 영화 데이터를 제목을 문서 ID로 하여 저장
      await FirebaseFirestore.instance.collection('movies').doc(movieTitle).set({
        'title': movieTitle,
        'posterUrl': posterUrl,
        'director': _directorController.text,
        'actors': _actorsController.text,
        'releaseYear': _releaseYearController.text,
        'duration': _durationController.text,
        'ageLimit': _ageLimitController.text,
        'genres': _selectedGenres,
        'date': _selectedDate,
      });

      // 영화 추가 후 이전 화면으로 이동
      Navigator.pop(context);
    } catch (e) {
      print('영화 추가 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Movie'), // 화면 상단 제목
        automaticallyImplyLeading: false, // 뒤로 가기 버튼 비활성화
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16), // 페이지 padding 설정
        child: Column(
          children: [
            // 영화 제목 입력 필드
            TextField(
              controller: _movieTitleController,
              decoration: InputDecoration(labelText: 'Movie Title'),
            ),
            SizedBox(height: 8),
            // 포스터 이미지 업로드 부분
            _posterImage == null
                ? Text('No image selected.') // 이미지가 선택되지 않았을 때 텍스트 표시
                : Image.file(
              File(_posterImage!.path), // 선택된 이미지가 있으면 해당 이미지 표시
              height: 150,
            ),
            ElevatedButton(
              onPressed: _pickImage, // 이미지 선택 버튼
              child: Text('Upload Poster'),
            ),
            // 나머지 영화 정보 입력 필드들 (감독, 배우, 개봉 연도, 상영 시간, 관람 등급)
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
            // 영화 상영 날짜 선택 버튼
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
                    _selectedDate = picked; // 날짜 선택 시 상태 업데이트
                  });
                }
              },
              child: Text('Select Date'),
            ),
            SizedBox(height: 8),
            // 장르 선택
            Text('Genres', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8.0,
              children: genres.map((genre) {
                return ChoiceChip(
                  label: Text(genre), // 각 장르를 ChoiceChip으로 표시
                  selected: _selectedGenres.contains(genre),
                  onSelected: (selected) {
                    setState(() {
                      selected ? _selectedGenres.add(genre) : _selectedGenres.remove(genre); // 장르 선택 시 상태 업데이트
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 8),
            // 영화 추가 버튼
            ElevatedButton(
              onPressed: _submitMovieData, // 영화 데이터를 Firestore에 저장하는 함수 호출
              child: Text('Add Movie'),
            ),
          ],
        ),
      ),
      // 하단 네비게이션 바
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
        currentIndex: 1, // 현재 Add Movie 페이지 인덱스
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/'); // 홈 화면으로 이동
              break;
            case 1:
            // 현재 Add Movie 페이지이므로 아무 동작도 하지 않음
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/myPage'); // 마이 페이지로 이동
              break;
          }
        },
      ),
    );
  }
}
