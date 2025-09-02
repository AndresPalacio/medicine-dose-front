import 'package:flutter/material.dart';
import '../../../../utils/colors.dart';
import '../../../../custom_widgets/contra_text.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final String iconPath;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.iconPath,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? wood_smoke,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: athens_gray.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono
                Image.asset(
                  iconPath,
                  width: 20,
                  height: 20,
                  color: textColor ?? wood_smoke,
                ),
                
                const SizedBox(width: 12),
                
                // Texto
                ContraText(
                  text: text,
                  size: 16,
                  weight: FontWeight.w600,
                  color: textColor ?? wood_smoke,
                  alignment: Alignment.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
