import 'package:flutter/material.dart';
import 'package:morrolingo/database/question.dart';
import 'package:morrolingo/utilities/theme/custom/colors_palette.dart';

class QuestionListItem extends StatelessWidget {
  // 1. Dodajemy nowe parametry
  const QuestionListItem({
    super.key,
    required this.question,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
  });

  final Question question;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    // 2. Używamy InkWell, aby cała karta była klikalna
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
        elevation: 2.0,
        // 4. Zmieniamy kolor karty, jeśli jest zaznaczona
        color: isSelected ? Colors.green : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          // Używamy Row, aby umieścić Checkbox obok tekstu
          child: Row(
            children: [
              // Expanded sprawia, że kolumna z tekstem zajmuje całą dostępną przestrzeń
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.question,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      question.answer,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[350]
                            : Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              // 3. Pokazujemy Checkbox tylko w trybie zaznaczania
              if (isSelectionMode)
                Checkbox(
                  value: isSelected,
                  onChanged: (bool? value) {
                    // Logikę zmiany stanu obsługuje onTap na całym InkWell,
                    // więc tutaj przekazujemy mu to samo zadanie.
                    onTap();
                  },
                  activeColor: TColors.greenAccent,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
