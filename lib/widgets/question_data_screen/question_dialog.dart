import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:morrolingo/database/question.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:morrolingo/utilities/class/questions_stream_class.dart';

class AddQuestionDialog extends StatefulWidget {
  const AddQuestionDialog._({this.question, this.questions, this.onSavePartial})
    : assert(question == null || questions == null);
  final Question? question;
  final List<Question>? questions;
  final Function(dynamic)? onSavePartial;

  factory AddQuestionDialog({Function(dynamic)? onSavePartial}) =>
      AddQuestionDialog._(onSavePartial: onSavePartial);

  factory AddQuestionDialog.single({Key? key, Question? question}) =>
      AddQuestionDialog._(question: question);

  // Publiczny konstruktor do tworzenia dialogu dla wielu pytań
  factory AddQuestionDialog.bulk({
    Key? key,
    List<Question>? questions,
    Function(dynamic)? onSavePartial,
  }) => AddQuestionDialog._(questions: questions, onSavePartial: onSavePartial);

  @override
  State<AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<AddQuestionDialog> {
  // Kontrolery do zarządzania tekstem w polach
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _multilineController = TextEditingController();
  late final bool _isEditMode =
      widget.questions != null || widget.question != null;
  late bool _isBulkMode = widget.questions != null && widget.question == null;

  @override
  void initState() {
    super.initState();
    if (widget.question != null) {
      _questionController.text = widget.question!.question;
      _answerController.text = widget.question!.answer;
    } else if (widget.questions != null) {
      String lines = widget.questions!
          .map((q) => '${q.question} - ${q.answer}')
          .join('\n')
          .toString();
      _multilineController.text = lines;
    }
  }

  @override
  void dispose() {
    // Pamiętaj o zwalnianiu zasobów kontrolerów, aby uniknąć wycieków pamięci!
    _questionController.dispose();
    _answerController.dispose();
    _multilineController.dispose();
    super.dispose();
  }

  Future<void> _pickImageAndScan() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wybierz źródło obrazu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Aparat'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return; // Użytkownik zamknął dialog

    if (source == ImageSource.camera) {
    } else {}

    if (!mounted) return;

    await _proceedWithImagePicking(source);
  }

