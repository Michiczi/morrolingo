import 'package:flutter/material.dart';

class GrowingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;

  const GrowingText({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<GrowingText> createState() => _GrowingTextState();
}

class _GrowingTextState extends State<GrowingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward(); // animacja startuje od razu

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic, // płynne powiększanie
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      // wyśrodkowanie tekstu
      child: ScaleTransition(
        scale: _scale,
        child: Text(widget.text, style: widget.style),
      ),
    );
  }
}
