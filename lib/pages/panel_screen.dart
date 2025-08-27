import 'package:flutter/material.dart';
import 'package:morrolingo/pages/flashcards_screen.dart';
import 'package:morrolingo/pages/guessing_screen.dart';
import 'package:morrolingo/pages/question_data_screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:morrolingo/widgets/panel_screen/subject_card.dart';
import '../database/app_database.dart';
import '../database/question_dao.dart';
import 'package:morrolingo/utilities/theme/custom/colors_palette.dart';

class PanelScreen extends StatefulWidget {
  const PanelScreen({super.key});
  static final String id = 'panel_screen';

  @override
  State<PanelScreen> createState() => _PanelScreenState();
}

class _PanelScreenState extends State<PanelScreen> {
  late SharedPreferences sharedPreferences;
  // ignore: unused_field
  QuestionDao? _questionDao;
  List<String> _subjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final database = await AppDatabase.instance;
    sharedPreferences = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _questionDao = database.questionDao;
        _subjects = sharedPreferences.getStringList('subjects') ?? [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Panel Przedmiotów',
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subjects.isEmpty
          ? const Center(child: Text('Brak przedmiotów...'))
          : AnimationLimiter(
              child: ListView.builder(
                padding: const EdgeInsets.all(12.0),
                itemCount: _subjects.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: SubjectCard(
                          subjectName: _subjects[index],
                          onEditQuestions: () {
                            Navigator.pushNamed(
                              context,
                              QuestionDataScreen.id,
                              arguments: _subjects[index],
                            );
                          },
                          onEditName: () async {
                            final oldName = _subjects[index];
                            final newName = await _showEditNameDialog(
                              oldName,
                              context,
                            );

                            if (newName != null && newName.isNotEmpty) {
                              await _updateSubjectName(oldName, newName);
                            }
                          },
                          onDelete: () async {
                            final subjectToDelete = _subjects[index];
                            final bool confirmed =
                                await _showDeleteConfirmationDialog(
                                  subjectToDelete,
                                  context,
                                );
                            if (confirmed) {
                              await _deleteSubject(subjectToDelete);
                            }
                          },
                          onLessonPressed: () => Navigator.pushNamed(
                            context,
                            GuessingScreen.id,
                            arguments: _subjects[index],
                          ),
                          onFlashcardsPressed: () => Navigator.pushNamed(
                            context,
                            FlashcardsScreen.id,
                            arguments: _subjects[index],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSubjectDialog,
        backgroundColor: TColors.success,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddSubjectDialog() async {
    final TextEditingController subjectNameController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Dodaj nowy przedmiot'),
          content: TextField(
            controller: subjectNameController,
            decoration: InputDecoration(hintText: "Nazwa przedmiotu"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Anuluj'),
            ),
            TextButton(
              onPressed: () {
                final String subjectName = subjectNameController.text.trim();
                if (subjectName.isNotEmpty) {
                  _addSubject(subjectName);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Dodaj'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addSubject(String subjectName) async {
    if (!_subjects.contains(subjectName)) {
      _subjects.add(subjectName);
      await sharedPreferences.setStringList('subjects', _subjects);
      setState(() {});
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Błąd'),
          content: const Text('Ten przedmiot już istnieje.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _deleteSubject(String subjectName) async {
    // Krok 1: Usuń pytania z bazy danych
    await _questionDao?.deleteQuestionsBySubject(subjectName);

    // Krok 2: Zmodyfikuj listę w pamięci
    _subjects.remove(subjectName);

    // Krok 3: Zapisz zmienioną listę do SharedPreferences
    await sharedPreferences.setStringList('subjects', _subjects);

    // Krok 4: Poinformuj Fluttera, żeby odświeżył UI. To wszystko!
    setState(() {});
  }

  Future<void> _updateSubjectName(String oldName, String newName) async {
    // Zabezpieczenie przed duplikatami
    if (_subjects.contains(newName)) {
      // Można tu pokazać użytkownikowi komunikat, np. używając ScaffoldMessenger
      return;
    }

    // Krok 1: Zaktualizuj bazę danych
    await _questionDao?.updateSubjectName(oldName, newName);

    // Krok 2: Znajdź i zaktualizuj element na liście w pamięci
    final int index = _subjects.indexOf(oldName);
    if (index != -1) {
      _subjects[index] = newName;
    }

    // Krok 3: Zapisz zaktualizowaną listę do SharedPreferences
    await sharedPreferences.setStringList('subjects', _subjects);

    // Krok 4: Odśwież UI
    setState(() {});
  }
}

Future<bool> _showDeleteConfirmationDialog(
  String subjectName,
  BuildContext context,
) async {
  return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Czy jesteś pewien?'),
            content: Text(
              'Czy na pewno chcesz usunąć przedmiot "$subjectName" i wszystkie powiązane z nim pytania? Tej operacji nie można cofnąć.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Anuluj'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Usuń'),
              ),
            ],
          );
        },
      ) ??
      false;
}

Future<String?> _showEditNameDialog(
  String oldName,
  BuildContext context,
) async {
  final TextEditingController subjectNameController = TextEditingController(
    text: oldName,
  );
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Zmień nazwę przedmiotu'),
        content: TextField(
          controller: subjectNameController,
          decoration: const InputDecoration(hintText: "Nowa nazwa przedmiotu"),
          autofocus: true,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(null); // Zwróć null przy anulowaniu
            },
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () {
              final String newName = subjectNameController.text.trim();
              if (newName.isNotEmpty) {
                Navigator.of(context).pop(newName); // Zwróć nową nazwę
              }
            },
            child: const Text('Zapisz'),
          ),
        ],
      );
    },
  );
}