  Future<void> _proceedWithImagePicking(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? imageFile = await picker.pickImage(source: source);

    if (imageFile == null) return;

    if (!mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      final String rawScannedText = recognizedText.text;
      developer.log('Zeskanowany tekst (surowy): $rawScannedText');

      await textRecognizer.close();

      // Zaktualizuj pole tekstowe
      final currentText = _multilineController.text;
      if (currentText.isNotEmpty && !currentText.endsWith('\n')) {
        _multilineController.text += '\n';
      }
      _multilineController.text += _cleanScannedText(rawScannedText);
    } catch (e) {
      developer.log('Błąd podczas rozpoznawania tekstu: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nie udało się rozpoznać tekstu.')),
      );
    } finally {
      // Zamknij dialog ładowania, niezależnie od wyniku
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  String _cleanScannedText(String rawText) {
    return rawText
        .split('\n') // 1. Podziel tekst na linie
        .map((line) {
          // 2. Dla każdej linii:
          //    a) Zastąp wielokrotne białe znaki pojedynczą spacją
          //    b) Usuń białe znaki z początku i końca
          return line.replaceAll(RegExp(r'\s+'), ' ').trim();
        })
        .where((line) => line.isNotEmpty) // 3. Usuń puste linie
        .join('\n'); // 4. Połącz linie z powrotem w jeden tekst
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Zwalnia focus z aktywnego pola tekstowego, gdy klikniemy w tło
        FocusScope.of(context).unfocus();
      },
      child: AlertDialog(
        title: Text(
          _isBulkMode
              ? 'Dodaj wiele pytań'
              : widget.question == null
              ? 'Dodaj nowe pytanie'
              : 'Edytuj pytanie',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!_isEditMode)
                    Switch(
                      value: _isBulkMode,
                      onChanged: (value) {
                        setState(() {
                          _isBulkMode = value;
                          if (_isBulkMode &&
                              _multilineController.text.trim().isEmpty) {
                            final question = _questionController.text.trim();
                            final answer = _answerController.text.trim();
                            if (question.isNotEmpty || answer.isNotEmpty) {
                              _multilineController.text = '$question - $answer';
                            }
                          }
                        });
                      },
                    ),
                ],
              ),
              if (_isBulkMode)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: _multilineController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Pytanie - Odpowiedź',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ),
                      suffixIcon: GestureDetector(
                        onTap: _pickImageAndScan,
                        child: Icon(Icons.photo_camera),
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    TextField(
                      controller: _questionController,
                      maxLength: 45,
                      decoration: const InputDecoration(labelText: 'Pytanie'),
                      textCapitalization: TextCapitalization.sentences,
                      buildCounter:
                          (
                            context, {
                            required currentLength,
                            required isFocused,
                            required maxLength,
                          }) => _buildCounter(currentLength, maxLength),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _answerController,
                      maxLength: 45,
                      decoration: const InputDecoration(labelText: 'Odpowiedź'),
                      textCapitalization: TextCapitalization.sentences,
                      buildCounter:
                          (
                            context, {
                            required currentLength,
                            required isFocused,
                            required maxLength,
                          }) => _buildCounter(currentLength, maxLength),
                    ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Anuluj'),
          ),
          TextButton(
            onPressed: () async {
              final questionText = _questionController.text.trim();
              final answerText = _answerController.text.trim();

              if (_isBulkMode) {
                final lines = _multilineController.text.split('\n');
                final validQuestionAnswerPairs = <Map<String, String>>[];
                final problematicRawLines = <String>[];

                for (final currentLine in lines) {
                  final trimmedLine = currentLine.trim();
                  if (trimmedLine.isEmpty) continue;

                  final parts = trimmedLine.split(' - ');
                  if (parts.length >= 2) {
                    final questionPart = parts[0].trim();
                    final answerPart = parts.sublist(1).join(' - ').trim();

                    if (questionPart.isNotEmpty &&
                        answerPart.isNotEmpty &&
                        questionPart.length <= 45 &&
                        answerPart.length <= 45) {
                      validQuestionAnswerPairs.add({
                        'question': questionPart,
                        'answer': answerPart,
                      });
                    } else {
                      problematicRawLines.add(currentLine);
                    }
                  } else {
                    problematicRawLines.add(currentLine);
                  }
                }

                if (problematicRawLines.isNotEmpty) {
                  // Errors were found. Save the valid ones and show errors.
                  if (validQuestionAnswerPairs.isNotEmpty) {
                    if (_isEditMode && widget.questions != null) {
                      final partialResult = QuestionsStream();
                      final originalQuestions = widget.questions!;
                      final remainingOriginals = List<Question>.from(
                        originalQuestions,
                      );

                      for (final pair in validQuestionAnswerPairs) {
                        final newQuestionText = pair['question']!;
                        final newAnswerText = pair['answer']!;
                        final originalIndex = remainingOriginals.indexWhere(
                          (q) => q.question == newQuestionText,
                        );

                        if (originalIndex != -1) {
                          final originalQuestion = remainingOriginals.removeAt(
                            originalIndex,
                          );
                          if (originalQuestion.answer != newAnswerText) {
                            partialResult.questionsToUpdate.add(
                              originalQuestion.copyWith(answer: newAnswerText),
                            );
                          }
                        } else {
                          partialResult.questionsToAdd.add(
                            Question(
                              subject: originalQuestions.first.subject,
                              question: newQuestionText,
                              answer: newAnswerText,
                            ),
                          );
                        }
                      }
                      widget.onSavePartial?.call(partialResult);
                    } else {
                      // Bulk add mode
                      widget.onSavePartial?.call(validQuestionAnswerPairs);
                    }
                  }

                  // Update text field and show dialog
                  _multilineController.text = problematicRawLines.join('\n');
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Wykryto problemy'),
                      content: Builder(
                        builder: (context) {
                          final List<Widget> children = [];
                          if (validQuestionAnswerPairs.isNotEmpty) {
                            final count = validQuestionAnswerPairs.length;
                            final message = _isEditMode
                                ? (count == 1
                                      ? '1 wpis został zaktualizowany.'
                                      : '$count wpisów zostało zaktualizowanych.')
                                : (count == 1
                                      ? '1 poprawne pytanie zostało dodane.'
                                      : '$count poprawnych pytań zostało dodanych.');
                            children.add(Text(message));
                            children.add(const SizedBox(height: 16));
                          }
                          children.add(
                            Text(
                              problematicRawLines.length == 1
                                  ? 'Poniższy wpis wymaga poprawy:'
                                  : 'Poniższe wpisy wymagają poprawy:',
                            ),
                          );
                          children.add(const SizedBox(height: 8));
                          children.addAll(
                            problematicRawLines.map((line) => Text('• $line')),
                          );

                          return SingleChildScrollView(
                            child: ListBody(children: children),
                          );
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  // All entries are valid.
                  if (_isEditMode && widget.questions != null) {
                    final result = QuestionsStream();
                    final originalQuestions = widget.questions!;
                    final remainingOriginals = List<Question>.from(
                      originalQuestions,
                    );
                    final remainingNewLines = _multilineController.text
                        .split('\n')
                        .where((line) => line.trim().isNotEmpty)
                        .toList();

                    remainingNewLines.removeWhere((line) {
                      final parts = line.trim().split(' - ');
                      if (parts.length < 2) return false;
                      final newQuestionText = parts[0].trim();
                      final originalIndex = remainingOriginals.indexWhere(
                        (q) => q.question == newQuestionText,
                      );

                      if (originalIndex != -1) {
                        final originalQuestion = remainingOriginals.removeAt(
                          originalIndex,
                        );
                        final newAnswerText = parts
                            .sublist(1)
                            .join(' - ')
                            .trim();
                        if (originalQuestion.answer != newAnswerText) {
                          result.questionsToUpdate.add(
                            originalQuestion.copyWith(answer: newAnswerText),
                          );
                        }
                        return true;
                      }
                      return false;
                    });

                    remainingNewLines.removeWhere((line) {
                      final parts = line.trim().split(' - ');
                      if (parts.length < 2) return false;
                      final newAnswerText = parts.sublist(1).join(' - ').trim();
                      final originalIndex = remainingOriginals.indexWhere(
                        (q) => q.answer == newAnswerText,
                      );

                      if (originalIndex != -1) {
                        final originalQuestion = remainingOriginals.removeAt(
                          originalIndex,
                        );
                        final newQuestionText = parts[0].trim();
                        result.questionsToUpdate.add(
                          originalQuestion.copyWith(
                            question: newQuestionText,
                            answer: newAnswerText,
                          ),
                        );
                        return true;
                      }
                      return false;
                    });

                    for (final line in remainingNewLines) {
                      final parts = line.trim().split(' - ');
                      if (parts.length < 2) continue;
                      final newQuestionText = parts[0].trim();
                      final newAnswerText = parts.sublist(1).join(' - ').trim();
                      if (newQuestionText.isEmpty || newAnswerText.isEmpty) {
                        continue;
                      }
                      result.questionsToAdd.add(
                        Question(
                          subject: originalQuestions.first.subject,
                          question: newQuestionText,
                          answer: newAnswerText,
                        ),
                      );
                    }

                    result.questionsToDelete.addAll(remainingOriginals);
                    Navigator.of(context).pop(result);
                  } else {
                    // Bulk add mode, all valid
                    if (validQuestionAnswerPairs.isNotEmpty) {
                      Navigator.of(context).pop(validQuestionAnswerPairs);
                    } else {
                      Navigator.of(context).pop();
                    }
                  }
                }
              } else {
                // Single item mode (add or edit)
                if (questionText.isNotEmpty && answerText.isNotEmpty) {
                  if (widget.question != null) {
                    // Edit mode: return updated Question object
                    final updatedQuestion = widget.question!.copyWith(
                      question: questionText,
                      answer: answerText,
                    );
                    Navigator.of(context).pop(updatedQuestion);
                  } else {
                    // Add mode: return map
                    Navigator.of(
                      context,
                    ).pop({'question': questionText, 'answer': answerText});
                  }
                } else {
                  // Optional: Show an error if fields are empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pytanie i odpowiedź nie mogą być puste.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            child: const Text('Zapisz'),
          ),
        ],
      ),
    );
  }

  Widget? _buildCounter(int currentLength, int? maxLength) {
    if (currentLength == 0) {
      return null;
    }
    return Text(
      '$currentLength/$maxLength',
      style: Theme.of(context).textTheme.bodySmall,
      textAlign: TextAlign.end,
    );
  }
}
