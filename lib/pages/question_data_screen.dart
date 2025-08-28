import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:morrolingo/database/app_database.dart';
import 'package:morrolingo/database/question.dart';
import 'package:morrolingo/utilities/class/questions_stream_class.dart';
import 'package:morrolingo/utilities/theme/custom/colors_palette.dart';
import 'package:morrolingo/widgets/question_data_screen/question_dialog.dart';
import 'package:morrolingo/widgets/question_data_screen/question_list_item.dart';
import 'package:share_plus/share_plus.dart';

class QuestionDataScreen extends StatefulWidget {
  const QuestionDataScreen({super.key});
  static final String id = 'question_data_screen';

  @override
  State<QuestionDataScreen> createState() => _QuestionDataScreenState();
}

class _QuestionDataScreenState extends State<QuestionDataScreen> {
  String? subjectName;
  late AppDatabase _database;
  Future<List<Question>>? _questionsFuture;
  bool _isDbInitialized = false;

  // 1. Nowe zmienne stanu do zarządzania trybem zaznaczania
  bool _isSelectionMode = false;
  final Set<int> _selectedQuestionIds = {};

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    _database = await AppDatabase.instance;
    setState(() {
      _isDbInitialized = true;
    });
    if (subjectName != null) {
      _loadQuestions();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newSubjectName =
        ModalRoute.of(context)?.settings.arguments as String?;
    if (newSubjectName != null && newSubjectName != subjectName) {
      subjectName = newSubjectName;
      if (_isDbInitialized) {
        _loadQuestions();
      }
    }
  }

  void _loadQuestions() {
    setState(() {
      _questionsFuture = _database.questionDao.getQuestionsBySubject(
        subjectName!,
      );
    });
  }

  // 2. Logika obsługi interakcji
  void _onTap(Question question) {
    if (_isSelectionMode) {
      setState(() {
        if (_selectedQuestionIds.contains(question.id)) {
          _selectedQuestionIds.remove(question.id);
        } else {
          _selectedQuestionIds.add(question.id!);
        }
        if (_selectedQuestionIds.isEmpty) {
          _isSelectionMode = false;
        }
      });
    } else {
      _showEditQuestionDialog(question);
    }
  }

  void _onLongPress(Question question) {
    if (!_isSelectionMode) {
      setState(() {
        _isSelectionMode = true;
        _selectedQuestionIds.add(question.id!);
      });
    }
  }

