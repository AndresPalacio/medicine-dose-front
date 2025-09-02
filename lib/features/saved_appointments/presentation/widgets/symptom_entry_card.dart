import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_text.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/symptom_models.dart';
import 'package:vibe_coding_tutorial_weather_app/utils/colors.dart';

class SymptomEntryCard extends StatelessWidget {
  final SymptomEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SymptomEntryCard({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: wood_smoke, width: 2),
        boxShadow: [
          BoxShadow(
            color: athens_gray.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ContraText(
                      text: entry.symptomNames.isNotEmpty
                          ? entry.symptomNames.first
                          : 'Sin síntomas',
                      size: 18,
                      weight: FontWeight.bold,
                      color: wood_smoke,
                      alignment: Alignment.centerLeft,
                    ),
                    const SizedBox(height: 4),
                    ContraText(
                      text: 'Hora: ${entry.time}',
                      size: 14,
                      color: trout,
                      alignment: Alignment.centerLeft,
                    ),
                  ],
                ),
              ),
              _buildSeverityChip(entry.severity),
            ],
          ),
          const SizedBox(height: 12),

          // Información adicional
          if (entry.notes != null && entry.notes!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: athens_gray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.note, size: 16, color: trout),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ContraText(
                      text: entry.notes!,
                      size: 14,
                      color: trout,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Medicamentos relacionados
          if (entry.relatedMedications != null &&
              entry.relatedMedications!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: lightening_yellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: lightening_yellow, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.medication, size: 16, color: wood_smoke),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ContraText(
                      text: 'Medicamentos: ${entry.relatedMedications!}',
                      size: 14,
                      color: wood_smoke,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Botones de acción
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 16, color: wood_smoke),
                label: const ContraText(
                  text: 'Editar',
                  size: 14,
                  color: wood_smoke,
                  alignment: Alignment.center,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                label: const ContraText(
                  text: 'Eliminar',
                  size: 14,
                  color: Colors.red,
                  alignment: Alignment.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityChip(String severity) {
    Color chipColor;
    Color textColor;

    if (severity.contains('Leve')) {
      chipColor = Colors.green.withOpacity(0.2);
      textColor = Colors.green;
    } else if (severity.contains('Moderada') || severity.contains('Moderado')) {
      chipColor = Colors.orange.withOpacity(0.2);
      textColor = Colors.orange;
    } else if (severity.contains('Intenso') ||
        severity.contains('Severa') ||
        severity.contains('Alta')) {
      chipColor = Colors.red.withOpacity(0.2);
      textColor = Colors.red;
    } else {
      chipColor = Colors.purple.withOpacity(0.2);
      textColor = Colors.purple;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor, width: 1),
      ),
      child: ContraText(
        text: severity,
        size: 12,
        weight: FontWeight.w500,
        color: textColor,
        alignment: Alignment.center,
      ),
    );
  }
}
