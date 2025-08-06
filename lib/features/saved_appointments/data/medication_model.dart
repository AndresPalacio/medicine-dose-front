import 'package:flutter/material.dart';

class Medication {
  final String name;
  final String dosage;
  final String time;
  final DateTime date;
  bool isTaken;

  Medication({
    required this.name,
    required this.dosage,
    required this.time,
    required this.date,
    this.isTaken = false,
  });
}

class MedicationPlan {
  final String? userId; // Hacer opcional ya que no se envía al backend
  final String medicamento;
  final int cantidadTotal;
  final int cantidadPorToma;
  final int frecuenciaDias;
  final int duracion;
  final String tipoDuracion;
  final String unidadRepeticion;
  final int cantidadRepeticiones;
  final DateTime fechaInicio;
  final bool tomaDesayuno;
  final bool tomaAlmuerzo;
  final bool tomaCena;
  final String mealTiming;
  final int timeBeforeAfter;
  final String timeUnit;

  MedicationPlan({
    this.userId, // userId opcional
    required this.medicamento,
    required this.cantidadTotal,
    required this.cantidadPorToma,
    required this.frecuenciaDias,
    required this.duracion,
    required this.tipoDuracion,
    required this.unidadRepeticion,
    required this.cantidadRepeticiones,
    required this.fechaInicio,
    required this.tomaDesayuno,
    required this.tomaAlmuerzo,
    required this.tomaCena,
    required this.mealTiming,
    required this.timeBeforeAfter,
    required this.timeUnit,
  });
}
