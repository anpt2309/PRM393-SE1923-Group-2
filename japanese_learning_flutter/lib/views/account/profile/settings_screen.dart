import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_setting_provider.dart';
import '../../../widgets/app_bar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingProvider);
    final isDarkMode = appSettings.isDarkMode;
    final currentFontSize = appSettings.fontSizeLabel;
    final double scale = appSettings.textScaleFactor;

    final backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.8);
    final iconColor = isDarkMode ? Colors.white70 : Colors.black.withValues(alpha: 0.7);

    final reminderTime = TimeOfDay(hour: appSettings.reminderHour, minute: appSettings.reminderMinute);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: const CustomAppBar(title: 'Cài đặt', centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SECTION HIỂN THỊ
            _SectionTitle(title: 'Hiển thị', isDarkMode: isDarkMode),
            _buildSettingsCard(cardColor, [
              _buildPillSelectionTile(ref, Icons.text_fields, 'Cỡ chữ', textColor, iconColor, ['Nhỏ', 'Vừa', 'Lớn'], currentFontSize, scale, (val) => ref.read(appSettingProvider.notifier).updateFontSize(val)),
              _buildSwitchTile(Icons.dark_mode_outlined, 'Hiển thị chế độ màn hình tối', isDarkMode, iconColor, textColor, scale, (v) => ref.read(appSettingProvider.notifier).toggleDarkMode(v)),
              _buildSwitchTile(Icons.copy_all, 'Tự động dịch từ được copy', appSettings.autoTranslate, iconColor, textColor, scale, (v) => ref.read(appSettingProvider.notifier).updateAutoTranslate(v)),
              _buildSwitchTile(Icons.paste_outlined, 'Tự dán từ sao chép vào ô tìm kiếm', appSettings.autoPaste, iconColor, textColor, scale, (v) => ref.read(appSettingProvider.notifier).updateAutoPaste(v)),
            ]),
            const SizedBox(height: 16),

            // 2. SECTION HỌC TẬP & ÂM THANH
            _SectionTitle(title: 'Cấu hình học tập & Âm thanh', isDarkMode: isDarkMode),
            _buildSettingsCard(cardColor, [
              _buildPillSelectionTile(ref, Icons.speed, 'Tốc độ đọc phát âm', textColor, iconColor, ['Chậm', 'Bình thường', 'Nhanh'], appSettings.readingSpeed, scale, (val) => ref.read(appSettingProvider.notifier).updateReadingSpeed(val)),
              _buildSwitchTile(Icons.replay_circle_filled_outlined, 'Tự động lặp lại âm thanh', appSettings.autoRepeatAudio, iconColor, textColor, scale, (v) => ref.read(appSettingProvider.notifier).updateAutoRepeatAudio(v)),
            ]),
            const SizedBox(height: 16),

            // 3. SECTION THÔNG BÁO
            _SectionTitle(title: 'Thông báo & Hoạt động', isDarkMode: isDarkMode),
            _buildSettingsCard(cardColor, [
              _buildSwitchTile(Icons.notifications_active_outlined, 'Bật nhắc học (${reminderTime.format(context)})', appSettings.dailyReminder, iconColor, textColor, scale, (v) => ref.read(appSettingProvider.notifier).updateDailyReminder(v)),
              if (appSettings.dailyReminder)
                _buildActionTile(Icons.access_time, 'Thay đổi khung giờ nhắc', iconColor, textColor, isDarkMode, onTap: () async {
                  final picked = await showTimePicker(context: context, initialTime: reminderTime);
                  if (picked != null) {
                    ref.read(appSettingProvider.notifier).updateReminderTime(picked.hour, picked.minute);
                  }
                }),
            ]),
          ],
        ),
      ),
    );
  }

  // Helper tạo Card để tránh lặp code
  Widget _buildSettingsCard(Color cardColor, List<Widget> children) {
    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Column(children: children)),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value, Color iconColor, Color textColor, double scale, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      secondary: Icon(icon, color: iconColor, size: 22 * scale),
      title: Text(title, style: TextStyle(fontSize: 14.5, color: textColor)),
      value: value,
      activeColor: Colors.blue,
      onChanged: onChanged,
    );
  }

  Widget _buildActionTile(IconData icon, String title, Color iconColor, Color textColor, bool isDark, {required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(title, style: TextStyle(fontSize: 14.5, color: textColor)),
      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.white30 : Colors.black26),
      onTap: onTap,
    );
  }

  Widget _buildPillSelectionTile(WidgetRef ref, IconData icon, String title, Color textColor, Color iconColor, List<String> options, String selectedValue, double scale, ValueChanged<String> onSelected) {
    final isDarkMode = ref.read(appSettingProvider).isDarkMode;
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 22 * scale),
      title: Text(title, style: TextStyle(fontSize: 14.5, color: textColor)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          final isSelected = option == selectedValue;
          return GestureDetector(
            onTap: () => onSelected(option),
            child: Container(
              margin: const EdgeInsets.only(left: 6.0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.withValues(alpha: 0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: isSelected ? Colors.blue.withValues(alpha: 0.3) : (isDarkMode ? Colors.white12 : Colors.grey.shade200)),
              ),
              child: Text(option, style: TextStyle(color: isSelected ? Colors.blue : (isDarkMode ? Colors.white60 : Colors.black54), fontSize: 12)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDarkMode;
  const _SectionTitle({required this.title, required this.isDarkMode});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(left: 8.0, bottom: 8.0, top: 8.0), child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white60 : Colors.black54)));
}
