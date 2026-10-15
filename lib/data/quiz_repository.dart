import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuizRepository {
  static final QuizRepository _instance = QuizRepository._internal();
  factory QuizRepository() => _instance;
  QuizRepository._internal();

  Map<int, WeekData> _weeks = {};
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<int> get availableWeeks => _weeks.keys.toList()..sort();

  int get totalQuestionCount =>
      _weeks.values.fold(0, (sum, w) => sum + w.questions.length);

  List<Question> getAllQuestions() {
    final list = <Question>[];
    final sortedWeeks = availableWeeks;
    for (final w in sortedWeeks) {
      final weekData = _weeks[w];
      if (weekData != null) {
        list.addAll(weekData.questions);
      }
    }
    return list;
  }

  Future<void> loadQuestions() async {
    if (_isLoaded && _weeks.isNotEmpty) return;

    try {
      final jsonString =
          await rootBundle.loadString('assets/data/questions.json');
      final Map<String, dynamic> decoded = json.decode(jsonString);

      _weeks = {};
      decoded.forEach((key, value) {
        final weekNum = int.tryParse(key);
        if (weekNum != null && value is Map<String, dynamic>) {
          _weeks[weekNum] = WeekData.fromJson(value);
        }
      });

      _isLoaded = true;
    } catch (e) {
      _weeks = {
        1: WeekData(
          week: 1,
          title: "Week 1 Assignment",
          questionCount: 10,
          questions: _createWeek1Fallback(),
        )
      };
      _isLoaded = true;
    }
  }

  WeekData? getWeek(int week) {
    if (week == 0) {
      // Special: All weeks combined
      final allQs = getAllQuestions();
      return WeekData(
        week: 0,
        title: "All Weeks (111 Questions)",
        questionCount: allQs.length,
        questions: allQs,
      );
    }
    return _weeks[week];
  }

  List<Question> _createWeek1Fallback() {
    final answers = ['a', 'd', 'b', 'c', 'a', 'd', 'b', 'b', 'b', 'a'];
    return List.generate(10, (index) {
      final qNum = index + 1;
      final ans = answers[index];
      return Question(
        id: 'w1_q$qNum',
        week: 1,
        questionNumber: qNum,
        title: 'Question $qNum',
        imageAsset: 'assets/questions/week1/q$qNum.png',
        acceptedAnswer: ans,
        acceptedText: 'Accepted answer: ($ans)',
        options: ['a', 'b', 'c', 'd'],
      );
    });
  }
}
