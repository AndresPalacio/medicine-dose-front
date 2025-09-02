import 'package:flutter/material.dart';

class Symptom {
  final int id;
  final String name;
  final String description;
  final String category;
  final IconData icon;
  final List<String> severityLevels;

  Symptom({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.severityLevels,
  });
}

class SymptomEntry {
  final String id;
  final List<Map<String, dynamic>>
      symptoms; // Cambiado de symptomIds a symptoms
  final List<String> symptomNames;
  final String severity;
  final String? notes;
  final DateTime date;
  final String time;
  final String? relatedMedications;
  final Map<String, dynamic>? additionalData;

  SymptomEntry({
    required this.id,
    required this.symptoms, // Cambiado de symptomIds a symptoms
    required this.symptomNames,
    required this.severity,
    this.notes,
    required this.date,
    required this.time,
    this.relatedMedications,
    this.additionalData,
  });

  factory SymptomEntry.fromJson(Map<String, dynamic> json) {
    final symptomNames = json['symptomNames'];
    final symptoms = json['symptoms'];
    final severity = json['severity'] ?? 'LEVE';
    final notes = json['notes'];
    final date = json['date'];
    final time = json['time'] ?? '';

    // Manejar tanto arrays como strings para compatibilidad
    List<String> names = [];
    List<Map<String, dynamic>> symptomsList = [];

    if (symptomNames is List) {
      names = symptomNames.cast<String>();
    } else if (symptomNames is String) {
      // Fallback: convertir string separado por comas a array
      names = symptomNames.split(', ').map((s) => s.trim()).toList();
    }

    if (symptoms is List) {
      symptomsList = symptoms.cast<Map<String, dynamic>>();
    } else if (symptoms is String) {
      // Fallback: convertir string separado por comas a array de síntomas
      symptomsList = symptoms
          .split(', ')
          .map(
              (s) => {'id': int.tryParse(s.trim()) ?? 0, 'category': 'general'})
          .where((symptom) => (symptom['id'] as int) > 0)
          .toList();
    }

    return SymptomEntry(
      id: json['id'] ?? '',
      symptoms: symptomsList,
      symptomNames: names,
      severity: severity,
      notes: notes,
      date: DateTime.parse(date),
      time: time,
      relatedMedications: json['relatedMedications'] != null
          ? json['relatedMedications'].toString()
          : null,
      additionalData: json['additionalData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symptoms': symptoms,
      'symptomNames': symptomNames,
      'severity': severity,
      'notes': notes,
      'date': date.toIso8601String(),
      'time': time,
      'relatedMedications': relatedMedications,
      'additionalData': additionalData,
    };
  }

  // Getter para compatibilidad con código existente
  String get symptomName {
    if (symptomNames.isEmpty) return '';
    return symptomNames.first;
  }

  // Getter para obtener solo los IDs de síntomas (para compatibilidad)
  List<int> get symptomIds {
    return symptoms.map((s) => s['id'] as int).toList();
  }
}

// Nuevo modelo para tracking de alimentación
class FoodEntry {
  final String id;
  final String mealType; // desayuno, almuerzo, cena, snack
  final String foodName;
  final String? description;
  final DateTime date;
  final String time;
  final String? ingredients;
  final String? portion;
  final bool? causedDiscomfort;
  final String? discomfortNotes;
  final Map<String, dynamic>? additionalData;

  FoodEntry({
    required this.id,
    required this.mealType,
    required this.foodName,
    this.description,
    required this.date,
    required this.time,
    this.ingredients,
    this.portion,
    this.causedDiscomfort,
    this.discomfortNotes,
    this.additionalData,
  });

  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    final foodName = json['foodName'] ?? json['name'] ?? 'Comida desconocida';
    final mealType = json['mealType'] ?? json['category'] ?? '';
    final description = json['description'] ?? json['notes'];
    final date = json['date'];
    final time = json['time'] ?? '';

