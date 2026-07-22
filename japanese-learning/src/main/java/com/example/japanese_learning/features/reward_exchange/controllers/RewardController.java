package com.example.japanese_learning.features.reward_exchange.controllers;

import com.example.japanese_learning.dto.request.RedeemRequests;
import com.example.japanese_learning.dto.response.ApiResponse;
import com.example.japanese_learning.dto.response.RedeemHistoryResponse;
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
            @RequestParam String firebaseUid,
            @RequestBody RedeemRequests request) {
        RedeemResponse response = rewardService.redeemReward(firebaseUid, request);

        // Đóng gói theo chuẩn cấu trúc ApiResponse
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

    // Thêm endpoint này vào file RewardController.java

    @GetMapping("/history/{firebaseUid}")
    public ResponseEntity<ApiResponse<List<RedeemHistoryResponse>>> getRedeemHistory(@PathVariable String firebaseUid) {
        List<RedeemHistoryResponse> history = rewardService.getRedeemHistory(firebaseUid);

        ApiResponse<List<RedeemHistoryResponse>> apiResponse = ApiResponse.<List<RedeemHistoryResponse>>builder()
                .id(200)
                .message("Lấy lịch sử đổi thưởng thành công!")
                .data(history)
                .build();

        return ResponseEntity.ok(apiResponse);
    }

    // API lấy thông tin chi tiết 1 reward theo ID
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<RewardResponse>> getRewardById(@PathVariable Long id) {
        RewardResponse reward = rewardService.getRewardById(id);

        ApiResponse<RewardResponse> apiResponse = ApiResponse.<RewardResponse>builder()
                .id(200)
                .message("Lấy thông tin phần thưởng thành công!")
                .data(reward)
                .build();

        return ResponseEntity.ok(apiResponse);
    }
}