import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReplyScreen extends StatefulWidget {
  final String reviewId; // 리뷰 ID
  final String movieTitle; // 영화 제목

  ReplyScreen({required this.reviewId, required this.movieTitle});

  @override
  _ReplyScreenState createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<ReplyScreen> {
  final TextEditingController _replyController = TextEditingController(); // 답글 입력 필드 컨트롤러

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Replies'), // 답글 화면 제목
      ),
      body: Column(
        children: [
          Expanded(
            // Firestore에서 실시간으로 답글 목록 불러오기
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('movies') // 'movies' 컬렉션
                  .doc(widget.movieTitle) // 해당 영화 문서
                  .collection('reviews') // 'reviews' 컬렉션
                  .doc(widget.reviewId) // 해당 리뷰 문서
                  .collection('replies') // 'replies' 컬렉션
                  .snapshots(), // 실시간으로 데이터를 가져옴
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator()); // 데이터가 없으면 로딩 표시

                var replies = snapshot.data!.docs; // 답글 데이터
                var currentUser = FirebaseAuth.instance.currentUser; // 현재 로그인한 사용자

                return ListView.builder(
                  itemCount: replies.length, // 답글 개수만큼 리스트 생성
                  itemBuilder: (context, index) {
                    var reply = replies[index]; // 각 답글 데이터
                    bool likedByUser = reply['likedUsers']?.contains(currentUser?.uid) ?? false; // 현재 사용자가 좋아요를 눌렀는지 확인
                    bool isAuthor = reply['userId'] == currentUser?.uid; // 답글 작성자인지 확인

                    return ListTile(
                      title: Text(reply['replyText']), // 답글 내용
                      subtitle: Row(
                        children: [
                          Text(isAuthor ? "작성자" : reply['userName']), // 작성자 표시
                          Spacer(),
                          // 좋아요 버튼
                          IconButton(
                            icon: Icon(
                              likedByUser ? Icons.thumb_up : Icons.thumb_up_outlined, // 눌렀을 때와 안 눌렀을 때 아이콘
                              color: likedByUser ? Colors.blue : null, // 좋아요 누른 상태에서는 파란색으로 표시
                            ),
                            onPressed: () => _toggleLikeReply(reply.id, likedByUser), // 좋아요 토글 기능
                          ),
                          SizedBox(width: 8),
                          Text('${reply['likeCount'] ?? 0}'), // 좋아요 개수 표시
                        ],
                      ),
                      tileColor: isAuthor ? Colors.yellow[100] : null, // 작성자는 배경색 다르게 표시
                    );
                  },
                );
              },
            ),
          ),
          // 답글 입력 창
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController, // 답글 입력 필드
                    decoration: InputDecoration(labelText: 'Reply...'), // 입력 필드 안내 문구
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send), // 답글 제출 버튼
                  onPressed: _submitReply, // 답글 제출 함수 호출
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 답글 제출 함수
  void _submitReply() async {
    if (_replyController.text.isEmpty) return; // 답글이 비어있으면 아무 작업도 하지 않음

    var currentUser = FirebaseAuth.instance.currentUser; // 현재 로그인한 사용자 정보

    // Firestore에 답글 데이터 추가
    await FirebaseFirestore.instance
        .collection('movies') // 'movies' 컬렉션
        .doc(widget.movieTitle) // 해당 영화 문서
        .collection('reviews') // 'reviews' 컬렉션
        .doc(widget.reviewId) // 해당 리뷰 문서
        .collection('replies') // 'replies' 컬렉션
        .add({
      'replyText': _replyController.text, // 답글 내용
      'userName': currentUser?.displayName ?? 'User', // 사용자 이름
      'userId': currentUser?.uid, // 사용자 ID
      'likeCount': 0, // 초기 좋아요 개수
      'likedUsers': [], // 좋아요 누른 사용자 목록 초기화
      'timestamp': FieldValue.serverTimestamp(), // 답글 작성 시간
    });

    _replyController.clear(); // 답글 입력 필드 초기화
  }

  // 답글 좋아요 토글 함수
  void _toggleLikeReply(String replyId, bool likedByUser) async {
    var currentUser = FirebaseAuth.instance.currentUser; // 현재 로그인한 사용자

    var replyRef = FirebaseFirestore.instance
        .collection('movies')
        .doc(widget.movieTitle)
        .collection('reviews')
        .doc(widget.reviewId)
        .collection('replies')
        .doc(replyId); // Firestore에서 해당 답글 문서 참조

    FirebaseFirestore.instance.runTransaction((transaction) async {
      var replySnapshot = await transaction.get(replyRef); // 해당 답글 문서 가져오기

      if (!replySnapshot.exists) return; // 문서가 존재하지 않으면 종료

      var likedUsers = List<String>.from(replySnapshot['likedUsers'] ?? []); // 좋아요 누른 사용자 목록
      int likeCount = replySnapshot['likeCount'] ?? 0; // 좋아요 개수

      if (likedByUser) {
        // 이미 좋아요를 누른 경우 -> 좋아요 취소
        likedUsers.remove(currentUser!.uid);
        likeCount--;
      } else {
        // 좋아요를 누르지 않은 경우 -> 좋아요 추가
        likedUsers.add(currentUser!.uid);
        likeCount++;
      }

      // Firestore에 업데이트된 값 저장
      transaction.update(replyRef, {
        'likedUsers': likedUsers, // 업데이트된 좋아요 사용자 목록
        'likeCount': likeCount, // 업데이트된 좋아요 개수
      });
    });
  }
}