    return FoodEntry(
      id: json['id'] ?? '',
      mealType: mealType,
      foodName: foodName,
      description: description,
      date: DateTime.parse(date),
      time: time,
      ingredients: json['ingredients'],
      portion: json['portion'] ?? json['quantity']?.toString(),
      causedDiscomfort: json['causedDiscomfort'],
      discomfortNotes: json['discomfortNotes'],
      additionalData: json['additionalData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mealType': mealType,
      'foodName': foodName,
      'description': description,
      'date': date.toIso8601String(),
      'time': time,
      'ingredients': ingredients,
      'portion': portion,
      'causedDiscomfort': causedDiscomfort,
      'discomfortNotes': discomfortNotes,
      'additionalData': additionalData,
    };
  }
}

// Nuevo modelo para tracking de deposiciones
class BowelMovementEntry {
  final String id;
  final DateTime date;
  final String time;
  final String consistency; // Bristol Stool Scale
  final String color;
  final bool? hasBlood;
  final bool? hasMucus;
  final String? notes;
  final bool? wasPainful;
  final String? painLevel;
  final Map<String, dynamic>? additionalData;

  BowelMovementEntry({
    required this.id,
    required this.date,
    required this.time,
    required this.consistency,
    required this.color,
    this.hasBlood,
    this.hasMucus,
    this.notes,
    this.wasPainful,
    this.painLevel,
    this.additionalData,
  });

  factory BowelMovementEntry.fromJson(Map<String, dynamic> json) {
    return BowelMovementEntry(
      id: json['id'] ?? '',
      date: DateTime.parse(json['date']),
      time: json['time'] ?? '',
      consistency: json['consistency'] ?? json['type'] ?? '',
      color: json['color'] ?? '',
      hasBlood: json['blood'] ?? json['hasBlood'],
      hasMucus: json['mucus'] ?? json['hasMucus'],
      notes: json['notes'],
      wasPainful: json['pain'] != null,
      painLevel: json['pain'],
      additionalData: json['additionalData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'time': time,
      'consistency': consistency,
      'color': color,
      'blood': hasBlood,
      'mucus': hasMucus,
      'notes': notes,
      'pain': wasPainful == true ? painLevel : null,
      'additionalData': additionalData,
    };
  }
}

class SymptomCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  SymptomCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}

// Datos predefinidos de síntomas comunes
class SymptomData {
  static final List<SymptomCategory> categories = [
    SymptomCategory(
      id: 'general',
      name: 'General',
      description: 'Síntomas generales del cuerpo',
      icon: Icons.health_and_safety,
      color: Colors.blue,
    ),
    SymptomCategory(
      id: 'pain',
      name: 'Dolor',
      description: 'Diferentes tipos de dolor',
      icon: Icons.healing,
      color: Colors.red,
    ),
    SymptomCategory(
      id: 'digestive',
      name: 'Digestivo',
      description: 'Síntomas relacionados con el sistema digestivo',
      icon: Icons.restaurant,
      color: Colors.orange,
    ),
    SymptomCategory(
      id: 'respiratory',
      name: 'Respiratorio',
      description: 'Síntomas relacionados con la respiración',
      icon: Icons.air,
      color: Colors.green,
    ),
    SymptomCategory(
      id: 'neurological',
      name: 'Neurológico',
      description: 'Síntomas relacionados con el sistema nervioso',
      icon: Icons.psychology,
      color: Colors.purple,
    ),
    SymptomCategory(
      id: 'sibo_specific',
      name: 'SIBO Específico',
      description: 'Síntomas específicos de SIBO',
      icon: Icons.bug_report,
      color: Colors.brown,
    ),
    SymptomCategory(
      id: 'helicobacter',
      name: 'Helicobacter',
      description: 'Síntomas relacionados con Helicobacter pylori',
      icon: Icons.science,
      color: Colors.indigo,
    ),
  ];

