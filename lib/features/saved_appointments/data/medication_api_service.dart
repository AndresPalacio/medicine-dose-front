import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/medication_api_models.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/medication_model.dart';

class MedicationApiService {
  String _baseUrl =
      'https://qlgcj2104b.execute-api.us-east-1.amazonaws.com/prod/api';

  Future<List<MedicationResponse>> getAllMedications() async {
    final response = await http.get(Uri.parse('$_baseUrl/medications'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body
          .map((dynamic item) => MedicationResponse.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load medications');
    }
  }

  Future<List<CalendarEventResponse>> getCalendarEvents() async {
    final response =
        await http.get(Uri.parse('$_baseUrl/medications/calendar'));

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
    final response = await http.get(
        Uri.parse('$_baseUrl/medications/daily-detail?date=$formattedDate'));

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
    // Algunos backends usan IDs compuestos con caracteres reservados (#, |, etc.).
    // Debemos codificar el segmento para que el navegador no corte la URL en '#'.
    final encodedDoseId = Uri.encodeComponent(doseId);
    final url = '$_baseUrl/medications/doses/$encodedDoseId';

    // DEBUG
    // ignore: avoid_print
    print(
        'DEBUG markDoseAsTaken → PUT $url (doseId=$doseId, isTaken=$isTaken)');

    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'isTaken': isTaken}),
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

    final body = {
      'name': plan.medicamento,
      'totalQuantity': plan.cantidadTotal,
      'quantityPerDose': plan.cantidadPorToma,
      'frequency': plan.frecuenciaDias,
      'duration': plan.duracion,
      'durationType': durationType,
      'startDate': DateFormat('yyyy-MM-dd').format(plan.fechaInicio),
      'meals': meals,
      'mealTiming': plan.mealTiming,
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
    final response = await http.delete(Uri.parse('$_baseUrl/medications/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('No se pudo borrar el medicamento');
    }
  }
}
