package com.example.japanese_learning.features.exam_history.service;

import com.example.japanese_learning.dto.request.ChatRequest;
import com.example.japanese_learning.dto.response.CommentResponse;
import com.example.japanese_learning.dto.response.QuestionReportResponse;
import com.example.japanese_learning.entity.account.User;
import com.example.japanese_learning.entity.exam.Comment;
import com.example.japanese_learning.entity.exam.Question;
import com.example.japanese_learning.entity.exam.Option;
import com.example.japanese_learning.entity.exam.QuestionReport;
import com.example.japanese_learning.features.exam_attempt.repository.QuestionRepository;
import com.example.japanese_learning.features.exam_attempt.repository.UserRepository;
import com.example.japanese_learning.features.exam_history.repository.CommentRepository;
import com.example.japanese_learning.features.exam_history.repository.QuestionReportRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.ai.chat.messages.SystemMessage;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ChatService {
    private final ChatClient chatClient;
    private final CommentRepository commentRepository;
    private final UserRepository userRepository;
    private final QuestionRepository questionRepository;
    private final QuestionReportRepository questionReportRepository;


    @Transactional
    public String callAPIModelAI(Long userId, ChatRequest request) {
        User user = userRepository.findById(userId).orElseThrow(()
                -> new RuntimeException("Người dùng không tồn tại"));
        
        final String conversationId = (request.getQuestionId() != null)
                ? "user_" + user.getId() + "_question_" + request.getQuestionId()
                : "user_" + user.getId();
        
        String systemInstruction = "You are Japanese_Learning AI. Please respond in a friendly and helpful manner.";

        if (request.getQuestionId() != null) {
            Question question = questionRepository.findById(request.getQuestionId())
                    .orElseThrow(() -> new RuntimeException("Câu hỏi không tồn tại"));

            StringBuilder optionsText = new StringBuilder();
            List<Option> options = question.getOption();
            if (question.getOption() != null) {
                for (Option opt : options) {
                    optionsText.append("- ").append(opt.getContent());
                    if (Boolean.TRUE.equals(opt.getIsCorrect())) {
                        optionsText.append(" (Đáp án đúng)");
                    }
                    optionsText.append("\n");
                }
            }

             systemInstruction = String.format("""
                Bạn là một trợ lý ảo hỗ trợ học tiếng Nhật chuyên nghiệp và thân thiện.
                Mục tiêu duy nhất của bạn là giải thích ngắn gọn câu hỏi ôn tập dưới đây cho người dùng.
                
                Thông tin câu hỏi hiện tại:
                - Nội dung câu hỏi: %s
                - Các lựa chọn đáp án:
                %s
                
                RÀNG BUỘC QUAN TRỌNG:
                1. Bạn CHỈ được phép trả lời các câu hỏi liên quan trực tiếp đến câu hỏi tiếng Nhật trên (ví dụ: giải thích ngữ pháp, từ vựng, tại sao chọn đáp án đó, dịch nghĩa, phân tích cấu trúc câu).
                2. Nếu người dùng hỏi câu hỏi ngoài lề hoặc không liên quan đến câu hỏi ôn tập này (ví dụ: hỏi về lập trình, toán học, thời tiết, viết code, tán gẫu ngoài lề, hoặc các chủ đề tiếng Nhật khác không liên quan), bạn phải từ chối một cách lịch sự và hướng dẫn họ tập trung vào câu hỏi hiện tại.
                   Ví dụ phản hồi từ chối: "Xin lỗi, tôi chỉ có thể hỗ trợ giải thích câu hỏi tiếng Nhật này. Bạn có thắc mắc gì về ngữ pháp hay từ vựng của câu này không?"
                3. Khi trình bày câu trả lời, KHÔNG sử dụng ký tự đặc biệt như *, **, #, hoặc các ký hiệu trang trí. Chỉ dùng văn bản thuần túy, trình bày rõ ràng, dễ hiểu.
                """, question.getContent(), optionsText.toString());
        }

        SystemMessage promptSystem = new SystemMessage(systemInstruction);
        UserMessage message = new UserMessage(request.getRequest());
        Prompt prompt = new Prompt(promptSystem, message);

        return chatClient.prompt(prompt)
                .advisors(advisorSpec -> advisorSpec.param(
                    ChatMemory.CONVERSATION_ID, conversationId
                ))
                .call()
                .content();
    }

    public List<CommentResponse> getUserComment() {
        List<CommentResponse> getAllComment = commentRepository.findAllComment();
        return getAllComment;
    }

    public CommentResponse createComment(Long userId, ChatRequest request) {
        User user = userRepository.findById(userId).orElseThrow(()
                -> new RuntimeException("Người dùng không tồn tại"));
        Question question = questionRepository.findById(request.getQuestionId()).orElseThrow(()
                -> new RuntimeException("Câu hỏi không tồn tại"));

        Comment comment = new Comment();
        comment.setContent(request.getRequest());
        comment.setUser(user);
        comment.setQuestion(question);
        commentRepository.save(comment);
        return new CommentResponse(comment.getId(), comment.getContent(), user.getUsername(), question.getId());
    }

    public QuestionReportResponse createReportQuestion(Long userId, ChatRequest request) {
        User user = userRepository.findById(userId).orElseThrow(()
                -> new RuntimeException("Người dùng không tồn tại"));
        Question question = questionRepository.findById(request.getQuestionId()).orElseThrow(()
                -> new RuntimeException("Câu hỏi không tồn tại"));

        QuestionReport questionReport = new QuestionReport();
        questionReport.setContent(request.getRequest());
        questionReport.setUser(user);
        questionReport.setQuestion(question);
        questionReportRepository.save(questionReport);


        return QuestionReportResponse.builder()
                .id(question.getId())
                .userName(user.getUsername())
                .questionName(question.getContent())
                .content(request.getRequest())
                .build();
    }

}
