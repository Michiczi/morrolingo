import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morrolingo/utilities/theme/custom/colors_palette.dart';
import 'package:morrolingo/widgets/custom_button.dart';
import 'dart:math';
import 'package:morrolingo/widgets/summary_view/stat_card.dart';
import 'package:morrolingo/widgets/summary_view/growing_text.dart';
import 'package:vibration/vibration.dart';

class SummaryView extends StatefulWidget {
  final int highestStreak;
  final double accuracy;
  final int sessionTime;
  final VoidCallback onReturn;

  const SummaryView({
    super.key,
    required this.highestStreak,
    required this.accuracy,
    required this.sessionTime,
    required this.onReturn,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SummaryViewState createState() => _SummaryViewState();
}

class _SummaryViewState extends State<SummaryView>
    with TickerProviderStateMixin {
  late AnimationController _streakController;
  late Animation<int> _streakAnimation;

  late AnimationController _accuracyController;
  late Animation<double> _accuracyAnimation;

  late AnimationController _timeController;
  late Animation<int> _timeAnimation;

  late AnimationController _textAnimationController;
  late Animation<double> _textAnimation;

  final _finishPositiveTexts = [
    "Niczym huragan",
    "Prawdziwy zielony ninja",
    "Wymiatasz!",
    "Mistrz spinjitzu",
    "Absolutna diwa",
  ];
  final _finishNegativeTexts = [
    "Po długiej bitwie opadł kurz",
    "Ninja nigdy się nie poddają!",
  ];
  final _finishTexts = ["Dobra robota!", "Slay girl", "Dajesz czadu"];

  late String _finalText;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();

    // Inicjalizacja kontrolerów
    _streakController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _accuracyController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _timeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Streak Animation z wibracją
    int lastStreakValue = -1;
    _streakAnimation =
        IntTween(begin: 0, end: widget.highestStreak).animate(_streakController)
          ..addListener(() {
            if (_streakAnimation.value != lastStreakValue) {
              lastStreakValue = _streakAnimation.value;
              Vibration.hasVibrator().then((hasVib) {
                if (hasVib) {
                  Vibration.vibrate(duration: 20);
                } else {
                  HapticFeedback.lightImpact();
                }
              });
            }
          });

    // Accuracy Animation z wibracją
    int lastAccuracyValue = -1;
    _accuracyAnimation =
        Tween<double>(
          begin: 0,
          end: widget.accuracy,
        ).animate(_accuracyController)..addListener(() {
          int current = _accuracyAnimation.value.toInt();
          if (current != lastAccuracyValue) {
            lastAccuracyValue = current;
            Vibration.hasVibrator().then((hasVib) {
              if (hasVib) {
                Vibration.vibrate(duration: 20);
              } else {
                HapticFeedback.lightImpact();
              }
            });
          }
        });

    // Time Animation z wibracją
    int lastTimeValue = -1;
    _timeAnimation =
        IntTween(begin: 0, end: widget.sessionTime).animate(_timeController)
          ..addListener(() {
            if (_timeAnimation.value != lastTimeValue) {
              lastTimeValue = _timeAnimation.value;
              Vibration.hasVibrator().then((hasVib) {
                if (hasVib) {
                  Vibration.vibrate(duration: 20);
                } else {
                  HapticFeedback.lightImpact();
                }
              });
            }
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              Vibration.hasVibrator().then((hasVib) {
                if (hasVib) {
                  Vibration.cancel();
                }
              });
            }
          });

    _textAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textAnimationController, curve: Curves.easeOut),
    );
    _textAnimationController.forward();

    // Start animations with delays
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) _streakController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) _accuracyController.forward();
    });
    Future.delayed(const Duration(milliseconds: 2150), () {
      if (mounted) _timeController.forward();
    });

    final rand = Random();
    if (widget.accuracy < 40) {
      _finalText =
          _finishNegativeTexts[rand.nextInt(_finishNegativeTexts.length)];
    } else if (widget.accuracy < 70) {
      _finalText = _finishTexts[rand.nextInt(_finishTexts.length)];
    } else {
      _finalText =
          _finishPositiveTexts[rand.nextInt(_finishPositiveTexts.length)];
    }

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showButton = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _streakController.dispose();
    _accuracyController.dispose();
    _timeController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    final animatedFontSize =
                        10.0 + (60.0 - 10.0) * _textAnimation.value;
                    return SizedBox(
                      width: 300,
                      height: 150,
                      child: FittedBox(
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              TColors.success,
                              TColors.greenButtonBottom,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds),
                          child: GrowingText(
                            text: _finalText,
                            style: TextStyle(
                              fontSize: animatedFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AnimatedBuilder(
                      animation: _streakAnimation,
                      builder: (context, child) => StatCard(
                        title: 'Najwyższy streak',
                        value: _streakAnimation.value.toString(),
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _accuracyAnimation,
                      builder: (context, child) => StatCard(
                        title: 'Wynik',
                        value:
                            "${_accuracyAnimation.value.toStringAsFixed(0)}%",
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _timeAnimation,
                      builder: (context, child) => StatCard(
                        title: 'Czas',
                        value: _formatTime(_timeAnimation.value),
                        color: const Color(0xFF319BD4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _showButton
            ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: CustomButton(
                  text: 'Powrót do ekranu głównego',
                  onPressed: widget.onReturn,
                  style: CustomButtonStyle(
                    buttonColor: TColors.warning,
                    bottomColor: Colors.orange.shade900,
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(), // nic nie pokazuje przed upływem 3s
      ),
    );
  }
}
