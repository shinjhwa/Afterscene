import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'movie_room_screen.dart';

class SawMoviesScreen extends StatefulWidget {
  @override
  _SawMoviesScreenState createState() => _SawMoviesScreenState();
}

class _SawMoviesScreenState extends State<SawMoviesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Movies I've Seen")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('sawMovies')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var sawMovies = snapshot.data!.docs;

          return ListView.builder(
            itemCount: sawMovies.length,
            itemBuilder: (context, index) {
              var movie = sawMovies[index];

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
                          .collection('sawMovies')
                          .doc(movie['movieId'])
                          .snapshots(),
                      builder: (context, AsyncSnapshot<DocumentSnapshot> sawSnapshot) {
                        if (!sawSnapshot.hasData) return CircularProgressIndicator();

                        bool hasSeen = sawSnapshot.data!.exists;

                        return IconButton(
                          icon: Icon(
                            hasSeen ? Icons.visibility : Icons.visibility_off,
                            color: hasSeen ? Colors.blue : null,
                          ),
                          onPressed: () async {
                            if (hasSeen) {
                              // 본 영화 취소
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('sawMovies')
                                  .doc(movie['movieId'])
                                  .delete();
                              setState(() {
                                hasSeen = false;
                              });
                            } else {
                              // 본 영화 추가
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('sawMovies')
                                  .doc(movie['movieId'])
                                  .set({'movieId': movie['movieId']});
                              setState(() {
                                hasSeen = true;
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
