import 'package:flutter/material.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_text.dart';
import 'package:vibe_coding_tutorial_weather_app/utils/colors.dart';

class MedicationCardWidget extends StatelessWidget {
  final String name;
  final String meal;
  final int quantity;
  final bool isTaken;
  final VoidCallback onToggle;

  const MedicationCardWidget({
    super.key,
    required this.name,
    required this.meal,
    required this.quantity,
    required this.isTaken,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: wood_smoke, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContraText(
                  text: name,
                  size: 21,
                  color: wood_smoke,
                  weight: FontWeight.bold,
                  alignment: Alignment.centerLeft,
                ),
                const SizedBox(height: 4),
                ContraText(
                  text: 'Cantidad: $quantity',
                  size: 16,
                  color: trout,
                  alignment: Alignment.centerLeft,
                ),
                const SizedBox(height: 4),
                ContraText(
                  text: 'Horario: $meal',
                  size: 16,
                  color: trout,
                  alignment: Alignment.centerLeft,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isTaken ? lightening_yellow : athens_gray,
                shape: BoxShape.circle,
                border: Border.all(color: wood_smoke, width: 2),
              ),
              child: Icon(
                Icons.check,
                color: isTaken ? wood_smoke : white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
