import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_button_round.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_text.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/custom_header.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/medication_api_models.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/medication_api_service.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/presentation/pages/add_medication_page.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/presentation/pages/calendar_page.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/presentation/pages/medical_appointments_page.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/presentation/pages/edit_medications_page.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/presentation/widgets/medication_card_widget.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/responsive_action_buttons.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/responsive_date_selector.dart';
import 'package:vibe_coding_tutorial_weather_app/utils/colors.dart';

class SavedAppointmentsPage extends StatefulWidget {
  const SavedAppointmentsPage({super.key});

  @override
  State<SavedAppointmentsPage> createState() => _SavedAppointmentsPageState();
}

class _SavedAppointmentsPageState extends State<SavedAppointmentsPage> {
  late DateTime _selectedDate;
  String _visibleDateRange = '';
  final List<DateTime> _dates = [];
  late ScrollController _scrollController;
  final double _dateChipWidth = 68.0; // 60 width + 8 horizontal margin

  final MedicationApiService _apiService = MedicationApiService();
  bool _isLoading = true;
  String? _error;

  Map<String, MedicationResponse> _medicationsMap = {};
  List<MedicationDoseResponse> _dailyDoses = [];

  // Variables para la caché optimizada
  List<MedicationDoseResponse> _monthlyData = [];
  DateTime? _currentCachedMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    // Inicializar la lista de fechas con 6 meses antes y 6 meses después de hoy
    final startDate = _selectedDate.subtract(const Duration(days: 182));
    final endDate = _selectedDate.add(const Duration(days: 182));
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      _dates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }
    _scrollController = ScrollController();
    _scrollController.addListener(_updateVisibleDateRange);

    _fetchInitialData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToDate(_selectedDate, jump: true);
      _updateVisibleDateRange();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateVisibleDateRange);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final medications = await _apiService.getAllMedications();
      _medicationsMap = {for (var med in medications) med.id: med};
      await _fetchDailyDoses(_selectedDate);
    } catch (e) {
      setState(() {
        _error = "Error al cargar los datos iniciales: $e";
      });
      // DEBUG
      // ignore: avoid_print
      print('DEBUG _fetchInitialData error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchDailyDoses(DateTime date) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Verificar si necesitamos cargar datos del mes
      final currentMonth = DateTime(date.year, date.month, 1);
      if (_currentCachedMonth == null ||
          _currentCachedMonth!.year != currentMonth.year ||
          _currentCachedMonth!.month != currentMonth.month) {
        // Cargar datos del mes completo (con caché del servicio)
        _monthlyData = await _apiService.getMonthlyDetail(date);
        _currentCachedMonth = currentMonth;

        // DEBUG
        // ignore: avoid_print
        print(
            'DEBUG _fetchDailyDoses → Loaded monthly data for ${currentMonth.year}-${currentMonth.month} (${_monthlyData.length} items)');
      }

      // Filtrar datos del día específico
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final dailyDoses = _monthlyData.where((medication) {
        return medication.date == formattedDate;
      }).toList();

      if (mounted) {
        setState(() {
          _dailyDoses = dailyDoses;
        });
      }

      // DEBUG
      // ignore: avoid_print
      print(
          'DEBUG _fetchDailyDoses → Filtered ${dailyDoses.length} items for date: $formattedDate');
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Error al cargar las tomas del día: $e";
        });
        // DEBUG
        // ignore: avoid_print
        print('DEBUG _fetchDailyDoses error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateVisibleDateRange() {
    if (!_scrollController.hasClients || !mounted) return;

    final firstVisibleIndex =
        (_scrollController.offset / _dateChipWidth).floor();
    final screenWidth = MediaQuery.of(context).size.width;
    final visibleItemsCount = (screenWidth / _dateChipWidth).ceil();
    final lastVisibleIndex =
        (firstVisibleIndex + visibleItemsCount - 1).clamp(0, _dates.length - 1);

    final startDate = _dates[firstVisibleIndex];
    final endDate = _dates[lastVisibleIndex];

    final formatter = DateFormat('d MMMM', 'es_ES');

    setState(() {
      _visibleDateRange =
          '${formatter.format(startDate)} - ${formatter.format(endDate)}';
      // Actualizar también la fecha seleccionada para sincronizar el mes/año
      _selectedDate = startDate;
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _fetchDailyDoses(date);
    _scrollToDate(date);
  }

  void _jumpToDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      // Recalcular la lista de fechas si la fecha seleccionada está fuera del rango actual
      final today = DateTime.now();
      final daysFromToday = date.difference(today).inDays;
      if (daysFromToday < 0 || daysFromToday >= _dates.length) {
        // Recrear la lista de fechas centrada en la fecha seleccionada
        _dates.clear();
        final startDate =
            date.subtract(const Duration(days: 182)); // 6 meses antes
        final endDate = date.add(const Duration(days: 182)); // 6 meses después
        DateTime currentDate = startDate;
        while (currentDate.isBefore(endDate) ||
            currentDate.isAtSameMomentAs(endDate)) {
          _dates.add(currentDate);
          currentDate = currentDate.add(const Duration(days: 1));
        }
      }
    });
    _fetchDailyDoses(date);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToDate(date, jump: true);
      _updateVisibleDateRange();
    });
  }

  /// Actualiza la caché local cuando se marca una dosis como tomada
  void _updateLocalCache(String doseId, bool isTaken) {
    if (_monthlyData.isNotEmpty) {
      // Buscar la dosis en la caché local y actualizarla
      final doseIndex = _monthlyData.indexWhere((dose) => dose.id == doseId);
      if (doseIndex != -1) {
        // Crear una nueva instancia con el estado actualizado
        final updatedDose = MedicationDoseResponse(
          id: _monthlyData[doseIndex].id,
          medicationId: _monthlyData[doseIndex].medicationId,
          medicationName: _monthlyData[doseIndex].medicationName,
          date: _monthlyData[doseIndex].date,
          meal: _monthlyData[doseIndex].meal,
          quantity: _monthlyData[doseIndex].quantity,
          taken: isTaken,
          mealTiming: _monthlyData[doseIndex].mealTiming,
          timeBeforeAfter: _monthlyData[doseIndex].timeBeforeAfter,
          timeUnit: _monthlyData[doseIndex].timeUnit,
        );

        // Actualizar la dosis en la caché
        _monthlyData[doseIndex] = updatedDose;

        // DEBUG
        // ignore: avoid_print
        print(
            'DEBUG _updateLocalCache → Updated dose $doseId to taken=$isTaken');
      }
    }
  }

  /// Limpia la caché local cuando se modifican los medicamentos
  void _clearLocalCache() {
    _monthlyData.clear();
    _currentCachedMonth = null;
    // DEBUG
    // ignore: avoid_print
    print('DEBUG _clearLocalCache → Local cache cleared');
  }

  void _scrollToDate(DateTime date, {bool jump = false}) {
    final selectedDateIndex = _dates.indexWhere((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);

    if (selectedDateIndex != -1 && _scrollController.hasClients) {
      final scrollOffset = selectedDateIndex * _dateChipWidth;

      if (jump) {
        _scrollController.jumpTo(
            scrollOffset.clamp(0, _scrollController.position.maxScrollExtent));
      } else {
        _scrollController.animateTo(
          scrollOffset.clamp(0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _scrollBy(int days) {
    final currentOffset = _scrollController.offset;
    final scrollAmount = days * _dateChipWidth;

    _scrollController.animateTo(
      (currentOffset + scrollAmount)
          .clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: athens_gray,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMedicationPage(),
            ),
          );
          if (result == true) {
            _fetchInitialData();
          }
        },
        backgroundColor: lightening_yellow,
        child: const Icon(
          Icons.add,
          color: wood_smoke,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(
                Icons.arrow_back,
                color: wood_smoke,
              ),
            ),
            const SizedBox(height: 16),
            CustomHeader(
              lineOneText: "Tus",
              lineTwotext: "Medicamentos",
              color: wood_smoke,
              fg_color: wood_smoke,
              bg_color: athens_gray,
            ),
            const SizedBox(height: 16),
            ResponsiveDateSelector(
              selectedDate: _selectedDate,
              onEditPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditMedicationsPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ResponsiveActionButtons(
              onCitasPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MedicalAppointmentsPage(),
                  ),
                );
              },
              onCalendarioPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CalendarPage(),
                  ),
                );
              },
              onCambiarMesPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  locale: const Locale('es', 'ES'),
                );
                if (pickedDate != null) {
                  _jumpToDate(pickedDate);
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ContraButtonRound(
                  borderColor: wood_smoke,
                  shadowColor: athens_gray,
                  color: white,
                  iconPath: "assets/icons/arrow_back.svg",
                  callback: () => _scrollBy(-7),
                ),
                ContraText(
                  alignment: Alignment.center,
                  text: _visibleDateRange,
                  size: 18,
                  color: trout,
                ),
                ContraButtonRound(
                  borderColor: wood_smoke,
                  shadowColor: athens_gray,
                  color: white,
                  iconPath: "assets/icons/arrow_forward.svg",
                  callback: () => _scrollBy(7),
                )
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: _dates.length,
                itemBuilder: (context, index) {
                  final date = _dates[index];
                  final isSelected = date.day == _selectedDate.day &&
                      date.month == _selectedDate.month &&
                      date.year == _selectedDate.year;
                  return GestureDetector(
                    onTap: () => _onDateSelected(date),
                    child: _buildDateChip(date, isSelected),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const ContraText(
              text: 'Tus Recordatorios',
              size: 22,
              weight: FontWeight.bold,
              color: wood_smoke,
              alignment: Alignment.centerLeft,
            ),
            const SizedBox(height: 16),
            _buildMedicationList(),
            const SizedBox(height: 80), // Espacio para el FAB
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationList() {
    if (_isLoading && _dailyDoses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: ContraText(
            text: _error!,
            size: 18,
            color: trout,
            alignment: Alignment.center,
          ),
        ),
      );
    }

    if (_dailyDoses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: ContraText(
            text: "No hay medicamentos para este día.",
            size: 18,
            color: trout,
            alignment: Alignment.center,
          ),
        ),
      );
    }

    final pendingDoses = _dailyDoses.where((dose) => !dose.taken).toList();
    final takenDoses = _dailyDoses.where((dose) => dose.taken).toList();

    return RefreshIndicator(
      onRefresh: _fetchInitialData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pendingDoses.isNotEmpty) ...[
            const ContraText(
              text: 'Pendientes',
              size: 18,
              weight: FontWeight.bold,
              alignment: Alignment.centerLeft,
            ),
            const SizedBox(height: 12),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: pendingDoses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final dose = pendingDoses[index];
                final medication = _medicationsMap[dose.medicationId];
                return MedicationCardWidget(
                  name: medication?.name ?? 'Medicamento no encontrado',
                  meal: dose.meal,
                  quantity: dose.quantity,
                  isTaken: dose.taken,
                  onToggle: () async {
                    final originalState = dose.taken;
                    // DEBUG
                    // ignore: avoid_print
                    print(
                        'DEBUG SavedAppointmentsPage.onToggle doseId=${dose.id} before=${originalState}');
                    setState(() {
                      dose.taken = !originalState;
                    });
                    try {
                      await _apiService.markDoseAsTaken(
                          dose.id, !originalState);
                      // Actualizar caché local después de marcar dosis
                      _updateLocalCache(dose.id, !originalState);
                    } catch (e) {
                      // DEBUG
                      // ignore: avoid_print
                      print(
                          'DEBUG SavedAppointmentsPage.onToggle ERROR for doseId=${dose.id}: $e');
                      setState(() {
                        dose.taken = originalState;
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error al actualizar la toma.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 24),
          ],
          if (takenDoses.isNotEmpty) ...[
            const ContraText(
              text: 'Completados',
              size: 18,
              weight: FontWeight.bold,
              alignment: Alignment.centerLeft,
            ),
            const SizedBox(height: 12),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: takenDoses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final dose = takenDoses[index];
                final medication = _medicationsMap[dose.medicationId];
                return MedicationCardWidget(
                  name: medication?.name ?? 'Medicamento no encontrado',
                  meal: dose.meal,
                  quantity: dose.quantity,
                  isTaken: dose.taken,
                  onToggle: () async {
                    final originalState = dose.taken;
                    // DEBUG
                    // ignore: avoid_print
                    print(
                        'DEBUG SavedAppointmentsPage.onToggle (taken list) doseId=${dose.id} before=${originalState}');
                    setState(() {
                      dose.taken = !originalState;
                    });
                    try {
                      await _apiService.markDoseAsTaken(
                          dose.id, !originalState);
                      // Actualizar caché local después de marcar dosis
                      _updateLocalCache(dose.id, !originalState);
                    } catch (e) {
                      // DEBUG
                      // ignore: avoid_print
                      print(
                          'DEBUG SavedAppointmentsPage.onToggle (taken list) ERROR for doseId=${dose.id}: $e');
                      setState(() {
                        dose.taken = originalState;
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error al actualizar la toma.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateChip(DateTime date, bool isSelected) {
    return Container(
      width: 60,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected ? lightening_yellow : white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: wood_smoke, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ContraText(
              text: date.day.toString(),
              color: wood_smoke,
              weight: FontWeight.bold,
              size: 20,
              alignment: Alignment.center),
          const SizedBox(height: 4),
          ContraText(
              text: _getWeekday(date.weekday),
              color: trout,
              size: 14,
              alignment: Alignment.center),
        ],
      ),
    );
  }

  String _getWeekday(int weekday) {
    const weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return weekdays[weekday - 1];
  }
}
