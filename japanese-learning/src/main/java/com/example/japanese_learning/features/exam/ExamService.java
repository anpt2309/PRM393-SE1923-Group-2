package com.example.japanese_learning.features.exam;

import com.example.japanese_learning.dto.response.ExamResponse;
import com.example.japanese_learning.entity.exam.Exam;
import com.example.japanese_learning.mapper.ExamMapping;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ExamService {
    private final ExamRepository examRepository;
    private final ExamMapping mapping;

    public Page<ExamResponse> getExam(String levelExam, String difficultyExam, Pageable pageable) {
        List<String> level = null;
        List<Long> difficulty = null;
        if (levelExam != null && !levelExam.isBlank()) {
            level = Arrays.stream(levelExam.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .toList();
        }
        if (difficultyExam != null && !difficultyExam.isBlank()) {
            difficulty = Arrays.stream(difficultyExam.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .map(Long::parseLong)
                    .toList();
        }
        Page<Exam> getExamPage = examRepository.getExam(level, difficulty, pageable);
        List<ExamResponse> exam = mapping.toExamResponse(getExamPage.getContent());
        return new PageImpl<>(exam, getExamPage.getPageable(), getExamPage.getTotalPages());
    }

}