  static final List<Symptom> symptoms = [
    // Síntomas generales
    Symptom(
      id: 1,
      name: 'Fatiga',
      description: 'Cansancio extremo o falta de energía',
      category: 'general',
      icon: Icons.bedtime,
      severityLevels: ['Leve', 'Moderada', 'Severa', 'Extrema'],
    ),
    Symptom(
      id: 2,
      name: 'Fiebre',
      description: 'Temperatura corporal elevada',
      category: 'general',
      icon: Icons.thermostat,
      severityLevels: [
        'Leve (37-38°C)',
        'Moderada (38-39°C)',
        'Alta (39-40°C)',
        'Muy alta (>40°C)'
      ],
    ),
    Symptom(
      id: 3,
      name: 'Dolor de cabeza',
      description: 'Dolor en la cabeza o cuello',
      category: 'pain',
      icon: Icons.headphones,
      severityLevels: ['Leve', 'Moderado', 'Intenso', 'Insoportable'],
    ),
    Symptom(
      id: 4,
      name: 'Náuseas',
      description: 'Sensación de malestar estomacal',
      category: 'digestive',
      icon: Icons.sick,
      severityLevels: ['Leve', 'Moderada', 'Intensa', 'Vómitos'],
    ),
    Symptom(
      id: 5,
      name: 'Tos',
      description: 'Tos seca o con flemas',
      category: 'respiratory',
      icon: Icons.coronavirus,
      severityLevels: ['Leve', 'Moderada', 'Frecuente', 'Constante'],
    ),
    Symptom(
      id: 6,
      name: 'Mareos',
      description: 'Sensación de vértigo o desequilibrio',
      category: 'neurological',
      icon: Icons.rotate_right,
      severityLevels: ['Leve', 'Moderado', 'Intenso', 'Desmayo'],
    ),
    Symptom(
      id: 7,
      name: 'Insomnio',
      description: 'Dificultad para dormir',
      category: 'general',
      icon: Icons.nightlight,
      severityLevels: ['Leve', 'Moderada', 'Severa', 'Total'],
    ),
    Symptom(
      id: 8,
      name: 'Pérdida de apetito',
      description: 'Falta de deseo de comer',
      category: 'digestive',
      icon: Icons.no_food,
      severityLevels: ['Leve', 'Moderada', 'Significativa', 'Total'],
    ),
    Symptom(
      id: 9,
      name: 'Falta de aire',
      description: 'Dificultad para respirar',
      category: 'respiratory',
      icon: Icons.air,
      severityLevels: ['Leve', 'Moderada', 'Intensa', 'Asfixia'],
    ),
    Symptom(
      id: 10,
      name: 'Dolor muscular',
      description: 'Dolor en los músculos',
      category: 'pain',
      icon: Icons.fitness_center,
      severityLevels: ['Leve', 'Moderado', 'Intenso', 'Debilitante'],
    ),
    // Síntomas específicos de SIBO
    Symptom(
      id: 11,
      name: 'Hinchazón abdominal',
      description: 'Distensión del abdomen después de comer',
      category: 'sibo_specific',
      icon: Icons.airline_seat_flat,
      severityLevels: ['Leve', 'Moderada', 'Intensa', 'Extrema'],
    ),
    Symptom(
      id: 12,
      name: 'Gases excesivos',
      description: 'Flatulencia y eructos frecuentes',
      category: 'sibo_specific',
      icon: Icons.wind_power,
      severityLevels: ['Leve', 'Moderada', 'Intensa', 'Constante'],
    ),
    Symptom(
      id: 13,
      name: 'Dolor abdominal',
      description: 'Dolor en el área del estómago e intestinos',
      category: 'sibo_specific',
      icon: Icons.healing,
      severityLevels: ['Leve', 'Moderado', 'Intenso', 'Debilitante'],
    ),
    Symptom(
      id: 14,
      name: 'Diarrea',
      description: 'Deposiciones líquidas frecuentes',
      category: 'sibo_specific',
      icon: Icons.water_drop,
      severityLevels: [
        'Leve (1-2 veces)',
        'Moderada (3-4 veces)',
        'Intensa (5-6 veces)',
        'Severa (>6 veces)'
      ],
    ),
    Symptom(
      id: 15,
      name: 'Estreñimiento',
      description: 'Dificultad para evacuar',
      category: 'sibo_specific',
      icon: Icons.block,
      severityLevels: [
        'Leve (1-2 días)',
        'Moderado (3-4 días)',
        'Intenso (5-7 días)',
        'Severo (>7 días)'
      ],
    ),
    // Síntomas específicos de Helicobacter
    Symptom(
      id: 16,
      name: 'Ardor estomacal',
      description: 'Sensación de quemazón en el estómago',
      category: 'helicobacter',
      icon: Icons.local_fire_department,
      severityLevels: ['Leve', 'Moderado', 'Intenso', 'Insoportable'],
    ),
    Symptom(
      id: 17,
      name: 'Reflujo ácido',
      description: 'Regreso del contenido estomacal al esófago',
      category: 'helicobacter',
      icon: Icons.trending_up,
      severityLevels: ['Leve', 'Moderado', 'Intenso', 'Constante'],
    ),
    Symptom(
      id: 18,
      name: 'Saciedad temprana',
      description: 'Sentirse lleno rápidamente al comer',
      category: 'helicobacter',
      icon: Icons.fastfood,
      severityLevels: ['Leve', 'Moderada', 'Intensa', 'Total'],
    ),
    Symptom(
      id: 19,
      name: 'Heces negras',
      description: 'Deposiciones de color negro o alquitranadas',
      category: 'helicobacter',
      icon: Icons.colorize,
      severityLevels: ['Ocasional', 'Frecuente', 'Constante', 'Con sangre'],
    ),
  ];

