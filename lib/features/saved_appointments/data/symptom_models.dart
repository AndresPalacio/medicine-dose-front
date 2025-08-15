import 'package:flutter/material.dart';

class Symptom {
  final String id;
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
  final String symptomId;
  final String symptomName;
  final String severity;
  final String? notes;
  final DateTime date;
  final String time;
  final List<String>? relatedMedications;
  final Map<String, dynamic>? additionalData;

  SymptomEntry({
    required this.id,
    required this.symptomId,
    required this.symptomName,
    required this.severity,
    this.notes,
    required this.date,
    required this.time,
    this.relatedMedications,
    this.additionalData,
  });

  factory SymptomEntry.fromJson(Map<String, dynamic> json) {
    return SymptomEntry(
      id: json['id'],
      symptomId: json['symptomId'],
      symptomName: json['symptomName'],
      severity: json['severity'],
      notes: json['notes'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      relatedMedications: json['relatedMedications'] != null
          ? List<String>.from(json['relatedMedications'])
          : null,
      additionalData: json['additionalData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symptomId': symptomId,
      'symptomName': symptomName,
      'severity': severity,
      'notes': notes,
      'date': date.toIso8601String(),
      'time': time,
      'relatedMedications': relatedMedications,
      'additionalData': additionalData,
    };
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
  final List<String>? ingredients;
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
    return FoodEntry(
      id: json['id'],
      mealType: json['mealType'],
      foodName: json['foodName'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      ingredients: json['ingredients'] != null
          ? List<String>.from(json['ingredients'])
          : null,
      portion: json['portion'],
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
      id: json['id'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      consistency: json['consistency'],
      color: json['color'],
      hasBlood: json['hasBlood'],
      hasMucus: json['hasMucus'],
      notes: json['notes'],
      wasPainful: json['wasPainful'],
      painLevel: json['painLevel'],
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
      'hasBlood': hasBlood,
      'hasMucus': hasMucus,
      'notes': notes,
      'wasPainful': wasPainful,
      'painLevel': painLevel,
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
      id: 'fatigue',
      name: 'Fatiga',
      description: 'Cansancio extremo o falta de energía',
      category: 'general',
      icon: Icons.bedtime,
      severityLevels: ['Leve', 'Moderada', 'Severa', 'Extrema'],
    ),
    Symptom(
      id: 'fever',
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
      id: 'headache',
      name: 'Dolor de cabeza',
      description: 'Dolor en la cabeza o cuello',
      category: 'pain',
      icon: Icons.headphones,
      severityLevels: ['Leve', 'Moderado', 'Intenso', 'Insoportable'],
    ),
    Symptom(
      id: 'nausea',
      name: 'Náuseas',
      description: 'Sensación de malestar estomacal',
      category: 'digestive',
      icon: Icons.sick,
      severityLevels: ['Leve', 'Moderada', 'Intensa', 'Vómitos'],
    ),
    Symptom(
      id: 'cough',
      name: 'Tos',
      description: 'Tos seca o con flemas',
      category: 'respiratory',
      icon: Icons.coronavirus,
      severityLevels: ['Leve', 'Moderada', 'Frecuente', 'Constante'],
    ),
    Symptom(
      id: 'dizziness',
      name: 'Mareos',
      description: 'Sensación de vértigo o desequilibrio',
      category: 'neurological',
      icon: Icons.rotate_right,
      severityLevels: ['Leve', 'Moderado', 'Intenso', 'Desmayo'],
    ),
    Symptom(
      id: 'insomnia',
      name: 'Insomnio',
      description: 'Dificultad para dormir',
      category: 'general',
      icon: Icons.nightlight,
      severityLevels: ['Leve', 'Moderada', 'Severa', 'Total'],
    ),
    Symptom(
      id: 'appetite_loss',
      name: 'Pérdida de apetito',
      description: 'Falta de deseo de comer',
      category: 'digestive',
      icon: Icons.no_food,
      severityLevels: ['Leve', 'Moderada', 'Significativa', 'Total'],
    ),
    Symptom(
      id: 'shortness_breath',
      name: 'Falta de aire',
      description: 'Dificultad para respirar',
      category: 'respiratory',
      icon: Icons.air,
      severityLevels: ['Leve', 'Moderada', 'Intensa', 'Asfixia'],
    ),
    Symptom(
      id: 'muscle_pain',
      name: 'Dolor muscular',
      description: 'Dolor en los músculos',
      category: 'pain',
      icon: Icons.fitness_center,
      severityLevels: ['Leve', 'Moderado', 'Intenso', 'Debilitante'],
    ),
    // Síntomas específicos de SIBO
    Symptom(
      id: 'bloating',
      name: 'Hinchazón abdominal',
      description: 'Distensión del abdomen después de comer',
      category: 'sibo_specific',
      icon: Icons.airline_seat_flat,
      severityLevels: ['Leve', 'Moderada', 'Intensa', 'Extrema'],
    ),
    Symptom(
      id: 'gas',
      name: 'Gases excesivos',
      description: 'Flatulencia y eructos frecuentes',
      category: 'sibo_specific',
      icon: Icons.wind_power,
      severityLevels: ['Leve', 'Moderada', 'Intensa', 'Constante'],
    ),
    Symptom(
      id: 'abdominal_pain',
      name: 'Dolor abdominal',
      description: 'Dolor en el área del estómago e intestinos',
      category: 'sibo_specific',
      icon: Icons.healing,
      severityLevels: ['Leve', 'Moderado', 'Intenso', 'Debilitante'],
    ),
    Symptom(
      id: 'diarrhea',
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
      id: 'constipation',
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
      id: 'stomach_burning',
      name: 'Ardor estomacal',
      description: 'Sensación de quemazón en el estómago',
      category: 'helicobacter',
      icon: Icons.local_fire_department,
      severityLevels: ['Leve', 'Moderado', 'Intenso', 'Insoportable'],
    ),
    Symptom(
      id: 'acid_reflux',
      name: 'Reflujo ácido',
      description: 'Regreso del contenido estomacal al esófago',
      category: 'helicobacter',
      icon: Icons.trending_up,
      severityLevels: ['Leve', 'Moderado', 'Intenso', 'Constante'],
    ),
    Symptom(
      id: 'early_satiety',
      name: 'Saciedad temprana',
      description: 'Sentirse lleno rápidamente al comer',
      category: 'helicobacter',
      icon: Icons.fastfood,
      severityLevels: ['Leve', 'Moderada', 'Intensa', 'Total'],
    ),
    Symptom(
      id: 'black_stools',
      name: 'Heces negras',
      description: 'Deposiciones de color negro o alquitranadas',
      category: 'helicobacter',
      icon: Icons.colorize,
      severityLevels: ['Ocasional', 'Frecuente', 'Constante', 'Con sangre'],
    ),
  ];

  // Datos para tracking de alimentación
  static final List<String> mealTypes = [
    'Desayuno',
    'Almuerzo',
    'Cena',
    'Snack',
    'Colación',
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

  static List<Symptom> getSymptomsByCategory(String categoryId) {
    return symptoms.where((symptom) => symptom.category == categoryId).toList();
  }

  static Symptom? getSymptomById(String id) {
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
}
