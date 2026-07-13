package com.example.japanese_learning.dto.response;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDate;

@Getter
@Setter
@Builder
public class DailyCheckinResponse {
    private Integer streakDays;
    private LocalDate lastLogin;
    private Integer currentCoin;
    private boolean isNewCheckinToday;
}
