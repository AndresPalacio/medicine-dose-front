class MedicationResponse {
  final String id; // Cambiar a String (UUID)
  final String name;
  final int totalQuantity;
  final int quantityPerDose;
  final int frequency;
  final int duration;
  final String durationType;
  final DateTime startDate;
  final List<String> meals;
  final String mealTiming;
  final dynamic timeBeforeAfter; // Puede ser int o String
  final String? timeUnit; // Hacer opcional
  final bool taken; // Agregar campo taken
  final DateTime createdAt; // Agregar campo createdAt
  final DateTime updatedAt; // Agregar campo updatedAt
  late final DateTime endDate;

  MedicationResponse({
    required this.id,
    required this.name,
    required this.totalQuantity,
    required this.quantityPerDose,
    required this.frequency,
    required this.duration,
    required this.durationType,
    required this.startDate,
    required this.meals,
    required this.mealTiming,
    this.timeBeforeAfter,
    this.timeUnit,
    required this.taken,
    required this.createdAt,
    required this.updatedAt,
  }) {
    // Calcular endDate según durationType
    switch (durationType) {
      case 'DAYS':
        endDate = startDate.add(Duration(days: duration - 1));
        break;
      case 'WEEKS':
        endDate = startDate.add(Duration(days: duration * 7 - 1));
        break;
      case 'MONTHS':
        endDate =
            DateTime(startDate.year, startDate.month + duration, startDate.day)
                .subtract(const Duration(days: 1));
        break;
      default:
        endDate = startDate;
    }
  }

  factory MedicationResponse.fromJson(Map<String, dynamic> json) {
    return MedicationResponse(
      id: json['medId'] ?? json['id'], // El backend usa 'medId'
      name: json['name'],
      totalQuantity: json['totalQuantity'] ?? 0, // Campo opcional
      quantityPerDose: json['quantityPerDose'],
      frequency: json['frequency'],
      duration: json['duration'],
      durationType: json['durationType'] ?? 'DAYS', // Campo opcional
      startDate: DateTime.parse(json['startDate']),
      meals: (json['meals'] as List<dynamic>).map((e) => e.toString()).toList(),
      mealTiming: json['timeBeforeAfter'] ??
          json['mealTiming'] ??
          'INDIFERENTE', // El backend usa 'timeBeforeAfter'
      timeBeforeAfter: json['timeBeforeAfter'],
      timeUnit: json['timeUnit'],
      taken: json['taken'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class MedicationDoseResponse {
  final String id;
  final String medicationId;
  final String medicationName;
  final String date;
  final String meal;
  final int quantity;
  bool taken;
  final String? mealTiming;
  final int? timeBeforeAfter;
  final String? timeUnit;

  MedicationDoseResponse({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.date,
    required this.meal,
    required this.quantity,
    required this.taken,
    this.mealTiming,
    this.timeBeforeAfter,
    this.timeUnit,
  });

  factory MedicationDoseResponse.fromJson(Map<String, dynamic> json) {
    return MedicationDoseResponse(
      id: json['id'],
      medicationId: json['medicationId'],
      medicationName: json['medicationName'] ?? 'Medicamento desconocido',
      date: json['date'],
      meal: json['meal'],
      quantity: json['quantity'],
      taken: json['taken'] ?? false,
      mealTiming: json['mealTiming'],
      timeBeforeAfter: json['timeBeforeAfter'],
      timeUnit: json['timeUnit'],
    );
  }
}

class CalendarEventResponse {
  final String id;
  final String title;
  final String start;
  final String description;
  final List<MedicationDoseResponse> doses;

  CalendarEventResponse({
    required this.id,
    required this.title,
    required this.start,
    required this.description,
    required this.doses,
  });

  factory CalendarEventResponse.fromJson(Map<String, dynamic> json) {
    return CalendarEventResponse(
      id: json['id'],
      title: json['title'],
      start: json['start'],
      description: json['description'],
      doses: (json['doses'] as List<dynamic>)
          .map((dose) => MedicationDoseResponse.fromJson(dose))
          .toList(),
    );
  }
}

class CalendarDoseResponse {
  final String id;
  final String medicationId;
  final String medicationName;
  final String date;
  final String meal;
  final String status;
  final String? expectedTime;

  CalendarDoseResponse({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.date,
    required this.meal,
    required this.status,
    this.expectedTime,
  });

  factory CalendarDoseResponse.fromJson(Map<String, dynamic> json) {
    return CalendarDoseResponse(
      id: json['id'],
      medicationId: json['medicationId'],
      medicationName: json['medicationName'],
      date: json['date'],
      meal: json['meal'],
      status: json['status'],
      expectedTime: json['expectedTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'date': date,
      'meal': meal,
      'status': status,
      'expectedTime': expectedTime,
    };
  }

  // Método para convertir a DateTime
  DateTime get dateTime => DateTime.parse(date);

  // Método para verificar si la dosis está pendiente
  bool get isPending => status == 'PENDING';

  // Método para verificar si la dosis está completada
  bool get isCompleted => status == 'COMPLETED';

  // Método para obtener el nombre de la comida en español
  String get mealInSpanish {
    switch (meal.toUpperCase()) {
      case 'DESAYUNO':
        return 'Desayuno';
      case 'ALMUERZO':
        return 'Almuerzo';
      case 'CENA':
        return 'Cena';
      default:
        return meal;
    }
  }
}

class CalendarResponse {
  final List<CalendarDoseResponse> doses;

  CalendarResponse({
    required this.doses,
  });

  factory CalendarResponse.fromJson(List<dynamic> json) {
    return CalendarResponse(
      doses: json.map((dose) => CalendarDoseResponse.fromJson(dose)).toList(),
    );
  }

  // Método para obtener dosis por fecha
  List<CalendarDoseResponse> getDosesByDate(String date) {
    return doses.where((dose) => dose.date == date).toList();
  }

  // Método para obtener dosis por medicamento
  List<CalendarDoseResponse> getDosesByMedication(String medicationId) {
    return doses.where((dose) => dose.medicationId == medicationId).toList();
  }

  // Método para obtener dosis pendientes
  List<CalendarDoseResponse> getPendingDoses() {
    return doses.where((dose) => dose.isPending).toList();
  }

  // Método para obtener dosis completadas
  List<CalendarDoseResponse> getCompletedDoses() {
    return doses.where((dose) => dose.isCompleted).toList();
  }

  // Método para obtener dosis de hoy
  List<CalendarDoseResponse> getTodayDoses() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return getDosesByDate(today);
  }

  // Método para obtener dosis de una semana específica
  List<CalendarDoseResponse> getDosesForWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return doses.where((dose) {
      final doseDate = dose.dateTime;
      return doseDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          doseDate.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();
  }

  // Método para obtener dosis de un mes específico
  List<CalendarDoseResponse> getDosesForMonth(int year, int month) {
    return doses.where((dose) {
      final doseDate = dose.dateTime;
      return doseDate.year == year && doseDate.month == month;
    }).toList();
  }
}
