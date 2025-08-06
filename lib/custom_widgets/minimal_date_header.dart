import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_text.dart';
import 'package:vibe_coding_tutorial_weather_app/utils/colors.dart';

class MinimalDateHeader extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onEditPressed;
  final VoidCallback onDateTap;

  const MinimalDateHeader({
    Key? key,
    required this.selectedDate,
    required this.onEditPressed,
    required this.onDateTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    // Formatear fecha
    final monthName = DateFormat('MMMM', 'es_ES').format(selectedDate);
    final year = selectedDate.year;

    return Row(
      children: [
        // Fecha clickeable
        Expanded(
          child: GestureDetector(
            onTap: onDateTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 12 : 8,
                horizontal: isSmallScreen ? 16 : 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isSmallScreen) ...[
                    ContraText(
                      alignment: Alignment.centerLeft,
                      text: 'Medicamentos',
                      size: 14,
                      weight: FontWeight.w600,
                      color: trout,
                    ),
                    const SizedBox(height: 4),
                  ],
                  Row(
                    children: [
                      ContraText(
                        alignment: Alignment.centerLeft,
                        text: '$monthName $year',
                        size: isSmallScreen ? 26 : 24,
                        weight: FontWeight.bold,
                        color: wood_smoke,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: wood_smoke.withOpacity(0.6),
                        size: isSmallScreen ? 24 : 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // Botón de editar
        IconButton(
          icon: Icon(
            Icons.edit_outlined,
            color: wood_smoke,
            size: isSmallScreen ? 24 : 20,
          ),
          tooltip: 'Editar tratamientos',
          onPressed: onEditPressed,
        ),
      ],
    );
  }
}
