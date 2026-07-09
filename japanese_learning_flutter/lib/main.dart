import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'routes/app_router.dart';
import 'providers/app_setting_provider.dart';

void main() async {
  // Kích hoạt Flutter sẵn sàng trước khi chạy lệnh ẩn (async)
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo SharedPreferences trước khi chạy App
  final sharedPreferences = await SharedPreferences.getInstance();

  // Kích hoạt Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ProviderScope(
      overrides: [
        // Cung cấp instance SharedPreferences vào hệ thống Riverpod
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingProvider);
    final isDark = settings.isDarkMode;

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
            textScaleFactor: settings.textScaleFactor,
          ),
          child: widget!,
        );
      },
    );
  }
}