  // Datos para tracking de alimentación
  static final List<String> mealTypes = [
    'DESAYUNO',
    'ALMUERZO',
    'CENA',
    'SNACK',
    'COLACIÓN',
  ];

  static final List<String> commonFoods = [
    'Arroz',
    'Pollo',
    'Pescado',
    'Carne',
    'Huevos',
    'Leche',
    'Queso',
    'Yogur',
    'Pan',
    'Pasta',
    'Frijoles',
    'Lentejas',
    'Brócoli',
    'Espinacas',
    'Zanahorias',
    'Manzana',
    'Plátano',
    'Naranja',
    'Aguacate',
    'Almendras',
    'Nueces',
    'Aceite de oliva',
    'Mantequilla',
    'Azúcar',
    'Sal',
  ];

  // Datos para tracking de deposiciones (Escala de Bristol)
  static final List<Map<String, dynamic>> bristolStoolScale = [
    {
      'type': 'Tipo 1',
      'description': 'Bolas duras y separadas',
      'color': Colors.brown,
      'consistency': 'Muy dura',
    },
    {
      'type': 'Tipo 2',
      'description': 'Forma de salchicha pero grumosa',
      'color': Colors.brown,
      'consistency': 'Dura',
    },
    {
      'type': 'Tipo 3',
      'description': 'Forma de salchicha con grietas',
      'color': Colors.brown,
      'consistency': 'Normal',
    },
    {
      'type': 'Tipo 4',
      'description': 'Forma de salchicha suave y lisa',
      'color': Colors.brown,
      'consistency': 'Normal',
    },
    {
      'type': 'Tipo 5',
      'description': 'Blandas con bordes claros',
      'color': Colors.brown,
      'consistency': 'Blanda',
    },
    {
      'type': 'Tipo 6',
      'description': 'Pastosas con bordes irregulares',
      'color': Colors.brown,
      'consistency': 'Muy blanda',
    },
    {
      'type': 'Tipo 7',
      'description': 'Completamente líquidas',
      'color': Colors.brown,
      'consistency': 'Líquida',
    },
  ];