  void _clearSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedQuestionIds.clear();
    });
  }

  // Nowa metoda do usuwania
  void _deleteSelectedQuestions() async {
    final allQuestions = await _questionsFuture;
    if (allQuestions == null) return;

    final questionsToDelete = allQuestions
        .where((q) => _selectedQuestionIds.contains(q.id))
        .toList();

    if (questionsToDelete.isEmpty) {
      return;
    }

    final bool? confirmed = await showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) => AlertDialog(
        content: Text(
          'Czy na pewno chcesz usunąć ${questionsToDelete.length} pytań?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Usuń', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _database.questionDao.deleteMultipleQuestions(questionsToDelete);
      setState(() {
        _loadQuestions();
        _clearSelection();
      });
    }
  }

  void _shareQuestions() async {
    final allQuestions = await _questionsFuture;
    if (allQuestions == null) return;

    final questionsToShare = allQuestions
        .where((q) => _selectedQuestionIds.contains(q.id))
        .toList();

    if (questionsToShare.isEmpty) return;

    final textToShare = questionsToShare
        .map((q) => '${q.question} - ${q.answer}')
        .join('\n');
    SharePlus.instance.share(
      ShareParams(title: 'Pytania', text: textToShare.toString()),
    );
  }

  void _editSelectedQuestions() async {
    final allQuestions = await _questionsFuture;
    if (allQuestions == null) return;

    final questionsToEdit = allQuestions
        .where((q) => _selectedQuestionIds.contains(q.id))
        .toList();

    if (questionsToEdit.isEmpty) {
      _showAddQuestionDialog();
    } else if (questionsToEdit.length == 1) {
      _showEditQuestionDialog(questionsToEdit.first);
    } else {
      if (!mounted) return;
      final result = await showDialog<dynamic>(
        context: context,
        builder: (context) => AddQuestionDialog.bulk(
          questions: questionsToEdit,
          onSavePartial: (partialResult) async {
            if (partialResult is QuestionsStream) {
              if (partialResult.questionsToUpdate.isNotEmpty) {
                await _database.questionDao.updateMultipleQuestions(
                  partialResult.questionsToUpdate,
                );
              }
              if (partialResult.questionsToDelete.isNotEmpty) {
                await _database.questionDao.deleteMultipleQuestions(
                  partialResult.questionsToDelete,
                );
              }
              if (partialResult.questionsToAdd.isNotEmpty) {
                await _database.questionDao.insertMultipleQuestions(
                  partialResult.questionsToAdd,
                );
              }
              _loadQuestions();
              _clearSelection();
            }
          },
        ),
      );
      if (result == null) return;
      // Obsługa wyniku z edycji wielu pytań
      if (result is QuestionsStream) {
        if (result.questionsToUpdate.isNotEmpty) {
          await _database.questionDao.updateMultipleQuestions(
            result.questionsToUpdate,
          );
        }
        if (result.questionsToDelete.isNotEmpty) {
          await _database.questionDao.deleteMultipleQuestions(
            result.questionsToDelete,
          );
        }
        if (result.questionsToAdd.isNotEmpty) {
          await _database.questionDao.insertMultipleQuestions(
            result.questionsToAdd,
          );
        }

        _loadQuestions();
        _clearSelection();
      }
    }
  }

  void _showAddQuestionDialog() async {
    if (subjectName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Błąd: Nie wybrano przedmiotu.')),
      );
      return;
    }
    _showManualAddQuestionDialog();
  }

  void _showManualAddQuestionDialog() async {
    final result = await showDialog<dynamic>(
      context: context,
      builder: (context) => AddQuestionDialog(
        onSavePartial: (partialResult) async {
          if (partialResult is List<Map<String, String>>) {
            final List<Question> newQuestions = [];
            for (final map in partialResult) {
              final question = map['question'];
              final answer = map['answer'];
              if (question != null && answer != null) {
                newQuestions.add(
                  Question(
                    subject: subjectName!,
                    question: question,
                    answer: answer,
                  ),
                );
              }
            }
            await _database.questionDao.insertMultipleQuestions(newQuestions);
            _loadQuestions();
          }
        },
      ),
    );

    if (result == null || !mounted) return;

    if (result is Map<String, String>) {
      final questionText = result['question'];
      final answerText = result['answer'];
      if (questionText != null && answerText != null) {
        final newQuestion = Question(
          question: questionText,
          answer: answerText,
          subject: subjectName!,
        );
        await _database.questionDao.insertQuestion(newQuestion);
        _loadQuestions();
      }
    } else if (result is List<Map<String, String>>) {
      final List<Question> newQuestions = [];
      for (final map in result) {
        final question = map['question'];
        final answer = map['answer'];
        if (question != null && answer != null) {
          newQuestions.add(
            Question(subject: subjectName!, question: question, answer: answer),
          );
        }
      }

      if (newQuestions.isNotEmpty) {
        await _database.questionDao.insertMultipleQuestions(newQuestions);
        _loadQuestions();
      }
    }
  }

  void _showEditQuestionDialog(Question questionToEdit) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AddQuestionDialog.single(question: questionToEdit),
    );
    if (result != null) {
      final updatedQuestion = Question(
        id: questionToEdit.id,
        subject: questionToEdit.subject,
        question: result['question']!,
        answer: result['answer']!,
      );

      await _database.questionDao.updateQuestion(updatedQuestion);
      _loadQuestions();
    }
  }

  void _toggleSelectAll() async {
    final allQuestions = await _questionsFuture;
    if (allQuestions == null || allQuestions.isEmpty) return;

    final allIds = allQuestions.map((q) => q.id!).toSet();
    final areAllSelected = _selectedQuestionIds.length == allIds.length;

    if (areAllSelected) {
      _clearSelection();
    } else {
      setState(() {
        _selectedQuestionIds.addAll(allIds);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 3. Dynamiczny AppBar
      appBar: _isSelectionMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              ),
              title: Text('${_selectedQuestionIds.length} wybrano'),
              backgroundColor: TColors.success,
              actions: [
                IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: _toggleSelectAll,
                ),
              ],
            )
          : AppBar(
              title: Text(subjectName ?? 'Baza pytań'),
              backgroundColor: TColors.success,
            ),
      body: !_isDbInitialized
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Question>>(
              future: _questionsFuture,
              builder: (context, snapshot) {
                if (subjectName == null ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Błąd: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Brak pytań w bazie.',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }
                final questions = snapshot.data!;
                return AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      final isSelected = _selectedQuestionIds.contains(
                        question.id,
                      );
                      // 4. Przekazujemy nowe parametry do widgetu
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: QuestionListItem(
                              question: question,
                              isSelected: isSelected,
                              isSelectionMode: _isSelectionMode,
                              onTap: () => _onTap(question),
                              onLongPress: () => _onLongPress(question),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      // 5. Dynamiczny FloatingActionButton i BottomAppBar
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton(
              onPressed: _showAddQuestionDialog,
              backgroundColor: TColors.success,
              child: const Icon(Icons.add, color: Colors.white),
            ),
      bottomNavigationBar: _isSelectionMode
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: TColors.error,
                    ), // This line is causing the error
                    onPressed: _deleteSelectedQuestions,
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: _shareQuestions,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _editSelectedQuestions,
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
