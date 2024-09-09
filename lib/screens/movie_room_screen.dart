import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage 추가
import 'dart:io'; // 이미지 파일을 사용하기 위해 추가
import 'package:image_picker/image_picker.dart'; // 이미지 선택 패키지

class MovieRoomScreen extends StatefulWidget {
  final String movieTitle;

  MovieRoomScreen({required this.movieTitle});

  @override
  _MovieRoomScreenState createState() => _MovieRoomScreenState();
}

class _MovieRoomScreenState extends State<MovieRoomScreen> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 3.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movieTitle),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildMovieInfo(),
            _buildRatingSection(),
            SizedBox(height: 10),
            _buildReviews(), // 리뷰 섹션
            SizedBox(height: 10),
            _buildGallery(),
          ],
        ),
      ),
      bottomNavigationBar: _buildChatRoomButton(), // 채팅방 버튼을 하단에 고정
    );
  }

  // 영화 정보와 포스터를 보여주는 부분
  Widget _buildMovieInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 영화 포스터
        Container(
          height: 200,
          child: Image.network(
            'https://via.placeholder.com/150x200', // 포스터 URL로 대체
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 10),
        // 영화 기본 정보 (제목, 감독, 연도 등)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.movieTitle,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text('Director: Christopher Nolan'), // 예시 정보
              Text('Year: 2020'), // 예시 정보
              Text('Actors: Actor 1, Actor 2'), // 예시 정보
            ],
          ),
        ),
      ],
    );
  }

  // 영화 별점을 입력하고 리뷰를 작성하는 부분
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

  // 리뷰 목록을 보여주는 부분 (스크롤 가능)
  Widget _buildReviews() {
    return Container(
      height: 300, // 리뷰 목록의 고정 높이 설정
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('movies')
            .doc(widget.movieTitle)
            .collection('reviews')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var reviews = snapshot.data!.docs;
          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              var review = reviews[index];
              return ListTile(
                title: Text(review['reviewText']),
                subtitle: Row(
                  children: [
                    Text('Rating: ${review['rating']}'),
                    Spacer(),
                    Text(review['userName']), // 사용자 이름 추가
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.thumb_up),
                      onPressed: () {}, // 좋아요 기능 추가 예정
                    ),
                    IconButton(
                      icon: Icon(Icons.thumb_down),
                      onPressed: () {}, // 싫어요 기능 추가 예정
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

  // 갤러리 섹션 (사진 추가 가능)
  Widget _buildGallery() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(Icons.photo_album),
          SizedBox(width: 8),
          Text('Gallery'),
          Spacer(),
          ElevatedButton(
            onPressed: () {
              // 갤러리 기능 추가 예정
            },
            child: Text('Upload'),
          ),
        ],
      ),
    );
  }

  // 채팅방으로 이동하는 버튼 (bottomNavigationBar에 위치)
  Widget _buildChatRoomButton() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          // 채팅방 화면으로 이동하는 코드 추가 예정
        },
        child: Text('Go to Chat Room'),
      ),
    );
  }

  // 리뷰 제출하기
  void _submitReview() async {
    if (_reviewController.text.isEmpty) return;

    User? currentUser = FirebaseAuth.instance.currentUser;

    String userName = currentUser?.displayName ?? 'User123';

    await FirebaseFirestore.instance
        .collection('movies')
        .doc(widget.movieTitle)
        .collection('reviews')
        .add({
      'reviewText': _reviewController.text,
      'rating': _rating,
      'userName': userName, // 사용자 이름
      'timestamp': FieldValue.serverTimestamp(),
    });
    _reviewController.clear();
    setState(() {
      _rating = 3.0;
    });
  }
}
