import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/medication_api_models.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/medication_model.dart';

class MedicationApiService {
  String _baseUrl = 'http://localhost:8080/api';

  // Variables para la caché de medicamentos mensuales
  Map<String, List<MedicationDoseResponse>> _monthlyCache = {};
  String? _currentCachedMonth;

  Future<List<MedicationResponse>> getAllMedications() async {
    final url = '$_baseUrl/medications?userId=main';

    // DEBUG
    // ignore: avoid_print
    print('DEBUG getAllMedications → GET $url');

    final response = await http.get(Uri.parse(url));

    // DEBUG
    // ignore: avoid_print
    print(
        'DEBUG getAllMedications ← status=${response.statusCode} body=${utf8.decode(response.bodyBytes)}');

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body
          .map((dynamic item) => MedicationResponse.fromJson(item))
          .toList();
    } else {
      throw Exception(
          'Failed to load medications: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}');
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
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/medications/calendar?userId=main'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body
            .map((dynamic item) => CalendarEventResponse.fromJson(item))
            .toList();
      } else {
        throw Exception(
            'Failed to load calendar events: ${response.statusCode}');
      }
    } catch (e) {
      // Si hay error de conexión, devolver datos de ejemplo
      print('DEBUG getCalendarEvents: Error connecting to server: $e');
      return _getMockCalendarEvents();
    }
  }

  // Método para generar datos de ejemplo cuando el servidor no está disponible
  List<CalendarEventResponse> _getMockCalendarEvents() {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final tomorrow =
        DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 1)));

    return [
      CalendarEventResponse(
        id: 'mock-1',
        title: 'ESOZ 40MG - Desayuno',
        start: today,
        description: 'Tomar 1 cápsula con el desayuno',
        doses: [
          MedicationDoseResponse(
            id: '1',
            medicationId: 'mock-med-1',
            medicationName: 'ESOZ 40MG',
            date: today,
            meal: 'DESAYUNO',
            quantity: 1,
            taken: false,
            mealTiming: 'DURANTE',
            timeBeforeAfter: 0,
            timeUnit: 'MINUTOS',
          ),
        ],
      ),
      CalendarEventResponse(
        id: 'mock-2',
        title: 'ESOZ 40MG - Desayuno',
        start: tomorrow,
        description: 'Tomar 1 cápsula con el desayuno',
        doses: [
          MedicationDoseResponse(
            id: '2',
            medicationId: 'mock-med-1',
            medicationName: 'ESOZ 40MG',
            date: tomorrow,
            meal: 'DESAYUNO',
            quantity: 1,
            taken: false,
            mealTiming: 'DURANTE',
            timeBeforeAfter: 0,
            timeUnit: 'MINUTOS',
          ),
        ],
      ),
    ];
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
    final url =
        '$_baseUrl/medications/daily-detail?date=$formattedDate&userId=main';

    // DEBUG
    // ignore: avoid_print
    print('DEBUG getDailyDetail → GET $url');

    final response = await http.get(Uri.parse(url));

    // DEBUG
    // ignore: avoid_print
    print(
        'DEBUG getDailyDetail ← status=${response.statusCode} body=${utf8.decode(response.bodyBytes)}');

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body
          .map((dynamic item) => MedicationDoseResponse.fromJson(item))
          .toList();
    } else {
      throw Exception(
          'Failed to load daily detail: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}');
    }
  }

  /// Obtiene los medicamentos mensuales con caché para optimizar las consultas
  /// Solo hace una nueva petición si cambia el mes o si no hay datos en caché
  Future<List<MedicationDoseResponse>> getMonthlyDetail(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final monthKey = DateFormat('yyyy-MM').format(date);

    // DEBUG
    // ignore: avoid_print
    print('DEBUG getMonthlyDetail → Checking cache for month: $monthKey');

    // Verificar si ya tenemos datos en caché para este mes
    if (_monthlyCache.containsKey(monthKey) &&
        _currentCachedMonth == monthKey) {
      // DEBUG
      // ignore: avoid_print
      print(
          'DEBUG getMonthlyDetail ← Returning cached data for month: $monthKey');
      return _monthlyCache[monthKey]!;
    }

    // Si no hay caché o cambió el mes, hacer la petición
    final url =
        '$_baseUrl/medications/monthly-detail?date=$formattedDate&userId=main';

    // DEBUG
    // ignore: avoid_print
    print('DEBUG getMonthlyDetail → GET $url');

    final response = await http.get(Uri.parse(url));

    // DEBUG
    // ignore: avoid_print
    print(
        'DEBUG getMonthlyDetail ← status=${response.statusCode} body=${utf8.decode(response.bodyBytes)}');

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      final medications = body
          .map((dynamic item) => MedicationDoseResponse.fromJson(item))
          .toList();

      // Guardar en caché
      _monthlyCache[monthKey] = medications;
      _currentCachedMonth = monthKey;

      // DEBUG
      // ignore: avoid_print
      print(
          'DEBUG getMonthlyDetail ← Cached data for month: $monthKey (${medications.length} items)');

      return medications;
    } else {
      throw Exception(
          'Failed to load monthly detail: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}');
    }
  }

  /// Limpia la caché de medicamentos mensuales
  /// Útil cuando se actualiza, crea o elimina un medicamento
  void clearMonthlyCache() {
    _monthlyCache.clear();
    _currentCachedMonth = null;
    // DEBUG
    // ignore: avoid_print
    print('DEBUG clearMonthlyCache → Cache cleared');
  }

  /// Obtiene medicamentos para un día específico desde la caché mensual
  /// Si no hay caché, hace la petición completa del mes
  Future<List<MedicationDoseResponse>> getDailyDetailFromCache(
      DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final monthKey = DateFormat('yyyy-MM').format(date);

    // Obtener datos del mes (usando caché si está disponible)
    final monthlyData = await getMonthlyDetail(date);

    // Filtrar por fecha específica
    final dailyData = monthlyData.where((medication) {
      return medication.date == formattedDate;
    }).toList();

    // DEBUG
    // ignore: avoid_print
    print(
        'DEBUG getDailyDetailFromCache → Filtered ${dailyData.length} items for date: $formattedDate');

    return dailyData;
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

    // Nota: La caché se actualiza localmente en la UI, no se limpia aquí
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

    // Limpiar caché después de crear un medicamento
    clearMonthlyCache();
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

    // Limpiar caché después de actualizar un medicamento
    clearMonthlyCache();
  }

  Future<void> deleteMedication(String id) async {
    final response =
        await http.delete(Uri.parse('$_baseUrl/medications/$id?userId=main'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('No se pudo borrar el medicamento');
    }

    // Limpiar caché después de eliminar un medicamento
    clearMonthlyCache();
  }
}
