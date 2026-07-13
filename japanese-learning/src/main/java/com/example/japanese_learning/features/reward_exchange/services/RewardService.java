package com.example.japanese_learning.features.reward_exchange.services;

import com.example.japanese_learning.dto.request.RedeemRequest;
import com.example.japanese_learning.dto.response.RedeemResponse;
import com.example.japanese_learning.dto.response.RewardResponse;
import com.example.japanese_learning.entity.account.User;
import com.example.japanese_learning.entity.rewards.CoinTransaction;
import com.example.japanese_learning.entity.rewards.Reward;
import com.example.japanese_learning.entity.rewards.RewardRedemption;
import com.example.japanese_learning.enums.TransactionType;
import com.example.japanese_learning.features.reward_exchange.repositories.CoinTransactionRepository;
import com.example.japanese_learning.features.reward_exchange.repositories.RewardRedemptionRepository;
import com.example.japanese_learning.features.reward_exchange.repositories.RewardRepository;
import com.example.japanese_learning.features.reward_exchange.repositories.UserRewardRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RewardService {

    private final UserRewardRepository userRewardRepository;
    private final RewardRepository rewardRepository;
    private final RewardRedemptionRepository rewardRedemptionRepository;
    private final CoinTransactionRepository coinTransactionRepository;

    @Transactional
    // ─── THAY ĐỔI Ở ĐÂY ─────────────────────────────────────────
    // Đổi kiểu tham số đầu vào từ Long userId thành String firebaseUid để khớp với Firebase
    public RedeemResponse redeemReward(String firebaseUid, RedeemRequest request) {

        // 1. Kiểm tra User tồn tại hay không thông qua Firebase UID thay vì ID tự tăng
        User user = userRewardRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new RuntimeException("Người dùng không tồn tại với UID: " + firebaseUid));
        // ─────────────────────────────────────────────────────────────

        // 2. Kiểm tra phần thưởng (Reward) tồn tại hay không
        Reward reward = rewardRepository.findById(request.getRewardId())
                .orElseThrow(() -> new RuntimeException("Phần thưởng không tồn tại"));

        // 3. Kiểm tra ví xu của User có đủ để trả giá (cost) của phần thưởng không
        if (user.getCoin() < reward.getCost()) {
            throw new RuntimeException("Số dư xu của bạn không đủ để đổi phần thưởng này");
        }

        // 4. Khấu trừ xu của User
        int remainingCoin = user.getCoin() - reward.getCost();
        user.setCoin(remainingCoin);
        userRewardRepository.save(user);

        // 5. Ghi nhận nhật ký dòng tiền (CoinTransaction)
        CoinTransaction transaction = new CoinTransaction();
        transaction.setUser(user);
        transaction.setAmount(reward.getCost());
        // Giả sử Enum TransactionType của bạn có giá trị DEDUCT hoặc OUT cho giao dịch trừ tiền
        transaction.setType(TransactionType.DEDUCT);
        transaction.setReason("Đổi phần thưởng: " + reward.getName());
        coinTransactionRepository.save(transaction);

        // 6. Cấp phát Voucher / Tạo bản ghi đổi thưởng (RewardRedemption)
        RewardRedemption redemption = new RewardRedemption();
        redemption.setUser(user);
        redemption.setReward(reward);
        redemption.setIsUsed(false); // Mặc định là mới đổi, chưa mang đi thanh toán mua đề
        redemption.setPurchase(null); // Chưa liên kết tới đơn mua nào cả
        RewardRedemption savedRedemption = rewardRedemptionRepository.save(redemption);

        // 7. Trả kết quả thành công về cho Controller
        return RedeemResponse.builder()
                .redemptionId(savedRedemption.getId())
                .rewardName(reward.getName())
                .spentCoin(reward.getCost())
                .remainingCoin(remainingCoin)
                .redeemedAt(LocalDateTime.now()) // Thời điểm xử lý thành công
                .build();
    }

    // List rewards
    public List<RewardResponse> getAllRewards() {
        List<Reward> rewards = rewardRepository.findAll();

        // Map từ Entity sang DTO rút gọn
        return rewards.stream()
                .map(reward -> RewardResponse.builder()
                        .id(reward.getId())
                        .name(reward.getName())
                        .cost(reward.getCost())
                        .discountAmount(reward.getDiscountAmount())
                        .description(reward.getDescription())
                        .build())
                .collect(Collectors.toList());
    }
}