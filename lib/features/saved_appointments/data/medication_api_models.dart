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
  final int? timeBeforeAfter; // Hacer opcional
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
      id: json['id'],
      name: json['name'],
      totalQuantity: json['totalQuantity'],
      quantityPerDose: json['quantityPerDose'],
      frequency: json['frequency'],
      duration: json['duration'],
      durationType: json['durationType'],
      startDate: DateTime.parse(json['startDate']),
      meals: (json['meals'] as List<dynamic>).map((e) => e.toString()).toList(),
      mealTiming: json['mealTiming'] ?? 'INDIFERENTE',
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
  final String date;
  final String meal;
  final int quantity;
  bool taken;

  MedicationDoseResponse({
    required this.id,
    required this.medicationId,
    required this.date,
    required this.meal,
    required this.quantity,
    required this.taken,
  });

  factory MedicationDoseResponse.fromJson(Map<String, dynamic> json) {
    return MedicationDoseResponse(
      id: json['id'],
      medicationId: json['medicationId'],
      date: json['date'],
      meal: json['meal'],
      quantity: json['quantity'],
      taken: json['taken'],
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
