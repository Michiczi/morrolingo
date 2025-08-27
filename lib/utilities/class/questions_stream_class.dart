import 'package:morrolingo/database/question.dart';

class QuestionsStream {
  List<Question> questionsToDelete;
  List<Question> questionsToAdd;
  List<Question> questionsToUpdate;
  QuestionsStream({
    List<Question>? questionsToAdd,
    List<Question>? questionsToUpdate,
    List<Question>? questionsToDelete,
  }) : questionsToAdd = questionsToAdd ?? [],
       questionsToUpdate = questionsToUpdate ?? [],
       questionsToDelete = questionsToDelete ?? [];
}
