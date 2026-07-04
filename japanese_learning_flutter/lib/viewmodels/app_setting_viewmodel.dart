import 'package:flutter/material.dart';

/// ViewModel quản lý cấu hình giao diện toàn cục:
/// - Chế độ màu tối/sáng tùy chỉnh
/// - Kích thước cỡ chữ
class AppSettingViewModel extends ChangeNotifier {
  // 1. Quản lý cỡ chữ toàn cục
  String _fontSizeLabel = 'Vừa';
  double _textScaleFactor = 1.0;

  // 2. Quản lý màu sắc riêng (chỉ đổi màu button, nền card, không đổi theme hệ thống)
  bool _isCustomDarkColor = false;

  String get fontSizeLabel => _fontSizeLabel;
  double get textScaleFactor => _textScaleFactor;
  bool get isCustomDarkColor => _isCustomDarkColor;

  /// Bật/tắt chế độ màu tối
  void toggleCustomColor(bool isDark) {
    _isCustomDarkColor = isDark;
    notifyListeners();
  }

  /// Thay đổi kích thước cỡ chữ
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
    notifyListeners();
  }
}
