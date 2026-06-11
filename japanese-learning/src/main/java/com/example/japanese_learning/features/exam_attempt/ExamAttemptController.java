package com.example.japanese_learning.features.exam_attempt;

import com.example.japanese_learning.dto.request.AnswerRequest;
import com.example.japanese_learning.dto.request.ExamAttemptRequest;
import com.example.japanese_learning.dto.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class ExamAttemptController {
    private final ExamAttemptService examAttemptService;

    @PostMapping("/exams/attempt")
    public ApiResponse<Void> startExam(@RequestBody ExamAttemptRequest requests) {
        examAttemptService.startExam(requests.getUserId(), requests.getExamId());
        ApiResponse<Void> apiResponse = ApiResponse.<Void>builder()
                .id(200)
                .message("Khởi tạo bài thi thành công")
                .build();
        return apiResponse;
    }

    @PostMapping("/exams/auto-save/{ids}")
    public ApiResponse<Void> autoSaveAnswer(@PathVariable(name = "ids") Long examAttemptId,
                                            @RequestBody List<AnswerRequest> requests) {
        examAttemptService.autoSaveAnswer(examAttemptId, requests);
        ApiResponse<Void> apiResponse = ApiResponse.<Void>builder()
                .id(200)
                .message("Lưu đáp án User thành công")
                .build();
        return apiResponse;
    }
}
