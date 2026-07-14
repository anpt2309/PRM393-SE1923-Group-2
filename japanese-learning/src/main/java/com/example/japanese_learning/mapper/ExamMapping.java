package com.example.japanese_learning.mapper;

import com.example.japanese_learning.dto.response.ExamDetailResponse;
import com.example.japanese_learning.dto.response.ExamPartResponse;
import com.example.japanese_learning.dto.response.ExamResponse;
import com.example.japanese_learning.entity.exam.Exam;
import com.example.japanese_learning.features.exam.ExamProjection;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;
import org.mapstruct.NullValuePropertyMappingStrategy;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;

@Mapper(componentModel = "spring", nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
public interface ExamMapping {

    @Mapping(source = "difficulty", target = "difficulty", qualifiedByName = "definedDifficulty")
    @Mapping(source = "price", target = "price", qualifiedByName = "definedPrice")
    @Mapping(source = "userCount", target = "userCount", qualifiedByName = "definedUserCount")
    ExamResponse toExam(Exam exam);

    List<ExamResponse> toExamResponse(List<Exam> exam);

    @Mapping(source = "difficulty", target = "difficulty", qualifiedByName = "definedDifficulty")
    @Mapping(source = "userCount", target = "userCount", qualifiedByName = "definedUserCount")
    ExamDetailResponse toExamDetailResponse(ExamProjection projection);

    default ExamDetailResponse toCustomExamDetailResponse(List<ExamProjection> projections) {
        if (projections == null || projections.isEmpty()) {
            return null;
        }
        ExamDetailResponse examDetailMapping = toExamDetailResponse(projections.get(0));
        List<ExamPartResponse> partMapping = new ArrayList<>();
        for (ExamProjection p : projections) {
            ExamPartResponse response = ExamPartResponse.builder()
                    .partName(p.getPartName())
                    .partDuration(p.getPartDuration())
                    .build();
            partMapping.add(response);
        }
        examDetailMapping.setPart(partMapping);
        return examDetailMapping;
    }

    @Named("definedDifficulty")
    default String definedDifficult(Integer difficult) {
        if (difficult == null) {
            return "";
        }
        if (difficult == 1) {
            return "Dễ";
        } else if (difficult == 2) {
            return "Trung bình";
        } else {
            return "Khó";
        }
    }

    @Named("definedPrice")
    default String definedPrice(Double price) {
        String formatted = "";
        if (price == null) {
            return "";
        }
        if (price != 0) {
            DecimalFormat formatter = new DecimalFormat("#,###");
            formatted = formatter.format(price);
        } else {
            formatted = "miễn phí";
        }
        return formatted;
    }

    @Named("definedUserCount")
    default String definedUserCount(Long number) {
        if (number == null) {
            return null;
        }
        if (number < 1000) {
            return String.valueOf(number);
        }
        if (number < 1_000_000) {
            double value = number / 1000.0;
            if (value == (long) value) {
                return (long) value + "k";
            }
            return String.format("%.1fk", value);
        }
        return String.valueOf(number);
    }
}
