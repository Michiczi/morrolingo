import 'package:flutter/material.dart';
import 'package:morrolingo/widgets/custom_button.dart';

class ExitConfirmationDialog extends StatelessWidget {
  const ExitConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Opuścić sesję?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Zostań',
            onPressed: () => Navigator.of(context).pop(false),
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Opuść sesję',
            onPressed: () => Navigator.of(context).pop(true),
            style: CustomButtonStyle(
              buttonColor: Colors.red,
              bottomColor: Colors.red.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
