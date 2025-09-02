import 'package:flutter/material.dart';
import '../../data/medication_api_models.dart';
import '../../data/calendar_example.dart';
import '../widgets/calendar_dose_widget.dart';

class CalendarExamplePage extends StatefulWidget {
  const CalendarExamplePage({Key? key}) : super(key: key);

  @override
  State<CalendarExamplePage> createState() => _CalendarExamplePageState();
}

class _CalendarExamplePageState extends State<CalendarExamplePage> {
  CalendarResponse? calendarData;
  Map<String, dynamic>? statistics;

  @override
  void initState() {
    super.initState();
    _loadCalendarData();
  }

  void _loadCalendarData() {
    // Simular datos del calendario (los que proporcionaste)
    final jsonData = '''
[
    {
        "id": "f105b9aa-1428-49b6-a9d8-bad24d223ea5_2025-08-01_DESAYUNO",
        "medicationId": "f105b9aa-1428-49b6-a9d8-bad24d223ea5",
        "medicationName": "ESOZ 40MG",
        "date": "2025-08-01",
        "meal": "DESAYUNO",
        "status": "PENDING",
        "expectedTime": null
    },
    {
        "id": "f105b9aa-1428-49b6-a9d8-bad24d223ea5_2025-08-02_DESAYUNO",
        "medicationId": "f105b9aa-1428-49b6-a9d8-bad24d223ea5",
        "medicationName": "ESOZ 40MG",
        "date": "2025-08-02",
        "meal": "DESAYUNO",
        "status": "PENDING",
        "expectedTime": null
    },
    {
        "id": "f105b9aa-1428-49b6-a9d8-bad24d223ea5_2025-08-03_DESAYUNO",
        "medicationId": "f105b9aa-1428-49b6-a9d8-bad24d223ea5",
        "medicationName": "ESOZ 40MG",
        "date": "2025-08-03",
        "meal": "DESAYUNO",
        "status": "COMPLETED",
        "expectedTime": "08:00"
    }
]
''';

    setState(() {
      calendarData = CalendarExample.processCalendarData(jsonData);
      statistics = CalendarExample.getDoseStatistics(calendarData!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejemplo de Calendario'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: calendarData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Estadísticas
                  if (statistics != null) _buildStatisticsCard(),
                  const SizedBox(height: 24),

                  // Dosis de hoy
                  CalendarDoseListWidget(
                    title: 'Dosis de Hoy',
                    doses: calendarData!.getTodayDoses(),
                    onDoseTap: _onDoseTap,
                  ),
                  const SizedBox(height: 24),

                  // Dosis pendientes
                  CalendarDoseListWidget(
                    title: 'Dosis Pendientes',
                    doses: calendarData!.getPendingDoses(),
                    onDoseTap: _onDoseTap,
                  ),
                  const SizedBox(height: 24),

                  // Todas las dosis
                  CalendarDoseListWidget(
                    title: 'Todas las Dosis',
                    doses: calendarData!.doses,
                    onDoseTap: _onDoseTap,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatisticsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estadísticas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatItem(
                    'Total', statistics!['totalDoses'].toString(), Colors.blue),
                const SizedBox(width: 16),
                _buildStatItem('Pendientes',
                    statistics!['pendingDoses'].toString(), Colors.orange),
                const SizedBox(width: 16),
                _buildStatItem('Completadas',
                    statistics!['completedDoses'].toString(), Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Por Medicamento:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...(statistics!['dosesByMedication'] as Map<String, int>)
                .entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text('${entry.value} dosis'),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDoseTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dosis seleccionada'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
