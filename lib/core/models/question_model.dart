enum QuestionStatus { pending, answered, inProgress }

class QuestionModel {
  final String id;
  final String voterId;
  final String voterName;
  final String deputyId;
  final String deputyName;
  final String text;
  final DateTime createdAt;
  String? answer;
  QuestionStatus status;
  bool isCompleted;
  int likes;
  String? category;

  QuestionModel({
    required this.id,
    required this.voterId,
    required this.voterName,
    required this.deputyId,
    required this.deputyName,
    required this.text,
    required this.createdAt,
    this.answer,
    this.status = QuestionStatus.pending,
    this.isCompleted = false,
    this.likes = 0,
    this.category,
  });

  String get statusLabel {
    switch (status) {
      case QuestionStatus.pending:
        return 'Ожидает ответа';
      case QuestionStatus.answered:
        return isCompleted ? 'Выполнено' : 'Отвечено';
      case QuestionStatus.inProgress:
        return 'В работе';
    }
  }

  int get ratingValue => isCompleted ? 1 : 0;
}
