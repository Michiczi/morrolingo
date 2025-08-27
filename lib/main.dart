import 'package:flutter/material.dart';
import 'package:morrolingo/pages/flashcards_screen.dart';
import 'package:morrolingo/pages/guessing_screen.dart';
import 'package:morrolingo/pages/panel_screen.dart';
import 'package:morrolingo/pages/question_data_screen.dart';
import 'package:morrolingo/utilities/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Morrolingo',
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      home: const PanelScreen(),
      routes: {
        PanelScreen.id: (context) => const PanelScreen(),
        QuestionDataScreen.id: (context) => const QuestionDataScreen(),
        GuessingScreen.id: (context) => const GuessingScreen(),
        FlashcardsScreen.id: (context) => const FlashcardsScreen(),
      },
    );
  }
}
