package com.example.japanese_learning.dto.response;

import com.example.japanese_learning.enums.GroupType;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SampleSentenceGroupResponse {
    private String id;
    private GroupType type;
    private String name;
    private String jlptLevel;
}
