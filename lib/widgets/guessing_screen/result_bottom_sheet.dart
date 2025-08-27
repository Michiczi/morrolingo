import 'package:flutter/material.dart';
import 'package:morrolingo/widgets/custom_button.dart';

class ResultBottomSheet extends StatelessWidget {
  final bool isCorrect;
  final String correctAnswer;

  const ResultBottomSheet({
    super.key,
    required this.isCorrect,
    required this.correctAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          bottom: 52.0,
          top: 24.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isCorrect ? 'Dobrze!' : 'Zła odpowiedź',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isCorrect ? Colors.green : Colors.red,
              ),
            ),
            if (!isCorrect)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Poprawna odpowiedź: $correctAnswer',
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                  textAlign: TextAlign.left,
                ),
              ),
            const SizedBox(height: 20),
            CustomButton(
              onPressed: () {
                Navigator.pop(context, true); // Pop with a result
              },
              text: 'Dalej',
              style: CustomButtonStyle(
                buttonColor: isCorrect ? Colors.green : Colors.red,
                bottomColor: isCorrect
                    ? Colors.green.shade800
                    : Colors.red.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
