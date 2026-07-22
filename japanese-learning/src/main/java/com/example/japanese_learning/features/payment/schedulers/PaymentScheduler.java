package com.example.japanese_learning.features.payment.schedulers;

import com.example.japanese_learning.features.payment.services.PaymentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class PaymentScheduler {

    private final PaymentService paymentService;

    /**
     * Chạy định kỳ mỗi 60 giây (60.000ms) để quét và hủy đơn PENDING quá 5 phút
     */
    @Scheduled(fixedRate = 60000)
    public void autoCancelExpiredPurchases() {
        log.info("[Scheduler] Bắt đầu quét các đơn hàng PENDING quá 5 phút...");
        paymentService.cancelExpiredPurchases();
    }
}
