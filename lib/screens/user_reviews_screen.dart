import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'movie_room_screen.dart';

class UserReviewsScreen extends StatefulWidget {
  @override
  _UserReviewsScreenState createState() => _UserReviewsScreenState();
}

class _UserReviewsScreenState extends State<UserReviewsScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text("My Reviews")),
      body: StreamBuilder(
        // Firestore에서 현재 사용자의 리뷰를 가져옴
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('reviews') // 사용자의 리뷰를 불러옴
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator()); // 데이터가 없으면 로딩 표시
          }

          var reviews = snapshot.data!.docs; // 리뷰 데이터 목록

          return ListView.builder(
            itemCount: reviews.length, // 리뷰 개수만큼 리스트 생성
            itemBuilder: (context, index) {
              var review = reviews[index]; // 각 리뷰 데이터

              return FutureBuilder<DocumentSnapshot>(
                // 각 리뷰의 movieId를 참조해 해당 영화 데이터를 가져옴
                future: FirebaseFirestore.instance
                    .collection('movies')
                    .doc(review['movieId']) // 영화 문서에서 영화 정보 가져오기
                    .get(),
                builder: (context, movieSnapshot) {
                  if (!movieSnapshot.hasData) return CircularProgressIndicator(); // 영화 데이터 로딩 중

                  var movieData = movieSnapshot.data!.data() as Map<String, dynamic>; // 영화 데이터 맵

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 영화 정보 표시 (포스터, 제목, 감독)
                        ListTile(
                          leading: Image.network(
                            movieData['posterUrl'], // 영화 포스터 URL
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(movieData['title']), // 영화 제목
                          subtitle: Text(movieData['director']), // 감독 이름
                          onTap: () {
                            // 사용자가 영화 정보를 클릭하면 MovieRoomScreen으로 이동
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MovieRoomScreen(movieTitle: movieData['title']),
                              ),
                            );
                          },
                        ),
                        // 리뷰 및 별점 표시
                        Padding(
                          padding: const EdgeInsets.only(left: 64.0), // 포스터 옆으로 리뷰 위치 조정
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Rating: ${review['rating']} ★", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // 별점
                              SizedBox(height: 4),
                              Text(review['reviewText'], style: TextStyle(fontSize: 14)), // 리뷰 텍스트
                            ],
                          ),
                        ),
                        Divider(), // 리뷰와 영화 항목 사이에 구분선
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
