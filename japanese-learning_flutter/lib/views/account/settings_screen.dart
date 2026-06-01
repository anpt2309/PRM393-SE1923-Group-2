import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;          // Ánh xạ từ cột: is_dark_mode
  String _selectedFontSize = 'Vừa'; // Ánh xạ từ ENUM: 'SMALL' (Nhỏ), 'MEDIUM' (Vừa), 'LARGE' (Lớn)
  bool _autoTranslate = true;        // Ánh xạ từ cột: auto_translate_copied
  bool _autoPaste = true;            // Ánh xạ từ cột: auto_paste_search
  bool _keepScreenAwake = false;     // Ánh xạ từ cột: keep_screen_on

  String _selectedReadingSpeed = 'Bình thường'; // Ánh xạ từ ENUM: 'SLOW' (Chậm), 'NORMAL' (Bình thường), 'FAST' (Nhanh)
  bool _autoRepeatAudio = false;                // Ánh xạ từ cột: auto_repeat_audio

  bool _dailyReminder = true;        // Ánh xạ từ cột: enable_daily_reminder
  TimeOfDay _reminderTime = const TimeOfDay(hour: 19, minute: 0);

  @override
  Widget build(BuildContext context) {
    // =========================================================================
    // 🔴 NOTE THỜI TIẾT: TỰ ĐỘNG ĐỔI BẢNG MÀU DỰA VÀO BIẾN TRẠNG THÁI _isDarkMode
    // =========================================================================
    final backgroundColor = _isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final cardColor = _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = _isDarkMode ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.8);
    final subTextColor = _isDarkMode ? Colors.white60 : Colors.black54;
    final iconColor = _isDarkMode ? Colors.white70 : Colors.black.withValues(alpha: 0.7);
    final appBarColor = _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Cài đặt', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: appBarColor,
        elevation: _isDarkMode ? 0 : 0.5,
        leading: BackButton(color: _isDarkMode ? Colors.white70 : Colors.black54),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= SECTION: HIỂN THỊ =================
            _SectionTitle(title: 'Hiển thị', isDarkMode: _isDarkMode),
            Card(
              color: cardColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.text_fields, color: iconColor),
                      title: Text('Cỡ chữ', style: TextStyle(color: textColor, fontSize: 14.5)),
                      trailing: ToggleButtons(
                        borderRadius: BorderRadius.circular(8),
                        selectedColor: Colors.white,
                        fillColor: Colors.blue,
                        // 🔴 SỬA LỖI ĐỎ: Thay 'unselectedColor' bằng 'color' đúng chuẩn Flutter
                        color: subTextColor,
                        disabledColor: Colors.grey,
                        constraints: const BoxConstraints(minHeight: 32, minWidth: 55),
                        isSelected: [_selectedFontSize == 'Nhỏ', _selectedFontSize == 'Vừa', _selectedFontSize == 'Lớn'],
                        onPressed: (index) {
                          setState(() {
                            if (index == 0) _selectedFontSize = 'Nhỏ';
                            if (index == 1) _selectedFontSize = 'Vừa';
                            if (index == 2) _selectedFontSize = 'Lớn';
                          });
                        },
                        children: const [Text('Nhỏ'), Text('Vừa'), Text('Lớn')],
                      ),
                    ),
                    _buildSwitchTile(Icons.dark_mode_outlined, 'Hiển thị chế độ màn hình tối', _isDarkMode, iconColor, textColor, (v) => setState(() => _isDarkMode = v)),
                    _buildSwitchTile(Icons.copy_all, 'Tự động dịch từ được copy', _autoTranslate, iconColor, textColor, (v) => setState(() => _autoTranslate = v)),
                    _buildSwitchTile(Icons.paste_outlined, 'Tự dán từ sao chép vào ô tìm kiếm', _autoPaste, iconColor, textColor, (v) => setState(() => _autoPaste = v)),
                    _buildSwitchTile(Icons.wb_sunny_outlined, 'Giữ màn hình luôn sáng', _keepScreenAwake, iconColor, textColor, (v) => setState(() => _keepScreenAwake = v)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ================= SECTION: CẤU HÌNH HỌC TẬP =================
            _SectionTitle(title: 'Cấu hình học tập & Âm thanh', isDarkMode: _isDarkMode),
            Card(
              color: cardColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.speed, color: iconColor),
                      title: Text('Tốc độ đọc phát âm', style: TextStyle(color: textColor, fontSize: 14.5)),
                      trailing: ToggleButtons(
                        borderRadius: BorderRadius.circular(8),
                        selectedColor: Colors.white,
                        fillColor: Colors.blue,
                        // 🔴 SỬA LỖI ĐỎ: Thay 'unselectedColor' bằng 'color' đúng chuẩn Flutter
                        color: subTextColor,
                        constraints: const BoxConstraints(minHeight: 32, minWidth: 55),
                        isSelected: [_selectedReadingSpeed == 'Chậm', _selectedReadingSpeed == 'Bình thường', _selectedReadingSpeed == 'Nhanh'],
                        onPressed: (index) {
                          setState(() {
                            if (index == 0) _selectedReadingSpeed = 'Chậm';
                            if (index == 1) _selectedReadingSpeed = 'Bình thường';
                            if (index == 2) _selectedReadingSpeed = 'Nhanh';
                          });
                        },
                        children: const [Text('Chậm'), Text('Vừa'), Text('Nhanh')],
                      ),
                    ),
                    _buildSwitchTile(Icons.replay_circle_filled_outlined, 'Tự động lặp lại âm thanh bài học', _autoRepeatAudio, iconColor, textColor, (v) => setState(() => _autoRepeatAudio = v)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ================= SECTION: THÔNG BÁO =================
            _SectionTitle(title: 'Thông báo & Lịch sử hoạt động', isDarkMode: _isDarkMode),
            Card(
              color: cardColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildSwitchTile(Icons.notifications_active_outlined, 'Bật nhắc học hàng ngày (${_reminderTime.format(context)})', _dailyReminder, iconColor, textColor, (v) => setState(() => _dailyReminder = v)),

                  if (_dailyReminder)
                    ListTile(
                      leading: Icon(Icons.access_time, color: iconColor, size: 22),
                      title: Text('Thay đổi khung giờ nhắc nhở học', style: TextStyle(fontSize: 14.5, color: textColor)),
                      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: _isDarkMode ? Colors.white30 : Colors.black26),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: _reminderTime,
                        );
                        if (picked != null) {
                          setState(() => _reminderTime = picked);
                        }
                      },
                    ),

                  _buildActionTile(
                      Icons.app_registration,
                      'Thông báo ứng dụng (Lịch sử hoạt động, bài thi...)',
                      iconColor,
                      textColor,
                      _isDarkMode ? Colors.white30 : Colors.black26,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Chuyển hướng đến màn hình danh sách Thông báo/Lịch sử từ DB Eclipse'))
                        );
                      }
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value, Color iconColor, Color textColor, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      secondary: Icon(icon, color: iconColor, size: 22),
      title: Text(title, style: TextStyle(fontSize: 14.5, color: textColor)),
      value: value,
      activeThumbColor: Colors.blue,
      onChanged: onChanged,
    );
  }

  Widget _buildActionTile(IconData icon, String title, Color iconColor, Color textColor, Color arrowColor, {required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(title, style: TextStyle(fontSize: 14.5, color: textColor)),
      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: arrowColor),
      onTap: onTap,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDarkMode;
  const _SectionTitle({required this.title, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white60 : Colors.black54
        ),
      ),
    );
  }
}