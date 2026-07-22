package com.example.japanese_learning.entity.rewards;

import com.example.japanese_learning.entity.account.User;
import com.example.japanese_learning.entity.exam.Exam;
import com.example.japanese_learning.enums.PurchaseStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Table(name = "purchases")
public class Purchase {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Người mua
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // Đề thi được mua
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "exam_id", nullable = false)
    private Exam exam;

    // Trạng thái đơn mua
    @Enumerated(EnumType.STRING)
    private PurchaseStatus status = PurchaseStatus.PENDING;

    // Giá gốc
    @Column(nullable = false)
    private Integer originalPrice = 0;

    // Tiền được giảm
    @Column(nullable = false)
    private Integer discountAmount = 0;

    // Giá cuối cùng
    @Column(nullable = false)
    private Integer finalPrice = 0;

    // Voucher đã sử dụng
    @OneToOne(mappedBy = "purchase", cascade = CascadeType.ALL)
    private RewardRedemption appliedRedemption;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (this.createdAt == null) {
            this.createdAt = LocalDateTime.now();
        }
    }
}