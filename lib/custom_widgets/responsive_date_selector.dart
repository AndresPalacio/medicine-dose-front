import 'package:flutter/material.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_text.dart';
import 'package:vibe_coding_tutorial_weather_app/utils/colors.dart';

class ResponsiveDateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final IconData editIcon;
  final VoidCallback onEditPressed;

  const ResponsiveDateSelector({
    Key? key,
    required this.selectedDate,
    this.editIcon = Icons.edit,
    required this.onEditPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Ajustado para iPhone 11 (414px) y otros móviles comunes
    final isSmallScreen = screenWidth <= 430; // Incluye iPhone 11, 12, 13, etc.

    if (isSmallScreen) {
      // Diseño vertical para pantallas pequeñas
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ContraText(
                  alignment: Alignment.centerLeft,
                  text: 'Fecha seleccionada',
                  size: 14,
                  weight: FontWeight.w600,
                  color: trout,
                ),
                IconButton(
                  icon: Icon(editIcon, color: wood_smoke, size: 20),
                  tooltip: 'Editar tratamientos',
                  onPressed: onEditPressed,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ContraText(
              alignment: Alignment.center,
              text: '${selectedDate.year} / ${selectedDate.month}',
              size: 28,
              weight: FontWeight.bold,
              color: wood_smoke,
            ),
          ],
        ),
      );
    } else {
      // Diseño horizontal para pantallas más grandes
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Row(
          children: [
            Expanded(
              child: ContraText(
                alignment: Alignment.centerLeft,
                text: '${selectedDate.year} / ${selectedDate.month}',
                size: 24,
                weight: FontWeight.bold,
                color: wood_smoke,
              ),
            ),
            IconButton(
              icon: Icon(editIcon, color: wood_smoke),
              tooltip: 'Editar tratamientos',
              onPressed: onEditPressed,
            ),
          ],
        ),
      );
    }
  }
}
