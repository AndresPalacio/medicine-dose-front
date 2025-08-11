import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_text.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/medication_api_service.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/medication_api_models.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/presentation/widgets/infinite_calendar_widget.dart';
import 'package:vibe_coding_tutorial_weather_app/utils/colors.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime? _selectedDate;
  CalendarEventResponse? _selectedEvent;

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _onEventSelected(CalendarEventResponse event) {
    setState(() {
      _selectedEvent = event;
    });

    // Mostrar un diálogo con los detalles del evento
    _showEventDetails(event);
  }

  void _showEventDetails(CalendarEventResponse event) {
    final date = DateTime.parse(event.start);
    final formatter = DateFormat('dd MMMM yyyy', 'es_ES');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: carribean_green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.medication,
                          color: carribean_green, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ContraText(
                        alignment: Alignment.centerLeft,
                        text: formatter.format(date),
                        size: 18,
                        weight: FontWeight.bold,
                        color: carribean_green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ContraText(
                  alignment: Alignment.centerLeft,
                  text: event.title,
                  size: 16,
                  weight: FontWeight.bold,
                  color: wood_smoke,
                ),
                const SizedBox(height: 8),
                Divider(color: athens_gray, thickness: 1),
                const SizedBox(height: 8),
                ContraText(
                  alignment: Alignment.centerLeft,
                  text: 'Dosis:',
                  size: 15,
                  weight: FontWeight.bold,
                  color: trout,
                ),
                const SizedBox(height: 8),
                ...event.doses.map((dose) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            dose.taken
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: dose.taken ? carribean_green : mona_lisa,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ContraText(
                              alignment: Alignment.centerLeft,
                              text: '${dose.meal}: ${dose.quantity} unidad(es)',
                              size: 14,
                              color: wood_smoke,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: dose.taken
                                  ? carribean_green.withOpacity(0.15)
                                  : mona_lisa.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              dose.taken ? 'Tomada' : 'Pendiente',
                              style: TextStyle(
                                color: dose.taken ? carribean_green : mona_lisa,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: carribean_green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showManageDosesModal(event);
                      },
                      child: const Text('Gestionar tomas',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: trout,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cerrar',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showManageDosesModal(CalendarEventResponse event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _ManageDosesDialog(event: event);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: selago,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        title: const ContraText(
          alignment: Alignment.centerLeft,
          text: 'Calendario de Medicamentos',
          size: 20,
          weight: FontWeight.bold,
          color: wood_smoke,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: wood_smoke),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Información de la fecha seleccionada
          if (_selectedDate != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(16),
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
                  const ContraText(
                    alignment: Alignment.centerLeft,
                    text: 'Fecha Seleccionada',
                    size: 16,
                    weight: FontWeight.bold,
                    color: wood_smoke,
                  ),
                  const SizedBox(height: 8),
                  ContraText(
                    alignment: Alignment.centerLeft,
                    text: DateFormat('EEEE, dd MMMM yyyy', 'es_ES')
                        .format(_selectedDate!),
                    size: 14,
                    color: trout,
                  ),
                ],
              ),
            ),

          // Calendario infinito
          Expanded(
            child: InfiniteCalendarWidget(
              initialDate: _selectedDate,
              onDateSelected: _onDateSelected,
              onEventSelected: _onEventSelected,
            ),
          ),
        ],
      ),
    );
  }
}

class _ManageDosesDialog extends StatefulWidget {
  final CalendarEventResponse event;
  const _ManageDosesDialog({Key? key, required this.event}) : super(key: key);

  @override
  State<_ManageDosesDialog> createState() => _ManageDosesDialogState();
}

class _ManageDosesDialogState extends State<_ManageDosesDialog> {
  late List<MedicationDoseResponse> doses;
  bool loading = false;
  final MedicationApiService _apiService = MedicationApiService();

  @override
  void initState() {
    super.initState();
    doses = widget.event.doses
        .map((d) => MedicationDoseResponse(
              id: d.id,
              medicationId: d.medicationId,
              medicationName: d.medicationName,
              date: d.date,
              meal: d.meal,
              quantity: d.quantity,
              taken: d.taken,
            ))
        .toList();
  }

  Future<void> _toggleDose(int index) async {
    setState(() {
      loading = true;
    });
    final dose = doses[index];
    // DEBUG
    // ignore: avoid_print
    print(
        'DEBUG CalendarPage._toggleDose doseId=${dose.id} before=${dose.taken}');
    try {
      await _apiService.markDoseAsTaken(dose.id, !dose.taken);
      setState(() {
        doses[index] = MedicationDoseResponse(
          id: dose.id,
          medicationId: dose.medicationId,
          medicationName: dose.medicationName,
          date: dose.date,
          meal: dose.meal,
          quantity: dose.quantity,
          taken: !dose.taken,
        );
      });
    } catch (e) {
      // DEBUG
      // ignore: avoid_print
      print('DEBUG CalendarPage._toggleDose ERROR for doseId=${dose.id}: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar la toma')),
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit, color: carribean_green, size: 28),
                const SizedBox(width: 12),
                ContraText(
                  alignment: Alignment.centerLeft,
                  text: 'Gestionar tomas',
                  size: 18,
                  weight: FontWeight.bold,
                  color: carribean_green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...doses.asMap().entries.map((entry) {
              final i = entry.key;
              final dose = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Checkbox(
                      value: dose.taken,
                      onChanged: loading ? null : (val) => _toggleDose(i),
                      activeColor: carribean_green,
                    ),
                    Expanded(
                      child: ContraText(
                        alignment: Alignment.centerLeft,
                        text: '${dose.meal}: ${dose.quantity} unidad(es)',
                        size: 15,
                        color: wood_smoke,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: dose.taken
                            ? carribean_green.withOpacity(0.15)
                            : mona_lisa.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        dose.taken ? 'Tomada' : 'Pendiente',
                        style: TextStyle(
                          color: dose.taken ? carribean_green : mona_lisa,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: trout,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
