package com.example.japanese_learning.features.daily_checkin.controllers;

import com.example.japanese_learning.dto.response.DailyCheckinResponse;
import com.example.japanese_learning.features.daily_checkin.services.DailyCheckinService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/v1/daily-checkin")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class DailyCheckinController {

    private final DailyCheckinService dailyCheckinService;

    @PostMapping("/{firebaseUid}")
    public ResponseEntity<DailyCheckinResponse> checkin(@PathVariable String firebaseUid) {
        DailyCheckinResponse response = dailyCheckinService.processDailyCheckin(firebaseUid);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{firebaseUid}/history")
    public ResponseEntity<List<LocalDate>> getCheckinHistory(@PathVariable String firebaseUid) {
        List<LocalDate> history = dailyCheckinService.getCheckinHistory(firebaseUid);
        return ResponseEntity.ok(history);
    }
}