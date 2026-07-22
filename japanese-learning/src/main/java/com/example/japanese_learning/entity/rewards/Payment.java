package com.example.japanese_learning.entity.rewards;

import com.example.japanese_learning.enums.PaymentStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Table(name = "payments")
public class Payment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Đơn mua tương ứng
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "purchase_id", nullable = false)
    private Purchase purchase;

    // Mã thanh toán
    @Column(nullable = false, unique = true)
    private String paymentCode;

    // Số tiền cần thanh toán
    @Column(nullable = false)
    private Integer amount;

    // Link QR (VietQR)
    private String qrUrl;

    // Nội dung chuyển khoản
    private String qrContent;

    // Mã giao dịch từ ngân hàng
    private String transactionId;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", length = 50) // 🟢 Thêm dòng này vào
    private PaymentStatus status = PaymentStatus.PENDING;

    // Hết hạn QR
    private LocalDateTime expiredAt;

    // Thời điểm thanh toán thành công
    private LocalDateTime paidAt;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;
}