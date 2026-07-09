package com.example.japanese_learning.features.news.service;

import com.example.japanese_learning.dto.request.ArticleNoteRequest;
import com.example.japanese_learning.dto.response.ArticleNoteResponse;
import com.example.japanese_learning.dto.response.NewsArticleResponse;
import com.example.japanese_learning.dto.response.NewsCategoryResponse;
import com.example.japanese_learning.dto.response.VocabularyResponse;
import com.example.japanese_learning.entity.account.NewsArticle;
import com.example.japanese_learning.entity.account.NewsCategory;
import com.example.japanese_learning.entity.account.NewsVocabulary;
import com.example.japanese_learning.entity.account.User;
import com.example.japanese_learning.entity.account.UserArticleNote;
import com.example.japanese_learning.entity.learning.Vocabulary;
import com.example.japanese_learning.features.news.repository.NewsArticleRepository;
import com.example.japanese_learning.features.news.repository.NewsCategoryRepository;
import com.example.japanese_learning.features.news.repository.NewsVocabularyRepository;
import com.example.japanese_learning.features.news.repository.UserArticleNoteRepository;
import com.example.japanese_learning.features.exam_attempt.repository.UserRepository;
import com.example.japanese_learning.features.vocab.VocabularyRepository;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
public class NewsService {

