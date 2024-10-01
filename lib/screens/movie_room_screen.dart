import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication 패키지
import 'package:flutter/material.dart'; // Flutter 기본 UI 위젯
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore 패키지
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // 별점 평점 라이브러리
import 'reply_screen.dart'; // reply_screen.dart 파일 import
import 'my_page_screen.dart'; // MyPageScreen import

// 영화 방 화면, 사용자는 영화를 보고 리뷰를 작성하고 다른 사람들의 리뷰를 볼 수 있음
class MovieRoomScreen extends StatefulWidget {
  final String movieTitle; // 영화 제목을 받아옴

  MovieRoomScreen({required this.movieTitle});

  @override
  _MovieRoomScreenState createState() => _MovieRoomScreenState();
}

class _MovieRoomScreenState extends State<MovieRoomScreen> {
  final TextEditingController _reviewController = TextEditingController(); // 리뷰 작성 텍스트 필드 컨트롤러
  double _rating = 3.0; // 별점 기본 값
  bool _isLiked = false; // 좋아요 상태
  bool _hasSeenMovie = false; // '본 영화' 상태

  @override
  void initState() {
    super.initState();
    _loadUserMovieStatus(); // 사용자 영화 상태를 로드 (좋아요 여부, 본 영화 여부)
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
      future: FirebaseFirestore.instance.collection('movies').doc(widget.movieTitle).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator()); // 데이터 로딩 중일 때 로딩 표시
        }

        if (!snapshot.data!.exists) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No movie data available', // 해당 영화 데이터가 없을 경우 표시
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          );
        }

        var movieData = snapshot.data!.data() as Map<String, dynamic>; // Firestore에서 가져온 데이터를 맵으로 캐스팅

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 영화 포스터
                  Container(
                    height: 200,
                    child: Image.network(
                      movieData['posterUrl'] ?? 'https://via.placeholder.com/150x200',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 16), // 포스터와 버튼들 사이의 간격
                  Column(
                    children: [
                      // 좋아요 버튼
                      IconButton(
                        icon: Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _isLiked ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          _toggleMovieLike(widget.movieTitle); // 좋아요 상태 토글
                        },
                      ),
                      Text('Liked'),
                      SizedBox(height: 16),
                      // '본 영화' 버튼
                      IconButton(
                        icon: Icon(
                          _hasSeenMovie ? Icons.visibility : Icons.visibility_off,
                          color: _hasSeenMovie ? Colors.blue : Colors.grey,
                        ),
                        onPressed: () {
                          _toggleSawMovie(widget.movieTitle); // '본 영화' 상태 토글
                        },
                      ),
                      Text('I Saw This Movie'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10), // 간격 추가
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.movieTitle, // 영화 제목
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text('Director: ${movieData['director'] ?? 'Unknown'}'), // 감독 정보
                    Text('Year: ${movieData['releaseYear'] ?? 'Unknown'}'), // 개봉 연도
                    Text('Actors: ${movieData['actors'] ?? 'Unknown'}'), // 배우 정보
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 사용자 영화 상태 로드 함수 (좋아요 여부, 본 영화 여부)
  void _loadUserMovieStatus() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    DocumentSnapshot likedMovieDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('likedMovies')
        .doc(widget.movieTitle)
        .get();

    DocumentSnapshot sawMovieDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('sawMovies')
        .doc(widget.movieTitle)
        .get();

    setState(() {
      _isLiked = likedMovieDoc.exists;
      _hasSeenMovie = sawMovieDoc.exists;
    });
  }

  // 좋아요 상태 토글 함수
  void _toggleMovieLike(String movieId) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    DocumentReference userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('likedMovies')
        .doc(movieId);

    DocumentSnapshot movieSnapshot = await userDoc.get();

    if (movieSnapshot.exists) {
      await userDoc.delete();
      setState(() {
        _isLiked = false;
      });
    } else {
      await userDoc.set({'movieId': movieId});
      setState(() {
        _isLiked = true;
      });
    }
  }

  // '본 영화' 상태 토글 함수
  void _toggleSawMovie(String movieId) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    DocumentReference userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('sawMovies')
        .doc(movieId);

    DocumentSnapshot movieSnapshot = await userDoc.get();

    if (movieSnapshot.exists) {
      await userDoc.delete();
      setState(() {
        _hasSeenMovie = false;
      });
    } else {
      await userDoc.set({'movieId': movieId});
      setState(() {
        _hasSeenMovie = true;
      });
    }
  }

  // 별점 및 리뷰 작성 섹션
  Widget _buildRatingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          RatingBar.builder(
            initialRating: _rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),
          TextField(
            controller: _reviewController,
            decoration: InputDecoration(labelText: 'Write your review'), // 리뷰 작성 필드
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: _submitReview,
            child: Text('Submit Review'),
          ),
        ],
      ),
    );
  }

  // Firestore에서 리뷰 목록을 실시간으로 불러오는 함수
  Widget _buildReviews() {
    return Container(
      height: 300,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('movies')
            .doc(widget.movieTitle)
            .collection('reviews')
            .orderBy('likeCount', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var reviews = snapshot.data!.docs;
          var currentUser = FirebaseAuth.instance.currentUser;

          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              var review = reviews[index];
              bool likedByUser = review['likedUsers']?.contains(currentUser?.uid) ?? false;

              return ListTile(
                title: Text(review['reviewText']),
                subtitle: Row(
                  children: [
                    Text('Rating: ${review['rating']}'),
                    Spacer(),
                    GestureDetector(
                      child: Text(review['userName'], style: TextStyle(color: Colors.blue)),
                      onTap: () {
                        // 유저 프로필 페이지로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyPageScreen(
                              userId: review['userId'], // 유저 ID 전달
                              isEditable: currentUser?.uid == review['userId'], // 자신일 때만 수정 가능
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        likedByUser ? Icons.thumb_up : Icons.thumb_up_outlined,
                        color: likedByUser ? Colors.blue : null,
                      ),
                      onPressed: () => _toggleLike(review.id, likedByUser),
                    ),
                    SizedBox(width: 8),
                    Text('${review['likeCount'] ?? 0}'),
                    IconButton(
                      icon: Icon(Icons.comment),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReplyScreen(
                              reviewId: review.id,
                              movieTitle: widget.movieTitle,
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
    if (_reviewController.text.isEmpty) return;

    User? currentUser = FirebaseAuth.instance.currentUser;
    String userName = currentUser?.displayName ?? 'User123';

    final reviewData = {
      'reviewText': _reviewController.text,
      'rating': _rating,
      'userName': userName,
      'userId': currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'likeCount': 0,
      'likedUsers': [],
    };

    // Firestore에 리뷰 데이터 추가
    var movieRef = FirebaseFirestore.instance.collection('movies').doc(widget.movieTitle);

    // movies/{movieId}/reviews/{reviewId}에 저장
    var newReviewRef = await movieRef.collection('reviews').add(reviewData);

    // users/{userId}/reviews/{reviewId}에 동일한 리뷰 저장
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('reviews')
        .doc(newReviewRef.id)
        .set({...reviewData, 'movieId': widget.movieTitle}); // 사용자 컬렉션에도 저장

    _reviewController.clear();
    setState(() {
      _rating = 3.0;
    });
  }

  // 리뷰 좋아요 토글 기능
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

      var likedUsers = List<String>.from(reviewSnapshot['likedUsers'] ?? []);
      int likeCount = reviewSnapshot['likeCount'] ?? 0;

      if (likedByUser) {
        likedUsers.remove(currentUser!.uid);
        likeCount--;
      } else {
        likedUsers.add(currentUser!.uid);
        likeCount++;
      }

      transaction.update(reviewRef, {
        'likedUsers': likedUsers,
        'likeCount': likeCount,
      });
    });
  }
}
