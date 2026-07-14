package com.example.japanese_learning.dto.response;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class RewardResponse {
    private Long id;
    private String name;
    private Integer cost;
    private Integer discountAmount;
    private String description;
}
