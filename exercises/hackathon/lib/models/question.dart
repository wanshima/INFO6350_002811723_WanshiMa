class Question {
  final String question;
  final String type;
  final List<String> options;
  final List<String> correct;

  Question({
    required this.question,
    required this.type,
    required this.options,
    required this.correct,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      type: json['type'],
      options: List<String>.from(json['options']),
      correct: List<String>.from(json['correct']),
    );
  }
}
