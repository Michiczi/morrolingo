import 'package:flutter/material.dart';
import 'package:morrolingo/widgets/custom_button.dart';

class GuessingView extends StatelessWidget {
  final String question;
  final TextEditingController answerController;
  final FocusNode answerFocusNode; // Add this
  final bool showResult;
  final VoidCallback onConfirm;

  const GuessingView({
    super.key,
    required this.question,
    required this.answerController,
    required this.answerFocusNode, // Add this
    required this.showResult,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            question,
            style: const TextStyle(fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            textAlign: TextAlign.center,
            controller: answerController,
            focusNode: answerFocusNode, // Assign the FocusNode
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Twoja odpowiedź',
            ),
          ),
          const SizedBox(height: 20),
          if (!showResult)
            CustomButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                onConfirm();
              },
              text: 'Zatwierdź',
            ),
        ],
      ),
    );
  }
}
