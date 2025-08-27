import 'package:floor/floor.dart';

@Entity(
  tableName: 'questions',
  indices: [
    Index(value: ['subject'])
  ],
)
class Question {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String subject;
  final String question;
  final String answer;

  Question({
    this.id,
    required this.subject,
    required this.question,
    required this.answer,
  });
}

extension QuestionCopyWith on Question {
  Question copyWith({
    int? id,
    String? subject,
    String? question,
    String? answer,
  }) {
    return Question(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      question: question ?? this.question,
      answer: answer ?? this.answer,
    );
  }
}
