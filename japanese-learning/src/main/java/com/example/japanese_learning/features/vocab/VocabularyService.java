package com.example.japanese_learning.features.vocab;

import com.example.japanese_learning.dto.response.VocabLessonResponse;
import com.example.japanese_learning.dto.response.VocabularyResponse;
import com.example.japanese_learning.entity.learning.Vocabulary;
import com.example.japanese_learning.enums.JlptLevel;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class VocabularyService {

    private final VocabularyRepository vocabularyRepository;

    @Transactional(readOnly = true)
    public List<VocabLessonResponse> getLessonsByLevel(String levelStr) {
        JlptLevel level = JlptLevel.valueOf(levelStr.toUpperCase());
        List<Object[]> distinctLessons = vocabularyRepository.findDistinctLessonsByJlptLevel(level);
        List<VocabLessonResponse> responses = new ArrayList<>();

        for (Object[] row : distinctLessons) {
            String lessonId = (String) row[0];
            String lessonTitle = (String) row[1];
            if (lessonId != null) {
                int totalWords = (int) vocabularyRepository.countWordsInLesson(level, lessonId);
                responses.add(VocabLessonResponse.builder()
                        .id(lessonId)
                        .title(lessonTitle)
                        .totalWords(totalWords)
                        .build());
            }
        }
        return responses;
    }

    @Transactional(readOnly = true)
    public List<VocabularyResponse> getWordsByLesson(String levelStr, String lessonId) {
        JlptLevel level = JlptLevel.valueOf(levelStr.toUpperCase());
        return vocabularyRepository.findByJlptLevelAndLessonId(level, lessonId).stream()
                .map(this::mapToResponse)
                .toList();
    }

    private VocabularyResponse mapToResponse(Vocabulary v) {
        return VocabularyResponse.builder()
                .id(v.getId())
                .word(v.getWord())
                .kanji(v.getKanji())
                .reading(v.getReading())
                .romaji(v.getRomaji())
                .englishMeaning(v.getEnglishMeaning())
                .vietnameseMeaning(v.getVietnameseMeaning())
                .collocations(v.getCollocations())
                .exampleSentenceJa(v.getExampleSentenceJa())
                .exampleSentenceJaHira(v.getExampleSentenceJaHira())
                .exampleSentenceVi(v.getExampleSentenceVi())
                .exampleSentenceEn(v.getExampleSentenceEn())
                .wordType(v.getWordType())
                .pitchAccent(v.getPitchAccent())
                .lessonId(v.getLessonId())
                .lessonTitle(v.getLessonTitle())
                .jlptLevel(v.getJlptLevel())
                .build();
    }

    @PostConstruct
    @Transactional
    public void seedDatabase() {
        if (vocabularyRepository.count() == 0) {
            List<Vocabulary> list = new ArrayList<>();

            // ─── N5 LEVEL ───
            // Lesson 1
            list.add(createVocab("食べる", "食 (THỰC)", "たべる", "taberu", "To eat", "Ăn",
                "朝ご飯を食べる (Ăn sáng),早く食べる (Ăn nhanh)", "毎日、朝ご飯を食べる。", "まいにち、あさごはんをたべる。",
                "Mỗi ngày tôi đều ăn sáng.", "I eat breakfast every day.", "Động từ nhóm 2", "Trọng âm: [2]",
                "n5_l1", "Bài 1: Chào hỏi & Sinh hoạt", JlptLevel.N5));

            list.add(createVocab("飲む", "飲 (ẨM)", "のむ", "nomu", "To drink", "Uống",
                "水を飲む (Uống nước),お茶を飲む (Uống trà)", "冷たい牛乳を飲む。", "つめたいぎゅうにゅうをのむ。",
                "Tôi uống sữa lạnh.", "I drink cold milk.", "Động từ nhóm 1", "Trọng âm: [1]",
                "n5_l1", "Bài 1: Chào hỏi & Sinh hoạt", JlptLevel.N5));

            list.add(createVocab("行く", "行 (HÀNH)", "いく", "iku", "To go", "Đi",
                "学校に行く (Đi đến trường),日本に行く (Đi Nhật)", "明日、学校に行く。", "あした、がっこうにいく。",
                "Ngày mai tôi đi học.", "Tomorrow I will go to school.", "Động từ nhóm 1", "Trọng âm: [0]",
                "n5_l1", "Bài 1: Chào hỏi & Sinh hoạt", JlptLevel.N5));

            // Lesson 2
            list.add(createVocab("友達", "友 / 達 (HỮU ĐẠT)", "ともだち", "tomodachi", "Friend", "Bạn bè",
                "友達と遊ぶ (Chơi với bạn),親しい友達 (Bạn thân)", "友達と公園で遊ぶ。", "ともだちとこうえんであそぶ。",
                "Tôi đi chơi với bạn bè ở công viên.", "I play with my friends at the park.", "Danh từ", "Trọng âm: [0]",
                "n5_l2", "Bài 2: Gia đình & Bạn bè", JlptLevel.N5));

            list.add(createVocab("家族", "家 / 族 (GIA TỘC)", "かぞく", "kazoku", "Family", "Gia đình",
                "家族と住む (Sống với gia đình),大切な家族 (Gia đình quan trọng)", "私の家族はベトナムに住んでいます。", "わたしのかぞくはべとなむにすんでいます。",
                "Gia đình của tôi đang sống ở Việt Nam.", "My family lives in Vietnam.", "Danh từ", "Trọng âm: [1]",
                "n5_l2", "Bài 2: Gia đình & Bạn bè", JlptLevel.N5));

            list.add(createVocab("先生", "先 / 生 (TIÊN SINH)", "せんせい", "sensei", "Teacher", "Thầy cô",
                "先生に質問する (Hỏi giáo viên),英語ของ先生 (Giáo viên tiếng Anh)", "日本語の先生に会う。", "にほんごのせんせいにあう。",
                "Tôi đi gặp giáo viên tiếng Nhật.", "I go to meet my Japanese teacher.", "Danh từ", "Trọng âm: [3]",
                "n5_l2", "Bài 2: Gia đình & Bạn bè", JlptLevel.N5));

            // Lesson 3
            list.add(createVocab("日本語", "日 / 本 / 語 (NHẬT BẢN NGỮ)", "にほんご", "nihongo", "Japanese language", "Tiếng Nhật",
                "日本語を話す (Nói tiếng Nhật),日本語を勉強する (Học tiếng Nhật)", "日本語の勉強はとても面白いです。", "にほんごのべんきょうはとてもおもしろいです。",
                "Học tiếng Nhật rất thú vị.", "Studying Japanese is very interesting.", "Danh từ", "Trọng âm: [0]",
                "n5_l3", "Bài 3: Học tập & Trường học", JlptLevel.N5));

            list.add(createVocab("学校", "学 / 校 (HỌC HIỆU)", "がっこう", "gakkou", "School", "Trường học",
                "学校に行く (Đi học),新しい学校 (Trường học mới)", "学校で日本語を勉強する。", "がっこうでにほんごをべんきょうする。",
                "Tôi học tiếng Nhật ở trường.", "I study Japanese at school.", "Danh từ", "Trọng âm: [0]",
                "n5_l3", "Bài 3: Học tập & Trường học", JlptLevel.N5));

            list.add(createVocab("本", "本 (BẢN)", "ほん", "ほん", "Book", "Sách",
                "本を読む (Đọc sách),図書館の本 (Sách thư viện)", "毎日、本を読みます。", "まいにち、ほんをよみます。",
                "Mỗi ngày tôi đều đọc sách.", "I read books every day.", "Danh từ", "Trọng âm: [1]",
                "n5_l3", "Bài 3: Học tập & Trường học", JlptLevel.N5));


            // ─── N4 LEVEL ───
            // Lesson 1
            list.add(createVocab("運転する", "運 / 転 (VẬN CHUYỂN)", "うんてんする", "untensuru", "To drive", "Lái xe",
                "車を運転する (Lái xe hơi),安全に運転する (Lái xe an toàn)", "父は毎日車を運転する。", "ちちはまいにちくるまをうんてんする。",
                "Bố tôi lái xe ô tô mỗi ngày.", "My father drives a car every day.", "Động từ nhóm 3", "Trọng âm: [0]",
                "n4_l1", "Bài 1: Giao thông & Đi lại", JlptLevel.N4));

            list.add(createVocab("乗る", "乗 (THỪA)", "のる", "noru", "To ride / board", "Lên xe / tàu",
                "電車に乗る (Lên tàu điện),自転車に乗る (Đi xe đạp)", "毎日、電車に乗る。", "まいにち、でんしゃにのる。",
                "Mỗi ngày tôi đều đi tàu điện.", "I ride the train every day.", "Động từ nhóm 1", "Trọng âm: [0]",
                "n4_l1", "Bài 1: Giao thông & Đi lại", JlptLevel.N4));

            list.add(createVocab("降りる", "降 (GIÁNG)", "おりる", "oriru", "To get off / descend", "Xuống xe / tàu",
                "バスを降りる (Xuống xe bus),駅で降りる (Xuống ở ga)", "次の駅で降ります。", "つぎのえきでおります。",
                "Tôi sẽ xuống ở ga tiếp theo.", "I will get off at the next station.", "Động từ nhóm 2", "Trọng âm: [2]",
                "n4_l1", "Bài 1: Giao thông & Đi lại", JlptLevel.N4));

            // Lesson 2
            list.add(createVocab("約束", "約 / 束 (ƯỚC THÚC)", "やくそく", "yakusoku", "Promise / Appointment", "Hứa, hẹn",
                "約束を守る (Giữ lời hứa),約束を破る (Thất hứa)", "友達との約束を守る。", "ともだちとのやくそくをまもる。",
                "Tôi giữ đúng lời hứa với bạn.", "I keep my promise with my friend.", "Danh từ / Động từ nhóm 3", "Trọng âm: [0]",
                "n4_l2", "Bài 2: Công việc & Đời sống", JlptLevel.N4));

            list.add(createVocab("準備", "准 / 備 (CHUẨN BỊ)", "じゅんび", "junbi", "Preparation", "Chuẩn bị",
                "旅行の準備 (Chuẩn bị du lịch),心の準備 (Chuẩn bị tinh thần)", "旅行の準備をしましょう。", "りょこうのじゅんびをしましょう。",
                "Chúng ta cùng chuẩn bị cho chuyến đi du lịch nào.", "Let's prepare for the trip.", "Danh từ / Động từ nhóm 3", "Trọng âm: [1]",
                "n4_l2", "Bài 2: Công việc & Đời sống", JlptLevel.N4));

            list.add(createVocab("集める", "集 (TẬP)", "あつめる", "atsumeru", "To collect", "Thu thập",
                "切手を集める (Sưu tầm tem),情報を集める (Thu thập thông tin)", "趣味で切手を集める。", "しゅみできってをあつめる。",
                "Tôi sưu tầm tem làm sở thích.", "I collect stamps as a hobby.", "Động từ nhóm 2", "Trọng âm: [3]",
                "n4_l2", "Bài 2: Công việc & Đời sống", JlptLevel.N4));

            // Lesson 3
            list.add(createVocab("旅行する", "旅 / 行 (LỮ HÀNH)", "りょこうする", "ryokousuru", "To travel", "Đi du lịch",
                "日本を旅行する (Du lịch Nhật Bản),家族と旅行する (Du lịch với gia đình)", "夏休みに日本を旅行する。", "なつやすみににほんをりょこうする。",
                "Tôi đi du lịch Nhật Bản vào kỳ nghỉ hè.", "I will travel in Japan during summer vacation.", "Động từ nhóm 3", "Trọng âm: [0]",
                "n4_l3", "Bài 3: Hoạt động giải trí", JlptLevel.N4));

            list.add(createVocab("歌う", "歌 (CA)", "うたう", "utau", "To sing", "Hát",
                "歌を歌う (Hát bài hát),大きな声で歌う (Hát to rõ)", "彼は綺麗な声で歌う。", "かれはきれいなこえでうたう。",
                "Anh ấy hát bằng một giọng hát rất đẹp.", "He sings in a beautiful voice.", "Động từ nhóm 1", "Trọng âm: [0]",
                "n4_l3", "Bài 3: Hoạt động giải trí", JlptLevel.N4));

            list.add(createVocab("遊ぶ", "遊 (DU)", "あそぶ", "asobu", "To play / hang out", "Vui chơi",
                "友達と遊ぶ (Chơi với bạn),公園で遊ぶ (Chơi ở công viên)", "子供たちが公園で遊ぶ。", "こどもたちがこうえんであそぶ。",
                "Trẻ con đang chơi đùa ở công viên.", "Children are playing in the park.", "Động từ nhóm 1", "Trọng âm: [0]",
                "n4_l3", "Bài 3: Hoạt động giải trí", JlptLevel.N4));


            // ─── N3 LEVEL ───
            // Lesson 1
            list.add(createVocab("解決", "解 / 決 (GIẢI QUYẾT)", "かいけつ", "kaiketsu", "Resolution", "Giải quyết",
                "問題を解決する (Giải quyết vấn đề),争いを解決する (Giải quyết tranh chấp)", "この問題は簡単に解決できない。", "もんだいをかいけつする。",
                "Vấn đề này không thể giải quyết dễ dàng.", "This problem cannot be solved easily.", "Danh từ / Động từ nhóm 3", "Trọng âm: [0]",
                "n3_l1", "Bài 1: Xã hội & Đời sống", JlptLevel.N3));

            list.add(createVocab("経済", "経 / 済 (KINH TẾ)", "けいざい", "keizai", "Economy", "Kinh tế",
                "経済が成長する (Kinh tế phát triển),経済状況 (Tình hình kinh tế)", "日本の経済について本を読みました。", "にほんのけいざいについてほんをよみました。",
                "Tôi đã đọc một cuốn sách về kinh tế Nhật Bản.", "I read a book about the Japanese economy.", "Danh từ", "Trọng âm: [1]",
                "n3_l1", "Bài 1: Xã hội & Đời sống", JlptLevel.N3));

            list.add(createVocab("環境", "環 / 境 (HOÀN CẢNH)", "かんきょう", "kankyou", "Environment", "Môi trường",
                "環境を守る (Bảo vệ môi trường),自然環境 (Môi trường tự nhiên)", "私たちは自然環境を守るべきです。", "わたしたちはしぜんかんきょうをまもるべきです。",
                "Chúng ta nên bảo vệ môi trường tự nhiên.", "We should protect the natural environment.", "Danh từ", "Trọng âm: [0]",
                "n3_l1", "Bài 1: Xã hội & Đời sống", JlptLevel.N3));

            // Lesson 2
            list.add(createVocab("興味", "興 / 味 (HỨNG VỊ)", "きょうみ", "kyoumi", "Interest", "Hứng thú",
                "興味を持つ (Có hứng thú),興味深い話 (Câu chuyện thú vị)", "私は日本の歴史に興味がある。", "わたしはにほんのれきしにきょうみがある。",
                "Tôi có hứng thú với lịch sử Nhật Bản.", "I have an interest in Japanese history.", "Danh từ", "Trọng âm: [1]",
                "n3_l2", "Bài 2: Giao tiếp & Thảo luận", JlptLevel.N3));

            list.add(createVocab("翻訳", "翻 / 訳 (PHIÊN DỊCH)", "ほんやく", "honyaku", "Translation", "Dịch thuật",
                "小説を翻訳する (Dịch tiểu thuyết),翻訳ソフト (Phần mềm dịch)", "日本語の小説をベトナム語に翻訳する。", "にほんごのしょうせつをべとなむごにほんやくする。",
                "Dịch tiểu thuyết tiếng Nhật sang tiếng Việt.", "Translate a Japanese novel into Vietnamese.", "Danh từ / Động từ nhóm 3", "Trọng âm: [0]",
                "n3_l2", "Bài 2: Giao tiếp & Thảo luận", JlptLevel.N3));

            list.add(createVocab("反対", "反 / 対 (PHẢN ĐỐI)", "はんたい", "hantai", "Opposition", "Phản đối",
                "意見に反対する (Phản đối ý kiến),計画に反対する (Phản đối kế hoạch)", "彼の意見に反対する。", "かれのいけんにはんたいする。",
                "Tôi phản đối ý kiến của anh ấy.", "I oppose his opinion.", "Danh từ / Động từ nhóm 3", "Trọng âm: [0]",
                "n3_l2", "Bài 2: Giao tiếp & Thảo luận", JlptLevel.N3));

            // Lesson 3
            list.add(createVocab("心配", "心 / 配 (TÂM PHỐI)", "しんぱい", "shinpai", "Worry", "Lo lắng",
                "家族を心配する (Lo lắng cho gia đình),心配事 (Chuyện lo lắng)", "明日のテストを心配する。", "あしたのてすとをしんぱいする。",
                "Tôi lo lắng về bài thi ngày mai.", "I worry about tomorrow's test.", "Danh từ / Động từ nhóm 3", "Trọng âm: [0]",
                "n3_l3", "Bài 3: Cảm xúc & Suy nghĩ", JlptLevel.N3));

            list.add(createVocab("信じる", "信 (TÍN)", "しんじる", "shinjiru", "To believe", "Tin tưởng",
                "自分を信じる (Tin vào bản thân),未来を信じる (Tin vào tương lai)", "自分の力を信じます。", "じぶんのちからをしんじます。",
                "Tôi tin vào năng lực của bản thân.", "I believe in my own strength.", "Động từ nhóm 2", "Trọng âm: [3]",
                "n3_l3", "Bài 3: Cảm xúc & Suy nghĩ", JlptLevel.N3));

            list.add(createVocab("怒る", "怒 (NỘ)", "おこる", "okoru", "To get angry", "Tức giận",
                "急に怒る (Đột ngột nổi giận),怒った顔 (Khuôn mặt giận dữ)", "友達が嘘をついて怒った。", "ともだちがうそをついておこった。",
                "Người bạn đã nổi giận vì bị nói dối.", "My friend got angry because of a lie.", "Động từ nhóm 1", "Trọng âm: [2]",
                "n3_l3", "Bài 3: Cảm xúc & Suy nghĩ", JlptLevel.N3));


            // ─── N2 LEVEL ───
            // Lesson 1
            list.add(createVocab("影響", "影 / 響 (ẢNH HƯỞNG)", "えいきょう", "eikyou", "Influence", "Ảnh hưởng",
                "影響を受ける (Chịu ảnh hưởng),悪影響を与える (Gây ảnh hưởng xấu)", "友達 từ ảnh hưởngを受ける。", "ともだちからおおきなえいきょうをうける。",
                "Chịu ảnh hưởng lớn từ bạn bè.", "Be heavily influenced by friends.", "Danh từ / Động từ nhóm 3", "Trọng âm: [0]",
                "n2_l1", "Bài 1: Xã hội & Quan hệ", JlptLevel.N2));

            list.add(createVocab("価値", "価 / 値 (GIÁ TRỊ)", "かち", "kachi", "Value", "Giá trị",
                "価値を見出す (Tìm thấy giá trị),価値観が違う (Khác nhân sinh quan)", "この古い本には高い価値がある。", "このふるいほんにはたかいかちがある。",
                "Cuốn sách cổ này có giá trị cao.", "This old book has high value.", "Danh từ", "Trọng âm: [1]",
                "n2_l1", "Bài 1: Xã hội & Quan hệ", JlptLevel.N2));

            list.add(createVocab("貢献", "貢 / 献 (CỐNG HIẾN)", "こうけん", "kouken", "Contribution", "Cống hiến",
                "社会に貢献する (Cống hiến xã hội),売さに貢献する (Đóng góp doanh số)", "新しい科学の発展に貢献する。", "あたらしいかがくのはってんにこうけんする。",
                "Đóng góp cống hiến cho sự phát triển của khoa học mới.", "Contribute to the development of new science.", "Danh từ / Động từ nhóm 3", "Trọng âm: [0]",
                "n2_l1", "Bài 1: Xã hội & Quan hệ", JlptLevel.N2));

            // Lesson 2
            list.add(createVocab("範囲", "範 / 囲 (PHẠM VI)", "はんい", "hani", "Scope / Range", "Phạm vi",
                "テストの範囲 (Phạm vi bài thi),活動範囲 (Phạm vi hoạt động)", "今回の試験の範囲はとても広いです。", "こんかいのしけんのはんいはとてもひろいです。",
                "Phạm vi của kỳ thi lần này rất rộng.", "The range of the exam this time is very wide.", "Danh từ", "Trọng âm: [1]",
                "n2_l2", "Bài 2: Khả năng & Giới hạn", JlptLevel.N2));

            list.add(createVocab("制限", "制 / 限 (CHẾ HẠN)", "せいげん", "seigen", "Limitation", "Hạn chế",
                "時間を制限する (Hạn chế thời gian),スピード制限 (Hạn chế tốc độ)", "ゲームの使用時間を制限します。", "げーむのしようじかんをせいげんします。",
                "Hạn chế thời gian sử dụng chơi game.", "Limit game usage time.", "Danh từ / Động từ nhóm 3", "Trọng âm: [0]",
                "n2_l2", "Bài 2: Khả năng & Giới hạn", JlptLevel.N2));

            list.add(createVocab("可能", "可 / 能 (KHẢ NĂNG)", "かのう", "kanou", "Possibility", "Khả thi, có thể",
                "実現可能な計画 (Kế hoạch khả thi),不可能な仕事 (Công việc bất khả thi)", "この計画は実現可能です。", "ここにしげんかのうです。",
                "Kế hoạch này hoàn toàn khả thi.", "This plan is feasible.", "Tính từ -na / Danh từ", "Trọng âm: [0]",
                "n2_l2", "Bài 2: Khả năng & Giới hạn", JlptLevel.N2));

            // Lesson 3
            list.add(createVocab("緊張", "緊 / 張 (KHẨN TRƯƠNG)", "きんちょう", "kinchou", "Nervousness", "Căng thẳng",
                "極度に緊張する (Cực kỳ căng thẳng),緊張を和らげる (Giảm căng thẳng)", "みんなの前で話す時に緊張する。", "みんなのまえではなすときにきんちょうする。",
                "Tôi bị căng thẳng khi nói trước mặt mọi người.", "I feel nervous when speaking in front of everyone.", "Danh từ / Động từ nhóm 3", "Trọng âm: [0]",
                "n2_l3", "Bài 3: Tâm trạng & Trạng thái", JlptLevel.N2));

            list.add(createVocab("我慢", "我 / 慢 (NGÃ MẠN)", "がまん", "gaman", "Patience / Endurance", "Chịu đựng",
                "痛みを我慢する (Chịu đựng cơn đau),我慢強い人 (Người kiên nhẫn)", "痛くても我慢する。", "いたくてもがまんする。",
                "Dù đau đớn tôi vẫn chịu đựng được.", "Endure even if it hurts.", "Danh từ / Động từ nhóm 3", "Trọng âm: [1]",
                "n2_l3", "Bài 3: Tâm trạng & Trạng thái", JlptLevel.N2));

            list.add(createVocab("満足", "満 / 足 (MÃN TÚC)", "まんぞく", "manzoku", "Satisfaction", "Hài lòng",
                "結果に満足する (Hài lòng với kết quả),満足度 (Mức độ hài lòng)", "今回のテストの結果に満足する。", "こんかいのてすとのけっかにまんぞくする。",
                "Tôi hài lòng với kết quả kỳ thi lần này.", "I am satisfied with this test result.", "Danh từ / Tính từ -na / Động từ nhóm 3", "Trọng âm: [1]",
                "n2_l3", "Bài 3: Tâm trạng & Trạng thái", JlptLevel.N2));


            // ─── N1 LEVEL ───
            // Lesson 1
            list.add(createVocab("圧倒的", "圧 / 倒 / 的 (ÁP ĐẢO ĐÍCH)", "あっとうてき", "attouteki", "Overwhelming", "Áp đảo",
                "圧倒的な強さ (Sức mạnh áp đảo),圧倒的に多い (Nhiều áp đảo)", "彼は圧倒的な強さで勝った。", "かれはあっとうてきなつよさでかった。",
                "Anh ấy giành chiến thắng với sức mạnh áp đảo.", "He won with overwhelming strength.", "Tính từ -na", "Trọng âm: [0]",
                "n1_l1", "Bài 1: Tư duy & Nhận thức", JlptLevel.N1));

            list.add(createVocab("懸念", "懸 / 念 (HUYỀN NIỆM)", "けねん", "kenen", "Concern", "Lo ngại",
                "懸念を表する (Bày tỏ lo ngại),懸念材料 (Yếu tố đáng lo ngại)", "将来の経済状況を懸念する。", "しょうらいのけいざいじょうきょうをけねんする。",
                "Lo ngại về tình hình kinh tế trong tương lai.", "Concern about the future economic situation.", "Danh từ / Động từ nhóm 3", "Trọng âm: [0]",
                "n1_l1", "Bài 1: Tư duy & Nhận thức", JlptLevel.N1));

            list.add(createVocab("把握", "把 / 握 (BẢ ÁC)", "はおく", "haoku", "Grasp / Understand", "Nắm bắt",
                "状況を把握する (Nắm bắt tình hình),要点を把握する (Nắm bắt ý chính)", "現状を正しく把握する必要があります。", "げんじょうをただしくはおくするひつようがあります。",
                "Cần phải nắm bắt chính xác tình hình hiện tại.", "We need to correctly grasp the current situation.", "Danh từ / Động từ nhóm 3", "Trọng âm: [0]",
                "n1_l1", "Bài 1: Tư duy & Nhận thức", JlptLevel.N1));

            // Lesson 2
            list.add(createVocab("妥協", "妥 / 協 (THỎA HIỆP)", "だきょう", "dakyou", "Compromise", "Thỏa hiệp",
                "妥協の余地がない (Không thể thỏa hiệp),安易に妥協する (Thỏa hiệp dễ dàng)", "話し合いで互いに妥協する。", "はなしあいでたがいにだきょうする。",
                "Hai bên thỏa hiệp với nhau thông qua đàm phán.", "Compromise with each other through discussion.", "Danh từ / Động từ nhóm 3", "Trọng âm: [0]",
                "n1_l2", "Bài 2: Hợp tác & Thương lượng", JlptLevel.N1));

            list.add(createVocab("交渉", "交 / 涉 (GIAO THIỆP)", "こうしょう", "koushou", "Negotiation", "Đàm phán",
                "条件を交渉する (Thương lượng điều kiện)", "新しい取引の条件を交渉します。", "あたらしいとりひきのじょうけんをこうしょうします。",
                "Đàm phán thương lượng điều kiện giao dịch mới.", "Negotiate the terms of a new transaction.", "Danh từ / Động từ nhóm 3", "Trọng âm: [0]",
                "n1_l2", "Bài 2: Hợp tác & Thương lượng", JlptLevel.N1));

            list.add(createVocab("紛争", "紛 / 争 (PHÂN TRANH)", "ふんそう", "funsou", "Dispute / Conflict", "Tranh chấp",
                "領土紛争 (Tranh chấp lãnh thổ),紛争を解決する (Giải quyết xung đột)", "二国間の紛争を平和的に解決する。", "にこくかんのふんそうをへいわてきにかいけつする。",
                "Giải quyết xung đột giữa hai quốc gia một cách hòa bình.", "Solve the conflict between two countries peacefully.", "Danh từ", "Trọng âm: [0]",
                "n1_l2", "Bài 2: Hợp tác & Thương lượng", JlptLevel.N1));

            // Lesson 3
            list.add(createVocab("極めて", "極 (CỰC)", "きわめて", "kiwamete", "Extremely", "Cực kỳ",
                "極めて重要 (Cực kỳ quan trọng),極めてまれ (Cực kỳ hiếm)", "これは極めて深刻な問題です。", "これはきわめてしんこくなもんだいです。",
                "Đây là một vấn đề cực kỳ nghiêm trọng.", "This is an extremely serious problem.", "Trạng từ", "Trọng âm: [2]",
                "n1_l3", "Bài 3: Trạng thái & Mức độ", JlptLevel.N1));

            list.add(createVocab("促進", "促 / 進 (XÚC TIẾN)", "そくしん", "sokushin", "Promotion", "Thúc đẩy",
                "販売を促進する (Thúc đẩy bán hàng),健康促進 (Nâng cao sức khỏe)", "経済の活発化を促進する。", "けいざいのかっぱつかをそくしんする。",
                "Thúc đẩy sự hoạt bát của nền kinh tế.", "Promote the revitalization of the economy.", "Danh từ / Động từ nhóm 3", "Trọng âm: [0]",
                "n1_l3", "Bài 3: Trạng thái & Mức độ", JlptLevel.N1));

            list.add(createVocab("抑制", "抑 / 制 (ỨC CHẾ)", "よくせい", "yokusei", "Suppression", "Kiềm chế",
                "感情を抑制する (Kiềm chế cảm xúc),インフレを抑制する (Kiềm chế lạm phát)", "怒りの感情を抑制する。", "いかりのかんじょうをよくせいする。",
                "Kiềm chế cảm xúc tức giận.", "Suppress feelings of anger.", "Danh từ / Động từ nhóm 3", "Trọng âm: [0]",
                "n1_l3", "Bài 3: Trạng thái & Mức độ", JlptLevel.N1));

            vocabularyRepository.saveAll(list);
        }
    }

    private Vocabulary createVocab(String word, String kanji, String reading, String romaji,
                                   String englishMeaning, String vietnameseMeaning, String collocations,
                                   String exampleSentenceJa, String exampleSentenceJaHira,
                                   String exampleSentenceVi, String exampleSentenceEn,
                                   String wordType, String pitchAccent, String lessonId, String lessonTitle, JlptLevel level) {
        Vocabulary v = new Vocabulary();
        v.setWord(word);
        v.setKanji(kanji);
        v.setReading(reading);
        v.setRomaji(romaji);
        v.setEnglishMeaning(englishMeaning);
        v.setVietnameseMeaning(vietnameseMeaning);
        v.setCollocations(collocations);
        v.setExampleSentenceJa(exampleSentenceJa);
        v.setExampleSentenceJaHira(exampleSentenceJaHira);
        v.setExampleSentenceVi(exampleSentenceVi);
        v.setExampleSentenceEn(exampleSentenceEn);
        v.setWordType(wordType);
        v.setPitchAccent(pitchAccent);
        v.setLessonId(lessonId);
        v.setLessonTitle(lessonTitle);
        v.setJlptLevel(level);
        return v;
    }
}
