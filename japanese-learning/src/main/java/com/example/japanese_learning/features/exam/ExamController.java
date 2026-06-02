package com.example.japanese_learning.features.exam;

import com.example.japanese_learning.dto.response.ApiResponse;
import com.example.japanese_learning.dto.response.ExamResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class ExamController {
    private final ExamService examService;

    @GetMapping("/exams")
    public ApiResponse<Page<ExamResponse>> getExam(@RequestParam(name = "title", required = false) String title,
                                             @RequestParam(name = "difficulty", required = false) Integer difficulty,
                                             @PageableDefault(sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        ApiResponse<Page<ExamResponse>> response = ApiResponse.<Page<ExamResponse>>builder()
                .id(200)
                .data(examService.getExam(title, difficulty, pageable))
                .build();
        return response;
    }
}
