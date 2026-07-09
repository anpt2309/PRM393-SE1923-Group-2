package com.example.japanese_learning.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NewsCategoryResponse {
    private Long id;
    private String categoryName;
    private String categorySlug;
}
