import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/flashcard.dart';
import '../models/flashcard_quiz.dart';
import '../models/flashcard_quiz_history.dart';
import '../models/flashcard_quiz_result.dart';
import '../models/flashcard_set.dart';

class FlashcardService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }

    try {
      return Platform.isAndroid
          ? 'http://10.0.2.2:8080'
          : 'http://localhost:8080';
    } catch (_) {
      return 'http://localhost:8080';
    }
  }

  //----------------------------------
  // GET MY FLASHCARD SETS
  //----------------------------------

  Future<List<FlashcardSet>> getMySets(
      int userId) async {
    final uri = Uri.parse(
      '$baseUrl/api/flashcards/sets/my?userId=$userId',
    );

    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Cannot load flashcard sets');
    }

    final List<dynamic> json =
    jsonDecode(utf8.decode(response.bodyBytes));

    return json
        .map((e) => FlashcardSet.fromJson(e))
        .toList();
  }

  //----------------------------------
  // GET PUBLIC SETS
  //----------------------------------

  Future<List<FlashcardSet>> getPublicSets() async {
    final uri = Uri.parse(
      '$baseUrl/api/flashcards/sets/public',
    );

    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Cannot load public sets');
    }

    final List<dynamic> json =
    jsonDecode(utf8.decode(response.bodyBytes));

    return json
        .map((e) => FlashcardSet.fromJson(e))
        .toList();
  }

  //----------------------------------
  // CREATE FLASHCARD SET
  //----------------------------------

  Future<FlashcardSet> createSet({
    required int userId,
    required String name,
    required String description,
    required bool isPublic,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/flashcards/sets?userId=$userId',
    );

    final response = await http
        .post(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "description": description,
        "isPublic": isPublic,
      }),
    )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception("Create flashcard set failed");
    }

    final json = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    return FlashcardSet.fromJson(json);
  }

  //----------------------------------
  // UPDATE FLASHCARD SET
  //----------------------------------

  Future<FlashcardSet> updateSet({
    required int setId,
    required int userId,
    required String name,
    required String description,
    required bool isPublic,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/flashcards/sets/$setId?userId=$userId',
    );

    final response = await http
        .put(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "description": description,
        "isPublic": isPublic,
      }),
    )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception("Update flashcard set failed");
    }

    final json = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    return FlashcardSet.fromJson(json);
  }

  //----------------------------------
  // DELETE FLASHCARD SET
  //----------------------------------

  Future<void> deleteSet({
    required int setId,
    required int userId,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/flashcards/sets/$setId?userId=$userId',
    );

    final response = await http
        .delete(uri)
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception("Delete flashcard set failed");
    }
  }
  //----------------------------------
  // CREATE FLASHCARD
  //----------------------------------

  Future<Flashcard> createFlashcard({
    required int userId,
    required int setId,
    required String front,
    required String back,
    String? note,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/flashcards?userId=$userId',
    );

    final response = await http
        .post(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "setId": setId,
        "front": front,
        "back": back,
        "note": note,
      }),
    )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception("Create flashcard failed");
    }

    final json = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    return Flashcard.fromJson(json);
  }

  //----------------------------------
  // GET FLASHCARDS OF A SET
  //----------------------------------

  Future<List<Flashcard>> getFlashcards(
      int setId) async {
    final uri = Uri.parse(
      '$baseUrl/api/flashcards/sets/$setId/cards',
    );

    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception("Cannot load flashcards");
    }

    final List<dynamic> json =
    jsonDecode(utf8.decode(response.bodyBytes));

    return json
        .map((e) => Flashcard.fromJson(e))
        .toList();
  }

  //----------------------------------
  // UPDATE FLASHCARD
  //----------------------------------

  Future<Flashcard> updateFlashcard({
    required int flashcardId,
    required int userId,
    required String front,
    required String back,
    String? note,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/flashcards/$flashcardId?userId=$userId',
    );

    final response = await http
        .put(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "front": front,
        "back": back,
        "note": note,
      }),
    )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception("Update flashcard failed");
    }

    final json = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    return Flashcard.fromJson(json);
  }

  //----------------------------------
  // DELETE FLASHCARD
  //----------------------------------

  Future<void> deleteFlashcard({
    required int flashcardId,
    required int userId,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/flashcards/$flashcardId?userId=$userId',
    );

    final response = await http
        .delete(uri)
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception("Delete flashcard failed");
    }
  }
  //----------------------------------
  // START FLASHCARD QUIZ
  //----------------------------------

  Future<FlashcardQuiz> startQuiz({
    required int userId,
    required int setId,
    required int totalQuestion,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/flashcard-quiz/start/$userId',
    );

    final response = await http
        .post(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "setId": setId,
        "totalQuestion": totalQuestion,
      }),
    )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception("Start quiz failed");
    }

    final json = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    return FlashcardQuiz.fromJson(json);
  }

  //----------------------------------
  // SUBMIT FLASHCARD QUIZ
  //----------------------------------

  Future<FlashcardQuizResult> submitQuiz({
    required int userId,
    required int quizId,
    required List<Map<String, dynamic>> answers,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/flashcard-quiz/submit/$userId',
    );

    final response = await http
        .post(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "quizId": quizId,
        "answers": answers,
      }),
    )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception("Submit quiz failed");
    }

    final json = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    return FlashcardQuizResult.fromJson(json);
  }

  //----------------------------------
  // GET FLASHCARD QUIZ HISTORY
  //----------------------------------

  Future<List<FlashcardQuizHistory>> getQuizHistory(
      int userId) async {
    final uri = Uri.parse(
      '$baseUrl/api/flashcard-quiz/history/$userId',
    );

    debugPrint("GET: $uri");
    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 8));

    debugPrint("Response Code: ${response.statusCode}");
    if (response.statusCode != 200) {
      debugPrint("Error Body: ${response.body}");
      throw Exception("Cannot load quiz history");
    }

    final String body = utf8.decode(response.bodyBytes);
    debugPrint("History Body: $body");
    
    final List<dynamic> json = jsonDecode(body);

    final List<FlashcardQuizHistory> results = [];
    for (var item in json) {
      try {
        results.add(FlashcardQuizHistory.fromJson(item));
      } catch (e) {
        debugPrint("Error parsing history item: $e. Item data: $item");
      }
    }
    return results;
  }
}
