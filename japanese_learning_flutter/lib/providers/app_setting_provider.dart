// lib/providers/app_setting_provider.dart
//
// Provider quản lý cấu hình giao diện toàn cục (Dark Mode, Font Size).
// Mỗi màn hình dùng ref.watch(appSettingProvider) để tự động rebuild khi
// người dùng thay đổi theme hoặc cỡ chữ trong màn hình Cài đặt.
//
// ⚠️  Lưu ý cho team: Singleton appSettings ở main.dart vẫn còn nguyên để
// các màn hình cũ (account/...) hoạt động bình thường. Provider này là lớp
// Riverpod mới dành cho các màn hình được refactor (HomeScreen, v.v.)
// Hai lớp chia sẻ state thông qua cùng một instance AppSettingViewModel.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanese_learning/main.dart'; // Import singleton appSettings

// ─────────────────────────────────────────────────────────────
// STATE CLASS
// ─────────────────────────────────────────────────────────────

/// Snapshot bất biến (immutable) của cấu hình giao diện.
class AppSettingState {
  final bool isDarkMode;
  final String fontSizeLabel;
  final double textScaleFactor;

  const AppSettingState({
    this.isDarkMode = false,
    this.fontSizeLabel = 'Vừa',
    this.textScaleFactor = 1.0,
  });

  AppSettingState copyWith({
    bool? isDarkMode,
    String? fontSizeLabel,
    double? textScaleFactor,
  }) {
    return AppSettingState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      fontSizeLabel: fontSizeLabel ?? this.fontSizeLabel,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────────────────────

class AppSettingNotifier extends Notifier<AppSettingState> {
  @override
  AppSettingState build() {
    // Đọc trạng thái ban đầu từ singleton (để đồng bộ nhất quán)
    return AppSettingState(
      isDarkMode: appSettings.isCustomDarkColor,
      fontSizeLabel: appSettings.fontSizeLabel,
      textScaleFactor: appSettings.textScaleFactor,
    );
  }

  /// Bật/tắt chế độ tối. Cập nhật cả Riverpod state và singleton gốc.
  void toggleDarkMode(bool isDark) {
    appSettings.toggleCustomColor(isDark); // cập nhật singleton để main.dart rebuild
    state = state.copyWith(isDarkMode: isDark);
  }

  /// Thay đổi cỡ chữ. Cập nhật cả Riverpod state và singleton gốc.
  void updateFontSize(String label) {
    appSettings.updateFontSize(label); // cập nhật singleton để main.dart rebuild
    state = state.copyWith(
      fontSizeLabel: label,
      textScaleFactor: appSettings.textScaleFactor,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PROVIDER DECLARATION
// ─────────────────────────────────────────────────────────────

/// Provider toàn cục cho cài đặt ứng dụng.
/// Các màn hình dùng: ref.watch(appSettingProvider) để lấy AppSettingState
/// Các màn hình dùng: ref.read(appSettingProvider.notifier) để gọi action
final appSettingProvider =
    NotifierProvider<AppSettingNotifier, AppSettingState>(
  AppSettingNotifier.new,
);
