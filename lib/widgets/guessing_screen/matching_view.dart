import 'package:flutter/material.dart';
import 'package:morrolingo/database/question.dart';
import 'package:morrolingo/widgets/custom_button.dart';

class MatchingView extends StatefulWidget {
  final List<Question> questions;
  final Function(bool allCorrect) onGameFinished;

  const MatchingView({
    super.key,
    required this.questions,
    required this.onGameFinished,
  });

  @override
  State<MatchingView> createState() => _MatchingViewState();
}

class _MatchingViewState extends State<MatchingView> {
  // maps and shuffled id-lists
  late Map<int, String> idToQuestion;
  late Map<int, String> idToAnswer;
  late List<int> shuffledQuestionIds;
  late List<int> shuffledAnswerIds;

  // selections by id
  int? selectedQuestionId;
  int? selectedAnswerId;

  // state
  final Map<int, bool> correctMatches = {}; // questionId -> true
  int? incorrectQuestionId;
  int? incorrectAnswerId;
  bool gameEnded = false;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    final n = widget.questions.length;

    idToQuestion = {};
    idToAnswer = {};
    for (int i = 0; i < n; i++) {
      idToQuestion[i] = widget.questions[i].question;
      idToAnswer[i] = widget.questions[i].answer;
    }

    shuffledQuestionIds = List<int>.generate(n, (i) => i)..shuffle();
    shuffledAnswerIds = List<int>.generate(n, (i) => i)..shuffle();

    selectedQuestionId = null;
    selectedAnswerId = null;
    correctMatches.clear();
    incorrectQuestionId = null;
    incorrectAnswerId = null;
    gameEnded = false;
  }

  void _onItemSelected(int id, bool isQuestion) {
    if (gameEnded) return;

    if (isQuestion) {
      // ignore selection of already correctly matched question
      if (correctMatches.containsKey(id)) return;
      setState(() {
        selectedQuestionId = (selectedQuestionId == id) ? null : id;
      });
    } else {
      // answer selected -> id maps directly to question id (we used same ids)
      if (correctMatches.containsKey(id)) return;
      setState(() {
        selectedAnswerId = (selectedAnswerId == id) ? null : id;
      });
    }

    // if both selected, check match
    if (selectedQuestionId != null && selectedAnswerId != null) {
      _checkMatch();
    }
  }

  void _checkMatch() {
    final qId = selectedQuestionId!;
    final aId = selectedAnswerId!;

    // correct if ids are equal (since idToAnswer[id] is answer for question id)
    if (qId == aId) {
      bool isGameFinished = false;
      setState(() {
        correctMatches[qId] = true;
        // clear selections
        selectedQuestionId = null;
        selectedAnswerId = null;
        if (correctMatches.length == widget.questions.length) {
          gameEnded = true;
          isGameFinished = true;
        }
      });

      if (isGameFinished) {
        // give a tiny delay so UI can show last green state before navigation
        Future.delayed(const Duration(milliseconds: 120), () {
          if (mounted) widget.onGameFinished(true);
        });
      }
    } else {
      // incorrect: mark pair, block input and notify parent after short delay
      setState(() {
        gameEnded = true;
        incorrectQuestionId = qId;
        incorrectAnswerId = aId;
      });

      // keep incorrect highlight visible for a short moment, then finish
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) widget.onGameFinished(false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // build a flat list: question, answer, question, answer...
    final int n = widget.questions.length;
    List<Widget> items = [];
    for (int i = 0; i < n; i++) {
      final qId = shuffledQuestionIds[i];
      final aId = shuffledAnswerIds[i];
      items.add(_buildItem(qId, true));
      items.add(_buildItem(aId, false));
    }

    // --- Responsive Aspect Ratio Calculation (kept from original) ---
    final double screenWidth = MediaQuery.of(context).size.width;
    const double gridHorizontalPadding =
        16.0 * 2; // Corresponds to padding: const EdgeInsets.all(16)
    const double crossAxisSpacing = 12.0; // As defined in GridView
    const double buttonTotalHeight = 70.0; // CustomButton height (approx)
    const double mainAxisSpacing = 12.0; // As defined in GridView

    final double columnWidth =
        (screenWidth - gridHorizontalPadding - crossAxisSpacing) / 2;
    final double desiredCellHeight = buttonTotalHeight + mainAxisSpacing;
    final double responsiveAspectRatio = columnWidth / desiredCellHeight;
    // --- End calculation ---

    return Center(
      child: AbsorbPointer(
        absorbing: gameEnded,
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: responsiveAspectRatio,
          padding: const EdgeInsets.all(16),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: items,
        ),
      ),
    );
  }

  Widget _buildItem(int id, bool isQuestion) {
    final text = isQuestion ? idToQuestion[id]! : idToAnswer[id]!;
    final bool isSelected = isQuestion
        ? selectedQuestionId == id
        : selectedAnswerId == id;
    final bool isCorrectlyMatched = correctMatches.containsKey(id);
    final bool isIncorrect =
        (incorrectQuestionId == id) || (incorrectAnswerId == id);

    // --- Style selection logic ---
    final baseTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: text.length > 25 ? 12.0 : 14.0,
    );

    Color? buttonColor;
    Color? bottomColor;

    if (isCorrectlyMatched) {
      buttonColor = Colors.green;
      bottomColor = Colors.green.shade800;
    } else if (isIncorrect) {
      buttonColor = Colors.red;
      bottomColor = Colors.red.shade800;
    } else if (isSelected) {
      buttonColor = Colors.blue.shade300;
      bottomColor = Colors.blue.shade600;
    }

    final style = CustomButtonStyle(
      buttonColor: buttonColor,
      bottomColor: bottomColor,
      textStyle: baseTextStyle,
    );
    // --- End of style selection ---

    return Opacity(
      opacity: (isCorrectlyMatched && !isSelected) ? 0.7 : 1.0,
      child: CustomButton(
        text: text,
        onPressed: () => _onItemSelected(id, isQuestion),
        style: style,
      ),
    );
  }
}
