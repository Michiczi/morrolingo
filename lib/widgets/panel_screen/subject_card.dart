import 'package:flutter/material.dart';
import 'package:morrolingo/widgets/custom_button.dart';
import 'package:morrolingo/utilities/theme/custom/colors_palette.dart';

class SubjectCard extends StatelessWidget {
  final String subjectName;
  final VoidCallback onEditQuestions;
  final VoidCallback onEditName;
  final VoidCallback onDelete;
  final VoidCallback onLessonPressed;
  final VoidCallback onFlashcardsPressed;

  const SubjectCard({
    super.key,
    required this.subjectName,
    required this.onEditQuestions,
    required this.onEditName,
    required this.onDelete,
    required this.onLessonPressed,
    required this.onFlashcardsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final customButtonStyle = CustomButtonStyle(
      buttonColor: TColors.success,
      bottomColor: TColors.greenButtonBottom,
      // Slightly more transparent for the 3D effect
      textStyle: const TextStyle(
        color: TColors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      borderRadius: BorderRadius.circular(8.0),
    );

    return Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 4.0,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      subjectName,
                      style: const TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.settings),
                    tooltip: 'Ustawienia',
                    onSelected: (value) {
                      if (value == 1) {
                        onEditQuestions();
                      } else if (value == 2) {
                        onEditName();
                      } else if (value == 3) {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 1, child: Text('Edytuj bazę pytań')),
                      PopupMenuItem(
                        value: 2,
                        child: Text('Edytuj nazwę przedmiotu'),
                      ),
                      PopupMenuItem(value: 3, child: Text('Usuń przedmiot')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      icon: Icons.book,
                      text: 'Lekcja',
                      onPressed: onLessonPressed,
                      style: customButtonStyle,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: CustomButton(
                      icon: Icons.style,
                      text: 'Fiszki',
                      onPressed: onFlashcardsPressed,
                      style: customButtonStyle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
