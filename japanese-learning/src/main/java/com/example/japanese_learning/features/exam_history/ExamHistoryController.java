package com.example.japanese_learning.features.exam_history;

import com.example.japanese_learning.dto.response.ApiResponse;
import com.example.japanese_learning.dto.response.ExamHistoryDetailResponse;
import com.example.japanese_learning.dto.response.ExamHistoryResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ExamHistoryController {
    private final ExamHistoryService examHistoryService;

    @GetMapping("/exams/history/{ids}")
    public ApiResponse<List<ExamHistoryResponse>> getExamHistory(@PathVariable(name = "ids") Long userId) {
        ApiResponse<List<ExamHistoryResponse>> response = ApiResponse.<List<ExamHistoryResponse>>builder()
                .id(200)
                .message("Danh sách bài kiểm tra đã làm")
                .data(examHistoryService.getExamHistory(userId))
                .build();
        return response;
    }

    @GetMapping("/exams/history/detail/{ids}")
    public ApiResponse<ExamHistoryDetailResponse> getExamHistoryDetail(@PathVariable(name = "ids") Long examAttemptId) {
        ApiResponse<ExamHistoryDetailResponse> response = ApiResponse.<ExamHistoryDetailResponse>builder()
                .id(200)
                .message("Chi tiết bài kiểm tra đã làm")
                // BUG: NonUniqueResultException: Query did not return a unique result: 3 results were returned
                // Query: list ; mapping Object
                 .data(examHistoryService.getExamHistoryDetail(examAttemptId))
                .build();
        return response;
    }
}
