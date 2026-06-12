import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Đã bổ sung: Bắt buộc phải có để nhận diện 'DefaultFirebaseOptions'
import 'views/account/login_screen.dart';
import 'views/account/profile_screen.dart';
import 'views/account/settings_screen.dart';
import 'views/account/news_screen.dart';
import 'views/account/sentence_screen.dart';
import 'views/flashcard/create_flashcard_screen.dart';
import 'views/flashcard/my_sets_screen.dart';

void main() async {
  // Kích hoạt Flutter sẵn sàng trước khi chạy lệnh ẩn (async)
  WidgetsFlutterBinding.ensureInitialized();

  // Kích hoạt Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Japanese Learning App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MySetsScreen(), // Đặt màn hình Đăng nhập xuất hiện đầu tiên khi mở app
    );
  }
}