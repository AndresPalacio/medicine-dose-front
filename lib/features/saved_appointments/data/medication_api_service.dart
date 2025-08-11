import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/medication_api_models.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/medication_model.dart';

class MedicationApiService {
  String _baseUrl =
      'https://qlgcj2104b.execute-api.us-east-1.amazonaws.com/prod/api';

  Future<List<MedicationResponse>> getAllMedications() async {
    final response =
        await http.get(Uri.parse('$_baseUrl/medications?userId=main'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body
          .map((dynamic item) => MedicationResponse.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load medications');
    }
  }

  // Método para obtener medicamentos con filtros específicos
  Future<List<MedicationResponse>> getMedicationsWithFilters({
    String? date,
    String? month,
  }) async {
    final queryParams = <String, String>{'userId': 'main'};
    if (date != null) queryParams['date'] = date;
    if (month != null) queryParams['month'] = month;

    final uri = Uri.parse('$_baseUrl/medications')
        .replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body
          .map((dynamic item) => MedicationResponse.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load medications with filters');
    }
  }

  Future<List<CalendarEventResponse>> getCalendarEvents() async {
    final response =
        await http.get(Uri.parse('$_baseUrl/medications/calendar?userId=main'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body
          .map((dynamic item) => CalendarEventResponse.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load calendar events');
    }
  }

  // Método adicional para obtener eventos del calendario con parámetros de fecha
  Future<List<CalendarEventResponse>> getCalendarEventsByDate(
      DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final response = await http.get(Uri.parse(
        '$_baseUrl/medications/calendar?date=$formattedDate&userId=main'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body
          .map((dynamic item) => CalendarEventResponse.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load calendar events');
    }
  }

  Future<List<MedicationDoseResponse>> getDailyDetail(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final response = await http.get(Uri.parse(
        '$_baseUrl/medications/daily-detail?date=$formattedDate&userId=main'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body
          .map((dynamic item) => MedicationDoseResponse.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load daily detail');
    }
  }

  Future<void> markDoseAsTaken(String doseId, bool isTaken) async {
    final url =
        '$_baseUrl/medications/mark-dose?doseId=$doseId&isTaken=${isTaken.toString()}&userId=main';

    // DEBUG
    // ignore: avoid_print
    print(
        'DEBUG markDoseAsTaken → PUT $url (doseId=$doseId, isTaken=$isTaken)');

    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    // DEBUG
    // ignore: avoid_print
    print(
        'DEBUG markDoseAsTaken ← status=${response.statusCode} body=${utf8.decode(response.bodyBytes)}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update dose status');
    }
  }

  Future<void> createMedication(MedicationPlan plan) async {
    final List<String> meals = [];
    if (plan.tomaDesayuno) meals.add('DESAYUNO');
    if (plan.tomaAlmuerzo) meals.add('ALMUERZO');
    if (plan.tomaCena) meals.add('CENA');

    String durationType;
    switch (plan.tipoDuracion) {
      case 'Semanas':
        durationType = 'WEEKS';
        break;
      case 'Meses':
        durationType = 'MONTHS';
        break;
      case 'Días':
      default:
        durationType = 'DAYS';
        break;
    }

    // Normalizar mealTiming según la nueva especificación
    String normalizedMealTiming = plan.mealTiming;
    if (plan.mealTiming == 'ANTES') {
      normalizedMealTiming = 'BEFORE';
    } else if (plan.mealTiming == 'DESPUES') {
      normalizedMealTiming = 'AFTER';
    }

    final body = {
      'userId': 'main',
      'name': plan.medicamento,
      'totalQuantity': plan.cantidadTotal,
      'quantityPerDose': plan.cantidadPorToma,
      'frequency': plan.frecuenciaDias,
      'duration': plan.duracion,
      'durationType': durationType,
      'startDate': DateFormat('yyyy-MM-dd').format(plan.fechaInicio),
      'meals': meals,
      'mealTiming': normalizedMealTiming,
      'timeBeforeAfter': plan.timeBeforeAfter,
      'timeUnit': plan.timeUnit,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/medications'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create medication.');
    }
  }

  Future<void> updateMedication(String id, Map<String, dynamic> body) async {
    // Normalizar mealTiming si está presente en el body
    if (body.containsKey('mealTiming')) {
      String mealTiming = body['mealTiming'];
      if (mealTiming == 'ANTES') {
        body['mealTiming'] = 'BEFORE';
      } else if (mealTiming == 'DESPUES') {
        body['mealTiming'] = 'AFTER';
      }
    }

    // Agregar userId al body si no está presente
    if (!body.containsKey('userId')) {
      body['userId'] = 'main';
    }

    final response = await http.put(
      Uri.parse('$_baseUrl/medications/$id'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('No se pudo actualizar el medicamento');
    }
  }

  Future<void> deleteMedication(String id) async {
    final response =
        await http.delete(Uri.parse('$_baseUrl/medications/$id?userId=main'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('No se pudo borrar el medicamento');
    }
  }
}
