import 'dart:convert';
import 'medication_api_models.dart';

class CalendarExample {
  // Ejemplo de datos del calendario (los que proporcionaste)
  static const String calendarData = '''
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
    }
]
''';

  // Método para procesar los datos del calendario
  static CalendarResponse processCalendarData(String jsonData) {
    try {
      final List<dynamic> jsonList = json.decode(jsonData);
      return CalendarResponse.fromJson(jsonList);
    } catch (e) {
      print('Error procesando datos del calendario: $e');
      return CalendarResponse(doses: []);
    }
  }

  // Método para obtener estadísticas de las dosis
  static Map<String, dynamic> getDoseStatistics(CalendarResponse calendar) {
    final totalDoses = calendar.doses.length;
    final pendingDoses = calendar.getPendingDoses().length;
    final completedDoses = calendar.getCompletedDoses().length;

    // Agrupar por medicamento
    final Map<String, int> dosesByMedication = {};
    for (final dose in calendar.doses) {
      dosesByMedication[dose.medicationName] =
          (dosesByMedication[dose.medicationName] ?? 0) + 1;
    }

    // Agrupar por comida
    final Map<String, int> dosesByMeal = {};
    for (final dose in calendar.doses) {
      dosesByMeal[dose.mealInSpanish] =
          (dosesByMeal[dose.mealInSpanish] ?? 0) + 1;
    }

    return {
      'totalDoses': totalDoses,
      'pendingDoses': pendingDoses,
      'completedDoses': completedDoses,
      'dosesByMedication': dosesByMedication,
      'dosesByMeal': dosesByMeal,
    };
  }

  // Método para obtener dosis de una fecha específica
  static List<CalendarDoseResponse> getDosesForSpecificDate(
      CalendarResponse calendar, String date) {
    return calendar.getDosesByDate(date);
  }

  // Método para obtener dosis de hoy
  static List<CalendarDoseResponse> getTodayDoses(CalendarResponse calendar) {
    return calendar.getTodayDoses();
  }

  // Método para obtener dosis de la semana actual
  static List<CalendarDoseResponse> getCurrentWeekDoses(
      CalendarResponse calendar) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return calendar.getDosesForWeek(weekStart);
  }

  // Método para obtener dosis del mes actual
  static List<CalendarDoseResponse> getCurrentMonthDoses(
      CalendarResponse calendar) {
    final now = DateTime.now();
    return calendar.getDosesForMonth(now.year, now.month);
  }
}
