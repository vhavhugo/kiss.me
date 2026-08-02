class QuestionnaireEntity {
  final String question;
  final String? answer;
  final String icon;

  QuestionnaireEntity({
    required this.question,
    this.answer,
    required this.icon,
  });
}
