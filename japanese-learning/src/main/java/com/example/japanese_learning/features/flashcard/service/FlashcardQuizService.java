package com.example.japanese_learning.features.flashcard.service;


import com.example.japanese_learning.dto.request.StartFlashcardQuizRequest;
import com.example.japanese_learning.dto.request.SubmitFlashcardQuizRequest;
import com.example.japanese_learning.dto.response.*;

import com.example.japanese_learning.entity.account.User;
import com.example.japanese_learning.entity.flashcards.*;

import com.example.japanese_learning.features.flashcard.repository.*;
import com.example.japanese_learning.features.exam_attempt.repository.UserRepository;

import lombok.RequiredArgsConstructor;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;


@Service
@RequiredArgsConstructor
public class FlashcardQuizService {


    private final UserRepository userRepository;

    private final FlashCardRepository flashCardRepository;

    private final FlashCardSetRepository flashCardSetRepository;

    private final FlashCardQuizRepository quizRepository;

    private final FlashCardQuizQuestionRepository questionRepository;

    private final FlashCardQuizHistoryRepository historyRepository;

    private final UserFlashCardProgressRepository progressRepository;


    // ==========================
    // START QUIZ
    // ==========================


    @Transactional
    public FlashcardQuizResponse startQuiz(
            Long userId,
            StartFlashcardQuizRequest request
    ) {

        User user = userRepository.findById(userId)
                .orElseThrow(
                        () -> new RuntimeException("User không tồn tại")
                );


        FlashcardSet set =
                flashCardSetRepository.findById(request.getSetId())
                        .orElseThrow(
                                () -> new RuntimeException("Không tìm thấy bộ flashcard")
                        );

        Integer totalQuestion = request.getTotalQuestion();

        if (totalQuestion == null || totalQuestion <= 0) {
            throw new RuntimeException("Số lượng câu hỏi không hợp lệ");
        }
        List<Flashcard> cards = flashCardRepository.findByFlashcardSet_Id(set.getId());


        if (cards.isEmpty()) {
            throw new RuntimeException("Bộ flashcard chưa có dữ liệu");
        }


        // random câu hỏi


        int limit = Math.min(totalQuestion, cards.size());

        Collections.shuffle(cards);

        cards = cards.subList(0, limit);


        // tạo quiz

        FlashcardQuiz quiz = new FlashcardQuiz();

        quiz.setUser(user);

        quiz.setFlashcardSet(set);

        quiz.setTotalQuestions(cards.size());

        quiz.setScore(0);


        quiz = quizRepository.save(quiz);


        List<FlashcardQuizQuestionResponse> responses
                = new ArrayList<>();


        for (Flashcard card : cards) {


            List<String> options =
                    createOptions(card, set.getId());


            FlashcardQuizQuestion question =
                    new FlashcardQuizQuestion();


            question.setQuiz(quiz);

            question.setFlashcard(card);


            question.setQuestion(
                    card.getFront()
            );


            question.setCorrectAnswer(
                    card.getBack()
            );


            question.setOptionA(options.get(0));
            question.setOptionB(options.get(1));
            question.setOptionC(options.get(2));
            question.setOptionD(options.get(3));


            questionRepository.save(question);


            FlashcardQuizQuestionResponse response =
                    FlashcardQuizQuestionResponse.builder()

                            .questionId(question.getId())

                            .question(card.getFront())

                            .optionA(options.get(0))

                            .optionB(options.get(1))

                            .optionC(options.get(2))

                            .optionD(options.get(3))

                            .build();


            responses.add(response);

        }


        return FlashcardQuizResponse.builder()

                .quizId(quiz.getId())

                .setId(set.getId())

                .totalQuestion(cards.size())

                .questions(responses)

                .build();


    }


    // ==========================
    // RANDOM OPTION
    // ==========================


    private List<String> createOptions(
            Flashcard correctCard,
            Long setId
    ) {


        List<String> options =
                new ArrayList<>();


        // đáp án đúng

        options.add(
                correctCard.getBack()
        );


        // lấy 3 đáp án sai

        List<Flashcard> wrongCards =
                flashCardRepository
                        .getRandomWrongAnswers(
                                setId,
                                correctCard.getId()
                        );


        for (Flashcard card : wrongCards) {

            options.add(
                    card.getBack()
            );

        }


        // phòng trường hợp bộ ít hơn 4 card

        while (options.size() < 4) {

            options.add("Không có đáp án");

        }


        Collections.shuffle(options);


        return options;

    }


