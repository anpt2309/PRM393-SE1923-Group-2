package com.example.japanese_learning.dto.response;

import com.example.japanese_learning.enums.JlptLevel;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GrammarLessonResponse {
    private Long id;
    private String structure;
    private String meaning;
    private String explanation;
    private String example;
    private JlptLevel jlptLevel;
    private String formulaJson;
    private String exampleAnatomyJson;
    private Double formalityNuance;
}