    private final NewsCategoryRepository categoryRepository;
    private final NewsArticleRepository articleRepository;
    private final NewsVocabularyRepository newsVocabularyRepository;
    private final VocabularyRepository vocabularyRepository;
    private final UserArticleNoteRepository userArticleNoteRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public List<NewsCategoryResponse> getAllCategories() {
        return categoryRepository.findAll().stream()
                .map(this::mapToCategoryResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<NewsArticleResponse> getArticlesByCategory(String categorySlug) {
        List<NewsArticle> articles;
        if (categorySlug == null || categorySlug.trim().isEmpty() || categorySlug.equalsIgnoreCase("all")) {
            articles = articleRepository.findAll();
        } else {
            articles = articleRepository.findByCategoryCategorySlug(categorySlug);
        }
        return articles.stream()
                .map(a -> mapToArticleResponse(a, false))
                .toList();
    }

    @Transactional(readOnly = true)
    public NewsArticleResponse getArticleById(Long id) {
        NewsArticle article = articleRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("News article not found with id: " + id));
        return mapToArticleResponse(article, true);
    }

    private NewsCategoryResponse mapToCategoryResponse(NewsCategory category) {
        return NewsCategoryResponse.builder()
                .id(category.getId())
                .categoryName(category.getCategoryName())
                .categorySlug(category.getCategorySlug())
                .build();
    }

    private NewsArticleResponse mapToArticleResponse(NewsArticle article, boolean isDetail) {
        if (!isDetail) {
            return NewsArticleResponse.builder()
                    .id(article.getId())
                    .categoryId(article.getCategory().getId())
                    .categorySlug(article.getCategory().getCategorySlug())
                    .title(article.getTitle())
                    .description(null)
                    .imageUrl(article.getImageUrl())
                    .audioUrl(article.getAudioUrl())
                    .contentKanjiScript(null)
                    .contentTranslation(null)
                    .createdAt(article.getCreatedAt())
                    .vocabularies(null)
                    .build();
        }

        List<NewsVocabulary> newsVocabs = newsVocabularyRepository.findByArticleId(article.getId());
        List<VocabularyResponse> vocabResponses = newsVocabs.stream()
                .map(nv -> {
                    Vocabulary v = nv.getVocabulary();
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
                })
                .toList();

        return NewsArticleResponse.builder()
                .id(article.getId())
                .categoryId(article.getCategory().getId())
                .categorySlug(article.getCategory().getCategorySlug())
                .title(article.getTitle())
                .description(article.getDescription())
                .imageUrl(article.getImageUrl())
                .audioUrl(article.getAudioUrl())
                .contentKanjiScript(article.getContentKanjiScript())
                .contentTranslation(article.getContentTranslation())
                .createdAt(article.getCreatedAt())
                .vocabularies(vocabResponses)
                .build();
    }

    @PostConstruct
    @Transactional
    public void seedNews() {
        if (categoryRepository.count() == 0) {
            // Seed Categories (exactly 4 categories)
            Map<String, String> cats = new LinkedHashMap<>();
            cats.put("Easy News", "easy-news");
            cats.put("Top", "top");
            cats.put("Chính Trị", "chinh-tri");
            cats.put("Kinh Tế", "kinh-te");

            Map<String, NewsCategory> categoryMap = new HashMap<>();
            for (Map.Entry<String, String> entry : cats.entrySet()) {
                NewsCategory cat = new NewsCategory();
                cat.setCategoryName(entry.getKey());
                cat.setCategorySlug(entry.getValue());
                cat = categoryRepository.save(cat);
                categoryMap.put(entry.getValue(), cat);
            }

            if (articleRepository.count() == 0) {
                // --- CATEGORY 1: EASY NEWS ---
                NewsArticle a1_1 = new NewsArticle();
                a1_1.setCategory(categoryMap.get("easy-news"));
                a1_1.setTitle("日本の小学校で英語の授業が増えています");
                a1_1.setDescription("日本の小学校では英語教育の強化が進んでいます。文部科学省の新しい指導方針により、早い段階から英語を話す・聞く練習が取り入れられています。子供たちはゲームや歌を通じて楽しく学習を進めています。この取り組みにより、将来の国際社会で活躍できる人材の育成が期待されています。また、外国人教師と接することで異文化理解も深まります。親たちの間でも、この教育改革を歓迎する声が非常に多くなっています。早期の英語学習は、子供たちの自信や可能性を大きく広げることでしょう。");
                a1_1.setImageUrl("https://picsum.photos/id/101/200/200");
                a1_1.setAudioUrl("https://www.w3schools.com/html/horse.mp3");
                a1_1.setContentKanjiScript("[{\"text\":\"日本\",\"furigana\":\"にほん\"},{\"text\":\"の\",\"furigana\":\"\"},{\"text\":\"小学校\",\"furigana\":\"しょうがっこう\"},{\"text\":\"で\",\"furigana\":\"\"},{\"text\":\"英語\",\"furigana\":\"えいご\"},{\"text\":\"の\",\"furigana\":\"\"},{\"text\":\"授業\",\"furigana\":\"じゅぎょう\"},{\"text\":\"が\",\"furigana\":\"\"},{\"text\":\"増えて\",\"furigana\":\"ふえて\"},{\"text\":\"います。\",\"furigana\":\"\"},{\"text\":\"文部科学省\",\"furigana\":\"もんぶかがくしょう\"},{\"text\":\"は\",\"furigana\":\"\"},{\"text\":\"新しい\",\"furigana\":\"あたらしい\"},{\"text\":\"指導\",\"furigana\":\"しどう\"},{\"text\":\"計画\",\"furigana\":\"けいかく\"},{\"text\":\"を\",\"furigana\":\"\"},{\"text\":\"始めました。\",\"furigana\":\"はじめました\"},{\"text\":\"子供\",\"furigana\":\"こども\"},{\"text\":\"たちは\",\"furigana\":\"\"},{\"text\":\"早い\",\"furigana\":\"はやい\"},{\"text\":\"段階\",\"furigana\":\"だんかい\"},{\"text\":\"から\",\"furigana\":\"\"},{\"text\":\"英語\",\"furigana\":\"えいご\"},{\"text\":\"を\",\"furigana\":\"\"},{\"text\":\"聞く\",\"furigana\":\"きく\"},{\"text\":\"練習\",\"furigana\":\"れんしゅう\"},{\"text\":\"をします。\",\"furigana\":\"\"},{\"text\":\"授業\",\"furigana\":\"じゅぎょう\"},{\"text\":\"では\",\"furigana\":\"\"},{\"text\":\"ゲーム\",\"furigana\":\"\"},{\"text\":\"や\",\"furigana\":\"\"},{\"text\":\"歌\",\"furigana\":\"うた\"},{\"text\":\"が\",\"furigana\":\"\"},{\"text\":\"使われます。\",\"furigana\":\"つかわれます\"},{\"text\":\"多くの\",\"furigana\":\"おおくの\"},{\"text\":\"親\",\"furigana\":\"おや\"},{\"text\":\"は\",\"furigana\":\"\"},{\"text\":\"この\",\"furigana\":\"\"},{\"text\":\"授業\",\"furigana\":\"じゅぎょう\"},{\"text\":\"を\",\"furigana\":\"\"},{\"text\":\"歓迎\",\"furigana\":\"かんげい\"},{\"text\":\"しています。\",\"furigana\":\"\"},{\"text\":\"外国人\",\"furigana\":\"がいこくじん\"},{\"text\":\"の\",\"furigana\":\"\"},{\"text\":\"先生\",\"furigana\":\"せんせい\"},{\"text\":\"も\",\"furigana\":\"\"},{\"text\":\"学校\",\"furigana\":\"がっこう\"},{\"text\":\"に\",\"furigana\":\"\"},{\"text\":\"来て\",\"furigana\":\"きて\"},{\"text\":\"います。\",\"furigana\":\"\"},{\"text\":\"子供\",\"furigana\":\"こども\"},{\"text\":\"たちは\",\"furigana\":\"\"},{\"text\":\"楽しく\",\"furigana\":\"たのしく\"},{\"text\":\"会話\",\"furigana\":\"かいわ\"},{\"text\":\"を\",\"furigana\":\"\"},{\"text\":\"学んで\",\"furigana\":\"まなんで\"},{\"text\":\"います。\",\"furigana\":\"\"},{\"text\":\"将来\",\"furigana\":\"しょうらい\"},{\"text\":\"の\",\"furigana\":\"\"},{\"text\":\"国際的な\",\"furigana\":\"こくさいてきな\"},{\"text\":\"活躍\",\"furigana\":\"かつやく\"},{\"text\":\"が\",\"furigana\":\"\"},{\"text\":\"期待\",\"furigana\":\"きたい\"},{\"text\":\"されています。\",\"furigana\":\"\"}]");
                a1_1.setContentTranslation("Số lượng giờ học tiếng Anh tại các trường tiểu học ở Nhật Bản đang ngày càng gia tăng. Theo hướng dẫn giảng dạy mới từ Bộ Giáo dục, Văn hóa, Thể thao, Khoa học và Công nghệ, việc luyện nghe và nói tiếng Anh đã được đưa vào từ rất sớm. Trẻ em đang học tiếng Anh một cách vui vẻ thông qua các trò chơi và bài hát. Nhiều phụ huynh đánh giá cao phương pháp này vì nó giúp trẻ tự tin giao tiếp hơn. Bên cạnh đó, các trường cũng tích cực tuyển dụng thêm giáo viên bản xứ để nâng cao chất lượng. Chương trình học mới này được kỳ vọng sẽ đào tạo nên những thế hệ trẻ năng động trong tương lai. Nhìn chung, việc đổi mới giáo dục này đang nhận được những phản hồi rất tích cực từ xã hội.");
                a1_1 = articleRepository.save(a1_1);

                NewsArticle a1_2 = new NewsArticle();
                a1_2.setCategory(categoryMap.get("easy-news"));
                a1_2.setTitle("富士山のゴミを減らすための新しいルール");
                a1_2.setDescription("富士山の美しい自然環境を守るための新しい規則が導入されました。近年、登山客の増加に伴いゴミ問題が深刻化しています。地元自治体はゴミの持ち帰りを徹底するよう求めています。ルールを守らない登山者には注意が与えられることもあります。将来世代にこの素晴らしい遺産を残すために全員の協力が必要です。ボランティアによる週末の清掃活動も各地で行われています。一人ひとりのマナーが、山の未来を守るために最も重要となります。");
                a1_2.setImageUrl("https://picsum.photos/id/102/200/200");
                a1_2.setAudioUrl("https://www.w3schools.com/html/horse.mp3");
                a1_2.setContentKanjiScript("[{\"text\":\"富士山\",\"furigana\":\"ふじさん\"},{\"text\":\"の\",\"furigana\":\"\"},{\"text\":\"ゴミ\",\"furigana\":\"\"},{\"text\":\"を\",\"furigana\":\"\"},{\"text\":\"減らす\",\"furigana\":\"へらす\"},{\"text\":\"ため、\",\"furigana\":\"\"},{\"text\":\"新しい\",\"furigana\":\"あたらしい\"},{\"text\":\"ルール\",\"furigana\":\"\"},{\"text\":\"が\",\"furigana\":\"\"},{\"text\":\"作られました。\",\"furigana\":\"\"},{\"text\":\"近年、\",\"furigana\":\"きんねん\"},{\"text\":\"登山客\",\"furigana\":\"とざんきゃく\"},{\"text\":\"の\",\"furigana\":\"\"},{\"text\":\"増加\",\"furigana\":\"ぞうか\"},{\"text\":\"で\",\"furigana\":\"\"},{\"text\":\"ゴミ問題\",\"furigana\":\"ごみもんだい\"},{\"text\":\"が\",\"furigana\":\"\"},{\"text\":\"深刻\",\"furigana\":\"しんこく\"},{\"text\":\"です。\",\"furigana\":\"\"},{\"text\":\"地元\",\"furigana\":\"じもと\"},{\"text\":\"の\",\"furigana\":\"\"},{\"text\":\"政府\",\"furigana\":\"せいふ\"},{\"text\":\"は\",\"furigana\":\"\"},{\"text\":\"ゴミの\",\"furigana\":\"\"},{\"text\":\"持ち帰り\",\"furigana\":\"もちかえり\"},{\"text\":\"を\",\"furigana\":\"\"},{\"text\":\"求めて\",\"furigana\":\"もとめて\"},{\"text\":\"います。\",\"furigana\":\"\"},{\"text\":\"多くの\",\"furigana\":\"おおくの\"},{\"text\":\"ゴミ箱\",\"furigana\":\"ごみばこ\"},{\"text\":\"が\",\"furigana\":\"\"},{\"text\":\"撤去\",\"furigana\":\"てっきょ\"},{\"text\":\"されました。\",\"furigana\":\"\"},{\"text\":\"ルールを\",\"furigana\":\"\"},{\"text\":\"守らない\",\"furigana\":\"まもらない\"},{\"text\":\"人\",\"furigana\":\"ひと\"},{\"text\":\"には\",\"furigana\":\"\"},{\"text\":\"注意\",\"furigana\":\"ちゅうい\"},{\"text\":\"が\",\"furigana\":\"\"},{\"text\":\"与えられます。\",\"furigana\":\"あたえられます\"},{\"text\":\"ボランティア\",\"furigana\":\"\"},{\"text\":\"も\",\"furigana\":\"\"},{\"text\":\"毎週\",\"furigana\":\"まいしゅう\"},{\"text\":\"掃除\",\"furigana\":\"そうじ\"},{\"text\":\"を\",\"furigana\":\"\"},{\"text\":\"しています。\",\"furigana\":\"\"},{\"text\":\"美しい\",\"furigana\":\"うつくしい\"},{\"text\":\"自然\",\"furigana\":\"しぜん\"},{\"text\":\"環境\",\"furigana\":\"かんきょう\"},{\"text\":\"を\",\"furigana\":\"\"},{\"text\":\"残す\",\"furigana\":\"のこす\"},{\"text\":\"ことが\",\"furigana\":\"\"},{\"text\":\"大切\",\"furigana\":\"たいせつ\"},{\"text\":\"です。\",\"furigana\":\"\"},{\"text\":\"みんなで\",\"furigana\":\"\"},{\"text\":\"山\",\"furigana\":\"やま\"},{\"text\":\"を\",\"furigana\":\"\"},{\"text\":\"守りましょう。\",\"furigana\":\"まもりましょう\"}]");
                a1_2.setContentTranslation("Các quy định mới đã được ban hành nhằm giảm lượng rác thải trên núi Phú Sĩ. Trong những năm gần đây, vấn đề rác thải trở nên nghiêm trọng do lượng khách leo núi tăng nhanh. Chính quyền địa phương đang kêu gọi du khách thực hiện nghiêm túc việc tự mang rác về. Nhiều thùng rác công cộng đã bị dỡ bỏ để khuyến khích ý thức tự giác của mỗi người. Những người leo núi không tuân thủ quy định có thể sẽ bị nhắc nhở và cảnh cáo. Các tình nguyện viên cũng tích cực dọn dẹp hàng tuần để giữ gìn cảnh quan. Việc bảo vệ môi trường tự nhiên xinh đẹp này để truyền lại cho thế hệ mai sau là vô cùng quan trọng. Hãy cùng chung tay bảo vệ ngọn núi biểu tượng của đất nước Nhật Bản.");
                a1_2 = articleRepository.save(a1_2);

                NewsArticle a1_3 = new NewsArticle();
                a1_3.setCategory(categoryMap.get("easy-news"));
                a1_3.setTitle("桜の開花が例年より早くなる見込みです");
                a1_3.setDescription("今年の桜の開花時期は全国的に例年より早まると予想されています。気象庁の長期予報によると、冬の平均気温が高かったことが主な要因です。開花が早まることで、お花見の計画を前倒しする人々が増えています。全国各地の観光地では、桜祭りの準備を急いで進めています。多くの観光客が美しい桜を楽しみにしています。旅行会社も新しい観光ツアーの日程調整に追われています。家族や友人と一緒に、素晴らしい春のひとときを計画しましょう。");
                a1_3.setImageUrl("https://picsum.photos/id/103/200/200");
                a1_3.setContentKanjiScript("[{\"text\":\"今年\",\"furigana\":\"ことし\"},{\"text\":\"の\",\"furigana\":\"\"},{\"text\":\"桜\",\"furigana\":\"さくら\"},{\"text\":\"の\",\"furigana\":\"\"},{\"text\":\"開花\",\"furigana\":\"かいか\"},{\"text\":\"は、\",\"furigana\":\"\"},{\"text\":\"例年\",\"furigana\":\"れいねん\"},{\"text\":\"より\",\"furigana\":\"\"},{\"text\":\"早く\",\"furigana\":\"はやく\"},{\"text\":\"なる\",\"furigana\":\"\"},{\"text\":\"見込み\",\"furigana\":\"みこみ\"},{\"text\":\"です。\",\"furigana\":\"\"},{\"text\":\"冬の\",\"furigana\":\"ふゆの\"},{\"text\":\"気温が\",\"furigana\":\"きおんが\"},{\"text\":\"高かった\",\"furigana\":\"たかかった\"},{\"text\":\"ことが\",\"furigana\":\"\"},{\"text\":\"原因\",\"furigana\":\"げんいん\"},{\"text\":\"です。\",\"furigana\":\"\"},{\"text\":\"人々は\",\"furigana\":\"ひとびとは\"},{\"text\":\"お花見の\",\"furigana\":\"おはなみの\"},{\"text\":\"計画を\",\"furigana\":\"けいかくを\"},{\"text\":\"早く\",\"furigana\":\"はやく\"},{\"text\":\"準備\",\"furigana\":\"じゅんび\"},{\"text\":\"しています。\",\"furigana\":\"\"},{\"text\":\"観光地\",\"furigana\":\"かんこうち\"},{\"text\":\"では\",\"furigana\":\"\"},{\"text\":\"祭り\",\"furigana\":\"まつり\"},{\"text\":\"の\",\"furigana\":\"\"},{\"text\":\"準備が\",\"furigana\":\"じゅんびが\"},{\"text\":\"進んでいます。\",\"furigana\":\"\"},{\"text\":\"旅行会社\",\"furigana\":\"りょこうがいしゃ\"},{\"text\":\"も\",\"furigana\":\"\"},{\"text\":\"ツアーを\",\"furigana\":\"\"},{\"text\":\"変更\",\"furigana\":\"へんこう\"},{\"text\":\"しています。\",\"furigana\":\"\"},{\"text\":\"みんな\",\"furigana\":\"\"},{\"text\":\"美しい\",\"furigana\":\"うつくしい\"},{\"text\":\"景色を\",\"furigana\":\"けしきを\"},{\"text\":\"楽しみに\",\"furigana\":\"たのしみに\"},{\"text\":\"しています。\",\"furigana\":\"\"},{\"text\":\"桜の\",\"furigana\":\"さくらの\"},{\"text\":\"季節は\",\"furigana\":\"きせつは\"},{\"text\":\"とても\",\"furigana\":\"\"},{\"text\":\"にぎやかに\",\"furigana\":\"\"},{\"text\":\"なります。\",\"furigana\":\"\"},{\"text\":\"家族と\",\"furigana\":\"かぞくと\"},{\"text\":\"一緒に\",\"furigana\":\"いっしょに\"},{\"text\":\"計画を\",\"furigana\":\"けいかくを\"},{\"text\":\"立てましょう。\",\"furigana\":\"たてましょう\"}]");
                a1_3.setContentTranslation("Hoa anh đào năm nay dự kiến sẽ nở sớm hơn so với trung bình mọi năm. Theo dự báo dài hạn từ Cơ quan Khí tượng, nguyên nhân chủ yếu là do nhiệt độ trung bình mùa đông năm nay cao hơn. Việc hoa nở sớm khiến nhiều người phải thay đổi và đẩy sớm kế hoạch đi ngắm hoa của mình. Tại các danh lam thắng cảnh trên toàn quốc, công tác chuẩn bị cho lễ hội hoa anh đào đang được khẩn trương tiến hành. Các doanh nghiệp lữ hành cũng nhanh chóng cập nhật lịch trình tour mới để phục vụ du khách. Nhiều người bày tỏ sự háo hức được ngắm nhìn sắc hồng rực rỡ của những cánh hoa đào. Nhìn chung, mùa hoa anh đào năm nay hứa hẹn sẽ mang lại bầu không khí vô cùng sôi động. Hãy cùng gia đình chuẩn bị những kế hoạch thật hoàn hảo cho chuyến đi ngắm hoa nhé.");
                a1_3 = articleRepository.save(a1_3);

                // --- CATEGORY 2: TOP ---
                NewsArticle a2_1 = new NewsArticle();
                a2_1.setCategory(categoryMap.get("top"));
                a2_1.setTitle("日本のAI技術的最前線と将来の展望");
                a2_1.setDescription("日本では人工知能の技術開発が急速に進められています。医療現場では、AIによる診断支援システムがすでに導入され始めています。また、高齢者の介護をサポートするロボットの共同開発も活発です。これらの技術は労働力不足を解決する手段として大いに期待されています。政府も関連産業の発展に向けて法的・資金的な支援を強化しています。今後の自動化の流れは、人々の働き方を大きく変える可能性があります。最新技術の恩恵を受けながら、社会全体で新しい未来を築く必要があります。");
                a2_1.setImageUrl("https://picsum.photos/id/104/200/200");
                a2_1.setContentKanjiScript("[{\"text\":\"人工知能\",\"furigana\":\"じんこうちのう\"},{\"text\":\"の\",\"furigana\":\"\"},{\"text\":\"技術\",\"furigana\":\"ぎじゅつ\"},{\"text\":\"は、\",\"furigana\":\"\"},{\"text\":\"日本で\",\"furigana\":\"にほんで\"},{\"text\":\"急速に\",\"furigana\":\"きゅうそくに\"},{\"text\":\"進歩\",\"furigana\":\"しんぽ\"},{\"text\":\"しています。\",\"furigana\":\"\"},{\"text\":\"病院\",\"furigana\":\"びょういん\"},{\"text\":\"では\",\"furigana\":\"\"},{\"text\":\"診断\",\"furigana\":\"しんだん\"},{\"text\":\"システム\",\"furigana\":\"\"},{\"text\":\"が\",\"furigana\":\"\"},{\"text\":\"使われて\",\"furigana\":\"つかわれて\"},{\"text\":\"います。\",\"furigana\":\"\"},{\"text\":\"介護を\",\"furigana\":\"かいごを\"},{\"text\":\"支援する\",\"furigana\":\"しえんする\"},{\"text\":\"ロボットも\",\"furigana\":\"\"},{\"text\":\"開発中\",\"furigana\":\"かいはつちゅう\"},{\"text\":\"です。\",\"furigana\":\"\"},{\"text\":\"労働力\",\"furigana\":\"ろうどうりょく\"},{\"text\":\"不足を\",\"furigana\":\"ぶそくを\"},{\"text\":\"解決する\",\"furigana\":\"かいけつする\"},{\"text\":\"ことが\",\"furigana\":\"\"},{\"text\":\"期待\",\"furigana\":\"きたい\"},{\"text\":\"されています。\",\"furigana\":\"\"},{\"text\":\"政府は\",\"furigana\":\"せいふは\"},{\"text\":\"企業への\",\"furigana\":\"きぎょうへの\"},{\"text\":\"支援を\",\"furigana\":\"しえんを\"},{\"text\":\"強化して\",\"furigana\":\"きょうかして\"},{\"text\":\"います。\",\"furigana\":\"\"},{\"text\":\"市場は\",\"furigana\":\"しじょうは\"},{\"text\":\"今後さらに\",\"furigana\":\"こんごさらに\"},{\"text\":\"拡大する\",\"furigana\":\"かくだいする\"},{\"text\":\"見込みです。\",\"furigana\":\"\"},{\"text\":\"生活が\",\"furigana\":\"せいかつが\"},{\"text\":\"便利に\",\"furigana\":\"べんりに\"},{\"text\":\"なることを\",\"furigana\":\"\"},{\"text\":\"みんな\",\"furigana\":\"\"},{\"text\":\"期待して\",\"furigana\":\"きたいして\"},{\"text\":\"います。\",\"furigana\":\"\"},{\"text\":\"技術の\",\"furigana\":\"ぎじゅつの\"},{\"text\":\"発展は\",\"furigana\":\"はってんは\"},{\"text\":\"未来の\",\"furigana\":\"みらいの\"},{\"text\":\"鍵です。\",\"furigana\":\"かぎです\"}]");
                a2_1.setContentTranslation("Công nghệ trí tuệ nhân tạo (AI) tại Nhật Bản đang phát triển vô cùng nhanh chóng. Tại các bệnh viện, hệ thống hỗ trợ chẩn đoán hình ảnh bằng AI đã bắt đầu được đưa vào sử dụng. Bên cạnh đó, việc phát triển các robot hỗ trợ chăm sóc người cao tuổi cũng đang diễn ra rất sôi nổi. Những công nghệ này được kỳ vọng sẽ là giải pháp hiệu quả cho tình trạng thiếu hụt lao động nghiêm trọng. Chính phủ Nhật Bản cũng đang tăng cường hỗ trợ vốn và hành lang pháp lý cho ngành công nghiệp này. Các chuyên gia dự báo rằng thị trường AI sẽ còn tăng trưởng mạnh mẽ hơn nữa trong thập kỷ tới. Người dân hy vọng rằng cuộc sống sẽ trở nên tiện lợi và an toàn hơn nhờ vào công nghệ mới này. Tóm lại, việc làm chủ công nghệ AI đóng vai trò vô cùng quan trọng đối với tương lai phát triển bền vững.");
                a2_1 = articleRepository.save(a2_1);

                NewsArticle a2_2 = new NewsArticle();
                a2_2.setCategory(categoryMap.get("top"));
                a2_2.setTitle("東京での国際技術カンファレンスが盛大に開幕");
                a2_2.setDescription("世界中から最先端の技術者が集まる国際カンファレンスが東京で開幕しました。環境問題の解決を目指す新しいグリーンテクノロジーが数多く展示されています。初日から多くの企業経営者や学生が会場を訪れ、情報交換を行いました。参加者は最新の研究成果についての議論を熱心に交わしています。このイベントは新たなイノベーションを生む重要な場となっています。海外のベンチャー企業と日本の大企業との提携も数多く発表されました。５日間の会期中には、さらなるビジネスチャンスが期待されています。");
                a2_2.setImageUrl("https://picsum.photos/id/105/200/200");
                a2_2.setContentKanjiScript("[{\"text\":\"東京で\",\"furigana\":\"とうきょうで\"},{\"text\":\"国際的な\",\"furigana\":\"こくさいてきな\"},{\"text\":\"技術\",\"furigana\":\"ぎじゅつ\"},{\"text\":\"会議が\",\"furigana\":\"かいぎが\"},{\"text\":\"始まりました。\",\"furigana\":\"はじまりました\"},{\"text\":\"新しい\",\"furigana\":\"あたらしい\"},{\"text\":\"環境\",\"furigana\":\"かんきょう\"},{\"text\":\"技術が\",\"furigana\":\"ぎじゅつが\"},{\"text\":\"多く\",\"furigana\":\"おおく\"},{\"text\":\"展示されて\",\"furigana\":\"てんじされて\"},{\"text\":\"います。\",\"furigana\":\"\"},{\"text\":\"多くの\",\"furigana\":\"おおくの\"},{\"text\":\"企業と\",\"furigana\":\"きぎょうと\"},{\"text\":\"学生が\",\"furigana\":\"がくせいが\"},{\"text\":\"会場を\",\"furigana\":\"かいじょうを\"},{\"text\":\"訪れました。\",\"furigana\":\"おとずれました\"},{\"text\":\"参加者は\",\"furigana\":\"さんかしゃは\"},{\"text\":\"熱心に\",\"furigana\":\"ねっしんに\"},{\"text\":\"議論を\",\"furigana\":\"ぎろんを\"},{\"text\":\"しています。\",\"furigana\":\"\"},{\"text\":\"新しい\",\"furigana\":\"あたらしい\"},{\"text\":\"ビジネスの\",\"furigana\":\"\"},{\"text\":\"機会が\",\"furigana\":\"きかいが\"},{\"text\":\"生まれて\",\"furigana\":\"うまれて\"},{\"text\":\"います。\",\"furigana\":\"\"},{\"text\":\"多くの\",\"furigana\":\"おおくの\"},{\"text\":\"契約が\",\"furigana\":\"けいやくが\"},{\"text\":\"ここで\",\"furigana\":\"\"},{\"text\":\"結ばれました。\",\"furigana\":\"むすばれました\"},{\"text\":\"未来の\",\"furigana\":\"みらいの\"},{\"text\":\"ための\",\"furigana\":\"\"},{\"text\":\"イノベーションの\",\"furigana\":\"\"},{\"text\":\"場所です。\",\"furigana\":\"ばしょです\"},{\"text\":\"会議は\",\"furigana\":\"かいぎは\"},{\"text\":\"五日間\",\"furigana\":\"いつかかん\"},{\"text\":\"続けられます。\",\"furigana\":\"つづけられます\"}]");
                a2_2.setContentTranslation("Hội nghị công nghệ quốc tế quy tụ các chuyên gia hàng đầu thế giới đã chính thức khai mạc tại Tokyo. Tại đây, rất nhiều công nghệ xanh mới nhằm giải quyết vấn đề biến đổi khí hậu đã được trưng bày. Ngay từ ngày đầu tiên, đông đảo các nhà quản lý doanh nghiệp và sinh viên đã đến tham quan. Khách tham gia thảo luận rất sôi nổi về các kết quả nghiên cứu và ứng dụng thực tiễn mới nhất. Các công ty khởi nghiệp cũng tận dụng cơ hội này để tìm kiếm nhà đầu tư tiềm năng. Nhiều biên bản ghi nhớ hợp tác chiến lược đã được ký kết ngay tại sự kiện. Hội nghị được đánh giá là một bệ phóng quan trọng cho những sáng kiến đổi mới sáng tạo trong tương lai. Sự kiện này sẽ tiếp tục diễn ra trong vòng 5 ngày tới với nhiều hoạt động hấp dẫn.");
                a2_2 = articleRepository.save(a2_2);

                NewsArticle a2_3 = new NewsArticle();
                a2_3.setCategory(categoryMap.get("top"));
                a2_3.setTitle("若者の地方移住が増加、新たなライフスタイルへ");
                a2_3.setDescription("都会から自然豊かな田舎へ移住する若者が増加傾向にあります。ＩＴの普及により場所を選ばずに仕事ができるようになったことが理由です。地方都市は移住者を歓迎するため、家賃支援や子育て支援を提供しています。豊かな自然に囲まれた静かな生活は若者たちの満足度を高めています。地域住民との交流を通じて、地元の伝統的なお祭りや文化を守る活動も行われています。このような新しいライフスタイルは、都市の集中を和らげる効果もあります。田舎での農業体験などを通じて、自然の素晴らしさを再発見する人もいます。");
                a2_3.setImageUrl("https://picsum.photos/id/106/200/200");
                a2_3.setAudioUrl("https://www.w3schools.com/html/horse.mp3");
                a2_3.setContentKanjiScript("[{\"text\":\"都会から\",\"furigana\":\"とかいから\"},{\"text\":\"地方へ\",\"furigana\":\"ちほうへ\"},{\"text\":\"移住する\",\"furigana\":\"いじゅうする\"},{\"text\":\"若者が\",\"furigana\":\"わかものが\"},{\"text\":\"増えています。\",\"furigana\":\"ふえています\"},{\"text\":\"リモートワークの\",\"furigana\":\"\"},{\"text\":\"普及が\",\"furigana\":\"ふきゅうが\"},{\"text\":\"その\",\"furigana\":\"\"},{\"text\":\"原因です。\",\"furigana\":\"げんいんです\"},{\"text\":\"地元の\",\"furigana\":\"じもとの\"},{\"text\":\"政府は\",\"furigana\":\"せいふは\"},{\"text\":\"家賃などの\",\"furigana\":\"やちんなどの\"},{\"text\":\"支援を\",\"furigana\":\"しえんを\"},{\"text\":\"提供しています。\",\"furigana\":\"ていきょうしています\"},{\"text\":\"自然の中での\",\"furigana\":\"しぜんのなかでの\"},{\"text\":\"静かな\",\"furigana\":\"しずかな\"},{\"text\":\"生活は\",\"furigana\":\"せいかつは\"},{\"text\":\"満足度が\",\"furigana\":\"まんぞくどが\"},{\"text\":\"高いです。\",\"furigana\":\"たかいです\"},{\"text\":\"野菜を\",\"furigana\":\"やさいを\"},{\"text\":\"自分で\",\"furigana\":\"じぶんで\"},{\"text\":\"育てる\",\"furigana\":\"そだてる\"},{\"text\":\"人も\",\"furigana\":\"ひとも\"},{\"text\":\"います。\",\"furigana\":\"\"},{\"text\":\"近所の人との\",\"furigana\":\"きんじょのひととの\"},{\"text\":\"交流も\",\"furigana\":\"こうりゅうも\"},{\"text\":\"深まっています。\",\"furigana\":\"ふかまっています\"},{\"text\":\"地元の\",\"furigana\":\"じもとの\"},{\"text\":\"伝統的な\",\"furigana\":\"でんとうてきな\"},{\"text\":\"祭りを\",\"furigana\":\"まつりを\"},{\"text\":\"守る\",\"furigana\":\"まもる\"},{\"text\":\"活動も\",\"furigana\":\"かつどうも\"},{\"text\":\"あります。\",\"furigana\":\"\"},{\"text\":\"これは\",\"furigana\":\"\"},{\"text\":\"新しい\",\"furigana\":\"あたらしい\"},{\"text\":\"生き方として\",\"furigana\":\"いきかたとして\"},{\"text\":\"注目されています。\",\"furigana\":\"ちゅうもくされています\"}]");
                a2_3.setContentTranslation("Số lượng người trẻ chuyển từ các đô thị lớn về các vùng nông thôn trù phú đang ngày một gia tăng. Nguyên nhân chính là do sự phổ biến của hình thức làm việc từ xa giúp họ có thể làm việc ở bất cứ đâu. Các chính quyền địa phương tích cực hỗ trợ tiền thuê nhà và dịch vụ chăm sóc trẻ để chào đón cư dân mới. Cuộc sống bình yên giữa thiên nhiên trong lành mang lại cho họ sự thư thái và hài lòng cao. Nhiều người đã bắt đầu tự trồng trọt rau quả hữu cơ phục vụ cho nhu cầu gia đình. Mối quan hệ gắn kết với cộng đồng địa phương giúp họ cảm thấy ấm áp và bớt cô đơn. Đồng thời, họ cũng đóng góp sức trẻ vào việc giữ gìn các lễ hội truyền thống của làng quê. Đây được coi là một xu hướng sống mới mẻ, tích cực và cân bằng cho thế hệ tương lai.");
                a2_3 = articleRepository.save(a2_3);

                // --- CATEGORY 3: CHÍNH TRỊ ---
                NewsArticle a3_1 = new NewsArticle();
                a3_1.setCategory(categoryMap.get("chinh-tri"));
                a3_1.setTitle("環境保護に向けた新しい法律案が国会で審議開始");
                a3_1.setDescription("温室効果ガスの排出量を大幅に削減するための新しい法律案が国会に提出されました。この法案には、企業に対する再生可能エネルギーの導入義務付けが含まれています。野党は中小企業への負担が大きすぎると指摘し、より慎重な議論を求めています。政府は２０３０年までの目標達成にはこの法律が不可欠だと主張しています。国民の間でも地球環境問題への関心が非常に高まっています。各地で市民団体による支持のデモも行われています。今月末に予定されている最終投票の結果が非常に注目されています。");
                a3_1.setImageUrl("https://picsum.photos/id/107/200/200");
                a3_1.setContentKanjiScript("[{\"text\":\"環境を\",\"furigana\":\"かんきょうを\"},{\"text\":\"守る\",\"furigana\":\"まもる\"},{\"text\":\"ための\",\"furigana\":\"\"},{\"text\":\"新しい\",\"furigana\":\"あたらしい\"},{\"text\":\"法律案が\",\"furigana\":\"ほうりつあんが\"},{\"text\":\"提出されました。\",\"furigana\":\"ていしゅつされました\"},{\"text\":\"企業に\",\"furigana\":\"きぎょうに\"},{\"text\":\"再生可能\",\"furigana\":\"さいせいかのう\"},{\"text\":\"エネルギーの\",\"furigana\":\"\"},{\"text\":\"使用を\",\"furigana\":\"しようを\"},{\"text\":\"求めます。\",\"furigana\":\"もとめます\"},{\"text\":\"反対派は\",\"furigana\":\"はんたいはは\"},{\"text\":\"中小企業への\",\"furigana\":\"ちゅうしょうきぎょうへの\"},{\"text\":\"負担を\",\"furigana\":\"ふたんを\"},{\"text\":\"心配しています。\",\"furigana\":\"しんぱいしています\"},{\"text\":\"政府は\",\"furigana\":\"せいふは\"},{\"text\":\"２０３０年の\",\"furigana\":\"にせんさんじゅうねんの\"},{\"text\":\"目標に\",\"furigana\":\"もくひょうに\"},{\"text\":\"必要だと\",\"furigana\":\"ひつようだと\"},{\"text\":\"主張しています。\",\"furigana\":\"しゅちょうしています\"},{\"text\":\"国民の\",\"furigana\":\"こくみんの\"},{\"text\":\"地球温暖化への\",\"furigana\":\"ちきゅうおんだんかへの\"},{\"text\":\"関心は\",\"furigana\":\"かんしんは\"},{\"text\":\"高いです。\",\"furigana\":\"たかいです\"},{\"text\":\"各地で\",\"furigana\":\"かくちで\"},{\"text\":\"環境運動が\",\"furigana\":\"かんきょううんどうが\"},{\"text\":\"行われて\",\"furigana\":\"おこなわれて\"},{\"text\":\"います。\",\"furigana\":\"\"},{\"text\":\"国会での\",\"furigana\":\"こっかいでの\"},{\"text\":\"真剣な\",\"furigana\":\"しんけんな\"},{\"text\":\"議論が\",\"furigana\":\"ぎろんが\"},{\"text\":\"続いています。\",\"furigana\":\"つづいています\"},{\"text\":\"今月末に\",\"furigana\":\"こんげつまつに\"},{\"text\":\"投票が\",\"furigana\":\"とうひょうが\"},{\"text\":\"行われる\",\"furigana\":\"おこなわれる\"},{\"text\":\"予定です。\",\"furigana\":\"よていです\"}]");
                a3_1.setContentTranslation("Một dự luật mới nhằm cắt giảm mạnh mẽ lượng khí thải nhà kính đã chính thức được trình lên Quốc hội. Dự luật này đưa ra các điều khoản bắt buộc doanh nghiệp phải chuyển sang sử dụng năng lượng tái tạo. Tuy nhiên, các đảng đối lập cho rằng gánh nặng tài chính đối với các doanh nghiệp vừa và nhỏ là quá lớn. Họ yêu cầu phải tổ chức thêm nhiều phiên điều trần để thảo luận kỹ lưỡng hơn. Trong khi đó, Chính phủ khẳng định luật này là bắt buộc nếu muốn đạt mục tiêu cắt giảm vào năm 2030. Người dân cũng đang bày tỏ sự quan tâm đặc biệt tới các vấn đề biến đổi khí hậu toàn cầu. Nhiều cuộc biểu tình ôn hòa ủng hộ dự luật đã diễn ra tại trung tâm thủ đô. Quốc hội dự kiến sẽ tiến hành bỏ phiếu thông qua vào cuối tháng này sau khi hoàn tất thảo luận.");
                a3_1 = articleRepository.save(a3_1);

                NewsArticle a3_2 = new NewsArticle();
                a3_2.setCategory(categoryMap.get("chinh-tri"));
                a3_2.setTitle("外交関係の強化に向けた首脳会談の成果");
                a3_2.setDescription("二国間の関係をさらに深めるため、両国の首相による公式会談が行われました。貿易の自由化や投資の拡大について具体的な合意が交わされました。また、安全保障分野における共同訓練の実施についても合意に達しました。両首脳は地域の平和と安定に協力して貢献する姿勢を強調しています。この会談は今後の外交関係に大きな好影響を与えるものと期待されています。多くのメディアが今回の会談結果を速報で大きく報じました。経済界からも、新しい貿易協定の進展に対する歓迎の声が上がっています。");
                a3_2.setImageUrl("https://picsum.photos/id/108/200/200");
                a3_2.setContentKanjiScript("[{\"text\":\"両国の\",\"furigana\":\"りょうこくの\"},{\"text\":\"首相による\",\"furigana\":\"しゅしょうによる\"},{\"text\":\"首脳会談が\",\"furigana\":\"しゅのうかいだんが\"},{\"text\":\"行われました。\",\"furigana\":\"おこなわれました\"},{\"text\":\"貿易の\",\"furigana\":\"ぼうえきの\"},{\"text\":\"自由化や\",\"furigana\":\"じゆうかや\"},{\"text\":\"投資の\",\"furigana\":\"とうしの\"},{\"text\":\"拡大について\",\"furigana\":\"かくだいについて\"},{\"text\":\"合意しました。\",\"furigana\":\"ごういしました\"},{\"text\":\"安全\",\"furigana\":\"あんぜん\"},{\"text\":\"保障での\",\"furigana\":\"ほしょうでの\"},{\"text\":\"共同訓練の\",\"furigana\":\"きょうどうくんれんの\"},{\"text\":\"実施も\",\"furigana\":\"じっしも\"},{\"text\":\"決定しました。\",\"furigana\":\"けっていしました\"},{\"text\":\"地域の\",\"furigana\":\"ちいきの\"},{\"text\":\"平和と\",\"furigana\":\"へいわと\"},{\"text\":\"安定に\",\"furigana\":\"あんていに\"},{\"text\":\"協力する\",\"furigana\":\"きょうりょくする\"},{\"text\":\"姿勢を\",\"furigana\":\"しせいを\"},{\"text\":\"示しました。\",\"furigana\":\"しめしました\"},{\"text\":\"メディアも\",\"furigana\":\"\"},{\"text\":\"この会談の\",\"furigana\":\"かいだんの\"},{\"text\":\"結果に\",\"furigana\":\"けっかに\"},{\"text\":\"注目しています。\",\"furigana\":\"ちゅうもくしています\"},{\"text\":\"外交的な\",\"furigana\":\"がいこうてきな\"},{\"text\":\"大きな\",\"furigana\":\"おおきな\"},{\"text\":\"成果として\",\"furigana\":\"せいかとして\"},{\"text\":\"評価されています。\",\"furigana\":\"ひょうかされています\"},{\"text\":\"企業も\",\"furigana\":\"きぎょうも\"},{\"text\":\"新しい\",\"furigana\":\"あたらしい\"},{\"text\":\"事業の\",\"furigana\":\"じぎょうの\"},{\"text\":\"チャンスを\",\"furigana\":\"\"},{\"text\":\"期待しています。\",\"furigana\":\"きたいしています\"},{\"text\":\"最後に\",\"furigana\":\"さいごに\"},{\"text\":\"共同声明が\",\"furigana\":\"きょうどうせいめいが\"},{\"text\":\"発表されました。\",\"furigana\":\"はっぴょうされました\"}]");
                a3_2.setContentTranslation("Thủ tướng hai nước đã tiến hành cuộc hội đàm chính thức nhằm làm sâu sắc hơn nữa mối quan hệ song phương. Hai bên đã đạt được nhiều thỏa thuận cụ thể về tự do hóa thương mại và mở rộng quy mô đầu tư. Ngoài ra, việc hợp tác triển khai các cuộc tập trận chung trong lĩnh vực an ninh quốc phòng cũng được thống nhất. Hai nhà lãnh đạo nhấn mạnh tầm quan trọng của việc chung tay đóng góp vào hòa bình khu vực. Sự kiện này thu hút sự quan tâm theo dõi sát sao từ giới truyền thông quốc tế. Các nhà phân tích đánh giá đây là một bước đi mang tính đột phá lớn trong ngoại giao. Doanh nghiệp hai nước cũng kỳ vọng sẽ có thêm nhiều dự án hợp tác đầu tư quy mô lớn. Cuộc hội đàm kết thúc bằng một tuyên bố chung khẳng định cam kết hợp tác lâu dài.");
                a3_2 = articleRepository.save(a3_2);

                NewsArticle a3_3 = new NewsArticle();
                a3_3.setCategory(categoryMap.get("chinh-tri"));
                a3_3.setTitle("少子高齢化対策における新たな支援制度");
                a3_3.setDescription("政府は急速に進む少子化に歯止めをかけるため、新たな支援策を決定しました。子育て世帯に対する直接的な現金給付の額が増やされる方針です。また、働く親が安心して子供を預けられる保育施設の建設も進められます。若い世代からはこの政策に対して賛同の声が多く上がっています。しかし、財源をどのように確保するかという課題も残されています。消費税率の引き上げを懸念する専門家も少なくありません。来年からの本格的な実施に向けて、さらに詳細な議論が必要とされています。");
                a3_3.setImageUrl("https://picsum.photos/id/109/200/200");
                a3_3.setContentKanjiScript("[{\"text\":\"政府は\",\"furigana\":\"せいふは\"},{\"text\":\"少子化を\",\"furigana\":\"しょうしかを\"},{\"text\":\"防ぐ\",\"furigana\":\"ふせぐ\"},{\"text\":\"ための\",\"furigana\":\"\"},{\"text\":\"新しい\",\"furigana\":\"あたらしい\"},{\"text\":\"政策を\",\"furigana\":\"せいさくを\"},{\"text\":\"発表しました。\",\"furigana\":\"はっぴょうしました\"},{\"text\":\"子育て\",\"furigana\":\"こそだて\"},{\"text\":\"世帯への\",\"furigana\":\"せたいへの\"},{\"text\":\"現金\",\"furigana\":\"げんきん\"},{\"text\":\"給付が\",\"furigana\":\"きゅうふが\"},{\"text\":\"増額されます。\",\"furigana\":\"ぞうがくされます\"},{\"text\":\"働く\",\"furigana\":\"はたらく\"},{\"text\":\"親のための\",\"furigana\":\"おやのための\"},{\"text\":\"保育施設も\",\"furigana\":\"ほいくしせつも\"},{\"text\":\"増やされます。\",\"furigana\":\"ふやされます\"},{\"text\":\"若い\",\"furigana\":\"わかい\"},{\"text\":\"世代からは\",\"furigana\":\"せだいからは\"},{\"text\":\"歓迎の\",\"furigana\":\"かんげいの\"},{\"text\":\"声が\",\"furigana\":\"こえが\"},{\"text\":\"上がっています。\",\"furigana\":\"あがっています\"},{\"text\":\"財源を\",\"furigana\":\"ざいげんを\"},{\"text\":\"どのように\",\"furigana\":\"\"},{\"text\":\"集めるかが\",\"furigana\":\"あつめるかが\"},{\"text\":\"大きな\",\"furigana\":\"おおきな\"},{\"text\":\"問題です。\",\"furigana\":\"もんだいです\"},{\"text\":\"消費税の\",\"furigana\":\"しょうひぜいの\"},{\"text\":\"増税などの\",\"furigana\":\"ぞうぜいなどの\"},{\"text\":\"意見も\",\"furigana\":\"いけんも\"},{\"text\":\"出ています。\",\"furigana\":\"でています\"},{\"text\":\"テレビや\",\"furigana\":\"\"},{\"text\":\"ネットで\",\"furigana\":\"\"},{\"text\":\"活発な\",\"furigana\":\"かっぱつな\"},{\"text\":\"議論が\",\"furigana\":\"ぎろんが\"},{\"text\":\"あります。\",\"furigana\":\"\"},{\"text\":\"新制度は\",\"furigana\":\"しんせいどは\"},{\"text\":\"来年から\",\"furigana\":\"らいねんから\"},{\"text\":\"実施される\",\"furigana\":\"じっしされる\"},{\"text\":\"予定です。\",\"furigana\":\"よていです\"}]");
                a3_3.setContentTranslation("Chính phủ vừa thông qua một loạt biện pháp hỗ trợ mới nhằm hạn chế tình trạng giảm tỷ lệ sinh nghiêm trọng. Theo đó, mức hỗ trợ bằng tiền mặt trực tiếp cho các gia đình đang nuôi con nhỏ sẽ được tăng lên đáng kể. Đồng thời, các dự án xây dựng thêm nhà trẻ công lập chất lượng cao cũng sẽ được khẩn trương triển khai. Nhiều phụ huynh trẻ bày tỏ sự ủng hộ nhiệt tình đối với những chính sách thiết thực này. Tuy nhiên, giới chuyên gia vẫn lo ngại về vấn đề làm thế nào để đảm bảo nguồn ngân sách lâu dài. Một số ý kiến đề xuất cần tăng thuế tiêu dùng để bù đắp vào phần thiếu hụt này. Các cuộc thảo luận công khai về vấn đề này đang diễn ra rất sôi nổi trên khắp cả nước. Dự kiến các chính sách mới này sẽ chính thức đi vào cuộc sống từ đầu năm tới.");
                a3_3 = articleRepository.save(a3_3);

                // --- CATEGORY 4: KINH TẾ ---
                NewsArticle a4_1 = new NewsArticle();
                a4_1.setCategory(categoryMap.get("kinh-te"));
                a4_1.setTitle("EV（電気自動車）市場の拡大と自動車産業の変化");
                a4_1.setDescription("世界的な環境意識の高まりを受け、電気自動車の普及が加速しています。国内外の自動車メーカーは新型ＥＶの開発競争を激化させています。特に走行距離を伸ばすための電池技術の開発が最優先されています。ガソリン車の販売禁止を目指す各国の動きもこの流れを後押ししています。今後の自動車業界の勢力図が大きく変わることが予想されます。さらに、都市部での充電インフラの整備も急速に進められています。消費者がより購入しやすい価格帯のモデルも登場する予定です。");
                a4_1.setImageUrl("https://picsum.photos/id/110/200/200");
                a4_1.setContentKanjiScript("[{\"text\":\"環境への\",\"furigana\":\"かんきょうへの\"},{\"text\":\"意識の\",\"furigana\":\"いしきの\"},{\"text\":\"高まりで、\",\"furigana\":\"たかまりで、\"},{\"text\":\"電気\",\"furigana\":\"でんき\"},{\"text\":\"自動車が\",\"furigana\":\"じどうしゃが\"},{\"text\":\"普及しています。\",\"furigana\":\"ふきゅうしています\"},{\"text\":\"国内外の\",\"furigana\":\"こくないがいの\"},{\"text\":\"メーカーが\",\"furigana\":\"\"},{\"text\":\"新型ＥＶの\",\"furigana\":\"しんがたＥＶの\"},{\"text\":\"開発で\",\"furigana\":\"かいはつで\"},{\"text\":\"競っています。\",\"furigana\":\"きそっています\"},{\"text\":\"走行距離を\",\"furigana\":\"そうこうきょりを\"},{\"text\":\"伸ばすための\",\"furigana\":\"のばすための\"},{\"text\":\"電池開発が\",\"furigana\":\"でんちかいはつが\"},{\"text\":\"重要です。\",\"furigana\":\"じゅうようです\"},{\"text\":\"ガソリン車の\",\"furigana\":\"がそりんしゃの\"},{\"text\":\"販売禁止の\",\"furigana\":\"はんばいきんしの\"},{\"text\":\"動きも\",\"furigana\":\"うごきも\"},{\"text\":\"進んでいます。\",\"furigana\":\"すすんでいます\"},{\"text\":\"２０３５年には\",\"furigana\":\"にせんさんじゅうごねんには\"},{\"text\":\"ＥＶが\",\"furigana\":\"\"},{\"text\":\"主流に\",\"furigana\":\"しゅりゅうに\"},{\"text\":\"なると\",\"furigana\":\"\"},{\"text\":\"言われています。\",\"furigana\":\"いわれています\"},{\"text\":\"充電スタンドの\",\"furigana\":\"じゅうでんすたんどの\"},{\"text\":\"インフラ\",\"furigana\":\"\"},{\"text\":\"整備も\",\"furigana\":\"せいびも\"},{\"text\":\"急がれています。\",\"furigana\":\"いそがれています\"},{\"text\":\"利用者の\",\"furigana\":\"りようしゃの\"},{\"text\":\"利便性が\",\"furigana\":\"りべんせいが\"},{\"text\":\"向上すれば\",\"furigana\":\"こうじょうすれば\"},{\"text\":\"さらに\",\"furigana\":\"\"},{\"text\":\"購入者が\",\"furigana\":\"こうにゅうしゃが\"},{\"text\":\"増えるでしょう。\",\"furigana\":\"ふえるでしょう\"},{\"text\":\"自動車\",\"furigana\":\"じどうしゃ\"},{\"text\":\"業界の\",\"furigana\":\"ぎょうかいの\"},{\"text\":\"未来は\",\"furigana\":\"みらいは\"},{\"text\":\"大きく\",\"furigana\":\"おおきく\"},{\"text\":\"変化します。\",\"furigana\":\"へんかします\"}]");
                a4_1.setContentTranslation("Dưới tác động của nhận thức bảo vệ môi trường toàn cầu ngày một cao, việc phổ cập xe điện (EV) đang diễn ra rất nhanh chóng. Các nhà sản xuất xe hơi trong và ngoài nước đang bước vào cuộc đua phát triển các mẫu xe điện mới cực kỳ khẽ liệt. Trong đó, việc nghiên cứu phát triển công nghệ pin giúp kéo dài quãng đường di chuyển được đặt lên hàng đầu. Các quyết định cấm bán xe chạy xăng của nhiều quốc gia cũng đang thúc đẩy mạnh mẽ xu hướng chuyển dịch này. Nhiều chuyên gia dự báo rằng thị trường xe điện sẽ chiếm ưu thế hoàn toàn vào năm 2035. Đồng thời, hạ tầng trạm sạc công cộng cũng đang được khẩn trương đầu tư đồng bộ. Trải nghiệm người dùng được cải thiện sẽ giúp thu hút thêm nhiều người tiêu dùng mua xe điện. Rõ ràng, bức tranh toàn cảnh ngành công nghiệp ô tô thế giới đang thay đổi sâu sắc.");
                a4_1 = articleRepository.save(a4_1);

                NewsArticle a4_2 = new NewsArticle();
                a4_2.setCategory(categoryMap.get("kinh-te"));
                a4_2.setTitle("円相場の変動と中小企業への影響について");
                a4_2.setDescription("外国為替市場での急激な円高の進行が、日本の中小企業に大きな影響を及ぼしています。特に海外から原材料を輸入している製造業にとって、コスト削減が緊急の課題です。一部の企業では製品価格の値上げを発表し、対応を急いでいます。しかし、価格競争の激化により利益が減少することを懸念する声も多いです。政府は中小企業向けの新しい融資や経営相談の支援策を開始しました。為替相場の安定が、日本経済の完全な回復には極めて重要です。長期化する不況への危機感から、多くの経営者が動向を注視しています。");
                a4_2.setImageUrl("https://picsum.photos/id/111/200/200");
                a4_2.setContentKanjiScript("[{\"text\":\"為替\",\"furigana\":\"かわせ\"},{\"text\":\"市場での\",\"furigana\":\"しじょうでの\"},{\"text\":\"円高の\",\"furigana\":\"えんだかの\"},{\"text\":\"進行が、\",\"furigana\":\"しんこうが、\"},{\"text\":\"中小企業に\",\"furigana\":\"ちゅうしょうきぎょうに\"},{\"text\":\"影響しています。\",\"furigana\":\"えいきょうしています\"},{\"text\":\"原材料を\",\"furigana\":\"げんざいりょうを\"},{\"text\":\"輸入する\",\"furigana\":\"ゆにゅうする\"},{\"text\":\"メーカーは\",\"furigana\":\"\"},{\"text\":\"コスト削減に\",\"furigana\":\"こすとさくげんに\"},{\"text\":\"苦労しています。\",\"furigana\":\"くろうしています\"},{\"text\":\"一部の\",\"furigana\":\"いちぶの\"},{\"text\":\"会社は\",\"furigana\":\"かいしゃは\"},{\"text\":\"製品価格の\",\"furigana\":\"せいひんかかくの\"},{\"text\":\"値上げを\",\"furigana\":\"ねあげを\"},{\"text\":\"発表しました。\",\"furigana\":\"はっぴょうしました\"},{\"text\":\"競合との\",\"furigana\":\"きょうごうとの\"},{\"text\":\"競争により\",\"furigana\":\"きょうそうにより\"},{\"text\":\"利益が\",\"furigana\":\"りえきが\"},{\"text\":\"減る\",\"furigana\":\"へる\"},{\"text\":\"心配があります。\",\"furigana\":\"しんぱいがあります\"},{\"text\":\"経営者は\",\"furigana\":\"けいえいしゃは\"},{\"text\":\"将来の\",\"furigana\":\"しょうらいの\"},{\"text\":\"見通しに\",\"furigana\":\"みとおしに\"},{\"text\":\"強い\",\"furigana\":\"つよい\"},{\"text\":\"不安を\",\"furigana\":\"ふアンを\"},{\"text\":\"抱いています。\",\"furigana\":\"だいています\"},{\"text\":\"政府は\",\"furigana\":\"せいふは\"},{\"text\":\"新しい\",\"furigana\":\"あたらしい\"},{\"text\":\"低金利\",\"furigana\":\"ていきんり\"},{\"text\":\"融資などの\",\"furigana\":\"ゆうしなどの\"},{\"text\":\"対策を\",\"furigana\":\"たいさくを\"},{\"text\":\"始めました。\",\"furigana\":\"はじめました\"},{\"text\":\"状況が\",\"furigana\":\"じょうきょうが\"},{\"text\":\"長期化すれば\",\"furigana\":\"ちょうきかすれば\"},{\"text\":\"倒産する\",\"furigana\":\"とうさんする\"},{\"text\":\"危険も\",\"furigana\":\"きけんも\"},{\"text\":\"高まります。\",\"furigana\":\"たかまります\"},{\"text\":\"市場の\",\"furigana\":\"しじょうの\"},{\"text\":\"安定が\",\"furigana\":\"あんていが\"},{\"text\":\"経済復活には\",\"furigana\":\"けいざいふっかつには\"},{\"text\":\"最も\",\"furigana\":\"もっとも\"},{\"text\":\"重要です。\",\"furigana\":\"じゅうようです\"}]");
                a4_2.setContentTranslation("Sự biến động mạnh mẽ của tỷ giá đồng Yên trên thị trường ngoại hối đang gây ra tác động vô cùng to lớn đối với các doanh nghiệp vừa và nhỏ của Nhật Bản. Đặc biệt đối với các doanh nghiệp sản xuất phụ thuộc nhiều vào nguyên liệu thô nhập khẩu từ nước ngoài, việc cắt giảm chi phí sản xuất đang là nhiệm vụ cấp bách nhất. Một số doanh nghiệp đã bắt buộc phải công bố tăng giá bán sản phẩm để ứng phó với tình hình khó khăn hiện tại. Tuy nhiên, việc tăng giá có thể dẫn tới nguy cơ đánh mất khách hàng vào tay các đối thủ cạnh tranh. Nhiều chủ doanh nghiệp bày tỏ sự lo ngại sâu sắc về sự suy giảm đáng kể lợi nhuận ròng. Trước tình hình đó, Chính phủ đã khẩn trương tung ra các gói vay ưu đãi và mở các trung tâm tư vấn tài chính hỗ trợ doanh nghiệp. Giới chuyên gia cảnh báo nếu tình trạng này kéo dài, nhiều doanh nghiệp có nguy cơ đối mặt với phá sản. Sự ổn định của thị trường tiền tệ là yếu tố sống còn cho sự phục hồi kinh tế lâu dài.");
                a4_2 = articleRepository.save(a4_2);

                NewsArticle a4_3 = new NewsArticle();
                a4_3.setCategory(categoryMap.get("kinh-te"));
                a4_3.setTitle("観光産業の復活、外国人旅行客が過去最多を記録");
                a4_3.setDescription("日本を訪れる外国人旅行客の数が過去最多のペースで増加し続けています。日本の伝統的な文化や美味しい日本食が多くの旅行客を魅了しています。各地の観光地ではホテルや老舗旅館の予約が満室になる状況が続いています。これにより、関連する飲食業界や交通機関の売上も急速に回復しています。しかし、深刻な人手不足が今後のさらなる成長の壁となっています。サービス品質を維持するためのデジタル技術の導入も検討されています。観光資源の多様化を図り、地方への旅行者を増やす試みも始まっています。");
                a4_3.setImageUrl("https://picsum.photos/id/112/200/200");
                a4_3.setContentKanjiScript("[{\"text\":\"日本を\",\"furigana\":\"にほんを\"},{\"text\":\"訪れる\",\"furigana\":\"おとずれる\"},{\"text\":\"外国人\",\"furigana\":\"がいこくじん\"},{\"text\":\"旅行客が\",\"furigana\":\"りょこうきゃくが\"},{\"text\":\"過去最多を\",\"furigana\":\"かこさいたを\"},{\"text\":\"記録しました。\",\"furigana\":\"きろくしました\"},{\"text\":\"伝統的な\",\"furigana\":\"でんとうてきな\"},{\"text\":\"文化と\",\"furigana\":\"ぶんかと\"},{\"text\":\"和食が\",\"furigana\":\"わしょくが\"},{\"text\":\"高い評価を\",\"furigana\":\"たかいひょうかを\"},{\"text\":\"得ています。\",\"furigana\":\"えています\"},{\"text\":\"多くの\",\"furigana\":\"おおくの\"},{\"text\":\"ホテルや\",\"furigana\":\"\"},{\"text\":\"旅館が\",\"furigana\":\"りょかんが\"},{\"text\":\"満室の\",\"furigana\":\"まんしつの\"},{\"text\":\"状態です。\",\"furigana\":\"じょうたいです\"},{\"text\":\"飲食店や\",\"furigana\":\"いんしょくてんや\"},{\"text\":\"タクシーの\",\"furigana\":\"\"},{\"text\":\"売上も\",\"furigana\":\"うりあげも\"},{\"text\":\"急速に\",\"furigana\":\"きゅうそくに\"},{\"text\":\"回復しています。\",\"furigana\":\"かいふくしています\"},{\"text\":\"しかし、\",\"furigana\":\"\"},{\"text\":\"深刻な\",\"furigana\":\"しんこくな\"},{\"text\":\"人手不足が\",\"furigana\":\"ひとでぶそくが\"},{\"text\":\"大きな\",\"furigana\":\"おおきな\"},{\"text\":\"課題です。\",\"furigana\":\"かだいです\"},{\"text\":\"一部の\",\"furigana\":\"いちぶの\"},{\"text\":\"店は\",\"furigana\":\"みせは\"},{\"text\":\"営業時間を\",\"furigana\":\"えいぎょうじかんを\"},{\"text\":\"短縮して\",\"furigana\":\"たんしゅくして\"},{\"text\":\"対応しています。\",\"furigana\":\"たいおうしています\"},{\"text\":\"ＩＴによる\",\"furigana\":\"\"},{\"text\":\"自動化の\",\"furigana\":\"じどうかの\"},{\"text\":\"導入が\",\"furigana\":\"どうにゅうが\"},{\"text\":\"解決策として\",\"furigana\":\"かいけつさくとして\"},{\"text\":\"提案されています。\",\"furigana\":\"ていあんされています\"},{\"text\":\"インバウンドの\",\"furigana\":\"\"},{\"text\":\"復活は\",\"furigana\":\"ふっかつは\"},{\"text\":\"日本経済に\",\"furigana\":\"にほんけいざいに\"},{\"text\":\"活力をもたらします。\",\"furigana\":\"かつりょくをもたらします\"}]");
                a4_3.setContentTranslation("Số lượng khách du lịch quốc tế đến Nhật Bản đang tiếp tục tăng trưởng mạnh mẽ và lập kỷ lục mới. Nét văn hóa truyền thống độc đáo cùng nền ẩm thực phong phú là những yếu tố thu hút du khách hàng đầu. Tại khắp các danh lam thắng cảnh, các khách sạn và nhà nghỉ truyền thống ryokan liên tục báo cháy phòng. Nhờ đó, doanh thu của ngành dịch vụ ăn uống và các hãng vận tải cũng phục hồi vô cùng nhanh chóng. Tuy nhiên, tình trạng thiếu hụt nhân lực nghiêm trọng đang là rào cản lớn đối với việc mở rộng quy mô. Nhiều cơ sở phải hạn chế nhận khách hoặc rút ngắn giờ phục vụ vì không có đủ nhân viên. Giới chuyên gia khuyến nghị cần đẩy mạnh áp dụng công nghệ tự động hóa trong quản lý du lịch. Nhìn chung, sự bùng nổ của ngành du lịch đang thổi một luồng sinh khí mới vào nền kinh tế Nhật Bản.");
                a4_3 = articleRepository.save(a4_3);

                // Associate Vocabs
                linkVocabToArticle(a1_1, "準備");
                linkVocabToArticle(a1_1, "影響");
                linkVocabToArticle(a1_2, "環境");
                linkVocabToArticle(a1_3, "準備");
                linkVocabToArticle(a2_1, "解決");
                linkVocabToArticle(a2_2, "影響");
                linkVocabToArticle(a2_3, "満足");
                linkVocabToArticle(a3_1, "解決");
                linkVocabToArticle(a3_2, "影響");
                linkVocabToArticle(a3_3, "解決");
                linkVocabToArticle(a4_1, "影響");
                linkVocabToArticle(a4_2, "影響");
                linkVocabToArticle(a4_3, "満足");
            }
        }
    }

    private void linkVocabToArticle(NewsArticle article, String vocabWord) {
        Optional<Vocabulary> vocabOpt = vocabularyRepository.findByWord(vocabWord);
        if (vocabOpt.isPresent()) {
            NewsVocabulary nv = new NewsVocabulary();
            nv.setArticle(article);
            nv.setVocabulary(vocabOpt.get());
            newsVocabularyRepository.save(nv);
        }
    }

    @Transactional
    public ArticleNoteResponse saveOrUpdateNote(ArticleNoteRequest request) {
        User user = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new IllegalArgumentException("User not found with id: " + request.getUserId()));
        NewsArticle article = articleRepository.findById(request.getArticleId())
                .orElseThrow(() -> new IllegalArgumentException("News article not found with id: " + request.getArticleId()));

        UserArticleNote note = userArticleNoteRepository.findByUserIdAndArticleId(request.getUserId(), request.getArticleId())
                .orElse(new UserArticleNote());

        note.setUser(user);
        note.setArticle(article);
        note.setNoteContent(request.getNoteContent());
        note.setUpdatedAt(LocalDateTime.now());

        UserArticleNote saved = userArticleNoteRepository.save(note);
        return mapToNoteResponse(saved);
    }

    @Transactional(readOnly = true)
    public ArticleNoteResponse getNote(Long userId, Long articleId) {
        return userArticleNoteRepository.findByUserIdAndArticleId(userId, articleId)
                .map(this::mapToNoteResponse)
                .orElse(ArticleNoteResponse.builder()
                        .userId(userId)
                        .articleId(articleId)
                        .noteContent("")
                        .build());
    }

    private ArticleNoteResponse mapToNoteResponse(UserArticleNote note) {
        return ArticleNoteResponse.builder()
                .id(note.getId())
                .userId(note.getUser().getId())
                .articleId(note.getArticle().getId())
                .noteContent(note.getNoteContent())
                .updatedAt(note.getUpdatedAt())
                .build();
    }
}
