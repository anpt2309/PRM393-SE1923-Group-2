package com.example.japanese_learning.features.exam;

import com.example.japanese_learning.dto.response.*;
import com.example.japanese_learning.entity.exam.Exam;
import com.example.japanese_learning.mapper.ExamMapping;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class ExamService {
    private final ExamRepository examRepository;
    private final ExamMapping mapping;

    public Page<ExamResponse> getExam(List<String> levelExam, List<Integer> difficultyExam,
                                      Double priceFrom, Double priceTo, Pageable pageable) {
        if (levelExam != null && levelExam.isEmpty()) {
            levelExam = null;
        }
        if (difficultyExam != null && difficultyExam.isEmpty()) {
            difficultyExam = null;
        }
        Page<Exam> exam = examRepository.getExam(levelExam, difficultyExam, priceFrom, priceTo, pageable);
        List<ExamResponse> toExamResponse = mapping.toExamResponse(exam.getContent());
        return new PageImpl<>(toExamResponse, exam.getPageable(), exam.getTotalElements());
    }

    public ExamDetailResponse getExamDetail(Long examId) {
        List<ExamProjection> getExamDetail = examRepository.getExamDetail(examId);
        if (getExamDetail.isEmpty()) {
            throw new RuntimeException("Bài thi không tồn tại");
        }

        ExamDetailResponse response = mapping.toCustomExamDetailResponse(getExamDetail);
        return response;
    }
}
