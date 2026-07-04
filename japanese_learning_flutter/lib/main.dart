import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanese_learning/viewmodels/app_setting_viewmodel.dart';
import 'firebase_options.dart';
import 'routes/app_router.dart';

// Alias để các màn hình cũ vẫn dùng AppSettingProvider không bị lỗi
typedef AppSettingProvider = AppSettingViewModel;

// Biến toàn cục để các màn hình con truy cập dễ dàng
final AppSettingViewModel appSettings = AppSettingViewModel();
void main() async {
  // Kích hoạt Flutter sẵn sàng trước khi chạy lệnh ẩn (async)
  WidgetsFlutterBinding.ensureInitialized();


  // Kích hoạt Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // ProviderScope bọc 1 lần duy nhất — toàn bộ team tự do thêm provider mới
  // mà không cần đụng vào file main.dart này nữa.
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng AnimatedBuilder để lắng nghe, mỗi khi gọi notifyListeners(),
    // toàn bộ MaterialApp bao gồm cấu hình màu và chữ sẽ được xây dựng lại
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, child) {
        // Tự động xác định cấu hình màu cục bộ dựa trên provider[cite: 4]
        final isDark = appSettings.isCustomDarkColor;
        return MaterialApp.router(
          title: 'Japanese Learning',
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,

          // Bảng màu theo chế độ tối/sáng
          theme: ThemeData(
            brightness: isDark ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
            cardColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            appBarTheme: AppBarTheme(
              backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              elevation: isDark ? 0 : 0.5,
            ),
          ),

          // Ép tỷ lệ kích thước chữ cho toàn bộ ứng dụng
          builder: (context, widget) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: appSettings.textScaleFactor,
              ),
              child: widget!,
            );
          },
        );
      },
    );
  }
}