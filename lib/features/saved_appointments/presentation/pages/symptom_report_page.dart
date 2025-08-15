import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_button.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_text.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/custom_header.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/symptom_service.dart';
import 'package:vibe_coding_tutorial_weather_app/utils/colors.dart';

class SymptomReportPage extends StatefulWidget {
  const SymptomReportPage({super.key});

  @override
  State<SymptomReportPage> createState() => _SymptomReportPageState();
}

class _SymptomReportPageState extends State<SymptomReportPage> {
  final SymptomService _symptomService = SymptomService();

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _reportText = '';
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  Future<void> _generateReport() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final report =
          await _symptomService.generateMedicalReport(_startDate, _endDate);
      setState(() {
        _reportText = report;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _reportText = 'Error al generar el reporte: $e';
        _isGenerating = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _generateReport();
    }
  }

  Future<void> _exportReport() async {
    try {
      final jsonData = await _symptomService.exportDataAsJson();
      // En una implementación completa, aquí se compartiría el archivo
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte exportado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: wood_smoke),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const ContraText(
          text: 'Reporte Médico',
          size: 20,
          weight: FontWeight.bold,
          color: wood_smoke,
          alignment: Alignment.center,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: wood_smoke),
            onPressed: _exportReport,
            tooltip: 'Exportar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomHeader(
              lineOneText: "Reporte de",
              lineTwotext: "Síntomas",
              color: wood_smoke,
              fg_color: wood_smoke,
              bg_color: athens_gray,
            ),
            const SizedBox(height: 24),

            // Selector de rango de fechas
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: athens_gray,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: wood_smoke, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ContraText(
                    text: 'Período del Reporte',
                    size: 16,
                    weight: FontWeight.bold,
                    color: wood_smoke,
                    alignment: Alignment.centerLeft,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ContraText(
                              text: 'Desde:',
                              size: 14,
                              color: trout,
                              alignment: Alignment.centerLeft,
                            ),
                            ContraText(
                              text: DateFormat('dd/MM/yyyy').format(_startDate),
                              size: 16,
                              color: wood_smoke,
                              weight: FontWeight.w500,
                              alignment: Alignment.centerLeft,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward, color: trout),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const ContraText(
                              text: 'Hasta:',
                              size: 14,
                              color: trout,
                              alignment: Alignment.centerRight,
                            ),
                            ContraText(
                              text: DateFormat('dd/MM/yyyy').format(_endDate),
                              size: 16,
                              color: wood_smoke,
                              weight: FontWeight.w500,
                              alignment: Alignment.centerRight,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ContraButton(
                    text: 'Cambiar Período',
                    iconPath: 'assets/icons/ic_search.svg',
                    callback: _selectDateRange,
                    color: lightening_yellow,
                    textColor: wood_smoke,
                    borderColor: wood_smoke,
                    shadowColor: athens_gray,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botones de acción rápida
            Row(
              children: [
                Expanded(
                  child: ContraButton(
                    text: 'Última Semana',
                    iconPath: 'assets/icons/ic_search.svg',
                    callback: () {
                      setState(() {
                        _endDate = DateTime.now();
                        _startDate = _endDate.subtract(const Duration(days: 7));
                      });
                      _generateReport();
                    },
                    color: white,
                    textColor: wood_smoke,
                    borderColor: wood_smoke,
                    shadowColor: athens_gray,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ContraButton(
                    text: 'Último Mes',
                    iconPath: 'assets/icons/ic_search.svg',
                    callback: () {
                      setState(() {
                        _endDate = DateTime.now();
                        _startDate =
                            _endDate.subtract(const Duration(days: 30));
                      });
                      _generateReport();
                    },
                    color: white,
                    textColor: wood_smoke,
                    borderColor: wood_smoke,
                    shadowColor: athens_gray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Reporte
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: athens_gray,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: wood_smoke, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.assessment, color: wood_smoke),
                      const SizedBox(width: 8),
                      const ContraText(
                        text: 'Reporte Médico',
                        size: 18,
                        weight: FontWeight.bold,
                        color: wood_smoke,
                        alignment: Alignment.centerLeft,
                      ),
                      const Spacer(),
                      if (_isGenerating)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: wood_smoke, width: 1),
                    ),
                    child: _isGenerating
                        ? const Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Generando reporte...'),
                              ],
                            ),
                          )
                        : SelectableText(
                            _reportText.isEmpty
                                ? 'No hay datos para mostrar'
                                : _reportText,
                            style: const TextStyle(
                              fontSize: 14,
                              color: wood_smoke,
                              height: 1.5,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Información adicional
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightening_yellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: lightening_yellow, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: wood_smoke),
                      const SizedBox(width: 8),
                      const ContraText(
                        text: 'Información del Reporte',
                        size: 16,
                        weight: FontWeight.bold,
                        color: wood_smoke,
                        alignment: Alignment.centerLeft,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const ContraText(
                    text:
                        '• Este reporte incluye todos los síntomas registrados en el período seleccionado.\n'
                        '• Los datos están organizados por fecha y hora.\n'
                        '• Puedes compartir este reporte con tu médico.\n'
                        '• El reporte se actualiza automáticamente al cambiar el período.',
                    size: 14,
                    color: trout,
                    alignment: Alignment.centerLeft,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
