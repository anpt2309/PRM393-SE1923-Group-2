package com.example.japanese_learning.features.exam_attempt;

import com.example.japanese_learning.dto.request.AnswerRequest;
import com.example.japanese_learning.dto.request.ExamAttemptRequest;
import com.example.japanese_learning.dto.response.*;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ExamAttemptController {
    private final ExamAttemptService examAttemptService;

    @PostMapping("/exams/attempt")
    public ApiResponse<ExamAttemptResponse> startExam(@RequestBody ExamAttemptRequest requests) {
        ApiResponse<ExamAttemptResponse> apiResponse = ApiResponse.<ExamAttemptResponse>builder()
                .id(200)
                .message("Khởi tạo bài thi thành công")
                .data(examAttemptService.startExam(requests.getUserId(), requests.getExamId()))
                .build();
        return apiResponse;
    }

    @GetMapping("/exams/attempt/{ids}")
    public ApiResponse<List<ExamPartAttemptResponse>> getQuestion(@PathVariable(name = "ids") Long examId) {
        ApiResponse<List<ExamPartAttemptResponse>> apiResponse = ApiResponse.<List<ExamPartAttemptResponse>>builder()
                .id(200)
                .message("Danh sách câu hỏi")
                .data(examAttemptService.getQuestion(examId))
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

    @PostMapping("/exams/submit/{attemptId}")
    public ApiResponse<SubmitResponse> submitExam(@PathVariable(name = "attemptId") Long examAttemptId,
            @RequestBody List<AnswerRequest> requests) {

        ApiResponse<SubmitResponse> apiResponse = ApiResponse.<SubmitResponse>builder()
                .id(200)
                .message("Lưu bài thi thành công")
                .data(examAttemptService.submitExam(examAttemptId, requests))
                .build();
        return apiResponse;
    }
}
