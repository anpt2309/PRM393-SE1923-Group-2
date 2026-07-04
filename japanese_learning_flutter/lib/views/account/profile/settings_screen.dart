import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_setting_provider.dart';
import '../../../widgets/app_bar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Trạng thái cục bộ (không nằm trong cấu hình giao diện)
  bool _autoTranslate = true;
  bool _autoPaste = true;
  bool _keepScreenAwake = false;
  String _selectedReadingSpeed = 'Bình thường';
  bool _autoRepeatAudio = false;

  // Trạng thái cho Thông báo
  bool _dailyReminder = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 19, minute: 0);

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingProvider);
    final isCustomDark = settings.isDarkMode;
    final currentFontSize = settings.fontSizeLabel;
    final double scale = settings.textScaleFactor;

    final backgroundColor =
        isCustomDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final cardColor = isCustomDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isCustomDark
        ? Colors.white.withOpacity(0.9)
        : Colors.black.withOpacity(0.8);
    final iconColor =
        isCustomDark ? Colors.white70 : Colors.black.withOpacity(0.7);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: const CustomAppBar(title: 'Cài đặt', centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SECTION HIỂN THỊ
            _SectionTitle(title: 'Hiển thị', isDarkMode: isCustomDark),
            _buildSettingsCard(cardColor, [
              _buildPillSelectionTile(
                Icons.text_fields,
                'Cỡ chữ',
                textColor,
                iconColor,
                ['Nhỏ', 'Vừa', 'Lớn'],
                currentFontSize,
                scale,
                isCustomDark,
                (val) => ref.read(appSettingProvider.notifier).updateFontSize(val),
              ),
              _buildSwitchTile(
                Icons.dark_mode_outlined,
                'Hiển thị chế độ màn hình tối',
                isCustomDark,
                iconColor,
                textColor,
                scale,
                (v) => ref.read(appSettingProvider.notifier).toggleDarkMode(v),
              ),
              _buildSwitchTile(
                Icons.copy_all,
                'Tự động dịch từ được copy',
                _autoTranslate,
                iconColor,
                textColor,
                scale,
                (v) => setState(() => _autoTranslate = v),
              ),
              _buildSwitchTile(
                Icons.paste_outlined,
                'Tự dán từ sao chép vào ô tìm kiếm',
                _autoPaste,
                iconColor,
                textColor,
                scale,
                (v) => setState(() => _autoPaste = v),
              ),
              _buildSwitchTile(
                Icons.wb_sunny_outlined,
                'Giữ màn hình luôn sáng',
                _keepScreenAwake,
                iconColor,
                textColor,
                scale,
                (v) => setState(() => _keepScreenAwake = v),
              ),
            ]),
            const SizedBox(height: 16),

            // 2. SECTION HỌC TẬP & ÂM THANH
            _SectionTitle(
                title: 'Cấu hình học tập & Âm thanh', isDarkMode: isCustomDark),
            _buildSettingsCard(cardColor, [
              _buildPillSelectionTile(
                Icons.speed,
                'Tốc độ đọc phát âm',
                textColor,
                iconColor,
                ['Chậm', 'Bình thường', 'Nhanh'],
                _selectedReadingSpeed,
                scale,
                isCustomDark,
                (val) => setState(() => _selectedReadingSpeed = val),
              ),
              _buildSwitchTile(
                Icons.replay_circle_filled_outlined,
                'Tự động lặp lại âm thanh',
                _autoRepeatAudio,
                iconColor,
                textColor,
                scale,
                (v) => setState(() => _autoRepeatAudio = v),
              ),
            ]),
            const SizedBox(height: 16),

            // 3. SECTION THÔNG BÁO
            _SectionTitle(
                title: 'Thông báo & Hoạt động', isDarkMode: isCustomDark),
            _buildSettingsCard(cardColor, [
              _buildSwitchTile(
                Icons.notifications_active_outlined,
                'Bật nhắc học (${_reminderTime.format(context)})',
                _dailyReminder,
                iconColor,
                textColor,
                scale,
                (v) => setState(() => _dailyReminder = v),
              ),
              if (_dailyReminder)
                _buildActionTile(
                  Icons.access_time,
                  'Thay đổi khung giờ nhắc',
                  iconColor,
                  textColor,
                  isCustomDark,
                  onTap: () async {
                    final picked = await showTimePicker(
                        context: context, initialTime: _reminderTime);
                    if (picked != null) setState(() => _reminderTime = picked);
                  },
                ),
              _buildActionTile(
                Icons.history,
                'Lịch sử hoạt động',
                iconColor,
                textColor,
                isCustomDark,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chuyển hướng đến lịch sử...')));
                },
              ),
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
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(children: children)),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value,
      Color iconColor, Color textColor, double scale, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      secondary: Icon(icon, color: iconColor, size: 22 * scale),
      title: Text(title, style: TextStyle(fontSize: 14.5, color: textColor)),
      value: value,
      activeColor: Colors.blue,
      onChanged: onChanged,
    );
  }

  Widget _buildActionTile(IconData icon, String title, Color iconColor,
      Color textColor, bool isDark,
      {required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(title, style: TextStyle(fontSize: 14.5, color: textColor)),
      trailing: Icon(Icons.arrow_forward_ios,
          size: 14, color: isDark ? Colors.white30 : Colors.black26),
      onTap: onTap,
    );
  }

  Widget _buildPillSelectionTile(
      IconData icon,
      String title,
      Color textColor,
      Color iconColor,
      List<String> options,
      String selectedValue,
      double scale,
      bool isCustomDark,
      ValueChanged<String> onSelected) {
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
                color: isSelected ? Colors.blue.withOpacity(0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                    color: isSelected
                        ? Colors.blue.withOpacity(0.3)
                        : (isCustomDark ? Colors.white12 : Colors.grey.shade200)),
              ),
              child: Text(option,
                  style: TextStyle(
                      color: isSelected
                          ? Colors.blue
                          : (isCustomDark ? Colors.white60 : Colors.black54),
                      fontSize: 12)),
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
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0, top: 8.0),
      child: Text(title,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white60 : Colors.black54)));
}