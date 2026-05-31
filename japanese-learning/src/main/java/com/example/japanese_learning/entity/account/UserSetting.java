package com.example.japanese_learning.entity.account;
import com.example.japanese_learning.enums.FontSize;
import com.example.japanese_learning.enums.ReadingSpeed;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalTime;


@Getter
@Setter
@Entity
@Table(name = "user_settings")
public class UserSetting {

    @Id
    @Column(name = "user_id")
    private Long userId;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "user_id")
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(name = "font_size")
    private FontSize fontSize = FontSize.MEDIUM;

    @Column(name = "is_dark_mode")
    private Boolean isDarkMode = false;

    @Column(name = "auto_translate_copied")
    private Boolean autoTranslateCopied = false;

    @Column(name = "auto_paste_search")
    private Boolean autoPasteSearch = false;

    @Column(name = "keep_screen_on")
    private Boolean keepScreenOn = false;

    @Enumerated(EnumType.STRING)
    @Column(name = "reading_speed")
    private ReadingSpeed readingSpeed = ReadingSpeed.NORMAL;

    @Column(name = "auto_repeat_audio")
    private Boolean autoRepeatAudio = false;

    @Column(name = "enable_daily_reminder")
    private Boolean enableDailyReminder = true;

    @Column(name = "reminder_time")
    private LocalTime reminderTime = LocalTime.of(19, 0);
}