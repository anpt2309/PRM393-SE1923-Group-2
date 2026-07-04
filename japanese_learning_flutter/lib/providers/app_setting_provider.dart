import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return const AppSettingState();
  }

  /// Bật/tắt chế độ tối.
  void toggleDarkMode(bool isDark) {
    state = state.copyWith(isDarkMode: isDark);
  }

  /// Thay đổi cỡ chữ.
  void updateFontSize(String label) {
    double factor = 1.0;
    switch (label) {
      case 'Nhỏ':
        factor = 0.85;
        break;
      case 'Lớn':
        factor = 1.25;
        break;
      case 'Vừa':
      default:
        factor = 1.0;
        break;
    }
    state = state.copyWith(
      fontSizeLabel: label,
      textScaleFactor: factor,
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
