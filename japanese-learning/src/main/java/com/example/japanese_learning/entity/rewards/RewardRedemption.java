package com.example.japanese_learning.entity.rewards;
import com.example.japanese_learning.entity.account.User;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Table(name = "reward_redemptions")
public class RewardRedemption {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reward_id")
    private Reward reward;

    @Column(name = "redeemed_at")
    private LocalDateTime redeemedAt;

    @Column(name = "voucher_code")
    private String voucherCode;

    private Boolean isUsed = false; // Để đánh dấu voucher này đã mang đi giảm giá chưa

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "purchase_id")
    private Purchase purchase; // Cực kỳ quan trọng để biết voucher này áp dụng cho đơn mua nào
}