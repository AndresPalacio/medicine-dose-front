import 'package:flutter/material.dart';
import '../../data/medication_api_models.dart';

class CalendarDoseWidget extends StatelessWidget {
  final CalendarDoseResponse dose;
  final VoidCallback? onTap;
  final bool showDetails;

  const CalendarDoseWidget({
    Key? key,
    required this.dose,
    this.onTap,
    this.showDetails = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icono de estado
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getStatusColor(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Nombre del medicamento
                  Expanded(
                    child: Text(
                      dose.medicationName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  // Estado
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(),
                      ),
                    ),
                  ),
                ],
              ),
              if (showDetails) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Icono de comida
                    Icon(
                      _getMealIcon(),
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    // Nombre de la comida
                    Text(
                      dose.mealInSpanish,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    // Fecha
                    Text(
                      _formatDate(dose.date),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (dose.expectedTime != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Hora esperada: ${dose.expectedTime}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (dose.status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.green;
      case 'MISSED':
        return Colors.red;
      case 'SKIPPED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (dose.status.toUpperCase()) {
      case 'PENDING':
        return 'Pendiente';
      case 'COMPLETED':
        return 'Completada';
      case 'MISSED':
        return 'Perdida';
      case 'SKIPPED':
        return 'Omitida';
      default:
        return dose.status;
    }
  }

  IconData _getMealIcon() {
    switch (dose.meal.toUpperCase()) {
      case 'DESAYUNO':
        return Icons.wb_sunny;
      case 'ALMUERZO':
        return Icons.restaurant;
      case 'CENA':
        return Icons.nights_stay;
      default:
        return Icons.fastfood;
    }
  }

  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return date;
    }
  }
}

class CalendarDoseListWidget extends StatelessWidget {
  final List<CalendarDoseResponse> doses;
  final String title;
  final VoidCallback? onDoseTap;

  const CalendarDoseListWidget({
    Key? key,
    required this.doses,
    required this.title,
    this.onDoseTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (doses.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.medication_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay dosis programadas',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: doses.length,
          itemBuilder: (context, index) {
            return CalendarDoseWidget(
              dose: doses[index],
              onTap: onDoseTap,
            );
          },
        ),
      ],
    );
  }
}
