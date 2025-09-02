import 'package:flutter/material.dart';
import '../../../../utils/colors.dart';
import '../../../../custom_widgets/contra_text.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool enabled;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        ContraText(
          text: label,
          size: 16,
          weight: FontWeight.bold,
          color: wood_smoke,
          alignment: Alignment.centerLeft,
        ),
        
        const SizedBox(height: 8),
        
        // Campo de texto
        Container(
          decoration: BoxDecoration(
            color: athens_gray,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: wood_smoke, width: 2),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            keyboardType: keyboardType,
            maxLines: maxLines,
            enabled: enabled,
            style: const TextStyle(
              color: wood_smoke,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: trout,
                fontSize: 16,
              ),
              prefixIcon: Icon(
                prefixIcon,
                color: wood_smoke,
                size: 20,
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
