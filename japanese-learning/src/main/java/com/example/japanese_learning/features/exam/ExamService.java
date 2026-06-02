package com.example.japanese_learning.features.exam;

import com.example.japanese_learning.dto.response.ExamResponse;
import com.example.japanese_learning.entity.exam.Exam;
import com.example.japanese_learning.features.exam_attempt.ExamAttemptRepository;
import com.example.japanese_learning.mapper.ExamMapping;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ExamService {
    private final ExamRepository examRepository;
    private final ExamMapping mapping;

    public Page<ExamResponse> getExam(String title, Integer difficulty, Pageable pageable) {
        Page<Exam> getExamPage = examRepository.getExam(title, difficulty, pageable);

        List<ExamResponse> exam = new ArrayList<>();
        for (Exam e : getExamPage.getContent()){
            ExamResponse response = mapping.toExam(e);
            exam.add(response);
        }
        return new PageImpl<>(exam, getExamPage.getPageable(), getExamPage.getTotalPages());
    }

}
