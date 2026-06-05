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

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id")
    private Exam examID; // Ánh xạ tới bảng Exams dựa trên id

    @Column(name = "purchased_at", insertable = false, updatable = false)
    private LocalDateTime purchasedAt;

    @Enumerated(EnumType.STRING)
    private PurchaseStatus status = PurchaseStatus.PENDING; // PENDING, APPROVED, REJECTED

    private Integer originalPrice = 0; // Giá gốc của đề thi
    private Integer discountAmount = 0; // Số tiền được giảm từ voucher
    private Integer finalPrice = 0; // Số tiền cuối cùng hiển thị trên QR code để user trả

    // Nếu muốn tracking trực tiếp voucher nào đã áp dụng vào đây
    @OneToOne(mappedBy = "purchase", cascade = CascadeType.ALL)
    private RewardRedemption appliedRedemption;
}