import 'package:flutter/material.dart';
import 'package:vibe_coding_tutorial_weather_app/utils/colors.dart';

class ContraInputField extends StatelessWidget {
  final String? hintText;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;
  final bool? obscureText;

  const ContraInputField({
    super.key,
    this.hintText,
    this.keyboardType,
    this.validator,
    this.controller,
    this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText ?? false,
      style: const TextStyle(color: wood_smoke),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: trout,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: white,
        enabledBorder: _buildOutlineInputBorder(),
        focusedBorder: _buildOutlineInputBorder(),
        errorBorder: _buildOutlineInputBorder(color: Colors.red),
        focusedErrorBorder: _buildOutlineInputBorder(color: Colors.red),
      ),
    );
  }

  OutlineInputBorder _buildOutlineInputBorder({Color? color}) {
    return OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide(
        color: color ?? wood_smoke,
        width: 2,
      ),
    );
  }
}
