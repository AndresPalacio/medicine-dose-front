import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_text.dart';
import 'package:vibe_coding_tutorial_weather_app/utils/colors.dart';

class ImprovedDateHeader extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onEditPressed;
  final VoidCallback onDateTap;

  const ImprovedDateHeader({
    Key? key,
    required this.selectedDate,
    required this.onEditPressed,
    required this.onDateTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    // Formatear fecha más amigable
    final monthName = DateFormat('MMMM', 'es_ES').format(selectedDate);
    final year = selectedDate.year;

    if (isSmallScreen) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título "Medicamentos para"
            Row(
              children: [
                const ContraText(
                  alignment: Alignment.centerLeft,
                  text: 'Medicamentos para',
                  size: 16,
                  weight: FontWeight.w600,
                  color: trout,
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: wood_smoke, size: 20),
                  tooltip: 'Editar tratamientos',
                  onPressed: onEditPressed,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Fecha principal más prominente y clickeable
            GestureDetector(
              onTap: onDateTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: wood_smoke.withOpacity(0.2), width: 1),
                ),
                child: Row(
                  children: [
                    ContraText(
                      alignment: Alignment.centerLeft,
                      text: '$monthName $year',
                      size: 24,
                      weight: FontWeight.bold,
                      color: wood_smoke,
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.calendar_today_outlined,
                      color: wood_smoke.withOpacity(0.6),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Para pantallas más grandes, mantener diseño más compacto
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: wood_smoke.withOpacity(0.15), width: 1),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ContraText(
                  alignment: Alignment.centerLeft,
                  text: 'Medicamentos para',
                  size: 14,
                  weight: FontWeight.w600,
                  color: trout,
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onDateTap,
                  child: Row(
                    children: [
                      ContraText(
                        alignment: Alignment.centerLeft,
                        text: '$monthName $year',
                        size: 22,
                        weight: FontWeight.bold,
                        color: wood_smoke,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.calendar_today_outlined,
                        color: wood_smoke.withOpacity(0.6),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.edit_outlined, color: wood_smoke),
              tooltip: 'Editar tratamientos',
              onPressed: onEditPressed,
            ),
          ],
        ),
      );
    }
  }
}
