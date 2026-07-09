package com.example.japanese_learning.features.sample_sentences.controller;

import com.example.japanese_learning.dto.response.ApiResponse;
import com.example.japanese_learning.dto.response.SampleSentenceGroupResponse;
import com.example.japanese_learning.dto.response.SentenceItemResponse;
import com.example.japanese_learning.dto.response.SentencePartResponse;
import com.example.japanese_learning.features.sample_sentences.service.SampleSentenceService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/sample-sentences")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class SampleSentenceController {

    private final SampleSentenceService sampleSentenceService;

    @GetMapping("/groups")
    public ApiResponse<List<SampleSentenceGroupResponse>> getGroups(@RequestParam String type) {
        List<SampleSentenceGroupResponse> data = sampleSentenceService.getGroups(type);
        return ApiResponse.<List<SampleSentenceGroupResponse>>builder()
                .id(200)
                .data(data)
                .build();
    }

    @GetMapping("/parts")
    public ApiResponse<List<SentencePartResponse>> getParts(@RequestParam Long groupId) {
        List<SentencePartResponse> data = sampleSentenceService.getParts(groupId);
        return ApiResponse.<List<SentencePartResponse>>builder()
                .id(200)
                .data(data)
                .build();
    }

    @GetMapping("/sentences")
    public ApiResponse<List<SentenceItemResponse>> getSentences(@RequestParam Long partId) {
        List<SentenceItemResponse> data = sampleSentenceService.getSentences(partId);
        return ApiResponse.<List<SentenceItemResponse>>builder()
                .id(200)
                .data(data)
                .build();
    }
}
