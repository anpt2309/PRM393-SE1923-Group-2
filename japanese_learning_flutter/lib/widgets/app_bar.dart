import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_setting_provider.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onBackPressed;

  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.actions,
    this.bottom,
    this.onBackPressed,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingProvider);
    final isCustomDark = settings.isDarkMode;
    final double scale = settings.textScaleFactor;

    // 🌟 BẢNG MÀU ĐƯỢC TINH CHỈNH THEO CẤU HÌNH GIAO DIỆN
    final Color zaloBlue = Colors.blue; // Màu xanh Blue thương hiệu
    final Color darkHeader = const Color(0xFF1A1A1A); // Màu nền AppBar khi bật chế độ tối

    // Tự động tính toán màu nền dựa trên trạng thái hệ thống cục bộ
    final computedBgColor = isCustomDark ? darkHeader : zaloBlue;

    // 🌟 ĐỒNG BỘ: Đi với nền xanh/tối thì chữ và icon BẮT BUỘC phải là màu TRẮNG để bảo vệ mắt
    final computedTextColor = Colors.white;
    final computedIconColor = isCustomDark ? Colors.white70 : Colors.white;

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? computedTextColor,
          fontWeight: FontWeight.bold,
          fontSize: 18, // Cỡ chữ gốc (đã được bọc MediaQuery co giãn tự động ở main)
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? computedBgColor,
      elevation: elevation ?? 0, // Phẳng hoàn toàn, không đổ bóng

      // Nút back quay lại tự động scale theo cỡ chữ cấu hình toàn cục
      leading: IconButton(
        icon: Icon(Icons.arrow_back, size: 22 * scale),
        color: iconColor ?? computedIconColor,
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      ),
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        56.0 + (bottom?.preferredSize.height ?? 0.0),
      );
}