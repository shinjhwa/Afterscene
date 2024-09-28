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
  DateTime _focusedDay = DateTime.now(); // 달력에서 포커스된 날짜
  DateTime? _selectedDay; // 선택된 날짜
  Map<DateTime, List<Map<String, dynamic>>> _events = {}; // 날짜별 영화 데이터를 저장

  final CollectionReference moviesCollection = FirebaseFirestore.instance.collection('movies'); // Firestore에서 'movies' 컬렉션 참조

  @override
  void initState() {
    super.initState();
    _loadEventsFromFirestore(); // Firestore에서 영화 데이터를 불러옴
  }

  // 날짜에서 시간 정보를 제거하고 날짜 정보만 반환하는 함수
  DateTime _getDateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day); // 연, 월, 일만 남기고 시간 정보는 제거
  }

  // Firestore에서 영화 데이터를 불러오는 함수
  void _loadEventsFromFirestore() async {
    QuerySnapshot snapshot = await moviesCollection.get(); // Firestore에서 영화 데이터를 가져옴
    setState(() {
      for (var doc in snapshot.docs) {
        DateTime movieDate = _getDateOnly((doc['date'] as Timestamp).toDate()); // 시간 정보는 제거하고 날짜만 사용
        String movieTitle = doc['title']; // 영화 제목
        String posterUrl = doc['posterUrl'] ?? 'https://via.placeholder.com/100x150'; // 포스터 URL, 없으면 기본 이미지로 설정

        // 영화 데이터 추가
        if (_events[movieDate] == null) {
          _events[movieDate] = [];
        }
        _events[movieDate]?.add({
          'title': movieTitle,
          'posterUrl': posterUrl,
        });
      }
    });
  }

  // 특정 날짜의 이벤트를 반환하는 함수
  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[_getDateOnly(day)] ?? []; // 날짜만 기준으로 비교
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
              return isSameDay(_selectedDay, day); // 선택된 날짜를 확인
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay; // 선택된 날짜 업데이트
                _focusedDay = focusedDay; // 포커스된 날짜 업데이트
              });
              // 선택된 날짜에 영화 이벤트가 있으면 MovieRoomScreen으로 이동
              if (_getEventsForDay(selectedDay).isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieRoomScreen(movieTitle: _getEventsForDay(selectedDay).first['title']),
                  ),
                );
              }
            },
            eventLoader: _getEventsForDay, // 각 날짜의 이벤트를 로드
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: _buildEventsMarker(date, events), // 이벤트 마커 표시
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
                scrollDirection: Axis.horizontal, // 가로 스크롤
                itemCount: _events.length, // 영화 이벤트의 개수
                itemBuilder: (context, index) {
                  DateTime key = _events.keys.elementAt(index); // 각 날짜에 해당하는 key (날짜)
                  String movieTitle = _events[key]!.first['title']; // 해당 날짜의 첫 번째 영화 제목
                  String posterUrl = _events[key]!.first['posterUrl']; // 해당 날짜의 첫 번째 영화 포스터 URL

                  return GestureDetector(
                    onTap: () {
                      // 영화 클릭 시 MovieRoomScreen으로 이동
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
                          // 영화 포스터 표시 (등록된 포스터 URL을 사용)
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1 / 1.3, // 가로 세로 비율을 1:1.3으로 설정
                              child: Image.network(
                                posterUrl, // 등록된 포스터 URL 사용
                                fit: BoxFit.cover, // 이미지 비율을 맞춤
                                errorBuilder: (context, error, stackTrace) {
                                  // 이미지 로딩에 실패할 경우 기본 이미지 표시
                                  return Image.network('https://via.placeholder.com/100x150', fit: BoxFit.cover);
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          // 영화 제목 표시
                          Text(
                            movieTitle,
                            style: TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis, // 영화 제목이 길면 생략 표시
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
            icon: Icon(Icons.home), // 홈 아이콘
            label: 'Home', // 라벨
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add), // 영화 추가 아이콘
            label: 'Add Movie', // 라벨
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // 마이페이지 아이콘
            label: 'My Page', // 라벨
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

  // 달력에 이벤트 마커 표시 (날짜에 이벤트가 있을 때 표시)
  Widget _buildEventsMarker(DateTime date, List events) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle, // 동그란 모양의 마커
        color: Colors.red, // 마커 색상 (빨간색)
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}', // 해당 날짜의 이벤트 개수 표시
          style: TextStyle(color: Colors.white, fontSize: 12.0),
        ),
      ),
    );
  }
}
