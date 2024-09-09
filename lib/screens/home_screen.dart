import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:table_calendar/table_calendar.dart';
import 'movie_room_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'my_page_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _events = {};

  final CollectionReference moviesCollection = FirebaseFirestore.instance.collection('movies');

  @override
  void initState() {
    super.initState();
    _loadEventsFromFirestore();
  }

  void _loadEventsFromFirestore() async {
    QuerySnapshot snapshot = await moviesCollection.get();
    setState(() {
      for (var doc in snapshot.docs) {
        DateTime movieDate = (doc['date'] as Timestamp).toDate();
        String movieTitle = doc['title'];
        if (_events[movieDate] == null) {
          _events[movieDate] = [];
        }
        _events[movieDate]?.add(movieTitle);
      }
    });
  }

  Future<String> _uploadPosterImage(File posterImage) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('posters/${DateTime.now().millisecondsSinceEpoch}.jpg');
      UploadTask uploadTask = storageRef.putFile(posterImage);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  void _addEventToFirestore(
      DateTime date,
      String title,
      String posterUrl,
      String director,
      String actors,
      String releaseYear,
      String duration,
      String ageLimit,
      List<String> genres
      ) async {
    await moviesCollection.add({
      'date': date,
      'title': title,
      'posterUrl': posterUrl,
      'director': director,
      'actors': actors,
      'releaseYear': releaseYear,
      'duration': duration,
      'ageLimit': ageLimit,
      'genres': genres,
    });

    setState(() {
      if (_events[date] == null) {
        _events[date] = [];
      }
      _events[date]?.add(title);
    });
  }

  void _submitMovieData(
      DateTime date,
      String title,
      File? posterImage,
      String director,
      String actors,
      String releaseYear,
      String duration,
      String ageLimit,
      List<String> genres) async {
    try {
      String posterUrl = '';
      if (posterImage != null) {
        posterUrl = await _uploadPosterImage(posterImage);
      }
      _addEventToFirestore(
        date,
        title,
        posterUrl,
        director,
        actors,
        releaseYear,
        duration,
        ageLimit,
        genres,
      );
    } catch (e) {
      print('Error adding movie: $e');
    }
  }

  List<String> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Afterscene'),
      ),
      // Stack을 사용하여 마이페이지 버튼과 메인 컨텐츠를 겹치게 배치
      body: Stack(
        children: [
          Column(
            children: [
              TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2022, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  if (_getEventsForDay(selectedDay).isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieRoomScreen(movieTitle: _getEventsForDay(selectedDay).first),
                      ),
                    );
                  }
                },
                eventLoader: _getEventsForDay,
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        right: 1,
                        bottom: 1,
                        child: _buildEventsMarker(date, events),
                      );
                    }
                    return SizedBox();
                  },
                ),
              ),
              Expanded(
                child: Container(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      DateTime key = _events.keys.elementAt(index);
                      String movieTitle = _events[key]!.first;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieRoomScreen(movieTitle: movieTitle),
                            ),
                          );
                        },
                        child: Container(
                          width: 130,
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              Expanded(
                                child: Image.network(
                                  'https://via.placeholder.com/100x150',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                movieTitle,
                                style: TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          // 마이페이지 버튼을 Stack 내부에 추가
          _buildMyPageButton(), // 마이페이지 버튼
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEventDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // 마이페이지로 이동하는 버튼 UI 및 로직
  Widget _buildMyPageButton() {
    return Positioned(
      bottom: 16, // 하단에서 16px 위로 위치
      left: 16, // 좌측에서 16px 우측으로 위치
      child: GestureDetector(
        onTap: () {
          // 마이페이지로 이동하는 로직
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyPageScreen(), // MyPageScreen으로 이동
            ),
          );
        },
        child: Container(
          width: 60, // 버튼의 너비
          height: 60, // 버튼의 높이
          decoration: BoxDecoration(
            color: Colors.blue, // 버튼의 배경색
            borderRadius: BorderRadius.circular(10), // 버튼의 모서리 둥글게
          ),
          child: Center(
            child: Icon(
              Icons.person, // 사람 아이콘 (마이페이지를 상징)
              color: Colors.white, // 아이콘 색상
              size: 30, // 아이콘 크기
            ),
          ),
        ),
      ),
    );
  }



  void _showAddEventDialog(BuildContext context) {
    String movieTitle = '';
    File? _posterImage;
    String director = '';
    String actors = '';
    String releaseYear = '';
    String duration = '';
    String ageLimit = '';
    List<String> selectedGenres = [];
    DateTime selectedDate = DateTime.now();

    final genres = ['액션', '범죄', 'SF', '코미디', '로맨스 코미디', '스릴러', '공포', '전쟁', '스포츠', '판타지', '음악', '뮤지컬', '멜로'];

    Future<void> _pickImage() async {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _posterImage = File(pickedFile.path);
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Movie Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Movie Title'),
                  onChanged: (value) {
                    movieTitle = value;
                  },
                ),
                SizedBox(height: 8),
                _posterImage == null
                    ? Text('No image selected.')
                    : Image.file(
                  _posterImage!,
                  height: 150,
                ),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Upload Poster'),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Director'),
                  onChanged: (value) {
                    director = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Actors (comma separated)'),
                  onChanged: (value) {
                    actors = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Release Year'),
                  onChanged: (value) {
                    releaseYear = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Duration (in minutes)'),
                  onChanged: (value) {
                    duration = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Age Limit'),
                  onChanged: (value) {
                    ageLimit = value;
                  },
                ),
                SizedBox(height: 8),
                Text('Select Date (Movie Watched)'),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Text('Choose Date'),
                ),
                SizedBox(height: 8),
                Text('Genres', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  children: genres.map((genre) {
                    return ChoiceChip(
                      label: Text(genre),
                      selected: selectedGenres.contains(genre),
                      onSelected: (selected) {
                        setState(() {
                          selected
                              ? selectedGenres.add(genre)
                              : selectedGenres.remove(genre);
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    _submitMovieData(
                        selectedDate,
                        movieTitle,
                        _posterImage,
                        director,
                        actors,
                        releaseYear,
                        duration,
                        ageLimit,
                        selectedGenres);
                    Navigator.pop(context);
                  },
                  child: Text('Add'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle(color: Colors.white, fontSize: 12.0),
        ),
      ),
    );
  }
}
