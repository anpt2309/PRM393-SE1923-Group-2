package com.example.japanese_learning.features.exam;

import com.example.japanese_learning.dto.response.ExamResponse;
import com.example.japanese_learning.entity.exam.Exam;
import com.example.japanese_learning.mapper.ExamMapping;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ExamService {
    private final ExamRepository examRepository;
    private final ExamMapping mapping;

    public Page<ExamResponse> getExam(List<String> levelExam, List<Integer> difficultyExam,
                                      Double priceFrom, Double priceTo ,Pageable pageable) {
        if (levelExam != null && levelExam.isEmpty()) {
            levelExam = null;
        }
        if (difficultyExam != null && difficultyExam.isEmpty()) {
            difficultyExam = null;
        }
        Page<Exam> exam = examRepository.getExam(levelExam, difficultyExam,priceFrom,priceTo,  pageable);
        List<ExamResponse> toExamResponse = mapping.toExamResponse(exam.getContent());
        return new PageImpl<>(toExamResponse, exam.getPageable(), exam.getTotalElements());
    }

}
