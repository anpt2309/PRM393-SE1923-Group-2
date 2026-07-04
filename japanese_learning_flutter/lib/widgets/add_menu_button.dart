import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GlobalAddMenuButton extends StatelessWidget {
  final Color cardColor;
  final Color textColor;
  final Color subTextColor;
  final Icon icon;
  final Function(String) onAction; // Callback để xử lý logic bên ngoài

  const GlobalAddMenuButton({
    super.key,
    required this.cardColor,
    required this.textColor,
    required this.subTextColor,
    required this.icon,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(color: cardColor),
      ),
      child: PopupMenuButton<String>(
        icon: icon,
        offset: const Offset(0, 50),
        onSelected: (value) {
          if (value == 'home') {
            // Dùng go_router: .go() thay thế và xóa sạch stack cũ
            context.go('/');
          } else {
            // Các chức năng còn lại (Tra cứu, Cài đặt) truyền ra ngoài
            onAction(value);
          }
        },
        itemBuilder: (context) => [
          _buildMenuItem('home', 'Trang chính', Icons.home_outlined),
          _buildMenuItem('settings', 'Cài đặt', Icons.settings_outlined),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, String text, IconData icon) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: subTextColor),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: textColor)),
        ],
      ),
    );
  }
}