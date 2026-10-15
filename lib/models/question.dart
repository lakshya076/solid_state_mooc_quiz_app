class Question {
  final String id;
  final int week;
  final int questionNumber;
  final String title;
  final String imageAsset;
  final String acceptedAnswer;
  final String acceptedText;
  final List<String> options;

  Question({
    required this.id,
    required this.week,
    required this.questionNumber,
    required this.title,
    required this.imageAsset,
    required this.acceptedAnswer,
    required this.acceptedText,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String? ?? '',
      week: json['week'] as int? ?? 1,
      questionNumber: json['question_number'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      imageAsset: json['image_asset'] as String? ?? '',
      acceptedAnswer: (json['accepted_answer'] as String? ?? '').toLowerCase(),
      acceptedText: json['accepted_text'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString().toLowerCase())
              .toList() ??
          ['a', 'b', 'c', 'd'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'week': week,
      'question_number': questionNumber,
      'title': title,
      'image_asset': imageAsset,
      'accepted_answer': acceptedAnswer,
      'accepted_text': acceptedText,
      'options': options,
    };
  }
}

class WeekData {
  final int week;
  final String title;
  final int questionCount;
  final List<Question> questions;

  WeekData({
    required this.week,
    required this.title,
    required this.questionCount,
    required this.questions,
  });

  factory WeekData.fromJson(Map<String, dynamic> json) {
    final list = (json['questions'] as List<dynamic>?)
            ?.map((q) => Question.fromJson(q as Map<String, dynamic>))
            .toList() ??
        [];
    return WeekData(
      week: json['week'] as int? ?? 1,
      title: json['title'] as String? ?? 'Week Assignment',
      questionCount: json['question_count'] as int? ?? list.length,
      questions: list,
    );
  }
}
