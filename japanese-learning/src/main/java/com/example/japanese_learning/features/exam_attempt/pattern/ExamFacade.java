package com.example.japanese_learning.features.exam_attempt.pattern;

import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
public class ExamFacade {
    private Map<String, ExamStrategy> examInjection = new HashMap<>();

    public ExamFacade(List<ExamStrategy> examStrategy) {
        for (ExamStrategy str : examStrategy){
            examInjection.put(str.examType(), str);
        }
    }
    

}
