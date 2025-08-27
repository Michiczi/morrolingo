import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

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

    // Zamknięcie ekranu po 1s
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.withAlpha(200),
      body: Center(
        child: Text(
          '${widget.streakCount} pytań z rzędu!',
          style: const TextStyle(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
