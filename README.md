
# Afterscene 🎬

**Afterscene** is a Flutter-based mobile application designed for college-level capstone project courses.  
It allows users to record, browse, review, and interact around movies through a fully integrated UI backed by Firebase.

---

## 🚀 Features

- 🔐 **User Authentication** with Firebase
- 📆 **Calendar-based movie viewing** (using `TableCalendar`)
- 🎥 **Movie management** (add/edit posters, title, genre, etc.)
- ⭐ **Ratings and reviews** per movie
- 💬 **Comment threads** on reviews (with like system)
- 👤 **My Page** to view and edit personal profile
- 🖼️ **Profile & Poster Image Upload** via Firebase Storage

---

## 📁 Project Structure

```
lib/
├── main.dart                      # App entry with routing & navigation
├── firebase_options.dart          # Firebase config
└── screens/
    ├── login_screen.dart
    ├── signup_screen.dart
    ├── home_screen.dart
    ├── add_movie_screen.dart
    ├── movie_room_screen.dart
    ├── reply_screen.dart
    └── my_page_screen.dart
```

---

## 🧩 Tech Stack

### Frontend  
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)  
![Material UI](https://img.shields.io/badge/Material--UI-0081CB?style=for-the-badge&logo=mui&logoColor=white)  
![Navigation](https://img.shields.io/badge/Navigation-internal-blue?style=for-the-badge)  
![StatefulWidget](https://img.shields.io/badge/StatefulWidget-Dart-blue?style=for-the-badge)  
![Image Picker](https://img.shields.io/badge/Image_Picker-FFCC00?style=for-the-badge&logo=flutter&logoColor=black)  
![TableCalendar](https://img.shields.io/badge/TableCalendar-Calendar-FF6F00?style=for-the-badge)

### Backend  
![Firebase Auth](https://img.shields.io/badge/Firebase_Auth-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)  
![Cloud Firestore](https://img.shields.io/badge/Cloud_Firestore-FFA000?style=for-the-badge&logo=firebase&logoColor=white)  
![Firebase Storage](https://img.shields.io/badge/Firebase_Storage-FFCCBC?style=for-the-badge&logo=firebase&logoColor=black)


---

## 🛠 Function Highlights

- **AddMovieScreen**: Register movie info + image upload to Firebase Storage  
- **HomeScreen**: Browse upcoming & past movies with calendar view  
- **MovieRoomScreen**: Leave reviews and rate others  
- **ReplyScreen**: Nested comment threads with like counts  
- **MyPageScreen**: Edit profile, upload image, manage favorite genres

---

## 🧪 How to Run

```bash
flutter pub get
flutter run
```

Ensure your Firebase project is set up correctly using `firebase_options.dart`.

---

## 📌 Notes

This project was developed as part of a university capstone design course (2024 2학기 다학제캡스톤디자인).  
All Firebase credentials are tied to a test project and can be reconfigured via FlutterFire CLI.

---
