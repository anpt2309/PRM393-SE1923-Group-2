import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/services/notification_service.dart';

// ─────────────────────────────────────────────────────────────
// STATE CLASS
// ─────────────────────────────────────────────────────────────

/// Snapshot bất biến (immutable) của cấu hình giao diện và ứng dụng.
class AppSettingState {
  final bool isDarkMode;
  final String fontSizeLabel;
  final double textScaleFactor;

  // Cấu hình học tập & âm thanh
  final bool autoTranslate;
  final bool autoPaste;
  final String readingSpeed;
  final bool autoRepeatAudio;

  // Cấu hình thông báo
  final bool dailyReminder;
  final int reminderHour;
  final int reminderMinute;

  const AppSettingState({
    this.isDarkMode = false,
    this.fontSizeLabel = 'Vừa',
    this.textScaleFactor = 1.0,
    this.autoTranslate = true,
    this.autoPaste = true,
    this.readingSpeed = 'Bình thường',
    this.autoRepeatAudio = false,
    this.dailyReminder = true,
    this.reminderHour = 19,
    this.reminderMinute = 0,
  });

  AppSettingState copyWith({
    bool? isDarkMode,
    String? fontSizeLabel,
    double? textScaleFactor,
    bool? autoTranslate,
    bool? autoPaste,
    bool? keepScreenAwake,
    String? readingSpeed,
    bool? autoRepeatAudio,
    bool? dailyReminder,
    int? reminderHour,
    int? reminderMinute,
  }) {
    return AppSettingState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      fontSizeLabel: fontSizeLabel ?? this.fontSizeLabel,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      autoTranslate: autoTranslate ?? this.autoTranslate,
      autoPaste: autoPaste ?? this.autoPaste,
      readingSpeed: readingSpeed ?? this.readingSpeed,
      autoRepeatAudio: autoRepeatAudio ?? this.autoRepeatAudio,
      dailyReminder: dailyReminder ?? this.dailyReminder,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// REPOSITORY PROVIDER
// ─────────────────────────────────────────────────────────────

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// ─────────────────────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────────────────────

class AppSettingNotifier extends Notifier<AppSettingState> {
  late SharedPreferences _prefs;
  final _notificationService = NotificationService();

  @override
  AppSettingState build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return _loadSettings();
  }

  AppSettingState _loadSettings() {
    return AppSettingState(
      isDarkMode: _prefs.getBool('isDarkMode') ?? false,
      fontSizeLabel: _prefs.getString('fontSizeLabel') ?? 'Vừa',
      textScaleFactor: _prefs.getDouble('textScaleFactor') ?? 1.0,
      autoTranslate: _prefs.getBool('autoTranslate') ?? true,
      autoPaste: _prefs.getBool('autoPaste') ?? true,
      readingSpeed: _prefs.getString('readingSpeed') ?? 'Bình thường',
      autoRepeatAudio: _prefs.getBool('autoRepeatAudio') ?? false,
      dailyReminder: _prefs.getBool('dailyReminder') ?? true,
      reminderHour: _prefs.getInt('reminderHour') ?? 19,
      reminderMinute: _prefs.getInt('reminderMinute') ?? 0,
    );
  }

  void toggleDarkMode(bool isDark) {
    state = state.copyWith(isDarkMode: isDark);
    _prefs.setBool('isDarkMode', isDark);
  }

  void updateFontSize(String label) {
    double factor = 1.0;
    switch (label) {
      case 'Nhỏ': factor = 0.85; break;
      case 'Lớn': factor = 1.25; break;
      case 'Vừa': default: factor = 1.0; break;
    }
    state = state.copyWith(fontSizeLabel: label, textScaleFactor: factor);
    _prefs.setString('fontSizeLabel', label);
    _prefs.setDouble('textScaleFactor', factor);
  }

  void updateAutoTranslate(bool val) {
    state = state.copyWith(autoTranslate: val);
    _prefs.setBool('autoTranslate', val);
  }

  void updateAutoPaste(bool val) {
    state = state.copyWith(autoPaste: val);
    _prefs.setBool('autoPaste', val);
  }

  void updateReadingSpeed(String val) {
    state = state.copyWith(readingSpeed: val);
    _prefs.setString('readingSpeed', val);
  }

  void updateAutoRepeatAudio(bool val) {
    state = state.copyWith(autoRepeatAudio: val);
    _prefs.setBool('autoRepeatAudio', val);
  }

  void updateDailyReminder(bool val) {
    state = state.copyWith(dailyReminder: val);
    _prefs.setBool('dailyReminder', val);
    _updateSystemReminder();
  }

  void updateReminderTime(int hour, int minute) {
    state = state.copyWith(reminderHour: hour, reminderMinute: minute);
    _prefs.setInt('reminderHour', hour);
    _prefs.setInt('reminderMinute', minute);
    _updateSystemReminder();
  }

  /// Gọi dịch vụ thông báo thật để đặt lịch
  void _updateSystemReminder() {
    _notificationService.scheduleDailyReminder(
      hour: state.reminderHour,
      minute: state.reminderMinute,
      enabled: state.dailyReminder,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PROVIDER DECLARATION
// ─────────────────────────────────────────────────────────────

final appSettingProvider =
    NotifierProvider<AppSettingNotifier, AppSettingState>(
      AppSettingNotifier.new,
    );
