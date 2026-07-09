package com.example.japanese_learning.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SentencePartResponse {
    private String id;
    private String groupId;
    private String title;
    private String description;
    private String icon;
}
