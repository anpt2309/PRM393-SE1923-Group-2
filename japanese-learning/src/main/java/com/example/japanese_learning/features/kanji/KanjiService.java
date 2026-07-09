package com.example.japanese_learning.features.kanji;

import com.example.japanese_learning.dto.response.KanjiResponse;
import com.example.japanese_learning.entity.learning.Kanji;
import com.example.japanese_learning.enums.JlptLevel;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class KanjiService {

    private final KanjiRepository kanjiRepository;

    @Transactional(readOnly = true)
    public List<KanjiResponse> getKanjiByLevel(String levelStr) {
        JlptLevel level = JlptLevel.valueOf(levelStr.toUpperCase());
        return kanjiRepository.findByJlptLevel(level).stream()
                .map(this::mapToResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public Optional<KanjiResponse> getKanjiDetails(String kanjiChar) {
        return kanjiRepository.findByKanjiChar(kanjiChar)
                .map(this::mapToResponse);
    }

    private KanjiResponse mapToResponse(Kanji k) {
        return KanjiResponse.builder()
                .id(k.getId())
                .kanjiChar(k.getKanjiChar())
                .meaning(k.getMeaning())
                .hanViet(k.getHanViet())
                .onyomi(k.getOnyomi())
                .onyomiCompounds(k.getOnyomiCompounds())
                .kunyomi(k.getKunyomi())
                .kunyomiCompounds(k.getKunyomiCompounds())
                .radicalsJson(k.getRadicalsJson())
                .strokeBadgesJson(k.getStrokeBadgesJson())
                .jlptLevel(k.getJlptLevel())
                .build();
    }

    @PostConstruct
    @Transactional
    public void seedDatabase() {
        if (kanjiRepository.count() == 0) {
            List<Kanji> list = new ArrayList<>();

            // ─── N5 LEVEL ───
            list.add(createKanji("明", "Sáng sủa, sáng suốt", "MINH", "メイ, ミョウ",
                "【明日】あす (Ngày mai);【説明】せつめい (Giải thích)", "あか.るい, あき.らか",
                "【明るい】あかるい (Sáng sủa);【明らか】あきらか (Rõ ràng)",
                "[{\"character\":\"日\",\"name\":\"Nhật\",\"meaning\":\"Mặt trời\",\"story\":\"Nguồn sáng ban ngày rực rỡ.\"},{\"character\":\"月\",\"name\":\"Nguyệt\",\"meaning\":\"Mặt trăng\",\"story\":\"Nguồn sáng ban đêm dịu mát.\"}]",
                "[{\"x\":0.20,\"y\":0.35,\"number\":1},{\"x\":0.38,\"y\":0.22,\"number\":2},{\"x\":0.38,\"y\":0.48,\"number\":3},{\"x\":0.38,\"y\":0.78,\"number\":4},{\"x\":0.65,\"y\":0.25,\"number\":5},{\"x\":0.78,\"y\":0.15,\"number\":6},{\"x\":0.78,\"y\":0.45,\"number\":7},{\"x\":0.78,\"y\":0.75,\"number\":8}]",
                JlptLevel.N5));

            list.add(createKanji("日", "Ngày, mặt trời", "NHẬT", "ニチ, ジツ",
                "【日本】にほん (Nhật Bản);【毎日】まいにち (Mỗi ngày)", "ひ, -び, -か",
                "【日曜日】にちようび (Chủ nhật);【三日】みっか (Ngày mùng 3)",
                "[{\"character\":\"日\",\"name\":\"Nhật\",\"meaning\":\"Mặt trời\",\"story\":\"Vẽ hình mặt trời hình tròn có nhân ở giữa.\"}]",
                "[{\"x\":0.25,\"y\":0.35,\"number\":1},{\"x\":0.50,\"y\":0.20,\"number\":2},{\"x\":0.50,\"y\":0.50,\"number\":3},{\"x\":0.50,\"y\":0.80,\"number\":4}]",
                JlptLevel.N5));

            list.add(createKanji("月", "Tháng, mặt trăng", "NGUYỆT", "ゲツ, ガツ",
                "【一月】いちがつ (Tháng 1);【今月】こんげつ (Tháng này)", "つき",
                "【月】つき (Mặt trăng);【月夜】つきよ (Đêm trăng sáng)",
                "[{\"character\":\"月\",\"name\":\"Nguyệt\",\"meaning\":\"Mặt trăng\",\"story\":\"Vẽ vầng trăng khuyết che chở ban đêm.\"}]",
                "[{\"x\":0.32,\"y\":0.25,\"number\":1},{\"x\":0.55,\"y\":0.18,\"number\":2},{\"x\":0.55,\"y\":0.45,\"number\":3},{\"x\":0.55,\"y\":0.70,\"number\":4}]",
                JlptLevel.N5));

            // ─── N4 LEVEL ───
            list.add(createKanji("車", "Xe cộ, phương tiện", "XA", "シャ",
                "【電車】でんしゃ (Tàu điện);【自転車】じてんしゃ (Xe đạp)", "くるま",
                "【車】くるま (Xe hơi);【荷車】にぐるま (Xe kéo chở hàng)",
                "[{\"character\":\"車\",\"name\":\"Xa\",\"meaning\":\"Bánh xe\",\"story\":\"Hình vẽ chiếc xe nhìn từ trên xuống có hai bánh xe.\"}]",
                "[{\"x\":0.30,\"y\":0.25,\"number\":1},{\"x\":0.50,\"y\":0.20,\"number\":2},{\"x\":0.50,\"y\":0.40,\"number\":3},{\"x\":0.30,\"y\":0.55,\"number\":4},{\"x\":0.50,\"y\":0.70,\"number\":5},{\"x\":0.70,\"y\":0.70,\"number\":6},{\"x\":0.50,\"y\":0.90,\"number\":7}]",
                JlptLevel.N4));

            list.add(createKanji("男", "Đàn ông, nam giới", "NAM", "ダン, ナN",
                "【男性】だんせい (Nam giới);【長男】ちょうなん (Con trai trưởng)", "おとこ",
                "【男の子】おとこのこ (Bé trai);【男らしい】おとこらしい (Nam tính)",
                "[{\"character\":\"田\",\"name\":\"Điền\",\"meaning\":\"Ruộng lúa\",\"story\":\"Mảnh ruộng chia ô vuông.\"},{\"character\":\"力\",\"name\":\"Lực\",\"meaning\":\"Sức lực\",\"story\":\"Cánh tay gồng lên dùng lực.\"}]",
                "[{\"x\":0.30,\"y\":0.20,\"number\":1},{\"x\":0.50,\"y\":0.15,\"number\":2},{\"x\":0.50,\"y\":0.35,\"number\":3},{\"x\":0.35,\"y\":0.40,\"number\":4},{\"x\":0.50,\"y\":0.40,\"number\":5},{\"x\":0.40,\"y\":0.65,\"number\":6},{\"x\":0.60,\"y\":0.75,\"number\":7}]",
                JlptLevel.N4));

            list.add(createKanji("女", "Phụ nữ, nữ giới", "NỮ", "ジョ, ニョ",
                "【女性】じょせい (Nữ giới);【彼女】かのじょ (Cô ấy/Bạn gái)", "おnna",
                "【女の子】おんなのこ (Bé gái);【女神】めがみ (Nữ thần)",
                "[{\"character\":\"女\",\"name\":\"Nữ\",\"meaning\":\"Phụ nữ\",\"story\":\"Hình dáng người phụ nữ đang quỳ gối cúi chào cung kính.\"}]",
                "[{\"x\":0.48,\"y\":0.25,\"number\":1},{\"x\":0.35,\"y\":0.50,\"number\":2},{\"x\":0.55,\"y\":0.48,\"number\":3}]",
                JlptLevel.N4));

            // ─── N3 LEVEL ───
            list.add(createKanji("使", "Sử dụng, sứ giả", "SỬ", "シ",
                "【使用】しよう (Sử dụng);【大使館】たいしかん (Đại sứ quán)", "つか.う",
                "【使う】つかう (Dùng);【使い方】つかいかた (Cách dùng)",
                "[{\"character\":\"亻\",\"name\":\"Nhân\",\"meaning\":\"Con người\",\"story\":\"Hình vẽ con người đang đứng.\"},{\"character\":\"吏\",\"name\":\"Lại\",\"meaning\":\"Quan lại\",\"story\":\"Vị quan thừa lệnh hoàng đế làm việc.\"}]",
                "[{\"x\":0.22,\"y\":0.20,\"number\":1},{\"x\":0.18,\"y\":0.50,\"number\":2},{\"x\":0.50,\"y\":0.15,\"number\":3},{\"x\":0.60,\"y\":0.30,\"number\":4},{\"x\":0.55,\"y\":0.48,\"number\":5},{\"x\":0.55,\"y\":0.65,\"number\":6},{\"x\":0.50,\"y\":0.80,\"number\":7},{\"x\":0.72,\"y\":0.85,\"number\":8}]",
                JlptLevel.N3));

            list.add(createKanji("信", "Tin tưởng, uy tín, thông tin", "TÌN", "シン",
                "【信用】しんよう (Tin cậy, tín dụng);【信号】しんごう (Đèn giao thông)", "しん.じる",
                "【信じる】しんじる (Tin tưởng);【自信】じしん (Tự tin)",
                "[{\"character\":\"亻\",\"name\":\"Nhân\",\"meaning\":\"Con người\",\"story\":\"Con người luôn hướng về sự chân thật.\"},{\"character\":\"言\",\"name\":\"Ngôn\",\"meaning\":\"Lời nói\",\"story\":\"Lời nói phát ra từ miệng rộng.\"}]",
                "[{\"x\":0.22,\"y\":0.20,\"number\":1},{\"x\":0.18,\"y\":0.50,\"number\":2},{\"x\":0.55,\"y\":0.15,\"number\":3},{\"x\":0.60,\"y\":0.32,\"number\":4},{\"x\":0.60,\"y\":0.48,\"number\":5},{\"x\":0.60,\"y\":0.65,\"number\":6},{\"x\":0.52,\"y\":0.80,\"number\":7},{\"x\":0.70,\"y\":0.80,\"number\":8},{\"x\":0.70,\"y\":0.92,\"number\":9}]",
                JlptLevel.N3));

            list.add(createKanji("活", "Sống, sinh hoạt, linh hoạt", "HOẠT", "カツ",
                "【活動】かつどう (Hoạt động);【生活】せいかつ (Cuộc sống)", "い.きる",
                "【活気】かっき (Sự hoạt bát, đầy sức sống);【活発】かっぱつ (Hoạt bát, năng nổ)",
                "[{\"character\":\"氵\",\"name\":\"Thủy\",\"meaning\":\"Nước\",\"story\":\"Ba giọt nước tuôn trào.\"},{\"character\":\"舌\",\"name\":\"Thiệt\",\"meaning\":\"Cái lưỡi\",\"story\":\"Lưỡi liếm láp thức ăn để duy trì cuộc sống.\"}]",
                "[{\"x\":0.20,\"y\":0.20,\"number\":1},{\"x\":0.18,\"y\":0.45,\"number\":2},{\"x\":0.18,\"y\":0.75,\"number\":3},{\"x\":0.55,\"y\":0.20,\"number\":4},{\"x\":0.48,\"y\":0.38,\"number\":5},{\"x\":0.70,\"y\":0.38,\"number\":6},{\"x\":0.58,\"y\":0.55,\"number\":7},{\"x\":0.52,\"y\":0.75,\"number\":8},{\"x\":0.72,\"y\":0.75,\"number\":9}]",
                JlptLevel.N3));

            // ─── N2 LEVEL ───
            list.add(createKanji("情", "Tình cảm, thực trạng", "TÌNH", "ジョウ, セイ",
                "【感情】かんじょう (Tình cảm, cảm xúc);【情報】じょうほう (Thông tin)", "なさ.け",
                "【情け】なさけ (Lòng trắc ẩn, sự nhân từ);【友情】ゆうじょう (Tình bạn)",
                "[{\"character\":\"忄\",\"name\":\"Tâm\",\"meaning\":\"Con tim\",\"story\":\"Biểu thị cảm xúc, tình cảm sâu kín.\"},{\"character\":\"青\",\"name\":\"Thanh\",\"meaning\":\"Màu xanh\",\"story\":\"Màu xanh hy vọng trẻ trung.\"}]",
                "[{\"x\":0.18,\"y\":0.30,\"number\":1},{\"x\":0.10,\"y\":0.45,\"number\":2},{\"x\":0.25,\"y\":0.55,\"number\":3},{\"x\":0.55,\"y\":0.20,\"number\":4},{\"x\":0.70,\"y\":0.25,\"number\":5},{\"x\":0.62,\"y\":0.42,\"number\":6},{\"x\":0.62,\"y\":0.55,\"number\":7},{\"x\":0.55,\"y\":0.68,\"number\":8},{\"x\":0.75,\"y\":0.68,\"number\":9},{\"x\":0.62,\"y\":0.85,\"number\":10},{\"x\":0.62,\"y\":0.95,\"number\":11}]",
                JlptLevel.N2));

            list.add(createKanji("報", "Báo cáo, đền đáp, tin tức", "BÁO", "ホウ",
                "【報告】ほうこく (Báo cáo);【報道】ほうどう (Đưa tin, phát thanh)", "むく.いる",
                "【報いる】むくいる (Đền đáp, báo ơn);【予報】よほう (Dự báo thời tiết)",
                "[{\"character\":\"幸\",\"name\":\"Hạnh\",\"meaning\":\"May mắn\",\"story\":\"Những cùm tay dùng để tra khảo phạm nhân để lấy lời báo cáo.\"},{\"character\":\"卩\",\"name\":\"Tiết\",\"meaning\":\"Tre\",\"story\":\"Khớp tre dùng làm thẻ tre ghi chép tin tức.\"}]",
                "[{\"x\":0.25,\"y\":0.18,\"number\":1},{\"x\":0.45,\"y\":0.22,\"number\":2},{\"x\":0.35,\"y\":0.35,\"number\":3},{\"x\":0.20,\"y\":0.48,\"number\":4},{\"x\":0.32,\"y\":0.60,\"number\":5},{\"x\":0.48,\"y\":0.60,\"number\":6},{\"x\":0.65,\"y\":0.30,\"number\":7},{\"x\":0.78,\"y\":0.42,\"number\":8},{\"x\":0.62,\"y\":0.68,\"number\":9},{\"x\":0.80,\"y\":0.75,\"number\":10},{\"x\":0.70,\"y\":0.90,\"number\":11}]",
                JlptLevel.N2));

            list.add(createKanji("感", "Cảm giác, cảm động", "CẢM", "カン",
                "【感謝】かんしゃ (Cảm ơn, tạ ơn);【感動】かんどう (Cảm động)", "かん.じる",
                "【感じる】かんじる (Cảm thấy);【直感】ちょっかん (Trực giác)",
                "[{\"character\":\"咸\",\"name\":\"Hàm\",\"meaning\":\"Tất cả\",\"story\":\"Tiếng kêu đồng loạt phát ra.\"},{\"character\":\"心\",\"name\":\"Tâm\",\"meaning\":\"Con tim\",\"story\":\"Trái tim cảm thụ sâu sắc.\"}]",
                "[{\"x\":0.22,\"y\":0.20,\"number\":1},{\"x\":0.40,\"y\":0.18,\"number\":2},{\"x\":0.45,\"y\":0.32,\"number\":3},{\"x\":0.32,\"y\":0.45,\"number\":4},{\"x\":0.58,\"y\":0.45,\"number\":5},{\"x\":0.48,\"y\":0.58,\"number\":6},{\"x\":0.65,\"y\":0.25,\"number\":7},{\"x\":0.72,\"y\":0.55,\"number\":8},{\"x\":0.85,\"y\":0.62,\"number\":9},{\"x\":0.32,\"y\":0.82,\"number\":10},{\"x\":0.48,\"y\":0.78,\"number\":11},{\"x\":0.65,\"y\":0.88,\"number\":12},{\"x\":0.75,\"y\":0.80,\"number\":13}]",
                JlptLevel.N2));

            // ─── N1 LEVEL ───
            list.add(createKanji("難", "Khó khăn, gian nan, tai ương", "NAN", "ナン",
                "【困難】こんなん (Khó khăn, vất vả);【避難】ひなん (Tị nạn, lánh nạn)", "むずか.しい, -にく.い",
                "【難しい】むずかしい (Khó khăn);【難い】にくい (Khó làm việc gì đó)",
                "[{\"character\":\"革\",\"name\":\"Cách\",\"meaning\":\"Da thuộc\",\"story\":\"Tấm da thú căng rộng.\"},{\"character\":\"隹\",\"name\":\"Chuy\",\"meaning\":\"Chim đuôi ngắn\",\"story\":\"Loài chim nhỏ có đuôi ngắn ngủn.\"}]",
                "[{\"x\":0.18,\"y\":0.20,\"number\":1},{\"x\":0.32,\"y\":0.18,\"number\":2},{\"x\":0.25,\"y\":0.35,\"number\":3},{\"x\":0.22,\"y\":0.48,\"number\":4},{\"x\":0.35,\"y\":0.48,\"number\":5},{\"x\":0.28,\"y\":0.65,\"number\":6},{\"x\":0.30,\"y\":0.78,\"number\":7},{\"x\":0.45,\"y\":0.72,\"number\":8},{\"x\":0.58,\"y\":0.25,\"number\":9},{\"x\":0.68,\"y\":0.18,\"number\":10},{\"x\":0.68,\"y\":0.42,\"number\":11},{\"x\":0.68,\"y\":0.65,\"number\":12},{\"x\":0.52,\"y\":0.85,\"number\":13},{\"x\":0.75,\"y\":0.85,\"number\":14},{\"x\":0.78,\"y\":0.52,\"number\":15},{\"x\":0.85,\"y\":0.92,\"number\":16}]",
                JlptLevel.N1));

            list.add(createKanji("警", "Cảnh giác, răn đe, cảnh sát", "CẢNH", "ケイ",
                "【警察】けいさつ (Cảnh sát);【警告】けいこk (Cảnh cáo)", "いまし.める",
                "【警固】けいご (Cảnh vệ, bảo vệ);【警報】けいほう (Cảnh báo, báo động)",
                "[{\"character\":\"敬\",\"name\":\"Kính\",\"meaning\":\"Cung kính\",\"story\":\"Kính trọng người lớn tuổi.\"},{\"character\":\"言\",\"name\":\"Ngôn\",\"meaning\":\"Lời nói\",\"story\":\"Lời nói cẩn trọng răn đe.\"}]",
                "[{\"x\":0.35,\"y\":0.15,\"number\":1},{\"x\":0.50,\"y\":0.12,\"number\":2},{\"x\":0.45,\"y\":0.25,\"number\":3},{\"x\":0.32,\"y\":0.38,\"number\":4},{\"x\":0.58,\"y\":0.35,\"number\":5},{\"x\":0.65,\"y\":0.15,\"number\":6},{\"x\":0.78,\"y\":0.28,\"number\":7},{\"x\":0.70,\"y\":0.45,\"number\":8},{\"x\":0.82,\"y\":0.48,\"number\":9},{\"x\":0.42,\"y\":0.60,\"number\":10},{\"x\":0.55,\"y\":0.60,\"number\":11},{\"x\":0.55,\"y\":0.70,\"number\":12},{\"x\":0.55,\"y\":0.80,\"number\":13},{\"x\":0.48,\"y\":0.90,\"number\":14},{\"x\":0.65,\"y\":0.90,\"number\":15},{\"x\":0.65,\"y\":0.98,\"number\":16}]",
                JlptLevel.N1));

            list.add(createKanji("察", "Xem xét, quan sát, cảnh sát", "SÁT", "サツ",
                "【観察】かんさつ (Quan sát);【察する】さっする (Cảm thông, suy đoán)", "さっ.する",
                "【察知】さっち (Cảm thấy, nhận ra);【考察】こうさつ (Khảo sát, xem xét)",
                "[{\"character\":\"宀\",\"name\":\"Miên\",\"meaning\":\"Mái nhà\",\"story\":\"Mái nhà che chở gia đình.\"},{\"character\":\"祭\",\"name\":\"Tế\",\"meaning\":\"Cúng tế\",\"story\":\"Nghi lễ cúng bái thần linh tôn nghiêm.\"}]",
                "[{\"x\":0.50,\"y\":0.12,\"number\":1},{\"x\":0.35,\"y\":0.22,\"number\":2},{\"x\":0.68,\"y\":0.22,\"number\":3},{\"x\":0.32,\"y\":0.45,\"number\":4},{\"x\":0.52,\"y\":0.40,\"number\":5},{\"x\":0.70,\"y\":0.42,\"number\":6},{\"x\":0.42,\"y\":0.55,\"number\":7},{\"x\":0.62,\"y\":0.55,\"number\":8},{\"x\":0.52,\"y\":0.68,\"number\":9},{\"x\":0.32,\"y\":0.85,\"number\":10},{\"x\":0.42,\"y\":0.82,\"number\":11},{\"x\":0.68,\"y\":0.85,\"number\":12},{\"x\":0.78,\"y\":0.88,\"number\":13}]",
                JlptLevel.N1));

            kanjiRepository.saveAll(list);
        }
    }

    private Kanji createKanji(String kanjiChar, String meaning, String hanViet, String onyomi,
                              String onyomiCompounds, String kunyomi, String kunyomiCompounds,
                              String radicalsJson, String strokeBadgesJson, JlptLevel level) {
        Kanji k = new Kanji();
        k.setKanjiChar(kanjiChar);
        k.setMeaning(meaning);
        k.setHanViet(hanViet);
        k.setOnyomi(onyomi);
        k.setOnyomiCompounds(onyomiCompounds);
        k.setKunyomi(kunyomi);
        k.setKunyomiCompounds(kunyomiCompounds);
        k.setRadicalsJson(radicalsJson);
        k.setStrokeBadgesJson(strokeBadgesJson);
        k.setJlptLevel(level);
        return k;
    }
}
