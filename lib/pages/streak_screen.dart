import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:morrolingo/widgets/custom_button.dart';

class StreakScreen extends StatefulWidget {
  final int streakCount;

  const StreakScreen({super.key, required this.streakCount});

  static const String id = 'streak_screen';

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  @override
  void initState() {
    super.initState();

    // Wibracja przy starcie
    Vibration.hasVibrator().then((hasVibrator) {
      if (hasVibrator) {
        Vibration.vibrate(duration: 500); // krótka wibracja 200ms
      } else {
        HapticFeedback.mediumImpact(); // fallback dla iOS
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.green.withAlpha(200),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.streakCount} pytań z rzędu!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Kontynuuj',
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: CustomButtonStyle(
                  buttonColor: Colors.white,
                  bottomColor: Colors.grey.shade300,
                  textStyle: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