    // ==========================
    // SUBMIT QUIZ
    // ==========================


    @Transactional
    public FlashcardQuizResultResponse submitQuiz(
            Long userId,
            SubmitFlashcardQuizRequest request
    ) {


        FlashcardQuiz quiz =
                quizRepository.findById(
                                request.getQuizId()
                        )
                        .orElseThrow(
                                () -> new RuntimeException(
                                        "Quiz không tồn tại"
                                )
                        );


        int correct = 0;


        List<FlashcardQuizQuestion> questions =
                questionRepository
                        .findByQuizId(
                                quiz.getId()
                        );


        for (
                SubmitFlashcardQuizRequest.AnswerRequest answer
                :
                request.getAnswers()
        ) {


            FlashcardQuizQuestion question =
                    questions.stream()

                            .filter(q ->
                                    q.getId()
                                            .equals(answer.getQuestionId())
                            )

                            .findFirst()

                            .orElse(null);


            if (question == null)
                continue;


            question.setUserAnswer(
                    answer.getAnswer()
            );


            boolean isCorrect =
                    question
                            .getCorrectAnswer()
                            .equalsIgnoreCase(
                                    answer.getAnswer()
                            );


            question.setIsCorrect(isCorrect);


            if (isCorrect) {

                correct++;

            }


            updateProgress(
                    userId,
                    question.getFlashcard(),
                    isCorrect
            );


        }


        questionRepository.saveAll(questions);


        int score =
                (correct * 100)
                        /
                        quiz.getTotalQuestions();


        quiz.setScore(score);

        quiz.setCompletedAt(
                LocalDateTime.now()
        );


        quizRepository.save(quiz);


        // lưu history


        FlashcardQuizHistory history =
                new FlashcardQuizHistory();


        history.setUser(
                quiz.getUser()
        );


        history.setFlashcardSet(
                quiz.getFlashcardSet()
        );


        history.setTotalQuestions(
                quiz.getTotalQuestions()
        );


        history.setCorrectAnswers(
                correct
        );


        history.setScore(score);


        history.setCompletedAt(
                LocalDateTime.now()
        );


        historyRepository.save(history);


        return FlashcardQuizResultResponse.builder()

                .quizId(quiz.getId())

                .totalQuestion(
                        quiz.getTotalQuestions()
                )

                .correctAnswer(correct)

                .score(score)

                .build();

    }


    // ==========================
    // UPDATE PROGRESS
    // ==========================


    private void updateProgress(
            Long userId,
            Flashcard flashcard,
            boolean correct
    ) {


        UserFlashcardProgress progress =

                progressRepository

                        .findByUserIdAndFlashcardId(
                                userId,
                                flashcard.getId()
                        )

                        .orElse(null);


        if (progress == null) {


            progress =
                    new UserFlashcardProgress();


            progress.setUser(
                    userRepository
                            .findById(userId)
                            .get()
            );


            progress.setFlashcard(
                    flashcard
            );


            progress.setMasteryLevel(0);

            progress.setReviewCount(0);

        }


        progress.setReviewCount(
                progress.getReviewCount() + 1
        );


        if (correct) {

            progress.setMasteryLevel(
                    progress.getMasteryLevel() + 1
            );

        } else {

            progress.setMasteryLevel(
                    Math.max(
                            0,
                            progress.getMasteryLevel() - 1
                    )
            );

        }


        progress.setLastReviewedAt(
                LocalDateTime.now()
        );


        progressRepository.save(progress);

    }

    public List<FlashcardQuizHistoryResponse> getHistory(Long userId){

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User không tồn tại"));

        List<FlashcardQuizHistory> histories =
                historyRepository.findByUserIdOrderByCompletedAtDesc(user.getId());

        return histories.stream()
                .map(history -> FlashcardQuizHistoryResponse.builder()
                        .historyId(history.getId())
                        .setName(history.getFlashcardSet().getName())
                        .totalQuestion(history.getTotalQuestions())
                        .correctAnswer(history.getCorrectAnswers())
                        .score(history.getScore())
                        .completedAt(history.getCompletedAt())
                        .build())
                .toList();

    }

}