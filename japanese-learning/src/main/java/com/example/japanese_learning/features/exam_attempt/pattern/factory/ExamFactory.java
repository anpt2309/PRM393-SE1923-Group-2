package com.example.japanese_learning.features.exam_attempt.pattern.factory;

import com.example.japanese_learning.features.exam_attempt.pattern.strategy.ExamStrategy;
import org.springframework.stereotype.Component;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@Component
public class ExamFactory {
    private Map<String, ExamStrategy> examInjection = new HashMap<>();

    public ExamFactory(List<ExamStrategy> examStrategy) {
        for (ExamStrategy str : examStrategy){
            examInjection.put(str.examType(), str);
        }
    }

    public ExamStrategy getTypeExam(String examType){
        ExamStrategy strategy = examInjection.get(examType);
        if(Objects.isNull(strategy)){
            throw new RuntimeException("Khong tim thay bai thi tuong ung");
        }
        return strategy;
    }

}
