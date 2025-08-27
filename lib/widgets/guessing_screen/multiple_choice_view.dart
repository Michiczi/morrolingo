import 'package:flutter/material.dart';
import 'package:morrolingo/utilities/theme/custom/colors_palette.dart';
import 'package:morrolingo/widgets/custom_button.dart';

class MultipleChoiceView extends StatelessWidget {
  final String question;
  final List<String> options;
  final Function(String) onOptionSelected;
  final String? selectedOption;
  final bool showResult;
  final String correctAnswer;

  const MultipleChoiceView({
    super.key,
    required this.question,
    required this.options,
    required this.onOptionSelected,
    this.selectedOption,
    required this.showResult,
    required this.correctAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            question,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ...options.map((option) {
            CustomButtonStyle style = const CustomButtonStyle();
            if (showResult) {
              if (option == correctAnswer) {
                style = CustomButtonStyle(
                  buttonColor: TColors.success,
                  bottomColor: TColors.greenButtonBottom,
                );
              } else if (option == selectedOption) {
                style = CustomButtonStyle(
                  buttonColor: TColors.error,
                  bottomColor: TColors.redButtonBottom,
                );
              }
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Opacity(
                opacity:
                    showResult &&
                        option != correctAnswer &&
                        option != selectedOption
                    ? 0.5
                    : 1.0,
                child: CustomButton(
                  text: option,
                  onPressed: showResult
                      ? () {}
                      : () => onOptionSelected(option),
                  style: style,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
