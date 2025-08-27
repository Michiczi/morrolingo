import 'package:flutter/material.dart';

enum ButtonState { initial, selected, correct, incorrect }

class LearningModeButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonState state;
  final bool disabled;

  const LearningModeButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.state = ButtonState.initial,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors(context);

    return ElevatedButton(
      onPressed: disabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors['background'],
        foregroundColor: colors['foreground'],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        elevation: 4,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Map<String, Color> _getColors(BuildContext context) {
    switch (state) {
      case ButtonState.selected:
        return {
          'background': Colors.blue.shade100,
          'foreground': Colors.blue.shade900,
        };
      case ButtonState.correct:
        return {
          'background': Colors.green.shade100,
          'foreground': Colors.green.shade900,
        };
      case ButtonState.incorrect:
        return {
          'background': Colors.red.shade100,
          'foreground': Colors.red.shade900,
        };
      case ButtonState.initial:
      // ignore: unreachable_switch_default
      default:
        return {
          'background': Theme.of(context).cardColor,
          'foreground': Theme.of(context).colorScheme.onSurface,
        };
    }
  }
}