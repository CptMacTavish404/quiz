class Question {
  String question;
  List<String> answers;
  String correctAnswer;

  Question({required this.question, required this.answers, required this.correctAnswer});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      answers: json['answers'].cast<String>(),
      correctAnswer: json['correctAnswer'],
    );
  }
}