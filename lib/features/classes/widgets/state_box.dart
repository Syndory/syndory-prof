import 'package:flutter/material.dart';

class StateBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const StateBox({
    super.key,
    required this.icon,
    this.iconColor = const Color(0xFF828282), // --gray3
    required this.title,
    required this.description,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      margin: const EdgeInsets.only(top: 40),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F092C4C), // 0.06 opacity
                  offset: Offset(0, 4),
                  blurRadius: 16,
                ),
                BoxShadow(
                  color: Color(0x0A092C4C), // 0.04 opacity
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 32,
              color: iconColor,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF092C4C), // --primary
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: Color(0xFF4F4F4F), // --gray2
            ),
          ),
          if (buttonText != null && onButtonPressed != null) ...[
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: onButtonPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF092C4C), width: 2), // --primary
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                buttonText!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF092C4C), // --primary
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
