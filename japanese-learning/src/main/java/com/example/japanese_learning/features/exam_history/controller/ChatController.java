package com.example.japanese_learning.features.exam_history.controller;
import com.example.japanese_learning.dto.request.ChatRequest;
import com.example.japanese_learning.dto.response.ApiResponse;
import com.example.japanese_learning.dto.response.CommentResponse;
import com.example.japanese_learning.dto.response.QuestionReportResponse;
import com.example.japanese_learning.features.exam_history.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ChatController {
    private final ChatService chatService;

    @PostMapping("/ai-model/chat/{ids}")
    public ApiResponse<String> aiChatModel(@PathVariable(name = "ids") Long userId
            ,@RequestBody ChatRequest request) {
        ApiResponse<String> response = ApiResponse.<String>builder()
                .id(1000)
                .data(chatService.callAPIModelAI(userId ,request))
                .build();
        return response;
    }

    @GetMapping("/user-comment/chat")
    public ApiResponse<List<CommentResponse>> commentChatModel() {
        ApiResponse<List<CommentResponse>> response = ApiResponse.<List<CommentResponse>>builder()
                .id(1000)
                .data(chatService.getUserComment())
                .build();
        return response;
    }

    @PostMapping("/user-comment/chat/{userId}")
    public ApiResponse<CommentResponse> createComment(
            @PathVariable(name = "userId") Long userId,
            @RequestBody ChatRequest request) {
        ApiResponse<CommentResponse> response = ApiResponse.<CommentResponse>builder()
                .id(1000)
                .data(chatService.createComment(userId, request))
                .build();
        return response;
    }

    @PostMapping("/user-comment/report/{userId}")
    public ApiResponse<QuestionReportResponse> createReportQuestion(
            @PathVariable(name = "userId") Long userId,
            @RequestBody ChatRequest request) {
        ApiResponse<QuestionReportResponse> response = ApiResponse.<QuestionReportResponse>builder()
                .id(1000)
                .data(chatService.createReportQuestion(userId, request))
                .build();
        return response;
    }
}
