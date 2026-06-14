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

import java.util.List;

@RestController
@RequiredArgsConstructor
public class ExamController {
    private final ExamService examService;

    @GetMapping("/exams")
    public ApiResponse<Page<ExamResponse>> getExam(@RequestParam(required = false) List<String> levelExam,
                                                   @RequestParam(required = false) List<Integer> difficultyExam,
                                                   @PageableDefault(sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable){

        ApiResponse<Page<ExamResponse>> apiResponse = ApiResponse.<Page<ExamResponse>>builder()
                .id(200)
                .data(examService.getExam(levelExam,difficultyExam,pageable))
                .build();
        return apiResponse;
    }
}
