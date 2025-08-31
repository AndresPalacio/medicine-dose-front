import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibe_coding_tutorial_weather_app/core/data_state.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_button.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_button_round.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_text.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/medication_api_models.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/medication_api_service.dart';
import 'package:vibe_coding_tutorial_weather_app/utils/colors.dart';

class InfiniteCalendarWidget extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime)? onDateSelected;
  final Function(List<MedicationDoseResponse>)? onEventSelected;

  const InfiniteCalendarWidget({
    Key? key,
    this.initialDate,
    this.onDateSelected,
    this.onEventSelected,
  }) : super(key: key);

  @override
  State<InfiniteCalendarWidget> createState() => _InfiniteCalendarWidgetState();
}

class _InfiniteCalendarWidgetState extends State<InfiniteCalendarWidget> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;
  final MedicationApiService _apiService = MedicationApiService();

  DataState<List<MedicationDoseResponse>> _calendarState =
      const DataState.loading();
  Map<String, List<MedicationDoseResponse>> _eventsMap = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    _loadCalendarEvents();
  }

  Future<void> _loadCalendarEvents() async {
    setState(() {
      _calendarState = const DataState.loading();
    });
    try {
      // Usar getMonthlyDetail que tiene caché y es más eficiente
      final monthlyDoses = await _apiService.getMonthlyDetail(_currentMonth);
      final eventsMap = <String, List<MedicationDoseResponse>>{};

      // Agrupar las dosis por fecha
      for (final dose in monthlyDoses) {
        if (eventsMap.containsKey(dose.date)) {
          eventsMap[dose.date]!.add(dose);
        } else {
          eventsMap[dose.date] = [dose];
        }
      }

      setState(() {
        _eventsMap = eventsMap;
        _calendarState = DataState.success(value: monthlyDoses);
      });
    } catch (e) {
      setState(() {
        _calendarState =
            DataState.failure('Error al cargar eventos del calendario');
      });
    }
  }

  /// Método público para refrescar los datos del calendario
  /// Útil cuando se actualiza el estado de una dosis
  Future<void> refreshCalendarEvents() async {
    // Limpiar la caché para forzar una nueva carga
    _apiService.clearCacheForDoseUpdate();
    await _loadCalendarEvents();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    widget.onDateSelected?.call(date);
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    final doses = _eventsMap[dateString];
    if (doses != null && doses.isNotEmpty) {
      widget.onEventSelected?.call(doses);
    }
  }

  void _navigateToMonth(int months) {
    setState(() {
      _currentMonth =
          DateTime(_currentMonth.year, _currentMonth.month + months, 1);
      // Si la fecha seleccionada no está en el mes, selecciona el primer día del mes
      if (_selectedDate.year != _currentMonth.year ||
          _selectedDate.month != _currentMonth.month) {
        _selectedDate = _currentMonth;
      }
    });
    // Recargar los eventos del nuevo mes
    _loadCalendarEvents();
  }

  Widget _buildMonthCalendar(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    final days = <Widget>[];
    // Días vacíos al inicio (lunes=1)
    for (int i = 1; i < firstWeekday; i++) {
      days.add(_buildEmptyDay());
    }
    // Días del mes
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final isSelected = date.day == _selectedDate.day &&
          date.month == _selectedDate.month &&
          date.year == _selectedDate.year;
      final isToday = date.day == DateTime.now().day &&
          date.month == DateTime.now().month &&
          date.year == DateTime.now().year;
      days.add(_buildDay(date, isSelected, isToday));
    }
    // Días vacíos al final
    int totalCells = days.length;
    int remainder = totalCells % 7;
    if (remainder != 0) {
      int emptyToAdd = 7 - remainder;
      for (int i = 0; i < emptyToAdd; i++) {
        days.add(_buildEmptyDay());
      }
    }
    return Column(
      children: [
        _buildMonthHeader(month),
        const SizedBox(height: 16),
        _buildWeekdayHeader(),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: days,
        ),
      ],
    );
  }

  Widget _buildMonthHeader(DateTime month) {
    final formatter = DateFormat('MMMM yyyy', 'es_ES');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ContraButtonRound(
          borderColor: wood_smoke,
          shadowColor: athens_gray,
          color: white,
          iconPath: "assets/icons/arrow_back.svg",
          callback: () => _navigateToMonth(-1),
        ),
        Expanded(
          child: ContraText(
            alignment: Alignment.center,
            text: formatter.format(month),
            size: 18,
            weight: FontWeight.bold,
            color: wood_smoke,
          ),
        ),
        ContraButtonRound(
          borderColor: wood_smoke,
          shadowColor: athens_gray,
          color: white,
          iconPath: "assets/icons/arrow_forward.svg",
          callback: () => _navigateToMonth(1),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return Row(
      children: weekdays
          .map((day) => Expanded(
                child: Center(
                  child: ContraText(
                    alignment: Alignment.center,
                    text: day,
                    size: 12,
                    weight: FontWeight.bold,
                    color: trout,
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDay(DateTime date, bool isSelected, bool isToday) {
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    final event = _eventsMap[dateString];
    final hasEvent = event != null;
    return GestureDetector(
      onTap: () => _onDateSelected(date),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? carribean_green : (isToday ? selago : white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? carribean_green : wood_smoke,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: ContraText(
                alignment: Alignment.center,
                text: '${date.day}',
                size: 14,
                weight:
                    isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? white : wood_smoke,
              ),
            ),
            if (hasEvent)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: mona_lisa,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDay() {
    return Container(
      margin: const EdgeInsets.all(2),
    );
  }

  Widget _buildEventsList() {
    if (_calendarState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: carribean_green),
      );
    }
    if (_calendarState.hasFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ContraText(
              alignment: Alignment.center,
              text: 'Error al cargar eventos',
              size: 16,
              color: alizarin_crimson,
            ),
            const SizedBox(height: 8),
            ContraButton(
              text: 'Reintentar',
              color: carribean_green,
              textColor: white,
              borderColor: wood_smoke,
              shadowColor: athens_gray,
              iconPath: "assets/icons/placeholder_icon.svg",
              callback: _loadCalendarEvents,
            ),
          ],
        ),
      );
    }
    final events = _calendarState.value;
    if (events == null || events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ContraText(
              alignment: Alignment.center,
              text: 'No hay eventos programados',
              size: 16,
              color: trout,
            ),
            const SizedBox(height: 8),
            ContraText(
              alignment: Alignment.center,
              text: 'Agrega medicamentos para ver eventos en el calendario',
              size: 14,
              color: santas_gray,
            ),
          ],
        ),
      );
    }
    // Filtrar dosis del mes actual
    final monthString = DateFormat('yyyy-MM').format(_currentMonth);
    final monthDoses =
        events.where((d) => d.date.startsWith(monthString)).toList();
    if (monthDoses.isEmpty) {
      return Center(
        child: ContraText(
          alignment: Alignment.center,
          text: 'No hay eventos para este mes',
          size: 16,
          color: trout,
        ),
      );
    }
    return ListView.builder(
      itemCount: monthDoses.length,
      itemBuilder: (context, index) {
        final dose = monthDoses[index];
        return _buildEventCard(dose);
      },
    );
  }

  Widget _buildEventCard(MedicationDoseResponse dose) {
    final date = DateTime.parse(dose.date);
    final formatter = DateFormat('dd MMMM yyyy', 'es_ES');
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: wood_smoke, width: 1),
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
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: mona_lisa,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ContraText(
                  alignment: Alignment.centerLeft,
                  text: formatter.format(date),
                  size: 14,
                  weight: FontWeight.bold,
                  color: wood_smoke,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ContraText(
            alignment: Alignment.centerLeft,
            text: '${dose.medicationName} - ${dose.meal}',
            size: 16,
            weight: FontWeight.bold,
            color: carribean_green,
          ),
          const SizedBox(height: 4),
          ContraText(
            alignment: Alignment.centerLeft,
            text: 'Tomar ${dose.quantity} pastilla(s)',
            size: 12,
            color: trout,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = 500.0; // Máximo ancho para web
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Calendario (solo un mes visible)
              Container(
                color: selago,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                child: _buildMonthCalendar(_currentMonth),
              ),
              const SizedBox(height: 16),
              // Lista de eventos scrolleable
              const ContraText(
                alignment: Alignment.centerLeft,
                text: 'Eventos del Mes',
                size: 18,
                weight: FontWeight.bold,
                color: wood_smoke,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 350,
                child: _buildEventsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
