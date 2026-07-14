package com.example.japanese_learning.features.reward_exchange.controllers;

import com.example.japanese_learning.dto.request.RedeemRequest;
import com.example.japanese_learning.dto.response.ApiResponse;
import com.example.japanese_learning.dto.response.RedeemResponse;
import com.example.japanese_learning.dto.response.RewardResponse;
import com.example.japanese_learning.features.reward_exchange.services.RewardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/rewards")
@RequiredArgsConstructor
public class RewardController {

    private final RewardService rewardService;

    // API đổi thưởng bằng xu
    @PostMapping("/redeem")
    public ResponseEntity<ApiResponse<RedeemResponse>> redeem(
            // ─── THAY ĐỔI Ở ĐÂY ─────────────────────────────────────────
            // Đổi từ `@RequestParam Long userId` sang `@RequestParam String firebaseUid` để nhận UID dạng chuỗi từ Flutter gửi lên
            @RequestParam String firebaseUid,
            // ─────────────────────────────────────────────────────────────
            @RequestBody RedeemRequest request) {

        // ─── THAY ĐỔI Ở ĐÂY ─────────────────────────────────────────
        // Truyền tham số firebaseUid vào hàm xử lý của service thay vì userId cũ
        RedeemResponse response = rewardService.redeemReward(firebaseUid, request);
        // ─────────────────────────────────────────────────────────────

        // Đóng gói theo chuẩn cấu trúc ApiResponse hiện tại của bạn
        ApiResponse<RedeemResponse> apiResponse = ApiResponse.<RedeemResponse>builder()
                .id(200) // Mã code thành công (hoặc HTTP Status)
                .message("Đổi phần thưởng thành công!")
                .data(response) // Sử dụng trường .data chính xác theo class của bạn
                .build();

        return ResponseEntity.ok(apiResponse);
    }


    // API lấy danh sách reward
    @GetMapping
    public ResponseEntity<ApiResponse<List<RewardResponse>>> getAllRewards() {
        List<RewardResponse> rewards = rewardService.getAllRewards();

        ApiResponse<List<RewardResponse>> apiResponse = ApiResponse.<List<RewardResponse>>builder()
                .id(200)
                .message("Lấy danh sách phần thưởng thành công!")
                .data(rewards)
                .build();

        return ResponseEntity.ok(apiResponse);
    }
}