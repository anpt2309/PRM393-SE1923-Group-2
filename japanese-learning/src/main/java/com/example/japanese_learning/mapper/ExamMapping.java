package com.example.japanese_learning.mapper;
import com.example.japanese_learning.dto.response.ExamResponse;
import com.example.japanese_learning.entity.exam.Exam;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;
import org.mapstruct.NullValuePropertyMappingStrategy;

import java.util.List;

@Mapper(componentModel = "spring", nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
public interface ExamMapping {
    @Mapping(source = "difficulty", target = "difficulty", qualifiedByName = "defined")
    ExamResponse toExam(Exam exam);

    List<ExamResponse> toExamResponse(List<Exam> exam);

    @Named("defined")
    default String definedDifficult(Integer difficult) {
        if (difficult == 1) {
            return "Dễ";
        } else if (difficult == 2) {
            return "Trung bình";
        } else {
            return "Khó";
        }
    }
}
