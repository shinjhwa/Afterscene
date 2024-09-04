import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Firestore 패키지 추가
import 'package:flutter_rating_bar/flutter_rating_bar.dart';  // 별점 입력을 위한 패키지

class MovieRoomScreen extends StatefulWidget {
  final String movieTitle;

  MovieRoomScreen({required this.movieTitle});

  @override
  _MovieRoomScreenState createState() => _MovieRoomScreenState();
}

class _MovieRoomScreenState extends State<MovieRoomScreen> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 3.0;  // 기본 별점

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movieTitle),
      ),
      body: Column(
        children: [
          // 영화 기본 정보 및 평균 별점
          _buildMovieInfo(),
          SizedBox(height: 20),
          // 한줄평 및 별점 입력
          _buildReviewInput(),
          SizedBox(height: 20),
          // 사용자가 등록한 리뷰 목록
          _buildReviewList(),
        ],
      ),
    );
  }

  // 영화 기본 정보 및 평균 별점
  Widget _buildMovieInfo() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('movies')
          .doc(widget.movieTitle)
          .collection('reviews')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var reviews = snapshot.data!.docs;
        double avgRating = reviews.isEmpty
            ? 0
            : reviews.map((doc) => doc['rating'] as double).reduce((a, b) => a + b) / reviews.length;

        return Column(
          children: [
            Text(
              widget.movieTitle,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Average Rating: ${avgRating.toStringAsFixed(1)}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        );
      },
    );
  }

  // 한줄평 및 별점 입력
  Widget _buildReviewInput() {
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
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
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
            decoration: InputDecoration(labelText: 'Write your review'),
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

  // 리뷰 제출하기 (Firestore에 저장)
  void _submitReview() async {
    if (_reviewController.text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('movies')
        .doc(widget.movieTitle)
        .collection('reviews')
        .add({
      'reviewText': _reviewController.text,
      'rating': _rating,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 리뷰 제출 후 초기화
    setState(() {
      _reviewController.clear();
      _rating = 3.0;
    });
  }

  // 리뷰 목록 표시
  Widget _buildReviewList() {
    return Expanded(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('movies')
            .doc(widget.movieTitle)
            .collection('reviews')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var reviews = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              var review = reviews[index];
              return ListTile(
                title: Text(review['reviewText']),
                subtitle: Text('Rating: ${review['rating']}'),
                trailing: Text(
                  (review['timestamp'] as Timestamp)
                      .toDate()
                      .toString(), // 리뷰 작성 시간 표시
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
