import 'package:flutter/material.dart';

class GuessingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onExit;
  final double progress;
  final String modeDescription;

  const GuessingAppBar({
    super.key,
    required this.onExit,
    required this.progress,
    required this.modeDescription,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            iconSize: 30.0,
            onPressed: onExit,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              tween: Tween<double>(begin: 0, end: progress),
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                backgroundColor: isDarkMode
                    ? Color(0xFF444444)
                    : Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.lightGreenAccent,
                ),
                borderRadius: BorderRadius.circular(10.0),
                minHeight: 18.0,
              ),
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size(double.infinity, 15.0),
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            modeDescription,
            textAlign: TextAlign.left,
            style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 40.0);
}
