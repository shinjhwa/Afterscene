import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'movie_room_screen.dart';
import 'my_page_screen.dart'; // 마이페이지로 이동하는 버튼을 위해 MyPageScreen 추가

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
    _loadEventsFromFirestore(); // Firestore에서 영화 데이터를 불러옴
  }

  // Firestore에서 영화 이벤트 데이터를 불러오는 함수
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

  // 특정 날짜의 이벤트를 반환하는 함수
  List<String> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Afterscene'), // 앱 제목
        automaticallyImplyLeading: false, // 뒤로 가기 화살표 없앰
      ),
      body: Column(
        children: [
          // 영화 이벤트가 있는 날짜를 달력에 표시
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
          // 영화 목록을 가로 스크롤로 표시
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
                            child: AspectRatio(
                              aspectRatio: 1 / 1.3, // 1:1.3 비율로 설정
                              child: Image.network(
                                'https://via.placeholder.com/100x150',
                                fit: BoxFit.cover,
                              ),
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
      // 하단 네비게이션 바에서 영화 추가 버튼을 사용하도록 변경
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
        currentIndex: 0, // 현재 선택된 네비게이션 바 인덱스
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/'); // 홈으로 이동
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/addMovie'); // Add Movie 화면으로 이동
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/myPage'); // MyPageScreen으로 이동
              break;
          }
        },
      ),
    );
  }

  // 달력에 이벤트 마커 표시
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
          '${events.length}', // 해당 날짜의 이벤트 수 표시
          style: TextStyle(color: Colors.white, fontSize: 12.0),
        ),
      ),
    );
  }
}
