import 'package:flutter/material.dart';

class AppSettingProvider extends ChangeNotifier {
  // 1. Quản lý cỡ chữ toàn cục
  String _fontSizeLabel = 'Vừa';
  double _textScaleFactor = 1.0;

  // 2. QUẢN LÝ MÀU SẮC RIÊNG (Chỉ đổi màu button, nền card, không đổi theme hệ thống)
  bool _isCustomDarkColor = false;

  String get fontSizeLabel => _fontSizeLabel;
  double get textScaleFactor => _textScaleFactor;
  bool get isCustomDarkColor => _isCustomDarkColor;

  // Hàm thay đổi trạng thái màu sắc riêng biệt
  void toggleCustomColor(bool isDark) {
    _isCustomDarkColor = isDark;
    notifyListeners(); // Báo cho tất cả các màn hình cập nhật lại màu sắc
  }

  // Hàm thay đổi kích thước cỡ chữ
  void updateFontSize(String label) {
    _fontSizeLabel = label;
    switch (label) {
      case 'Nhỏ':
        _textScaleFactor = 0.85;
        break;
      case 'Lớn':
        _textScaleFactor = 1.25;
        break;
      case 'Vừa':
      default:
        _textScaleFactor = 1.0;
        break;
    }
    notifyListeners(); // Báo cho toàn app co giãn chữ ngay lập tức
  }
}