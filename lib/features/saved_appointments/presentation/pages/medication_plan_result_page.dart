import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_button.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_text.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/medication_api_service.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/medication_model.dart';
import 'package:vibe_coding_tutorial_weather_app/utils/colors.dart';

class MedicationPlanResultPage extends StatefulWidget {
  final MedicationPlan plan;

  const MedicationPlanResultPage({super.key, required this.plan});

  @override
  State<MedicationPlanResultPage> createState() =>
      _MedicationPlanResultPageState();
}

class _MedicationPlanResultPageState extends State<MedicationPlanResultPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MedicationApiService _apiService = MedicationApiService();
  bool _isSaving = false;

  DateTime _computeEndDate(
      {required DateTime startDate,
      required int duration,
      required String durationTypeEs}) {
    switch (durationTypeEs) {
      case 'Semanas':
        return startDate.add(Duration(days: duration * 7 - 1));
      case 'Meses':
        // Para meses, calculamos la fecha exacta sumando los meses
        // y luego restamos 1 día para que sea el último día del período
        final endDate =
            DateTime(startDate.year, startDate.month + duration, startDate.day);
        return endDate.subtract(const Duration(days: 1));
      case 'Días':
      default:
        return startDate.add(Duration(days: duration - 1));
    }
  }

  int _computeOccurrencesCount(
      {required DateTime startDate,
      required DateTime endDate,
      required int frequencyDays}) {
    if (frequencyDays <= 0) return 0;
    final totalDays = endDate.difference(startDate).inDays;
    // Calcular cuántas veces se toma el medicamento en el rango de fechas
    // Si frequencyDays = 2, significa cada 2 días (día 0, 2, 4, 6, ...)
    return (totalDays ~/ frequencyDays) + 1; // +1 para incluir el día de inicio
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _savePlan() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await _apiService.createMedication(widget.plan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plan de medicación guardado con éxito.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true on success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el plan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: athens_gray,
      appBar: AppBar(
        backgroundColor: athens_gray,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: wood_smoke),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const ContraText(
          text: 'Resultado del Plan de Medicación',
          size: 22,
          weight: FontWeight.bold,
          color: wood_smoke,
          alignment: Alignment.center,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: wood_smoke, width: 2),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: lightening_yellow,
                ),
                labelColor: wood_smoke,
                unselectedLabelColor: wood_smoke,
                tabs: const [
                  Tab(text: 'Resumen'),
                  Tab(text: 'Calendario'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSummaryTab(),
                  _buildCalendarTab(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ContraButton(
              borderColor: wood_smoke,
              shadowColor: wood_smoke,
              color: lightening_yellow,
              textColor: wood_smoke,
              text: _isSaving ? 'Guardando...' : 'Guardar Plan',
              callback: _isSaving ? () {} : _savePlan,
              iconPath: '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTab() {
    final tomas = <String>[];
    if (widget.plan.tomaDesayuno) tomas.add('BREAKFAST');
    if (widget.plan.tomaAlmuerzo) tomas.add('LUNCH');
    if (widget.plan.tomaCena) tomas.add('DINNER');

    int totalTomasDia = tomas.length;
    final endDate = _computeEndDate(
      startDate: widget.plan.fechaInicio,
      duration: widget.plan.duracion,
      durationTypeEs: widget.plan.tipoDuracion,
    );
    final ocurrencias = _computeOccurrencesCount(
      startDate: widget.plan.fechaInicio,
      endDate: endDate,
      frequencyDays: widget.plan.frecuenciaDias,
    );

    int cantidadNecesaria =
        widget.plan.cantidadPorToma * totalTomasDia * ocurrencias;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Cantidad Necesaria Estimada', '$cantidadNecesaria'),
          const SizedBox(height: 24),
          _buildInfoCard(
            'Resumen del Plan',
            '${widget.plan.medicamento} ${widget.plan.cantidadPorToma} pastilla(s) $totalTomasDia veces al día (${tomas.join(', ')}) durante ${widget.plan.duracion} ${widget.plan.tipoDuracion.toLowerCase()} (del ${DateFormat('dd/MM/yyyy').format(widget.plan.fechaInicio)} al ${DateFormat('dd/MM/yyyy').format(endDate)})',
          ),
          // Aquí se podría agregar la lógica de "Próximas fechas de repetición"
        ],
      ),
    );
  }

  Widget _buildCalendarTab() {
    final tomas = <Map<String, dynamic>>[];
    final formatter = DateFormat('dd/MM/yyyy');

    final endDate = _computeEndDate(
      startDate: widget.plan.fechaInicio,
      duration: widget.plan.duracion,
      durationTypeEs: widget.plan.tipoDuracion,
    );

    DateTime currentDate = widget.plan.fechaInicio;
    while (!currentDate.isAfter(endDate)) {
      if (widget.plan.tomaDesayuno) {
        tomas.add({
          "fecha": formatter.format(currentDate),
          "horario": "BREAKFAST",
          "medicamento": widget.plan.medicamento,
          "cantidad": widget.plan.cantidadPorToma,
        });
      }
      if (widget.plan.tomaAlmuerzo) {
        tomas.add({
          "fecha": formatter.format(currentDate),
          "horario": "LUNCH",
          "medicamento": widget.plan.medicamento,
          "cantidad": widget.plan.cantidadPorToma,
        });
      }
      if (widget.plan.tomaCena) {
        tomas.add({
          "fecha": formatter.format(currentDate),
          "horario": "DINNER",
          "medicamento": widget.plan.medicamento,
          "cantidad": widget.plan.cantidadPorToma,
        });
      }
      currentDate = currentDate.add(Duration(days: widget.plan.frecuenciaDias));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: ContraText(
            text: 'Calendario de Tomas',
            size: 18,
            weight: FontWeight.bold,
            alignment: Alignment.centerLeft,
          ),
        ),
        _buildCalendarHeader(),
        Expanded(
          child: ListView.builder(
            itemCount: tomas.length,
            itemBuilder: (context, index) {
              final toma = tomas[index];
              return _buildCalendarRow(toma['fecha'], toma['horario'],
                  toma['medicamento'], '${toma['cantidad']}');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: wood_smoke, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContraText(
            text: title,
            size: 18,
            weight: FontWeight.bold,
            alignment: Alignment.centerLeft,
          ),
          const SizedBox(height: 8),
          ContraText(
            text: content,
            size: 15,
            alignment: Alignment.centerLeft,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: athens_gray,
        border: Border(bottom: BorderSide(color: wood_smoke, width: 2)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: ContraText(
                  text: 'FECHA',
                  weight: FontWeight.bold,
                  size: 12,
                  alignment: Alignment.centerLeft)),
          Expanded(
              child: ContraText(
                  text: 'HORARIO',
                  weight: FontWeight.bold,
                  size: 12,
                  alignment: Alignment.centerLeft)),
          Expanded(
              child: ContraText(
                  text: 'MEDICAMENTO',
                  weight: FontWeight.bold,
                  size: 12,
                  alignment: Alignment.centerLeft)),
          ContraText(
              text: 'CANTIDAD',
              weight: FontWeight.bold,
              size: 12,
              alignment: Alignment.centerLeft),
        ],
      ),
    );
  }

  Widget _buildCalendarRow(
      String date, String schedule, String med, String quantity) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: santas_gray, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: ContraText(
                  text: date, size: 14, alignment: Alignment.centerLeft)),
          Expanded(
              child: ContraText(
                  text: schedule, size: 14, alignment: Alignment.centerLeft)),
          Expanded(
              child: ContraText(
                  text: med, size: 14, alignment: Alignment.centerLeft)),
          ContraText(text: quantity, size: 14, alignment: Alignment.centerLeft),
        ],
      ),
    );
  }
}
