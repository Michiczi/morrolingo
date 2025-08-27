import 'package:flutter/material.dart';
import 'package:morrolingo/database/app_database.dart';
import 'package:morrolingo/database/question.dart';
import 'package:morrolingo/pages/question_data_screen.dart';
import 'package:morrolingo/widgets/custom_button.dart';
import 'package:morrolingo/utilities/theme/custom/colors_palette.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});
  static final String id = 'flashcards_screen';

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  List<Question> _questions = [];
  final Set<Question> _questionsToReview = {};
  String? subjectName;
  late AppDatabase _database;
  bool _isDbInitialized = false;
  bool _isLoading = true;
  String? flashcardText;
  int _knownQuestionsCount = 0;
  int _currentIndex = 0;
  bool _isAnswerVisible = false;
  int _numberOfQuestions = 0;

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

  void _loadQuestions() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final loadedQuestions = await _database.questionDao.getQuestionsBySubject(
      subjectName!,
    );

    if (mounted) {
      setState(() {
        _questions = loadedQuestions;
        _questions.shuffle();
        _numberOfQuestions = _questions.length;
        if (_questions.isNotEmpty) {
          _currentIndex = 0;
          flashcardText = _questions[_currentIndex].question;
        }
        _isLoading = false;
      });
    }
  }

  void _showAnswer() {
    setState(() {
      _isAnswerVisible = true;
      flashcardText = _questions[_currentIndex].answer;
    });
  }

  void _nextQuestion({bool known = true}) {
    bool sessionFinished = false;
    setState(() {
      if (_questions.isEmpty) {
        sessionFinished = true;
        return;
      }

      final currentQuestion = _questions[_currentIndex];

      if (known) {
        _questionsToReview.remove(currentQuestion);
        _questions.removeAt(_currentIndex);
        _knownQuestionsCount++;
      } else {
        _questionsToReview.add(currentQuestion);

        final questionToRequeue = _questions.removeAt(_currentIndex);
        final remainingInQueue = _questions.length - _currentIndex;

        if (remainingInQueue >= 4) {
          final insertionIndex = _currentIndex + (remainingInQueue / 2).round();
          _questions.insert(insertionIndex, questionToRequeue);
        } else {
          _questions.add(questionToRequeue);
        }
      }

      if (_questions.isEmpty) {
        sessionFinished = true;
      } else {
        if (_currentIndex >= _questions.length) {
          _currentIndex = 0;
        }
        flashcardText = _questions[_currentIndex].question;
        _isAnswerVisible = false;
      }
    });

    if (sessionFinished) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gratulację. Ukończyłeś dzienną lekcję z przedmiotu: $subjectName',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fiszki'), centerTitle: true),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_questions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Brak pytań w bazie.', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Dodaj pytania',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  QuestionDataScreen.id,
                  arguments: subjectName,
                );
              },
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  (_numberOfQuestions -
                          (_questionsToReview.length + _knownQuestionsCount))
                      .toString(),
                  style: TextStyle(color: TColors.info),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _questionsToReview.length.toString(),
                  style: TextStyle(color: TColors.error),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _knownQuestionsCount.toString(),
                  style: TextStyle(color: TColors.success),
                ),
              ),
            ],
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(flashcardText!, style: TextStyle(fontSize: 24.0)),
                ],
              ),
            ),
          ),

          if (!_isAnswerVisible)
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomButton(
                  onPressed: _showAnswer,
                  text: 'Pokaż odpowiedź',
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomButton(
                      onPressed: () => _nextQuestion(known: false),
                      icon: Icons.replay,
                      text: 'POWTÓRZ',
                      style: CustomButtonStyle(
                        buttonColor: TColors.warning,
                        bottomColor: TColors.warning,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomButton(
                      onPressed: _nextQuestion,
                      icon: Icons.arrow_forward,

                      text: 'DALEJ',
                      style: CustomButtonStyle(
                        buttonColor: TColors.success,
                        bottomColor: TColors.success,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

