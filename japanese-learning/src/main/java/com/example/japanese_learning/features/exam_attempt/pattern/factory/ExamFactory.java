package com.example.japanese_learning.features.exam_attempt.pattern.factory;

import com.example.japanese_learning.features.exam_attempt.pattern.strategy.ExamStrategy;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@Component

public class ExamFactory {
    private final Map<String, ExamStrategy> examInjection = new HashMap<>();

    public ExamFactory(List<ExamStrategy> exam) {
        for (ExamStrategy examStrategy : exam) {
            examInjection.put(examStrategy.examType(), examStrategy);
        }
    }


    public ExamStrategy getTypeOfExam(String examType) {
        ExamStrategy exam = examInjection.get(examType);
        if (Objects.isNull(exam)) {
            throw new RuntimeException("Không tìm thấy bài thi tương ứng");
        }
        return exam;
    }

}
