package com.example.japanese_learning.features.reward_exchange.services;

import com.example.japanese_learning.dto.request.RedeemRequests;
import com.example.japanese_learning.dto.response.RedeemHistoryResponse;
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
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RewardService {

    private final UserRewardRepository userRewardRepository;
    private final RewardRepository rewardRepository;
    private final RewardRedemptionRepository rewardRedemptionRepository;
    private final CoinTransactionRepository coinTransactionRepository;

    @Transactional
    public RedeemResponse redeemReward(String firebaseUid, RedeemRequests request) {

        // 1. Tìm kiếm User bằng Firebase UID
        User user = userRewardRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new RuntimeException("Người dùng không tồn tại với UID: " + firebaseUid));

        // 2. Kiểm tra phần thưởng tồn tại
        Reward reward = rewardRepository.findById(request.getRewardId())
                .orElseThrow(() -> new RuntimeException("Phần thưởng không tồn tại"));

        // 3. Kiểm tra số dư xu
        if (user.getCoin() < reward.getCost()) {
            throw new RuntimeException("Số dư xu của bạn không đủ để đổi phần thưởng này");
        }

        // 4. Khấu trừ xu và lưu User[cite: 23]
        int remainingCoin = user.getCoin() - reward.getCost();
        user.setCoin(remainingCoin);
        userRewardRepository.save(user);

        // 5. Ghi nhận nhật ký giao dịch xu[cite: 23]
        CoinTransaction transaction = new CoinTransaction();
        transaction.setUser(user);
        transaction.setAmount(reward.getCost());
        transaction.setType(TransactionType.DEDUCT);
        transaction.setReason("Đổi phần thưởng: " + reward.getName());
        coinTransactionRepository.save(transaction);

        // 6. Tạo mã Voucher ngẫu nhiên và lưu lịch sử đổi thưởng
        RewardRedemption redemption = new RewardRedemption();
        redemption.setUser(user);
        redemption.setReward(reward);
        redemption.setIsUsed(false);
        redemption.setRedeemedAt(LocalDateTime.now());
        String generatedCode = "V-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        redemption.setVoucherCode(generatedCode);

        RewardRedemption savedRedemption = rewardRedemptionRepository.save(redemption);

        // 7. Trả về phản hồi chi tiết[cite: 15, 23]
        return RedeemResponse.builder()
                .redemptionId(savedRedemption.getId())
                .rewardName(reward.getName())
                .spentCoin(reward.getCost())
                .remainingCoin(remainingCoin)
                .redeemedAt(LocalDateTime.now())
                .build();
    }

    public List<RewardResponse> getAllRewards() {
        return rewardRepository.findAll().stream()
                .map(reward -> RewardResponse.builder()
                        .id(reward.getId())
                        .name(reward.getName())
                        .cost(reward.getCost())
                        .discountAmount(reward.getDiscountAmount())
                        .description(reward.getDescription())
                        .build())
                .collect(Collectors.toList());
    }

    // lịch sử đổi quà
    public List<RedeemHistoryResponse> getRedeemHistory(String firebaseUid) {
        // 1. Tìm user theo Firebase UID
        User user = userRewardRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new RuntimeException("Người dùng không tồn tại với UID: " + firebaseUid));

        // 2. Lấy danh sách đổi thưởng đã lưu trong DB
        List<RewardRedemption> redemptions = rewardRedemptionRepository.findByUserOrderByIdDesc(user);

        // 3. Map sang danh sách DTO để trả về
        return redemptions.stream()
                .map(redemption -> RedeemHistoryResponse.builder()
                        .id(redemption.getId())
                        .rewardName(redemption.getReward().getName())
                        .cost(redemption.getReward().getCost())
                        .voucherCode(redemption.getVoucherCode())
                        .isUsed(redemption.getIsUsed())
                        .redeemedAt(redemption.getRedeemedAt()) // DB tự sinh qua trigger/default value
                        .build())
                .collect(Collectors.toList());
    }

    // Lấy thông tin chi tiết 1 phần thưởng theo ID
    public RewardResponse getRewardById(Long id) {
        Reward reward = rewardRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Phần thưởng không tồn tại với ID: " + id));

        return RewardResponse.builder()
                .id(reward.getId())
                .name(reward.getName())
                .cost(reward.getCost())
                .discountAmount(reward.getDiscountAmount())
                .description(reward.getDescription())
                .build();
    }
}