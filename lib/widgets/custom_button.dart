import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A data class for styling a [CustomButton].
class CustomButtonStyle {
  final TextStyle? textStyle;
  final Color? buttonColor;
  final Color? bottomColor;
  final BorderRadius? borderRadius;

  const CustomButtonStyle({
    this.textStyle,
    this.buttonColor,
    this.bottomColor,
    this.borderRadius,
  });
}

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final CustomButtonStyle? style;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.style,
    this.icon,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Use style properties with fallbacks to the theme
    final buttonStyle = widget.style;
    final theme = Theme.of(context);

    // Determine default colors based on theme brightness
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color defaultButtonColor = isDarkMode
        ? Colors.deepPurple
        : Colors.blue;
    final Color defaultBottomColor = isDarkMode
        ? Colors.deepPurple.shade800
        : Colors.blue.shade800;

    final Color backgroundColor =
        buttonStyle?.buttonColor ?? defaultButtonColor;
    final Color bottomColor = buttonStyle?.bottomColor ?? defaultBottomColor;
    final BorderRadius borderRadius =
        buttonStyle?.borderRadius ?? BorderRadius.circular(16.0);
    final TextStyle textStyle =
        buttonStyle?.textStyle ??
        TextStyle(
          color: isDarkMode ? Colors.white : theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        );

    final double mainButtonHeight =
        60.0; // Height of the main button part (from XML TextView)
    final double extensionHeight =
        50.0; // Fixed height of the bottom extension (from XML View)
    final double extensionTopMargin =
        14.0; // From XML layout_marginTop on bottomExtension
    final double pressDepth = 6.0; // How much the button moves down

    // Calculate total height for the SizedBox wrapper
    // The main button goes from 0 to mainButtonHeight (60)
    // The extension goes from extensionTopMargin (14) to extensionTopMargin + extensionHeight (14 + 50 = 64)
    // Max height needed is 64.0. Add pressDepth for the animation.
    final double totalWidgetHeight =
        math.max(mainButtonHeight, extensionTopMargin + extensionHeight) +
        pressDepth;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: SizedBox(
        width: double.infinity,
        height: totalWidgetHeight,
        child: Stack(
          children: [
            // Bottom "extension" part that creates the 3D effect
            Positioned(
              top: extensionTopMargin, // Position from the top of the Stack
              left: 0,
              right: 0,
              child: Container(
                height: extensionHeight, // Fixed height for the bottom part
                decoration: BoxDecoration(
                  color: bottomColor,
                  borderRadius: borderRadius,
                ),
              ),
            ),
            // Top, pressable "button" part
            AnimatedPositioned(
              duration: const Duration(milliseconds: 80),
              curve: Curves.easeIn,
              top: _isPressed ? pressDepth : 0,
              left: 0,
              right: 0,
              child: Container(
                height:
                    mainButtonHeight, // Fixed height for the main button part
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: borderRadius,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null)
                        Icon(
                          widget.icon,
                          color: textStyle.color,
                          size: textStyle.fontSize,
                        ),
                      if (widget.icon != null) const SizedBox(width: 8.0),
                      Flexible(
                        child: Text(
                          widget.text,
                          textAlign: TextAlign.center,
                          style: textStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
