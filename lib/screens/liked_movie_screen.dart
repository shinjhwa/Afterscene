import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'movie_room_screen.dart';

class LikedMoviesScreen extends StatefulWidget {
  @override
  _LikedMoviesScreenState createState() => _LikedMoviesScreenState();
}

class _LikedMoviesScreenState extends State<LikedMoviesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Liked Movies")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('likedMovies')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var likedMovies = snapshot.data!.docs;

          return ListView.builder(
            itemCount: likedMovies.length,
            itemBuilder: (context, index) {
              var movie = likedMovies[index];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('movies')
                    .doc(movie['movieId'])
                    .get(),
                builder: (context, movieSnapshot) {
                  if (!movieSnapshot.hasData) return CircularProgressIndicator();
                  var movieData = movieSnapshot.data!.data() as Map<String, dynamic>;

                  return ListTile(
                    leading: Image.network(
                      movieData['posterUrl'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(movieData['title']),
                    subtitle: Text(movieData['director']),
                    trailing: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('likedMovies')
                          .doc(movie['movieId'])
                          .snapshots(),
                      builder: (context, AsyncSnapshot<DocumentSnapshot> likeSnapshot) {
                        if (!likeSnapshot.hasData) return CircularProgressIndicator();

                        bool isLiked = likeSnapshot.data!.exists;

                        return IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : null,
                          ),
                          onPressed: () async {
                            if (isLiked) {
                              // 좋아요 취소
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('likedMovies')
                                  .doc(movie['movieId'])
                                  .delete();
                              setState(() {
                                isLiked = false;
                              });
                            } else {
                              // 좋아요 추가
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('likedMovies')
                                  .doc(movie['movieId'])
                                  .set({'movieId': movie['movieId']});
                              setState(() {
                                isLiked = true;
                              });
                            }
                          },
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieRoomScreen(movieTitle: movieData['title']),
                        ),
                      );
                    },
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
