import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'symptom_models.dart';

class SymptomApiService {
  String _baseUrl = 'https://3lp396k7td.execute-api.us-east-1.amazonaws.com/prod/api';

  // ===== MÉTODOS PARA SÍNTOMAS =====

  // Obtener todas las entradas de síntomas (usando endpoint por mes - más rápido)
  Future<List<SymptomEntry>> getAllSymptomEntries() async {
    try {
      // Usar endpoint por mes para obtener todos los síntomas del mes actual
      final currentDate = DateTime.now();
      final monthKey =
          '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}';

      print(
          'DEBUG getAllSymptomEntries → Usando endpoint por mes: month=$monthKey');

      final response = await http.get(
        Uri.parse('$_baseUrl/symptoms?userId=main&month=$monthKey'),
        headers: {'Content-Type': 'application/json'},
      );

      print('DEBUG getAllSymptomEntries → Status: ${response.statusCode}');
      print('DEBUG getAllSymptomEntries → Response: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        final symptoms =
            body.map((dynamic item) => SymptomEntry.fromJson(item)).toList();
        print(
            'DEBUG getAllSymptomEntries → Síntomas obtenidos: ${symptoms.length}');
        return symptoms;
      } else {
        print(
            'DEBUG getAllSymptomEntries → Error: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Failed to load symptoms: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error al obtener síntomas: $e');
      return [];
    }
  }

  // Obtener entradas de síntomas por fecha
  Future<List<SymptomEntry>> getSymptomEntriesByDate(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final response = await http.get(
        Uri.parse('$_baseUrl/symptoms?userId=main&date=$formattedDate'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((dynamic item) => SymptomEntry.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to load symptoms by date: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener síntomas por fecha: $e');
      return [];
    }
  }

  // Obtener entradas de síntomas por rango de fechas (usando endpoint inteligente)
  Future<List<SymptomEntry>> getSymptomEntriesByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final startFormatted = DateFormat('yyyy-MM-dd').format(startDate);
      final endFormatted = DateFormat('yyyy-MM-dd').format(endDate);

      print(
          'DEBUG getSymptomEntriesByDateRange → Usando endpoint por rango: startDate=$startFormatted, endDate=$endFormatted');

      final response = await http.get(
        Uri.parse(
            '$_baseUrl/symptoms?userId=main&startDate=$startFormatted&endDate=$endFormatted'),
        headers: {'Content-Type': 'application/json'},
      );

      print(
          'DEBUG getSymptomEntriesByDateRange → Status: ${response.statusCode}');
      print('DEBUG getSymptomEntriesByDateRange → Response: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        final symptoms =
            body.map((dynamic item) => SymptomEntry.fromJson(item)).toList();
        print(
            'DEBUG getSymptomEntriesByDateRange → Síntomas obtenidos: ${symptoms.length}');
        return symptoms;
      } else {
        print(
            'DEBUG getSymptomEntriesByDateRange → Error: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Failed to load symptoms by date range: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error al obtener síntomas por rango de fechas: $e');
      return [];
    }
  }

  // Agregar una nueva entrada de síntoma
  Future<bool> addSymptomEntry(SymptomEntry entry) async {
    try {
      // El backend ahora espera symptoms (objetos con id y categoría) en lugar de symptomIds
      // y relatedMedications como string
      final body = {
        'symptoms': entry.symptoms,
        'severity': entry.severity,
        'notes': entry.notes,
        'date': DateFormat('yyyy-MM-dd').format(entry.date),
        'time': entry.time,
        'relatedMedications': entry.relatedMedications ?? '',
        'userId': 'main',
      };

      print(
          'DEBUG addSymptomEntry → Enviando symptoms (objetos con id y categoría) y relatedMedications como string: $body');

      final response = await http.post(
        Uri.parse('$_baseUrl/symptoms'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('DEBUG addSymptomEntry → Status: ${response.statusCode}');
      print('DEBUG addSymptomEntry → Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('DEBUG addSymptomEntry → Síntoma creado exitosamente');
        return true;
      } else {
        print(
            'DEBUG addSymptomEntry → Error del backend: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Failed to create symptom: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error al agregar síntoma: $e');
      return false;
    }
  }

  // Actualizar una entrada de síntoma existente
  Future<bool> updateSymptomEntry(SymptomEntry updatedEntry) async {
    try {
      // El backend ahora espera symptoms (objetos con id y categoría) en lugar de symptomIds
      // y relatedMedications como string
      final body = {
        'symptoms': updatedEntry.symptoms,
        'severity': updatedEntry.severity,
        'notes': updatedEntry.notes,
        'date': DateFormat('yyyy-MM-dd').format(updatedEntry.date),
        'time': updatedEntry.time,
        'relatedMedications': updatedEntry.relatedMedications ?? '',
        'userId': 'main',
      };

      print(
          'DEBUG updateSymptomEntry → Enviando symptoms (objetos con id y categoría) y relatedMedications como string: $body');

      final response = await http.put(
        Uri.parse('$_baseUrl/symptoms/${updatedEntry.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('DEBUG updateSymptomEntry → Status: ${response.statusCode}');
      print('DEBUG updateSymptomEntry → Response: ${response.body}');

      if (response.statusCode == 200) {
        print('DEBUG updateSymptomEntry → Síntoma actualizado exitosamente');
        return true;
      } else {
        print(
            'DEBUG updateSymptomEntry → Error del backend: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Failed to update symptom: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error al actualizar síntoma: $e');
      return false;
    }
  }

  // Eliminar una entrada de síntoma
  Future<bool> deleteSymptomEntry(String entryId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/symptoms/$entryId?userId=main'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('DEBUG deleteSymptomEntry → Síntoma eliminado exitosamente');
        return true;
      } else {
        throw Exception('Failed to delete symptom: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al eliminar síntoma: $e');
      return false;
    }
  }

  // Obtener estadísticas de síntomas
  Future<Map<String, dynamic>> getSymptomStatistics(
      DateTime startDate, DateTime endDate) async {
    try {
      final startFormatted = DateFormat('yyyy-MM-dd').format(startDate);
      final endFormatted = DateFormat('yyyy-MM-dd').format(endDate);

      final response = await http.get(
        Uri.parse(
            '$_baseUrl/symptoms/stats?userId=main&startDate=$startFormatted&endDate=$endFormatted'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception(
            'Failed to load symptom statistics: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener estadísticas de síntomas: $e');
      return {};
    }
  }

  // ===== MÉTODOS PARA ALIMENTACIÓN =====

  // Obtener todas las entradas de alimentación (usando endpoint por mes - más rápido)
  Future<List<FoodEntry>> getAllFoodEntries() async {
    try {
      // Usar endpoint por mes para obtener todos los alimentos del mes actual
      final currentDate = DateTime.now();
      final monthKey =
          '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}';

      print(
          'DEBUG getAllFoodEntries → Usando endpoint por mes: month=$monthKey');

      final response = await http.get(
        Uri.parse('$_baseUrl/foods?userId=main&month=$monthKey'),
        headers: {'Content-Type': 'application/json'},
      );

      print('DEBUG getAllFoodEntries → Status: ${response.statusCode}');
      print('DEBUG getAllFoodEntries → Response: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        final foods =
            body.map((dynamic item) => FoodEntry.fromJson(item)).toList();
        print('DEBUG getAllFoodEntries → Alimentos obtenidos: ${foods.length}');
        return foods;
      } else {
        print(
            'DEBUG getAllFoodEntries → Error: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Failed to load foods: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error al obtener alimentos: $e');
      return [];
    }
  }

  // Obtener entradas de alimentación por fecha (usando endpoint optimizado)
  Future<List<FoodEntry>> getFoodEntriesByDate(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      print(
          'DEBUG getFoodEntriesByDate → Usando endpoint por fecha: date=$formattedDate');

      final response = await http.get(
        Uri.parse('$_baseUrl/foods?userId=main&date=$formattedDate'),
        headers: {'Content-Type': 'application/json'},
      );

      print('DEBUG getFoodEntriesByDate → Status: ${response.statusCode}');
      print('DEBUG getFoodEntriesByDate → Response: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        final foods =
            body.map((dynamic item) => FoodEntry.fromJson(item)).toList();
        print(
            'DEBUG getFoodEntriesByDate → Alimentos obtenidos: ${foods.length}');
        return foods;
      } else {
        print(
            'DEBUG getFoodEntriesByDate → Error: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Failed to load foods by date: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error al obtener alimentos por fecha: $e');
      return [];
    }
  }

  // Obtener entradas de alimentación por mes (usando endpoint más rápido)
  Future<List<FoodEntry>> getFoodEntriesByMonth(DateTime month) async {
    try {
      final monthKey =
          '${month.year}-${month.month.toString().padLeft(2, '0')}';

      print(
          'DEBUG getFoodEntriesByMonth → Usando endpoint por mes: month=$monthKey');

      final response = await http.get(
        Uri.parse('$_baseUrl/foods?userId=main&month=$monthKey'),
        headers: {'Content-Type': 'application/json'},
      );

      print('DEBUG getFoodEntriesByMonth → Status: ${response.statusCode}');
      print('DEBUG getFoodEntriesByMonth → Response: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        final foods =
            body.map((dynamic item) => FoodEntry.fromJson(item)).toList();
        print(
            'DEBUG getFoodEntriesByMonth → Alimentos obtenidos: ${foods.length}');
        return foods;
      } else {
        print(
            'DEBUG getFoodEntriesByMonth → Error: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Failed to load foods by month: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error al obtener alimentos por mes: $e');
      return [];
    }
  }

  // Obtener entradas de alimentación por rango de fechas (usando endpoint inteligente)
  Future<List<FoodEntry>> getFoodEntriesByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final startFormatted = DateFormat('yyyy-MM-dd').format(startDate);
      final endFormatted = DateFormat('yyyy-MM-dd').format(endDate);

      print(
          'DEBUG getFoodEntriesByDateRange → Usando endpoint por rango: startDate=$startFormatted, endDate=$endFormatted');

      final response = await http.get(
        Uri.parse(
            '$_baseUrl/foods?userId=main&startDate=$startFormatted&endDate=$endFormatted'),
        headers: {'Content-Type': 'application/json'},
      );

      print('DEBUG getFoodEntriesByDateRange → Status: ${response.statusCode}');
      print('DEBUG getFoodEntriesByDateRange → Response: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        final foods =
            body.map((dynamic item) => FoodEntry.fromJson(item)).toList();
        print(
            'DEBUG getFoodEntriesByDateRange → Alimentos obtenidos: ${foods.length}');
        return foods;
      } else {
        print(
            'DEBUG getFoodEntriesByDateRange → Error: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Failed to load foods by date range: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error al obtener alimentos por rango de fechas: $e');
      return [];
    }
  }

  // Agregar una nueva entrada de alimentación
  Future<bool> addFoodEntry(FoodEntry entry) async {
    try {
      final body = {
        'name': entry.foodName,
        'category': entry.mealType,
        'notes': entry.description,
        'date': DateFormat('yyyy-MM-dd').format(entry.date),
        'time': entry.time,
        'quantity': entry.portion,
        'ingredients': entry.ingredients,
        'causedDiscomfort': entry.causedDiscomfort,
        'discomfortNotes': entry.discomfortNotes,
        'userId': 'main',
      };

      print('DEBUG addFoodEntry → Enviando datos: $body');

      final response = await http.post(
        Uri.parse('$_baseUrl/foods'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('DEBUG addFoodEntry → Status: ${response.statusCode}');
      print('DEBUG addFoodEntry → Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('DEBUG addFoodEntry → Alimento creado exitosamente');
        return true;
      } else {
        throw Exception('Failed to create food: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al agregar alimento: $e');
      return false;
    }
  }

  // Actualizar una entrada de alimentación existente
  Future<bool> updateFoodEntry(FoodEntry updatedEntry) async {
    try {
      final body = {
        'name': updatedEntry.foodName,
        'category': updatedEntry.mealType,
        'notes': updatedEntry.description,
        'date': DateFormat('yyyy-MM-dd').format(updatedEntry.date),
        'time': updatedEntry.time,
        'quantity': updatedEntry.portion,
        'ingredients': updatedEntry.ingredients,
        'causedDiscomfort': updatedEntry.causedDiscomfort,
        'discomfortNotes': updatedEntry.discomfortNotes,
        'userId': 'main',
      };

      print('DEBUG updateFoodEntry → Enviando datos: $body');

      final response = await http.put(
        Uri.parse('$_baseUrl/foods/${updatedEntry.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('DEBUG updateFoodEntry → Status: ${response.statusCode}');
      print('DEBUG updateFoodEntry → Response: ${response.body}');

      if (response.statusCode == 200) {
        print('DEBUG updateFoodEntry → Alimento actualizado exitosamente');
        return true;
      } else {
        throw Exception('Failed to update food: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al actualizar alimento: $e');
      return false;
    }
  }

  // Eliminar una entrada de alimentación
  Future<bool> deleteFoodEntry(String entryId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/foods/$entryId?userId=main'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('DEBUG deleteFoodEntry → Alimento eliminado exitosamente');
        return true;
      } else {
        throw Exception('Failed to delete food: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al eliminar alimento: $e');
      return false;
    }
  }

  // Obtener estadísticas de alimentación
  Future<Map<String, dynamic>> getFoodStatistics(
      DateTime startDate, DateTime endDate) async {
    try {
      final startFormatted = DateFormat('yyyy-MM-dd').format(startDate);
      final endFormatted = DateFormat('yyyy-MM-dd').format(endDate);

      final response = await http.get(
        Uri.parse(
            '$_baseUrl/foods/stats?userId=main&startDate=$startFormatted&endDate=$endFormatted'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception(
            'Failed to load food statistics: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener estadísticas de alimentos: $e');
      return {};
    }
  }

  // ===== MÉTODOS PARA DEPOSICIONES =====

  // Obtener todas las entradas de deposiciones (usando endpoint por mes - más rápido)
  Future<List<BowelMovementEntry>> getAllBowelMovementEntries() async {
    try {
      // Usar endpoint por mes para obtener todas las deposiciones del mes actual
      final currentDate = DateTime.now();
      final monthKey =
          '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}';

      print(
          'DEBUG getAllBowelMovementEntries → Usando endpoint por mes: month=$monthKey');

      final response = await http.get(
        Uri.parse('$_baseUrl/bowel-movements?userId=main&month=$monthKey'),
        headers: {'Content-Type': 'application/json'},
      );

      print(
          'DEBUG getAllBowelMovementEntries → Status: ${response.statusCode}');
      print('DEBUG getAllBowelMovementEntries → Response: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        final bowelMovements = body
            .map((dynamic item) => BowelMovementEntry.fromJson(item))
            .toList();
        print(
            'DEBUG getAllBowelMovementEntries → Deposiciones obtenidas: ${bowelMovements.length}');
        return bowelMovements;
      } else {
        print(
            'DEBUG getAllBowelMovementEntries → Error: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Failed to load bowel movements: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error al obtener deposiciones: $e');
      return [];
    }
  }

  // Obtener entradas de deposiciones por fecha (usando endpoint optimizado)
  Future<List<BowelMovementEntry>> getBowelMovementEntriesByDate(
      DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      print(
          'DEBUG getBowelMovementEntriesByDate → Usando endpoint por fecha: date=$formattedDate');

      final response = await http.get(
        Uri.parse('$_baseUrl/bowel-movements?userId=main&date=$formattedDate'),
        headers: {'Content-Type': 'application/json'},
      );

      print(
          'DEBUG getBowelMovementEntriesByDate → Status: ${response.statusCode}');
      print('DEBUG getBowelMovementEntriesByDate → Response: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        final bowelMovements = body
            .map((dynamic item) => BowelMovementEntry.fromJson(item))
            .toList();
        print(
            'DEBUG getBowelMovementEntriesByDate → Deposiciones obtenidas: ${bowelMovements.length}');
        return bowelMovements;
      } else {
        print(
            'DEBUG getBowelMovementEntriesByDate → Error: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Failed to load bowel movements by date: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error al obtener deposiciones por fecha: $e');
      return [];
    }
  }

  // Obtener entradas de deposiciones por mes (usando endpoint más rápido)
  Future<List<BowelMovementEntry>> getBowelMovementEntriesByMonth(
      DateTime month) async {
    try {
      final monthKey =
          '${month.year}-${month.month.toString().padLeft(2, '0')}';

      print(
          'DEBUG getBowelMovementEntriesByMonth → Usando endpoint por mes: month=$monthKey');

      final response = await http.get(
        Uri.parse('$_baseUrl/bowel-movements?userId=main&month=$monthKey'),
        headers: {'Content-Type': 'application/json'},
      );

      print(
          'DEBUG getBowelMovementEntriesByMonth → Status: ${response.statusCode}');
      print(
          'DEBUG getBowelMovementEntriesByMonth → Response: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        final bowelMovements = body
            .map((dynamic item) => BowelMovementEntry.fromJson(item))
            .toList();
        print(
            'DEBUG getBowelMovementEntriesByMonth → Deposiciones obtenidas: ${bowelMovements.length}');
        return bowelMovements;
      } else {
        print(
            'DEBUG getBowelMovementEntriesByMonth → Error: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Failed to load bowel movements by month: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error al obtener deposiciones por mes: $e');
      return [];
    }
  }

  // Obtener entradas de deposiciones por rango de fechas (usando endpoint inteligente)
  Future<List<BowelMovementEntry>> getBowelMovementEntriesByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final startFormatted = DateFormat('yyyy-MM-dd').format(startDate);
      final endFormatted = DateFormat('yyyy-MM-dd').format(endDate);

      print(
          'DEBUG getBowelMovementEntriesByDateRange → Usando endpoint por rango: startDate=$startFormatted, endDate=$endFormatted');

      final response = await http.get(
        Uri.parse(
            '$_baseUrl/bowel-movements?userId=main&startDate=$startFormatted&endDate=$endFormatted'),
        headers: {'Content-Type': 'application/json'},
      );

      print(
          'DEBUG getBowelMovementEntriesByDateRange → Status: ${response.statusCode}');
      print(
          'DEBUG getBowelMovementEntriesByDateRange → Response: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        final bowelMovements = body
            .map((dynamic item) => BowelMovementEntry.fromJson(item))
            .toList();
        print(
            'DEBUG getBowelMovementEntriesByDateRange → Deposiciones obtenidas: ${bowelMovements.length}');
        return bowelMovements;
      } else {
        print(
            'DEBUG getBowelMovementEntriesByDateRange → Error: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Failed to load bowel movements by date range: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error al obtener deposiciones por rango de fechas: $e');
      return [];
    }
  }

  // Agregar una nueva entrada de deposición
  Future<bool> addBowelMovementEntry(BowelMovementEntry entry) async {
    try {
      final body = <String, dynamic>{
        'consistency': entry.consistency,
        'color': entry.color,
        'date': DateFormat('yyyy-MM-dd').format(entry.date),
        'time': entry.time,
        'blood': entry.hasBlood,
        'mucus': entry.hasMucus,
        'notes': entry.notes,
        'userId': 'main',
      };

      // Agregar campo 'hasPain' para indicar si hubo dolor
      body['hasPain'] = entry.wasPainful == true;

      // Solo agregar el campo 'pain' si realmente hubo dolor
      if (entry.wasPainful == true &&
          entry.painLevel != null &&
          entry.painLevel!.isNotEmpty) {
        body['pain'] = entry.painLevel;
      }

      // DEBUG: Log del body que se envía
      print('DEBUG addBowelMovementEntry → Body enviado:');
      print('  - Consistency: ${body['consistency']}');
      print('  - Color: ${body['color']}');
      print('  - Date: ${body['date']}');
      print('  - Time: ${body['time']}');
      print('  - HasPain: ${body['hasPain']}');
      print('  - Pain: ${body['pain']}');
      print('  - Blood: ${body['blood']}');
      print('  - Mucus: ${body['mucus']}');
      print('  - Notes: ${body['notes']}');
      print('  - UserId: ${body['userId']}');
      print('  - JSON completo: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse('$_baseUrl/bowel-movements'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('DEBUG addBowelMovementEntry → Deposición creada exitosamente');
        return true;
      } else {
        throw Exception(
            'Failed to create bowel movement: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al agregar deposición: $e');
      return false;
    }
  }

  // Actualizar una entrada de deposición existente
  Future<bool> updateBowelMovementEntry(BowelMovementEntry updatedEntry) async {
    try {
      final body = <String, dynamic>{
        'consistency': updatedEntry.consistency,
        'color': updatedEntry.color,
        'date': DateFormat('yyyy-MM-dd').format(updatedEntry.date),
        'time': updatedEntry.time,
        'blood': updatedEntry.hasBlood,
        'mucus': updatedEntry.hasMucus,
        'notes': updatedEntry.notes,
        'userId': 'main',
      };

      // Agregar campo 'hasPain' para indicar si hubo dolor
      body['hasPain'] = updatedEntry.wasPainful == true;

      // Solo agregar el campo 'pain' si realmente hubo dolor
      if (updatedEntry.wasPainful == true &&
          updatedEntry.painLevel != null &&
          updatedEntry.painLevel!.isNotEmpty) {
        body['pain'] = updatedEntry.painLevel;
      }

      // DEBUG: Log del body que se envía
      print('DEBUG updateBowelMovementEntry → Body enviado:');
      print('  - Consistency: ${body['consistency']}');
      print('  - Color: ${body['color']}');
      print('  - Date: ${body['date']}');
      print('  - Time: ${body['time']}');
      print('  - HasPain: ${body['hasPain']}');
      print('  - Pain: ${body['pain']}');
      print('  - Blood: ${body['blood']}');
      print('  - Mucus: ${body['mucus']}');
      print('  - Notes: ${body['notes']}');
      print('  - UserId: ${body['userId']}');
      print('  - JSON completo: ${jsonEncode(body)}');

      final response = await http.put(
        Uri.parse('$_baseUrl/bowel-movements/${updatedEntry.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print(
            'DEBUG updateBowelMovementEntry → Deposición actualizada exitosamente');
        return true;
      } else {
        throw Exception(
            'Failed to update bowel movement: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al actualizar deposición: $e');
      return false;
    }
  }

  // Eliminar una entrada de deposición
  Future<bool> deleteBowelMovementEntry(String entryId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/bowel-movements/$entryId?userId=main'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print(
            'DEBUG deleteBowelMovementEntry → Deposición eliminada exitosamente');
        return true;
      } else {
        throw Exception(
            'Failed to delete bowel movement: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al eliminar deposición: $e');
      return false;
    }
  }

  // Obtener estadísticas de deposiciones
  Future<Map<String, dynamic>> getBowelMovementStatistics(
      DateTime startDate, DateTime endDate) async {
    try {
      final startFormatted = DateFormat('yyyy-MM-dd').format(startDate);
      final endFormatted = DateFormat('yyyy-MM-dd').format(endDate);

      final response = await http.get(
        Uri.parse(
            '$_baseUrl/bowel-movements/stats?userId=main&startDate=$startFormatted&endDate=$endFormatted'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception(
            'Failed to load bowel movement statistics: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener estadísticas de deposiciones: $e');
      return {};
    }
  }

  // ===== MÉTODOS DE REPORTES =====

  // Generar reporte médico completo
  Future<String> generateMedicalReport(
      DateTime startDate, DateTime endDate) async {
    try {
      print(
          'DEBUG generateMedicalReport → Generando reporte para período: $startDate - $endDate');

      // Obtener datos del backend usando los endpoints HTTP optimizados
      print(
          'DEBUG generateMedicalReport → Obteniendo síntomas por rango de fechas...');
      final symptomEntries =
          await getSymptomEntriesByDateRange(startDate, endDate);

      print(
          'DEBUG generateMedicalReport → Obteniendo alimentos por rango de fechas...');
      final foodEntries = await getFoodEntriesByDateRange(startDate, endDate);

      print(
          'DEBUG generateMedicalReport → Obteniendo deposiciones por rango de fechas...');
      final bowelEntries =
          await getBowelMovementEntriesByDateRange(startDate, endDate);

      print('DEBUG generateMedicalReport → Datos obtenidos del backend:');
      print('  - Síntomas: ${symptomEntries.length}');
      print('  - Alimentos: ${foodEntries.length}');
      print('  - Deposiciones: ${bowelEntries.length}');

      // Ya no necesitamos filtrar localmente porque usamos endpoints por rango
      final foodEntriesInRange = foodEntries;
      final bowelEntriesInRange = bowelEntries;

      print('DEBUG generateMedicalReport → Datos ya filtrados por el backend:');
      print('  - Alimentos en rango: ${foodEntriesInRange.length}');
      print('  - Deposiciones en rango: ${bowelEntriesInRange.length}');

      if (symptomEntries.isEmpty &&
          foodEntriesInRange.isEmpty &&
          bowelEntriesInRange.isEmpty) {
        return 'No hay registros para el período seleccionado.';
      }

      String report = 'REPORTE MÉDICO COMPLETO\n';
      report +=
          'Período: ${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}\n';
      report +=
          'Total de registros: ${symptomEntries.length + foodEntriesInRange.length + bowelEntriesInRange.length}\n\n';

      // Sección de síntomas
      if (symptomEntries.isNotEmpty) {
        report += '=== SÍNTOMAS ===\n';
        report += 'Total de síntomas registrados: ${symptomEntries.length}\n\n';

        final Map<String, List<SymptomEntry>> entriesByDate = {};
        for (final entry in symptomEntries) {
          final dateKey =
              '${entry.date.day}/${entry.date.month}/${entry.date.year}';
          if (!entriesByDate.containsKey(dateKey)) {
            entriesByDate[dateKey] = [];
          }
          entriesByDate[dateKey]!.add(entry);
        }

        final sortedDates = entriesByDate.keys.toList()..sort();
        for (final date in sortedDates) {
          report += 'Fecha: $date\n';
          final dayEntries = entriesByDate[date]!;
          for (final entry in dayEntries) {
            report +=
                '  • ${entry.symptomNames.isNotEmpty ? entry.symptomNames.first : 'Sin síntomas'} - Severidad: ${entry.severity} - Hora: ${entry.time}\n';
            if (entry.notes != null && entry.notes!.isNotEmpty) {
              report += '    Notas: ${entry.notes}\n';
            }
          }
          report += '\n';
        }
      }

      // Sección de alimentación
      if (foodEntriesInRange.isNotEmpty) {
        report += '=== ALIMENTACIÓN ===\n';
        report +=
            'Total de comidas registradas: ${foodEntriesInRange.length}\n\n';

        final Map<String, List<FoodEntry>> entriesByDate = {};
        for (final entry in foodEntriesInRange) {
          final dateKey =
              '${entry.date.day}/${entry.date.month}/${entry.date.year}';
          if (!entriesByDate.containsKey(dateKey)) {
            entriesByDate[dateKey] = [];
          }
          entriesByDate[dateKey]!.add(entry);
        }

        final sortedDates = entriesByDate.keys.toList()..sort();
        for (final date in sortedDates) {
          report += 'Fecha: $date\n';
          final dayEntries = entriesByDate[date]!;
          for (final entry in dayEntries) {
            report +=
                '  • ${entry.mealType}: ${entry.foodName} - Hora: ${entry.time}\n';
            if (entry.causedDiscomfort == true) {
              report += '    ⚠️ Causó malestar\n';
              if (entry.discomfortNotes != null &&
                  entry.discomfortNotes!.isNotEmpty) {
                report += '    Notas: ${entry.discomfortNotes}\n';
              }
            }
          }
          report += '\n';
        }
      }

      // Sección de deposiciones
      if (bowelEntriesInRange.isNotEmpty) {
        report += '=== DEPOSICIONES ===\n';
        report +=
            'Total de deposiciones registradas: ${bowelEntriesInRange.length}\n\n';

        final Map<String, List<BowelMovementEntry>> entriesByDate = {};
        for (final entry in bowelEntriesInRange) {
          final dateKey =
              '${entry.date.day}/${entry.date.month}/${entry.date.year}';
          if (!entriesByDate.containsKey(dateKey)) {
            entriesByDate[dateKey] = [];
          }
          entriesByDate[dateKey]!.add(entry);
        }

        final sortedDates = entriesByDate.keys.toList()..sort();
        for (final date in sortedDates) {
          report += 'Fecha: $date\n';
          final dayEntries = entriesByDate[date]!;
          for (final entry in dayEntries) {
            report +=
                '  • ${entry.consistency} - Color: ${entry.color} - Hora: ${entry.time}\n';
            if (entry.wasPainful == true) report += '    ⚠️ Doloroso\n';
            if (entry.hasBlood == true) report += '    ⚠️ Con sangre\n';
            if (entry.hasMucus == true) report += '    ⚠️ Con moco\n';
            if (entry.notes != null && entry.notes!.isNotEmpty) {
              report += '    Notas: ${entry.notes}\n';
            }
          }
          report += '\n';
        }
      }

      print('DEBUG generateMedicalReport → Reporte generado exitosamente');
      return report;
    } catch (e) {
      print('Error al generar reporte médico: $e');
      return 'Error al generar el reporte: $e';
    }
  }

  // Exportar datos como JSON
  Future<String> exportDataAsJson() async {
    try {
      print('DEBUG exportDataAsJson → Exportando datos del backend...');

      // Usar endpoints optimizados por mes para obtener todos los datos
      print('DEBUG exportDataAsJson → Obteniendo síntomas del mes actual...');
      final symptomEntries = await getAllSymptomEntries();

      print('DEBUG exportDataAsJson → Obteniendo alimentos del mes actual...');
      final foodEntries = await getAllFoodEntries();

      print(
          'DEBUG exportDataAsJson → Obteniendo deposiciones del mes actual...');
      final bowelEntries = await getAllBowelMovementEntries();

      final data = {
        'exportDate': DateTime.now().toIso8601String(),
        'symptomEntries': {
          'total': symptomEntries.length,
          'data': symptomEntries.map((e) => e.toJson()).toList(),
        },
        'foodEntries': {
          'total': foodEntries.length,
          'data': foodEntries.map((e) => e.toJson()).toList(),
        },
        'bowelMovementEntries': {
          'total': bowelEntries.length,
          'data': bowelEntries.map((e) => e.toJson()).toList(),
        },
      };

      final jsonString = jsonEncode(data);
      print(
          'DEBUG exportDataAsJson → Datos exportados exitosamente: ${jsonString.length} caracteres');

      return jsonString;
    } catch (e) {
      print('Error al exportar datos: $e');
      return 'Error al exportar datos: $e';
    }
  }
}
