import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Firestore 추가
import 'package:table_calendar/table_calendar.dart';
import 'movie_room_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _events = {};

  // Firestore 컬렉션 참조
  final CollectionReference moviesCollection = FirebaseFirestore.instance.collection('movies');

  @override
  void initState() {
    super.initState();
    _loadEventsFromFirestore();
  }

  // Firestore에서 이벤트 불러오기
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

  // Firestore에 영화 추가
  void _addEventToFirestore(DateTime date, String title) async {
    await moviesCollection.add({
      'date': date,
      'title': title,
    });

    setState(() {
      if (_events[date] == null) {
        _events[date] = [];
      }
      _events[date]?.add(title);
    });
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
      body: Column(
        children: [
          // 캘린더 위젯
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
          // 영화 목록 가로 스크롤 리스트
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
                          // 영화 포스터 부분
                          Expanded(
                            child: Image.network(
                              'https://via.placeholder.com/100x150', // 영화 포스터 URL로 대체
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 8),
                          // 영화 제목
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEventDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // 영화 추가 다이얼로그
  void _showAddEventDialog(BuildContext context) {
    String movieTitle = '';
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Movie Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Movie Title'),
                onChanged: (value) {
                  movieTitle = value;
                },
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  _addEventToFirestore(selectedDate, movieTitle);
                  Navigator.pop(context);
                },
                child: Text('Add'),
              ),
            ],
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
