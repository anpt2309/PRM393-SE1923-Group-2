package com.example.japanese_learning.features.grammar;

import com.example.japanese_learning.dto.response.GrammarLessonResponse;
import com.example.japanese_learning.entity.learning.GrammarLesson;
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
public class GrammarLessonService {

    private final GrammarLessonRepository grammarLessonRepository;

    @Transactional(readOnly = true)
    public List<GrammarLessonResponse> getGrammarsByLevel(String levelStr) {
        JlptLevel level = JlptLevel.valueOf(levelStr.toUpperCase());
        return grammarLessonRepository.findByJlptLevel(level).stream()
                .map(this::mapToResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public Optional<GrammarLessonResponse> getGrammarDetails(Long id) {
        return grammarLessonRepository.findById(id)
                .map(this::mapToResponse);
    }

    private GrammarLessonResponse mapToResponse(GrammarLesson g) {
        return GrammarLessonResponse.builder()
                .id(g.getId())
                .structure(g.getStructure())
                .meaning(g.getMeaning())
                .explanation(g.getExplanation())
                .example(g.getExample())
                .jlptLevel(g.getJlptLevel())
                .formulaJson(g.getFormulaJson())
                .exampleAnatomyJson(g.getExampleAnatomyJson())
                .formalityNuance(g.getFormalityNuance())
                .build();
    }

    @PostConstruct
    @Transactional
    public void seedDatabase() {
        boolean hasLegacy = grammarLessonRepository.findAll().stream().anyMatch(g -> g.getFormulaJson() == null);
        if (hasLegacy) {
            grammarLessonRepository.deleteAll();
        }
        if (grammarLessonRepository.count() == 0) {
            List<GrammarLesson> list = new ArrayList<>();

            // ─── N5 LEVEL ───
            list.add(createGrammar("〜てみる", "Thử làm một việc gì đó", "Thử làm hành động gì đó để xem kết quả thế nào.", "日本に行ってみる。", JlptLevel.N5,
                "[{\"text\":\"V-te\"},{\"text\":\"→\"},{\"text\":\"〜てみる\",\"isTarget\":true}]",
                "[{\"text\":\"日本に\",\"grammaticalRole\":\"Destination\"},{\"text\":\"行っ\",\"grammaticalRole\":\"Action\"},{\"text\":\"てみる\",\"grammaticalRole\":\"Grammar Hub\",\"isTargetPattern\":true}]",
                0.35));

            list.add(createGrammar("〜てください", "Yêu cầu ai đó làm gì một cách lịch sự", "Dùng để yêu cầu, nhờ vả đối phương thực hiện hành động một cách lịch sự.", "ここに書いてください。", JlptLevel.N5,
                "[{\"text\":\"V-te\"},{\"text\":\"→\"},{\"text\":\"〜てください\",\"isTarget\":true}]",
                "[{\"text\":\"ここに\",\"grammaticalRole\":\"Location\"},{\"text\":\"書い\",\"grammaticalRole\":\"Action\"},{\"text\":\"てください\",\"grammaticalRole\":\"Grammar Hub\",\"isTargetPattern\":true}]",
                0.7));

            list.add(createGrammar("〜から", "Giải thích nguyên nhân, lý do (Vì...)", "Nêu nguyên nhân, lý do dẫn tới hành động ở vế sau.", "暑いから窓を開ける。", JlptLevel.N5,
                "[{\"text\":\"Phân câu (Thể thường / Lịch sự)\"},{\"text\":\"→\"},{\"text\":\"〜から\",\"isTarget\":true}]",
                "[{\"text\":\"暑い\",\"grammaticalRole\":\"Reason / Cause\"},{\"text\":\"から\",\"grammaticalRole\":\"Grammar Hub\",\"isTargetPattern\":true},{\"text\":\"窓を開ける\",\"grammaticalRole\":\"Result / Action\"}]",
                0.25));

            // ─── N4 LEVEL ───
            list.add(createGrammar("〜ながら", "Diễn tả hai hành động diễn ra đồng thời (Vừa... vừa...)", "Hành động ở vế sau là chính, vế trước là phụ.", "音楽を聞きながら勉強する。", JlptLevel.N4,
                "[{\"text\":\"V-masu (bỏ masu)\"},{\"text\":\"→\"},{\"text\":\"〜ながら\",\"isTarget\":true}]",
                "[{\"text\":\"音楽を\",\"grammaticalRole\":\"Object\"},{\"text\":\"聞き\",\"grammaticalRole\":\"Action 1\"},{\"text\":\"ながら\",\"grammaticalRole\":\"Grammar Hub\",\"isTargetPattern\":true},{\"text\":\"勉強する\",\"grammaticalRole\":\"Action 2\"}]",
                0.45));

            list.add(createGrammar("〜し〜し", "Liệt kê các lý do, trạng thái tương đồng", "Liệt kê nhiều lý do dẫn đến một kết quả hoặc nhận định chung.", "安いし、美味しいし便利です。", JlptLevel.N4,
                "[{\"text\":\"Thể thường\"},{\"text\":\"〜し\"},{\"text\":\"Thể thường\"},{\"text\":\"〜し\",\"isTarget\":true}]",
                "[{\"text\":\"安いし、\",\"grammaticalRole\":\"State 1 + Reason\"},{\"text\":\"美味しいし\",\"grammaticalRole\":\"State 2 + Reason\",\"isTargetPattern\":true},{\"text\":\"便利です\",\"grammaticalRole\":\"Conclusion\"}]",
                0.3));

            // ─── N3 LEVEL ───
            list.add(createGrammar("〜たばかり", "Diễn tả hành động vừa mới xảy ra chưa lâu theo cảm nhận", "Vừa mới làm gì đó xong (theo cảm nhận chủ quan của người nói).", "日本に来たばかり。", JlptLevel.N3,
                "[{\"text\":\"V-ta\"},{\"text\":\"→\"},{\"text\":\"〜たばかり\",\"isTarget\":true}]",
                "[{\"text\":\"日本に\",\"grammaticalRole\":\"Location\"},{\"text\":\"来た\",\"grammaticalRole\":\"Action\"},{\"text\":\"ばかり\",\"grammaticalRole\":\"Grammar Hub\",\"isTargetPattern\":true}]",
                0.35));

            list.add(createGrammar("〜ばいい", "Lời khuyên, khích lệ (Chỉ cần làm gì đó là được)", "Thể hiện ý kiến khuyên bảo đối phương chỉ cần làm hành động đó là đủ.", "先生に聞けばいい。", JlptLevel.N3,
                "[{\"text\":\"V-ba (Thể điều kiện)\"},{\"text\":\"→\"},{\"text\":\"〜ばいい\",\"isTarget\":true}]",
                "[{\"text\":\"先生に\",\"grammaticalRole\":\"Target\"},{\"text\":\"聞け\",\"grammaticalRole\":\"Action\"},{\"text\":\"ばいい\",\"grammaticalRole\":\"Grammar Hub\",\"isTargetPattern\":true}]",
                0.3));

            // ─── N2 LEVEL ───
            list.add(createGrammar("〜わけにはいかない", "Không thể làm một việc gì đó vì lý do đạo đức hoặc nghĩa vụ", "Không thể làm vì đạo đức, quy định hoặc lương tâm không cho phép.", "大事な試験の日に休むわけにはいかない。", JlptLevel.N2,
                "[{\"text\":\"V-u (Thể từ điển)\"},{\"text\":\"→\"},{\"text\":\"〜わけにはいかない\",\"isTarget\":true}]",
                "[{\"text\":\"大事な試験の\",\"grammaticalRole\":\"Context\"},{\"text\":\"日に\",\"grammaticalRole\":\"Time\"},{\"text\":\"休む\",\"grammaticalRole\":\"Action\"},{\"text\":\"わけにはいかない\",\"grammaticalRole\":\"Grammar Hub\",\"isTargetPattern\":true}]",
                0.65));

            // ─── N1 LEVEL ───
            list.add(createGrammar("〜ずにはいられない", "Không thể kìm nén được cảm xúc, hành động (Không thể không...)", "Không thể không làm hành động đó vì cảm xúc dâng trào.", "悲しい映画を見て泣かずにはいられない。", JlptLevel.N1,
                "[{\"text\":\"V-nai (bỏ nai)\"},{\"text\":\"→\"},{\"text\":\"〜ずにはいられない\",\"isTarget\":true}]",
                "[{\"text\":\"悲しい映画を\",\"grammaticalRole\":\"Trigger\"},{\"text\":\"見て\",\"grammaticalRole\":\"Condition\"},{\"text\":\"泣か\",\"grammaticalRole\":\"Action\"},{\"text\":\"ずにはいられない\",\"grammaticalRole\":\"Grammar Hub\",\"isTargetPattern\":true}]",
                0.8));

            grammarLessonRepository.saveAll(list);
        }
    }

    private GrammarLesson createGrammar(String structure, String meaning, String explanation, String example,
                                         JlptLevel level, String formulaJson, String exampleAnatomyJson, double formalityNuance) {
        GrammarLesson g = new GrammarLesson();
        g.setStructure(structure);
        g.setMeaning(meaning);
        g.setExplanation(explanation);
        g.setExample(example);
        g.setJlptLevel(level);
        g.setFormulaJson(formulaJson);
        g.setExampleAnatomyJson(exampleAnatomyJson);
        g.setFormalityNuance(formalityNuance);
        return g;
    }
}
