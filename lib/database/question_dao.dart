import 'package:floor/floor.dart';
import 'package:morrolingo/database/question.dart';

@dao
abstract class QuestionDao {
  @insert
  Future<void> insertQuestion(Question question);

  @delete
  Future<void> deleteQuestion(Question question);

  @Query('SELECT * FROM questions WHERE subject = :subject')
  Future<List<Question>> getQuestionsBySubject(String subject);

  @Query('DELETE FROM questions WHERE subject = :subjectName')
  Future<void> deleteQuestionsBySubject(String subjectName);

  @Query('UPDATE questions SET subject = :newName WHERE subject = :oldName')
  Future<void> updateSubjectName(String oldName, String newName);

  @update
  Future<void> updateQuestion(Question question);

  @delete
  Future<void> deleteMultipleQuestions(List<Question> questions);

  @insert
  Future<void> insertMultipleQuestions(List<Question> questions);

  @Query('SELECT DISTINCT subject FROM questions')
  Future<List<String>> getSubjectList();

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updateMultipleQuestions(List<Question> questions);
}