  static final List<String> stoolColors = [
    'Marrón normal',
    'Marrón claro',
    'Marrón oscuro',
    'Verde',
    'Amarillo',
    'Negro',
    'Rojo',
    'Blanco/Gris',
  ];

  // Método helper para convertir el formato del backend a formato de visualización para colores
  static String getStoolColorDisplayName(String backendValue) {
    if (backendValue.isEmpty) return 'Marrón normal';

    switch (backendValue.toUpperCase()) {
      case 'MARRON':
      case 'MARRÓN':
      case 'MARRON_NORMAL':
      case 'MARRÓN_NORMAL':
        return 'Marrón normal';
      case 'MARRON_CLARO':
      case 'MARRÓN_CLARO':
        return 'Marrón claro';
      case 'MARRON_OSCURO':
      case 'MARRÓN_OSCURO':
        return 'Marrón oscuro';
      case 'VERDE':
        return 'Verde';
      case 'AMARILLO':
        return 'Amarillo';
      case 'NEGRO':
        return 'Negro';
      case 'ROJO':
        return 'Rojo';
      case 'BLANCO':
      case 'GRIS':
      case 'BLANCO_GRIS':
        return 'Blanco/Gris';
      default:
        // Si no coincide exactamente, intentar encontrar el más cercano
        if (backendValue.toUpperCase().contains('MARRON') ||
            backendValue.toUpperCase().contains('MARRÓN')) {
          return 'Marrón normal';
        }
        return 'Marrón normal'; // Valor por defecto seguro
    }
  }

  // Método helper para convertir el formato de visualización al formato del backend para colores
  static String getStoolColorBackendValue(String displayName) {
    if (displayName.isEmpty) return 'MARRON';

    switch (displayName.toLowerCase()) {
      case 'marrón normal':
      case 'marron normal':
        return 'MARRON';
      case 'marrón claro':
      case 'marron claro':
        return 'MARRON_CLARO';
      case 'marrón oscuro':
      case 'marron oscuro':
        return 'MARRON_OSCURO';
      case 'verde':
        return 'VERDE';
      case 'amarillo':
        return 'AMARILLO';
      case 'negro':
        return 'NEGRO';
      case 'rojo':
        return 'ROJO';
      case 'blanco/gris':
      case 'blanco gris':
        return 'BLANCO_GRIS';
      default:
        // Si no coincide exactamente, intentar encontrar el más cercano
        if (displayName.toLowerCase().contains('marrón') ||
            displayName.toLowerCase().contains('marron')) {
          return 'MARRON';
        }
        return 'MARRON'; // Valor por defecto seguro
    }
  }

  static List<Symptom> getSymptomsByCategory(String categoryId) {
    return symptoms.where((symptom) => symptom.category == categoryId).toList();
  }

  static Symptom? getSymptomById(int id) {
    try {
      return symptoms.firstWhere((symptom) => symptom.id == id);
    } catch (e) {
      return null;
    }
  }

  static SymptomCategory? getCategoryById(String id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Método helper para convertir el formato del backend a formato de visualización
  static String getMealTypeDisplayName(String backendValue) {
    switch (backendValue.toUpperCase()) {
      case 'DESAYUNO':
        return 'Desayuno';
      case 'ALMUERZO':
        return 'Almuerzo';
      case 'CENA':
        return 'Cena';
      case 'SNACK':
        return 'Snack';
      case 'COLACIÓN':
        return 'Colación';
      default:
        return backendValue;
    }
  }

  // Método helper para convertir el formato de visualización al formato del backend
  static String getMealTypeBackendValue(String displayName) {
    switch (displayName.toLowerCase()) {
      case 'desayuno':
        return 'DESAYUNO';
      case 'almuerzo':
        return 'ALMUERZO';
      case 'cena':
        return 'CENA';
      case 'snack':
        return 'SNACK';
      case 'colación':
      case 'colacion':
        return 'COLACIÓN';
      default:
        return displayName.toUpperCase();
    }
  }
}
