import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'symptom_models.dart';

class SymptomService {
  static const String _symptomEntriesKey = 'symptom_entries';
  static const String _foodEntriesKey = 'food_entries';
  static const String _bowelMovementEntriesKey = 'bowel_movement_entries';

  // ===== MÉTODOS PARA SÍNTOMAS (EXISTENTES) =====

  // Obtener todas las entradas de síntomas
  Future<List<SymptomEntry>> getAllSymptomEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? entriesJson = prefs.getString(_symptomEntriesKey);

      if (entriesJson == null || entriesJson.isEmpty) {
        return [];
      }

      final List<dynamic> entriesList = json.decode(entriesJson);
      return entriesList.map((entry) => SymptomEntry.fromJson(entry)).toList();
    } catch (e) {
      print('Error al obtener entradas de síntomas: $e');
      return [];
    }
  }

  // Obtener entradas de síntomas por fecha
  Future<List<SymptomEntry>> getSymptomEntriesByDate(DateTime date) async {
    try {
      final allEntries = await getAllSymptomEntries();
      final formattedDate =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      return allEntries.where((entry) {
        final entryDate =
            '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}';
        return entryDate == formattedDate;
      }).toList();
    } catch (e) {
      print('Error al obtener entradas de síntomas por fecha: $e');
      return [];
    }
  }

  // Obtener entradas de síntomas por rango de fechas
  Future<List<SymptomEntry>> getSymptomEntriesByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final allEntries = await getAllSymptomEntries();

      return allEntries.where((entry) {
        return entry.date
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            entry.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      print('Error al obtener entradas de síntomas por rango de fechas: $e');
      return [];
    }
  }

  // Agregar una nueva entrada de síntoma
  Future<bool> addSymptomEntry(SymptomEntry entry) async {
    try {
      final allEntries = await getAllSymptomEntries();
      allEntries.add(entry);

      final prefs = await SharedPreferences.getInstance();
      final entriesJson =
          json.encode(allEntries.map((e) => e.toJson()).toList());

      return await prefs.setString(_symptomEntriesKey, entriesJson);
    } catch (e) {
      print('Error al agregar entrada de síntoma: $e');
      return false;
    }
  }

  // Actualizar una entrada de síntoma existente
  Future<bool> updateSymptomEntry(SymptomEntry updatedEntry) async {
    try {
      final allEntries = await getAllSymptomEntries();
      final index =
          allEntries.indexWhere((entry) => entry.id == updatedEntry.id);

      if (index != -1) {
        allEntries[index] = updatedEntry;

        final prefs = await SharedPreferences.getInstance();
        final entriesJson =
            json.encode(allEntries.map((e) => e.toJson()).toList());

        return await prefs.setString(_symptomEntriesKey, entriesJson);
      }

      return false;
    } catch (e) {
      print('Error al actualizar entrada de síntoma: $e');
      return false;
    }
  }

  // Eliminar una entrada de síntoma
  Future<bool> deleteSymptomEntry(String entryId) async {
    try {
      final allEntries = await getAllSymptomEntries();
      allEntries.removeWhere((entry) => entry.id == entryId);

      final prefs = await SharedPreferences.getInstance();
      final entriesJson =
          json.encode(allEntries.map((e) => e.toJson()).toList());

      return await prefs.setString(_symptomEntriesKey, entriesJson);
    } catch (e) {
      print('Error al eliminar entrada de síntoma: $e');
      return false;
    }
  }

  // ===== MÉTODOS PARA ALIMENTACIÓN =====

  // Obtener todas las entradas de alimentación
  Future<List<FoodEntry>> getAllFoodEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? entriesJson = prefs.getString(_foodEntriesKey);

      if (entriesJson == null || entriesJson.isEmpty) {
        return [];
      }

      final List<dynamic> entriesList = json.decode(entriesJson);
      return entriesList.map((entry) => FoodEntry.fromJson(entry)).toList();
    } catch (e) {
      print('Error al obtener entradas de alimentación: $e');
      return [];
    }
  }

  // Obtener entradas de alimentación por fecha
  Future<List<FoodEntry>> getFoodEntriesByDate(DateTime date) async {
    try {
      final allEntries = await getAllFoodEntries();
      final formattedDate =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      return allEntries.where((entry) {
        final entryDate =
            '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}';
        return entryDate == formattedDate;
      }).toList();
    } catch (e) {
      print('Error al obtener entradas de alimentación por fecha: $e');
      return [];
    }
  }

  // Agregar una nueva entrada de alimentación
  Future<bool> addFoodEntry(FoodEntry entry) async {
    try {
      final allEntries = await getAllFoodEntries();
      allEntries.add(entry);

      final prefs = await SharedPreferences.getInstance();
      final entriesJson =
          json.encode(allEntries.map((e) => e.toJson()).toList());

      return await prefs.setString(_foodEntriesKey, entriesJson);
    } catch (e) {
      print('Error al agregar entrada de alimentación: $e');
      return false;
    }
  }

  // Actualizar una entrada de alimentación existente
  Future<bool> updateFoodEntry(FoodEntry updatedEntry) async {
    try {
      final allEntries = await getAllFoodEntries();
      final index =
          allEntries.indexWhere((entry) => entry.id == updatedEntry.id);

      if (index != -1) {
        allEntries[index] = updatedEntry;

        final prefs = await SharedPreferences.getInstance();
        final entriesJson =
            json.encode(allEntries.map((e) => e.toJson()).toList());

        return await prefs.setString(_foodEntriesKey, entriesJson);
      }

      return false;
    } catch (e) {
      print('Error al actualizar entrada de alimentación: $e');
      return false;
    }
  }

  // Eliminar una entrada de alimentación
  Future<bool> deleteFoodEntry(String entryId) async {
    try {
      final allEntries = await getAllFoodEntries();
      allEntries.removeWhere((entry) => entry.id == entryId);

      final prefs = await SharedPreferences.getInstance();
      final entriesJson =
          json.encode(allEntries.map((e) => e.toJson()).toList());

      return await prefs.setString(_foodEntriesKey, entriesJson);
    } catch (e) {
      print('Error al eliminar entrada de alimentación: $e');
      return false;
    }
  }

  // ===== MÉTODOS PARA DEPOSICIONES =====

  // Obtener todas las entradas de deposiciones
  Future<List<BowelMovementEntry>> getAllBowelMovementEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? entriesJson = prefs.getString(_bowelMovementEntriesKey);

      if (entriesJson == null || entriesJson.isEmpty) {
        return [];
      }

      final List<dynamic> entriesList = json.decode(entriesJson);
      return entriesList
          .map((entry) => BowelMovementEntry.fromJson(entry))
          .toList();
    } catch (e) {
      print('Error al obtener entradas de deposiciones: $e');
      return [];
    }
  }

  // Obtener entradas de deposiciones por fecha
  Future<List<BowelMovementEntry>> getBowelMovementEntriesByDate(
      DateTime date) async {
    try {
      final allEntries = await getAllBowelMovementEntries();
      final formattedDate =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      return allEntries.where((entry) {
        final entryDate =
            '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}';
        return entryDate == formattedDate;
      }).toList();
    } catch (e) {
      print('Error al obtener entradas de deposiciones por fecha: $e');
      return [];
    }
  }

  // Agregar una nueva entrada de deposición
  Future<bool> addBowelMovementEntry(BowelMovementEntry entry) async {
    try {
      final allEntries = await getAllBowelMovementEntries();
      allEntries.add(entry);

      final prefs = await SharedPreferences.getInstance();
      final entriesJson =
          json.encode(allEntries.map((e) => e.toJson()).toList());

      return await prefs.setString(_bowelMovementEntriesKey, entriesJson);
    } catch (e) {
      print('Error al agregar entrada de deposición: $e');
      return false;
    }
  }

  // Actualizar una entrada de deposición existente
  Future<bool> updateBowelMovementEntry(BowelMovementEntry updatedEntry) async {
    try {
      final allEntries = await getAllBowelMovementEntries();
      final index =
          allEntries.indexWhere((entry) => entry.id == updatedEntry.id);

      if (index != -1) {
        allEntries[index] = updatedEntry;

        final prefs = await SharedPreferences.getInstance();
        final entriesJson =
            json.encode(allEntries.map((e) => e.toJson()).toList());

        return await prefs.setString(_bowelMovementEntriesKey, entriesJson);
      }

      return false;
    } catch (e) {
      print('Error al actualizar entrada de deposición: $e');
      return false;
    }
  }

  // Eliminar una entrada de deposición
  Future<bool> deleteBowelMovementEntry(String entryId) async {
    try {
      final allEntries = await getAllBowelMovementEntries();
      allEntries.removeWhere((entry) => entry.id == entryId);

      final prefs = await SharedPreferences.getInstance();
      final entriesJson =
          json.encode(allEntries.map((e) => e.toJson()).toList());

      return await prefs.setString(_bowelMovementEntriesKey, entriesJson);
    } catch (e) {
      print('Error al eliminar entrada de deposición: $e');
      return false;
    }
  }

  // ===== MÉTODOS DE ESTADÍSTICAS Y REPORTES =====

  // Obtener estadísticas de síntomas
  Future<Map<String, dynamic>> getSymptomStatistics(
      DateTime startDate, DateTime endDate) async {
    try {
      final entries = await getSymptomEntriesByDateRange(startDate, endDate);
      final Map<String, int> symptomFrequency = {};
      final Map<String, Map<String, int>> severityDistribution = {};

      for (final entry in entries) {
        // Contar frecuencia de síntomas
        symptomFrequency[entry.symptomName] =
            (symptomFrequency[entry.symptomName] ?? 0) + 1;

        // Distribución de severidad por síntoma
        if (!severityDistribution.containsKey(entry.symptomName)) {
          severityDistribution[entry.symptomName] = {};
        }
        severityDistribution[entry.symptomName]![entry.severity] =
            (severityDistribution[entry.symptomName]![entry.severity] ?? 0) + 1;
      }

      return {
        'totalEntries': entries.length,
        'symptomFrequency': symptomFrequency,
        'severityDistribution': severityDistribution,
        'dateRange': {
          'start': startDate.toIso8601String(),
          'end': endDate.toIso8601String(),
        },
      };
    } catch (e) {
      print('Error al obtener estadísticas de síntomas: $e');
      return {};
    }
  }

  // Obtener estadísticas de alimentación
  Future<Map<String, dynamic>> getFoodStatistics(
      DateTime startDate, DateTime endDate) async {
    try {
      final allEntries = await getAllFoodEntries();
      final entries = allEntries.where((entry) {
        return entry.date
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            entry.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();

      final Map<String, int> mealTypeFrequency = {};
      final Map<String, int> foodFrequency = {};
      final Map<String, int> discomfortFrequency = {};

      for (final entry in entries) {
        // Contar frecuencia por tipo de comida
        mealTypeFrequency[entry.mealType] =
            (mealTypeFrequency[entry.mealType] ?? 0) + 1;

        // Contar frecuencia de alimentos
        foodFrequency[entry.foodName] =
            (foodFrequency[entry.foodName] ?? 0) + 1;

        // Contar alimentos que causaron malestar
        if (entry.causedDiscomfort == true) {
          discomfortFrequency[entry.foodName] =
              (discomfortFrequency[entry.foodName] ?? 0) + 1;
        }
      }

      return {
        'totalEntries': entries.length,
        'mealTypeFrequency': mealTypeFrequency,
        'foodFrequency': foodFrequency,
        'discomfortFrequency': discomfortFrequency,
        'dateRange': {
          'start': startDate.toIso8601String(),
          'end': endDate.toIso8601String(),
        },
      };
    } catch (e) {
      print('Error al obtener estadísticas de alimentación: $e');
      return {};
    }
  }

  // Obtener estadísticas de deposiciones
  Future<Map<String, dynamic>> getBowelMovementStatistics(
      DateTime startDate, DateTime endDate) async {
    try {
      final allEntries = await getAllBowelMovementEntries();
      final entries = allEntries.where((entry) {
        return entry.date
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            entry.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();

      final Map<String, int> consistencyFrequency = {};
      final Map<String, int> colorFrequency = {};
      int painfulCount = 0;
      int bloodyCount = 0;
      int mucusCount = 0;

      for (final entry in entries) {
        // Contar frecuencia por consistencia
        consistencyFrequency[entry.consistency] =
            (consistencyFrequency[entry.consistency] ?? 0) + 1;

        // Contar frecuencia por color
        colorFrequency[entry.color] = (colorFrequency[entry.color] ?? 0) + 1;

        // Contar características especiales
        if (entry.wasPainful == true) painfulCount++;
        if (entry.hasBlood == true) bloodyCount++;
        if (entry.hasMucus == true) mucusCount++;
      }

      return {
        'totalEntries': entries.length,
        'consistencyFrequency': consistencyFrequency,
        'colorFrequency': colorFrequency,
        'painfulCount': painfulCount,
        'bloodyCount': bloodyCount,
        'mucusCount': mucusCount,
        'dateRange': {
          'start': startDate.toIso8601String(),
          'end': endDate.toIso8601String(),
        },
      };
    } catch (e) {
      print('Error al obtener estadísticas de deposiciones: $e');
      return {};
    }
  }

  // Generar reporte médico completo
  Future<String> generateMedicalReport(
      DateTime startDate, DateTime endDate) async {
    try {
      final symptomEntries =
          await getSymptomEntriesByDateRange(startDate, endDate);
      final foodEntries = await getAllFoodEntries();
      final bowelEntries = await getAllBowelMovementEntries();

      final foodEntriesInRange = foodEntries.where((entry) {
        return entry.date
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            entry.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();

      final bowelEntriesInRange = bowelEntries.where((entry) {
        return entry.date
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            entry.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();

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
                '  • ${entry.symptomName} - Severidad: ${entry.severity} - Hora: ${entry.time}\n';
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

      return report;
    } catch (e) {
      print('Error al generar reporte médico: $e');
      return 'Error al generar el reporte.';
    }
  }

  // Exportar datos como JSON
  Future<String> exportDataAsJson() async {
    try {
      final symptomEntries = await getAllSymptomEntries();
      final foodEntries = await getAllFoodEntries();
      final bowelEntries = await getAllBowelMovementEntries();

      final data = {
        'exportDate': DateTime.now().toIso8601String(),
        'symptomEntries': {
          'total': symptomEntries.length,
          'entries': symptomEntries.map((e) => e.toJson()).toList(),
        },
        'foodEntries': {
          'total': foodEntries.length,
          'entries': foodEntries.map((e) => e.toJson()).toList(),
        },
        'bowelMovementEntries': {
          'total': bowelEntries.length,
          'entries': bowelEntries.map((e) => e.toJson()).toList(),
        },
      };

      return json.encode(data);
    } catch (e) {
      print('Error al exportar datos: $e');
      return '{}';
    }
  }
}
