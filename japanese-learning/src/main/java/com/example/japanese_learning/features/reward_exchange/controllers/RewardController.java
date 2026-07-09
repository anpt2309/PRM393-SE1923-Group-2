package com.example.japanese_learning.features.reward_exchange.controllers;

import com.example.japanese_learning.dto.request.RedeemRequest;
import com.example.japanese_learning.dto.response.ApiResponse;
import com.example.japanese_learning.dto.response.RedeemResponse;
import com.example.japanese_learning.features.reward_exchange.services.RewardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/rewards")
@RequiredArgsConstructor
public class RewardController {

    private final RewardService rewardService;

    // API đổi thưởng bằng xu
    @PostMapping("/redeem")
    public ResponseEntity<ApiResponse<RedeemResponse>> redeem(
            @RequestParam Long userId, // Thực tế có thể lấy thông qua SecurityContext/JWT Token của user đăng nhập
            @RequestBody RedeemRequest request) {

        RedeemResponse response = rewardService.redeemReward(userId, request);

        // Đóng gói theo chuẩn cấu trúc ApiResponse hiện tại của bạn
        ApiResponse<RedeemResponse> apiResponse = ApiResponse.<RedeemResponse>builder()
                .id(200) // Mã code thành công (hoặc HTTP Status)
                .message("Đổi phần thưởng thành công!")
                .data(response) // Sử dụng trường .data chính xác theo class của bạn
                .build();

        return ResponseEntity.ok(apiResponse);
    }
}
