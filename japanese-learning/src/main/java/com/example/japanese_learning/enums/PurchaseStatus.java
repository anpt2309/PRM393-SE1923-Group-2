package com.example.japanese_learning.enums;

public enum PurchaseStatus {
    PENDING,    // Đang chờ người dùng chuyển khoản / Đang chờ Admin duyệt
    APPROVED,   // Admin đã xác nhận thanh toán thành công -> User được làm đề
    REJECTED    // Admin từ chối duyệt (Vd: Chuyển khoản sai số tiền, sai nội dung...)
}
