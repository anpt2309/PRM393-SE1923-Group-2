package com.example.japanese_learning.features.daily_checkin.services;

import com.example.japanese_learning.dto.response.DailyCheckinResponse;
import com.example.japanese_learning.entity.account.User;
import com.example.japanese_learning.entity.account.UserDailyCheckin;
import com.example.japanese_learning.features.daily_checkin.repositories.UserDailyCheckinRepository;
import com.example.japanese_learning.features.daily_checkin.repositories.UserCheckinRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DailyCheckinService {

    private final UserCheckinRepository userCheckinRepository;
    private final UserDailyCheckinRepository checkinRepository;

    @Transactional
    public DailyCheckinResponse processDailyCheckin(String firebaseUid) {
        User user = userCheckinRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng với UID: " + firebaseUid));

        LocalDate today = LocalDate.now();
        LocalDate lastLogin = user.getLastLogin();
        boolean isNewCheckinToday = false;

        // 1. Kiểm tra để cập nhật chuỗi StreakDays
        if (lastLogin == null || lastLogin.isBefore(today.minusDays(1))) {
            // Chưa từng đăng nhập hoặc ngắt quãng quá 1 ngày -> Reset về 1
            user.setStreakDays(1);
        } else if (lastLogin.equals(today.minusDays(1))) {
            // Đăng nhập liên tiếp vào ngày hôm sau -> Tăng streak thêm 1
            user.setStreakDays(user.getStreakDays() + 1);
        }
        // Trường hợp lastLogin.equals(today) -> Hôm nay đã đăng nhập rồi, giữ nguyên streak

        // 2. Cập nhật ngày đăng nhập cuối cùng
        user.setLastLogin(today);
        userCheckinRepository.save(user);

        // 3. Ghi nhận lịch sử check-in vào bảng user_daily_checkins nếu hôm nay chưa lưu
        boolean alreadyCheckedInToday = checkinRepository.existsByUserAndCheckinDate(user, today);
        if (!alreadyCheckedInToday) {
            UserDailyCheckin checkin = new UserDailyCheckin();
            checkin.setUser(user);
            checkin.setCheckinDate(today);
            checkinRepository.save(checkin);
            isNewCheckinToday = true;

            // (Tùy chọn) Thêm logic cộng coin thưởng tại đây nếu muốn:
            // user.setCoin(user.getCoin() + 10);
            // userRepository.save(user);
        }

        // 4. Map dữ liệu sang DTO trả về cho client
        return DailyCheckinResponse.builder()
                .streakDays(user.getStreakDays())
                .lastLogin(user.getLastLogin())
                .currentCoin(user.getCoin())
                .isNewCheckinToday(isNewCheckinToday)
                .build();
    }

    @Transactional(readOnly = true)
    public List<LocalDate> getCheckinHistory(String firebaseUid) {
        User user = userCheckinRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng với UID: " + firebaseUid));

        return checkinRepository.findByUser(user)
                .stream()
                .map(UserDailyCheckin::getCheckinDate)
                .toList();
    }
}
