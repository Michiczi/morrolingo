import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:morrolingo/database/app_database.dart';
import 'package:morrolingo/database/question.dart';
import 'package:morrolingo/pages/question_data_screen.dart';
import 'package:morrolingo/widgets/custom_button.dart';
import 'package:morrolingo/widgets/guessing_screen/exit_confirmation_dialog.dart';
import 'package:morrolingo/widgets/guessing_screen/guessing_app_bar.dart';
import 'package:morrolingo/pages/streak_screen.dart';
import 'package:morrolingo/widgets/guessing_screen/guessing_view.dart';
import 'package:morrolingo/widgets/guessing_screen/matching_view.dart';
import 'package:morrolingo/widgets/guessing_screen/multiple_choice_view.dart';
import 'package:morrolingo/widgets/guessing_screen/result_bottom_sheet.dart';
import 'package:morrolingo/widgets/summary_view/summary_view.dart';

enum LearningMode { loading, guessing, multipleChoice, matching, summary }

class GuessingScreen extends StatefulWidget {
  const GuessingScreen({super.key});
  static const String id = 'guessing_screen';

  @override
  State<GuessingScreen> createState() => _GuessingScreenState();
}

class _GuessingScreenState extends State<GuessingScreen> {
  late final String subjectName;

  // State variables
  List<Question> _questions = []; // Pool of remaining questions
  final List<Question> _answeredQuestions = [];
  final List<Question> _wrongAnswers = [];
  List<Question> _questionPool = []; // Full list for MC options etc.
  int _questionListLength = 0;

  LearningMode _currentMode = LearningMode.loading;
  int _currentStreak = 0;
  int _highestStreak = 0;
  late DateTime _sessionStartTime;

  Question? _currentQuestion;

  bool _isLoading = true;
  late TextEditingController _answerController;
  late FocusNode _answerFocusNode;
  late FocusNode _dummyFocusNode;
  bool _showResult = false;
  String modeDescription = "";
  bool _isAnswerSheetVisible = false;
  int _visualProgressIncrement = 0;

  // Mode-specific state
  List<String> _mcOptions = [];
  String? _selectedMcOption;
  List<Question> _matchingQuestions = [];

  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
    _answerFocusNode = FocusNode();
    _dummyFocusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      subjectName =
          (ModalRoute.of(context)?.settings.arguments ?? '') as String;
      _loadQuestions();
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    _answerFocusNode.dispose();
    _dummyFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final database = await AppDatabase.instance;
    final loadedQuestions = await database.questionDao.getQuestionsBySubject(
      subjectName,
    );

    loadedQuestions.shuffle();

