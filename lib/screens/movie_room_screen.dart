import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication 패키지
import 'package:flutter/material.dart'; // Flutter 기본 UI 위젯
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore 패키지
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // 별점 평점 라이브러리
import '../main.dart';
import 'reply_screen.dart'; // 답글 스크린 파일 import

class MovieRoomScreen extends StatefulWidget {
  final String movieTitle;

  MovieRoomScreen({required this.movieTitle});

  @override
  _MovieRoomScreenState createState() => _MovieRoomScreenState();
}

class _MovieRoomScreenState extends State<MovieRoomScreen> {
  final TextEditingController _reviewController = TextEditingController(); // 리뷰 작성 텍스트 필드 컨트롤러
  double _rating = 3.0; // 별점 기본 값
  bool _isLiked = false;
  bool _hasSeenMovie = false;

  @override
  void initState() {
    super.initState();
    _loadUserMovieStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movieTitle), // 영화 제목을 AppBar에 표시
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildMovieInfo(), // 영화 정보 표시 위젯
            _buildRatingSection(), // 별점 및 리뷰 작성 섹션
            SizedBox(height: 10),
            _buildReviews(), // 리뷰 목록 섹션
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }



  // Firestore에서 영화 정보와 포스터를 불러오는 함수
  Widget _buildMovieInfo() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('movies').doc(widget.movieTitle).get(), // 영화 제목을 기준으로 Firestore에서 문서 조회
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // 데이터가 아직 로딩 중일 경우
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.data!.exists) {
          // 해당 영화 데이터가 Firestore에 없을 경우
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No movie data available', // 영화 데이터가 없을 경우 표시
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          );
        }

        var movieData = snapshot.data!.data() as Map<String,
            dynamic>; // Firestore에서 가져온 데이터를 맵으로 캐스팅

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 포스터와 버튼을 가로로 배치
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 영화 포스터
                  Container(
                    height: 200,
                    child: Image.network(
                      movieData['posterUrl'] ??
                          'https://via.placeholder.com/150x200',
                      // 포스터 URL이 없을 경우 기본 이미지 표시
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 16), // 포스터와 버튼들 사이의 간격
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _isLiked ? Colors.red : Colors.grey,
                        ),
                        onPressed: _toggleMovieLike,
                      ),
                      Text('Liked'),
                      SizedBox(height: 16), // Liked와 I Saw This Movie 버튼 사이 간격
                      IconButton(
                        icon: Icon(
                          _hasSeenMovie ? Icons.visibility : Icons
                              .visibility_off,
                          color: _hasSeenMovie ? Colors.blue : Colors.grey,
                        ),
                        onPressed: _toggleSawMovie,
                      ),
                      Text('I Saw This Movie'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10), // 포스터와 영화 정보 사이 간격
              // 영화 제목, 감독, 개봉 연도, 배우 정보 등 표시
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.movieTitle, // 영화 제목
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text('Director: ${movieData['director'] ?? 'Unknown'}'),
                    // 감독
                    Text('Year: ${movieData['releaseYear'] ?? 'Unknown'}'),
                    // 개봉 연도
                    Text('Actors: ${movieData['actors'] ?? 'Unknown'}'),
                    // 배우
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _loadUserMovieStatus() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if(currentUser == null)
      return;

    DocumentSnapshot userMovieDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('movies')
        .doc(widget.movieTitle)
        .get();

    if (userMovieDoc.exists) {
      setState(() {
        _isLiked = userMovieDoc['liked'] ?? false;
        _hasSeenMovie = userMovieDoc['sawMovie'] ?? false;
      });
    }
  }

  void _toggleMovieLike() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if(currentUser == null)
      return;

    setState(() {
      _isLiked = !_isLiked; // 좋아요 상태를 토글
    });

    // Firestore에 사용자 상태 저장
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('movies')
        .doc(widget.movieTitle)
        .set({
      'liked': _isLiked,
    }, SetOptions(merge: true));
  }

  // I saw this movie 버튼 토글 함수
  void _toggleSawMovie() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() {
      _hasSeenMovie = !_hasSeenMovie; // 본 영화 상태를 토글
    });

    // Firestore에 사용자 상태 저장
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('movies')
        .doc(widget.movieTitle)
        .set({
      'sawMovie': _hasSeenMovie,
    }, SetOptions(merge: true));
  }


  // 별점 및 리뷰 작성 섹션
  Widget _buildRatingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // 별점 입력을 위한 RatingBar 위젯
          RatingBar.builder(
            initialRating: _rating, // 기본 별점 값
            minRating: 1, // 최소 별점
            direction: Axis.horizontal, // 별점을 수평으로 표시
            allowHalfRating: true, // 반 개의 별을 허용
            itemCount: 5, // 별 5개
            itemBuilder: (context, _) => Icon(
              Icons.star, // 별 모양 아이콘
              color: Colors.amber, // 별 색상은 노란색
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating; // 별점 값 업데이트
              });
            },
          ),
          TextField(
            controller: _reviewController, // 리뷰 작성 텍스트 필드
            decoration: InputDecoration(labelText: 'Write your review'), // 리뷰 입력 안내 문구
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: _submitReview, // 리뷰 제출 버튼
            child: Text('Submit Review'),
          ),
        ],
      ),
    );
  }

  // Firestore에서 실시간으로 리뷰들을 불러오는 함수
  Widget _buildReviews() {
    return Container(
      height: 300, // 리뷰 목록의 고정 높이 설정
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('movies') // 영화 컬렉션
            .doc(widget.movieTitle) // 해당 영화의 문서
            .collection('reviews') // 영화 리뷰 컬렉션
            .orderBy('likeCount', descending: true) // 좋아요 순으로 정렬
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator()); // 데이터가 없을 때 로딩 표시

          var reviews = snapshot.data!.docs; // 리뷰 데이터를 목록으로 저장
          return ListView.builder(
            itemCount: reviews.length, // 리뷰 개수만큼 리스트 생성
            itemBuilder: (context, index) {
              var review = reviews[index]; // 각 리뷰 데이터
              var currentUser = FirebaseAuth.instance.currentUser;

              bool likedByUser = review['likedUsers']?.contains(currentUser?.uid) ?? false; // likedUsers 필드가 없으면 빈 리스트 처리

              return ListTile(
                title: Text(review['reviewText']), // 리뷰 내용
                subtitle: Row(
                  children: [
                    Text('Rating: ${review['rating']}'), // 별점 표시
                    Spacer(),
                    Text(review['userName']), // 작성자 이름 표시
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        likedByUser ? Icons.thumb_up : Icons.thumb_up_outlined, // 사용자가 눌렀으면 채워진 따봉, 아니면 빈 따봉
                        color: likedByUser ? Colors.blue : null,
                      ),
                      onPressed: () => _toggleLike(review.id, likedByUser),
                    ),
                    SizedBox(width: 8),
                    Text('${review['likeCount'] ?? 0}'), // 따봉 개수 표시, 필드 없으면 0
                    IconButton(
                      icon: Icon(Icons.comment),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainScreen(
                              child: ReplyScreen(
                                reviewId: review.id,
                                movieTitle: widget.movieTitle,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 리뷰 제출 기능
  void _submitReview() async {
    if (_reviewController.text.isEmpty) return; // 리뷰 텍스트가 비어있으면 아무 작업도 하지 않음

    User? currentUser = FirebaseAuth.instance.currentUser; // 현재 로그인한 사용자 정보

    String userName = currentUser?.displayName ?? 'User123'; // 사용자 이름 없으면 기본 이름으로 설정

    // Firestore에 리뷰 데이터를 추가
    await FirebaseFirestore.instance
        .collection('movies') // 영화 컬렉션
        .doc(widget.movieTitle) // 해당 영화 문서
        .collection('reviews') // 영화의 리뷰 컬렉션
        .add({
      'reviewText': _reviewController.text, // 리뷰 내용
      'rating': _rating, // 별점
      'userName': userName, // 작성자 이름
      'timestamp': FieldValue.serverTimestamp(), // 서버 시간으로 타임스탬프 추가
      'likeCount': 0, // 따봉 초기 개수
      'likedUsers': [], // 따봉을 누른 사용자 목록 초기화
    });

    _reviewController.clear(); // 리뷰 필드 초기화
    setState(() {
      _rating = 3.0; // 별점 초기화
    });
  }

  // 따봉 기능 (클릭 시 따봉 추가/취소)
  void _toggleLike(String reviewId, bool likedByUser) async {
    var currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    var reviewRef = FirebaseFirestore.instance
        .collection('movies')
        .doc(widget.movieTitle)
        .collection('reviews')
        .doc(reviewId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      var reviewSnapshot = await transaction.get(reviewRef);

      if (!reviewSnapshot.exists) return;

      var likedUsers = List<String>.from(reviewSnapshot['likedUsers'] ?? []); // likedUsers 필드가 없을 때 빈 리스트
      int likeCount = reviewSnapshot['likeCount'] ?? 0; // likeCount가 없을 경우 0으로 초기화

      if (likedByUser) {
        // 이미 사용자가 따봉을 누른 경우 -> 취소
        likedUsers.remove(currentUser.uid);
        likeCount--;
      } else {
        // 사용자가 따봉을 누르지 않은 경우 -> 추가
        likedUsers.add(currentUser.uid);
        likeCount++;
      }

      transaction.update(reviewRef, {
        'likedUsers': likedUsers, // 따봉 누른 사용자 목록 업데이트
        'likeCount': likeCount, // 따봉 개수 업데이트
      });
    });
  }
}