    if (!mounted) return;
    setState(() {
      _questions = List.from(loadedQuestions);
      _questionPool = List.from(loadedQuestions);
      _questionListLength = loadedQuestions.length;
      _sessionStartTime = DateTime.now();
      _isLoading = false;
      _selectNextMode();
    });
  }

  void _selectNextMode() {
    if (_questions.isEmpty) {
      setState(() {
        _currentMode = LearningMode.summary;
        _updateModeDescription();
      });
      return;
    }

    _selectedMcOption = null;
    _mcOptions = [];
    _matchingQuestions = [];

    final random = Random();
    LearningMode newMode;

    if (_questionPool.length >= 4 && _questions.length >= 4) {
      final modeIndex = random.nextInt(3);
      if (modeIndex == 0) {
        newMode = LearningMode.guessing;
      } else if (modeIndex == 1) {
        newMode = LearningMode.multipleChoice;
      } else {
        newMode = LearningMode.matching;
      }
    } else if (_questionListLength >= 4) {
      final modeIndex = random.nextInt(2);
      newMode = (modeIndex == 0)
          ? LearningMode.guessing
          : LearningMode.multipleChoice;
    } else {
      newMode = LearningMode.guessing;
    }

    if (newMode != LearningMode.guessing) {
      _answerFocusNode.unfocus();
    }

    if (newMode != LearningMode.matching) {
      _currentQuestion = _questions.first;
    }

    if (newMode == LearningMode.multipleChoice) {
      _prepareMcOptions();
    } else if (newMode == LearningMode.matching) {
      _prepareMatchingQuestions();
    }

    setState(() {
      _currentMode = newMode;
      _showResult = false;
      _answerController.clear();
      _updateModeDescription();
    });

    if (newMode == LearningMode.guessing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FocusScope.of(context).requestFocus(_answerFocusNode);
        }
      });
    }
  }

  void _prepareMcOptions() {
    if (_currentQuestion == null) return;
    final correctAnswer = _currentQuestion!.answer;
    final options = <String>{correctAnswer};

    final wrongAnswerPool = _questionPool
        .where((q) => q.answer != correctAnswer)
        .map((q) => q.answer)
        .toList();
    wrongAnswerPool.shuffle();

    for (var answer in wrongAnswerPool) {
      if (options.length < 4) {
        options.add(answer);
      } else {
        break;
      }
    }

    int dummyCount = 1;
    while (options.length < 4) {
      options.add('Opcja $dummyCount');
      dummyCount++;
    }

    _mcOptions = options.toList()..shuffle();
  }

  void _prepareMatchingQuestions() {
    final questionSublist = List<Question>.from(_questions);
    questionSublist.shuffle();
    _matchingQuestions = questionSublist.take(4).toList();
  }

  Future<void> _handleAnswerSubmission() async {
    FocusScope.of(
      context,
    ).requestFocus(_dummyFocusNode); // Move focus to hide keyboard
    if (_currentQuestion == null) return;

    final isCorrect =
        _answerController.text.trim().toLowerCase() ==
        _currentQuestion!.answer.trim().toLowerCase();

    if (isCorrect) {
      setState(() {
        _visualProgressIncrement = 1;
      });
    }

    setState(() {
      _showResult = true;
    });

    final bool? shouldProceed = await _showResultView(isCorrect);

    setState(() {
      _visualProgressIncrement = 0;
    });

    if (shouldProceed == true) {
      setState(() {
        Question processedQuestion = _questions.removeAt(0);
        if (isCorrect) {
          _currentStreak++;
          if (_currentStreak > _highestStreak) {
            _highestStreak = _currentStreak;
          }
          _answeredQuestions.add(processedQuestion);
        } else {
          _currentStreak = 0;
          if (!_wrongAnswers.any((q) => q.id == processedQuestion.id)) {
            _wrongAnswers.add(processedQuestion);
          }
          _questions.add(processedQuestion);
        }
      });

      await WidgetsBinding.instance.endOfFrame;
      _proceedToNextStep();
    }
  }

  Future<void> _handleMcAnswer(String selectedAnswer) async {
    if (_currentQuestion == null) return;

    final isCorrect =
        selectedAnswer.trim().toLowerCase() ==
        _currentQuestion!.answer.trim().toLowerCase();

    if (isCorrect) {
      setState(() {
        _visualProgressIncrement = 1;
      });
    }

    // 🔹 zaznaczamy odpowiedź i pokazujemy wynik
    setState(() {
      _selectedMcOption = selectedAnswer;
      _showResult = true;
    });

    // 🔹 pokazujemy bottomsheet
    final bool? shouldProceed = await _showResultView(isCorrect);

    // 🔹 resetujemy pasek dopiero po wyświetleniu
    setState(() {
      _visualProgressIncrement = 0;
    });

    // 🔹 przejście dalej tylko jeśli odpowiedź była poprawna
    if (shouldProceed == true && isCorrect) {
      setState(() {
        Question processedQuestion = _questions.removeAt(0);

        _currentStreak++;
        if (_currentStreak > _highestStreak) {
          _highestStreak = _currentStreak;
        }
        _answeredQuestions.add(processedQuestion);

        // 🟢 tutaj dopiero resetujemy zaznaczenie, bo pytanie się zmienia
        _selectedMcOption = null;
        _showResult = false;
      });

      await WidgetsBinding.instance.endOfFrame;
      _proceedToNextStep();
    }
    // 🔹 jeśli było źle → pytanie zostaje i czerwone zaznaczenie też
    else if (!isCorrect) {
      setState(() {
        _currentStreak = 0;
        if (!_wrongAnswers.any((q) => q.id == _currentQuestion!.id)) {
          _wrongAnswers.add(_currentQuestion!);
        }
        // pytanie zostaje w puli → gracz musi spróbować ponownie
      });
    }
  }

  Future<void> _handleMatchingFinished(bool allCorrect) async {
    if (allCorrect) {
      setState(() {
        _visualProgressIncrement = 4;
      });
    }

    final bool? shouldProceed = await _showResultView(
      allCorrect,
      customCorrectAnswer: allCorrect
          ? "Wszystkie pary dopasowane!"
          : "Spróbuj ponownie później",
    );

    setState(() {
      _visualProgressIncrement = 0;
    });

    if (shouldProceed == true) {
      setState(() {
        final matchingIds = _matchingQuestions.map((q) => q.id).toSet();
        if (allCorrect) {
          _currentStreak += 4;
          if (_currentStreak > _highestStreak) {
            _highestStreak = _currentStreak;
          }
          _answeredQuestions.addAll(_matchingQuestions);
          _questions.removeWhere((q) => matchingIds.contains(q.id));
        } else {
          _currentStreak = 0;
          for (final q in _matchingQuestions) {
            if (!_wrongAnswers.any((item) => item.id == q.id)) {
              _wrongAnswers.add(q);
            }
          }
          _questions.removeWhere((q) => matchingIds.contains(q.id));
          _questions.addAll(_matchingQuestions);
        }
      });

      await WidgetsBinding.instance.endOfFrame;
      _proceedToNextStep();
    }
  }

  Future<void> _handleMatchingResult(bool isCorrect, Question question) async {
    // This method is called when an individual match is made (correct or incorrect)
    // For this bug, we are focusing on incorrect matches.
    if (!isCorrect) {
      setState(() {
        _currentStreak = 0;
        if (!_wrongAnswers.any((q) => q.id == question.id)) {
          _wrongAnswers.add(question);
        }
      });

      final bool? shouldProceed = await _showResultView(
        isCorrect,
        questionToShow: question,
      );

      if (shouldProceed == true) {
        // If user clicks "Next" on the incorrect result bottom sheet,
        // we should proceed to the next question/mode.
        _selectNextMode();
      }
    }
    // If it's a correct match, we don't show a bottom sheet immediately.
    // The _handleMatchingFinished will be called when all pairs are matched.
  }

  bool _checkStreak() {
    if (_currentStreak == 0) return false;
    int temp = _currentStreak;
    for (int i = 0; i < 4; i++) {
      if (temp > 0 && temp % 5 == 0) {
        return true;
      }
      temp--;
    }
    return false;
  }

  Future<void> _proceedToNextStep() async {
    if (_checkStreak()) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StreakScreen(streakCount: _currentStreak),
        ),
      );
    } else {
      await Future.delayed(Duration.zero);
    }
    _selectNextMode();
  }

  Future<bool?> _showResultView(
    bool isCorrect, {
    String? customCorrectAnswer,
    Question? questionToShow,
  }) async {
    if (_currentMode != LearningMode.matching &&
        _currentQuestion == null &&
        questionToShow == null) {
      return null;
    }
    setState(() {
      _isAnswerSheetVisible = true;
    });

    final bool? shouldProceed = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.zero),
      ),
      isDismissible: false,
      barrierColor: const Color.fromARGB(0, 0, 0, 0).withAlpha(0),
      useSafeArea: true,
      elevation: 20.0,
      builder: (context) {
        return ResultBottomSheet(
          isCorrect: isCorrect,
          correctAnswer:
              customCorrectAnswer ??
              (questionToShow ?? _currentQuestion)?.answer ??
              '',
        );
      },
    );

    setState(() {
      _isAnswerSheetVisible = false;
    });

    return shouldProceed;
  }

  void _updateModeDescription() {
    switch (_currentMode) {
      case LearningMode.guessing:
        modeDescription = "Podaj poprawną odpowiedź";
        break;
      case LearningMode.multipleChoice:
        modeDescription = "Wybierz poprawną odpowiedź";
        break;
      case LearningMode.matching:
        modeDescription = "Dopasuj odpowiedzi";
        break;
      case LearningMode.summary:
        modeDescription = "Podsumowanie";
        break;
      default:
        modeDescription = "";
    }
  }

  Future<void> _handleExitAttempt() async {
    if (_isAnswerSheetVisible) {
      Navigator.of(context).pop();
    }
    if (_answeredQuestions.isEmpty && _wrongAnswers.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final bool shouldPop =
        await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          builder: (context) => const ExitConfirmationDialog(),
        ) ??
        false;

    if (shouldPop && mounted) {
      Navigator.of(context).pop();
    } else if (mounted && _showResult && _currentQuestion != null) {
      final isCorrect =
          _answerController.text.trim().toLowerCase() ==
          _currentQuestion!.answer.trim().toLowerCase();
      _showResultView(isCorrect);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      // ignore: deprecated_member_use
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        _handleExitAttempt();
      },
      child: Scaffold(
        appBar: _currentMode == LearningMode.summary
            ? null
            : GuessingAppBar(
                onExit: _handleExitAttempt,
                progress: _questionListLength == 0
                    ? 0.0
                    : (_answeredQuestions.length + _visualProgressIncrement) /
                          _questionListLength,
                modeDescription: modeDescription,
              ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_questionListLength == 0) {
      return Scaffold(
        appBar: AppBar(title: const Text("Lekcja"), centerTitle: true),
        body: Padding(
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
        ),
      );
    }
    switch (_currentMode) {
      case LearningMode.guessing:
        if (_currentQuestion == null) {
          return const Center(child: Text('Błąd ładowania pytania.'));
        }
        return GuessingView(
          question: _currentQuestion!.question,
          answerController: _answerController,
          showResult: _showResult,
          onConfirm: _handleAnswerSubmission,
          answerFocusNode: _answerFocusNode,
        );
      case LearningMode.summary:
        return _buildSummaryView();
      case LearningMode.multipleChoice:
        if (_currentQuestion == null) {
          return const Center(child: Text('Błąd ładowania pytania.'));
        }
        return MultipleChoiceView(
          question: _currentQuestion!.question,
          options: _mcOptions,
          selectedOption: _selectedMcOption,
          showResult: _showResult,
          correctAnswer: _currentQuestion!.answer,
          onOptionSelected: _handleMcAnswer,
        );
      case LearningMode.matching:
        if (_matchingQuestions.isEmpty) {
          return const Center(
            child: Text('Błąd ładowania pytań do dopasowania.'),
          );
        }
        return MatchingView(
          questions: _matchingQuestions,
          onGameFinished: _handleMatchingFinished,
          onMatchResult: _handleMatchingResult,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSummaryView() {
    final duration = DateTime.now().difference(_sessionStartTime);
    final accuracy = _questionListLength > 0
        ? ((_questionListLength - _wrongAnswers.length) / _questionListLength) *
              100
        : 0.0;

    return SummaryView(
      highestStreak: _highestStreak,
      accuracy: accuracy,
      sessionTime: duration.inSeconds,
      onReturn: () => Navigator.of(context).pop(),
    );
  }
}
