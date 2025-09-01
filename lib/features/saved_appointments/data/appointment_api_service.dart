import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class MedicalAppointment {
  final String id;
  final DateTime dateTime;
  final String doctor;
  final String specialty;
  final String status; // 'Pendiente', 'Confirmada', 'Cancelada'
  final String? notes;
  final String userId;

  MedicalAppointment({
    required this.id,
    required this.dateTime,
    required this.doctor,
    required this.specialty,
    required this.status,
    this.notes,
    required this.userId,
  });

  factory MedicalAppointment.fromJson(Map<String, dynamic> json) {
    return MedicalAppointment(
      id: json['id'] ?? '',
      dateTime: DateTime.parse(json['dateTime']),
      doctor: json['doctor'] ?? '',
      specialty: json['specialty'] ?? '',
      status: json['status'] ?? 'Pendiente',
      notes: json['notes'],
      userId: json['userId'] ?? 'main',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'doctor': doctor,
      'specialty': specialty,
      'status': status,
      'notes': notes,
      'userId': userId,
    };
  }
}

class AppointmentApiService {
  String _baseUrl = 'http://localhost:8080/api';

  // Obtener todas las citas médicas
  Future<List<MedicalAppointment>> getAllAppointments() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/appointments?userId=main'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body
            .map((dynamic item) => MedicalAppointment.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load appointments: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener citas médicas: $e');
      return [];
    }
  }

  // Obtener citas por fecha
  Future<List<MedicalAppointment>> getAppointmentsByDate(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final response = await http.get(
        Uri.parse('$_baseUrl/appointments?userId=main&date=$formattedDate'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body
            .map((dynamic item) => MedicalAppointment.fromJson(item))
            .toList();
      } else {
        throw Exception(
            'Failed to load appointments by date: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener citas por fecha: $e');
      return [];
    }
  }

  // Obtener citas por rango de fechas
  Future<List<MedicalAppointment>> getAppointmentsByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final startFormatted = DateFormat('yyyy-MM-dd').format(startDate);
      final endFormatted = DateFormat('yyyy-MM-dd').format(endDate);

      final response = await http.get(
        Uri.parse(
            '$_baseUrl/appointments?userId=main&startDate=$startFormatted&endDate=$endFormatted'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body
            .map((dynamic item) => MedicalAppointment.fromJson(item))
            .toList();
      } else {
        throw Exception(
            'Failed to load appointments by date range: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener citas por rango de fechas: $e');
      return [];
    }
  }

  // Obtener cita específica
  Future<MedicalAppointment?> getAppointmentById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/appointments/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        return MedicalAppointment.fromJson(body);
      } else {
        throw Exception('Failed to load appointment: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener cita específica: $e');
      return null;
    }
  }

  // Crear nueva cita médica
  Future<bool> createAppointment(MedicalAppointment appointment) async {
    try {
      final body = {
        'dateTime': appointment.dateTime.toIso8601String(),
        'doctor': appointment.doctor,
        'specialty': appointment.specialty,
        'status': appointment.status,
        'notes': appointment.notes,
        'userId': 'main',
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/appointments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('DEBUG createAppointment → Cita creada exitosamente');
        return true;
      } else {
        throw Exception('Failed to create appointment: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al crear cita: $e');
      return false;
    }
  }

  // Actualizar cita médica
  Future<bool> updateAppointment(MedicalAppointment appointment) async {
    try {
      final body = {
        'dateTime': appointment.dateTime.toIso8601String(),
        'doctor': appointment.doctor,
        'specialty': appointment.specialty,
        'status': appointment.status,
        'notes': appointment.notes,
        'userId': 'main',
      };

      final response = await http.put(
        Uri.parse('$_baseUrl/appointments/${appointment.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('DEBUG updateAppointment → Cita actualizada exitosamente');
        return true;
      } else {
        throw Exception('Failed to update appointment: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al actualizar cita: $e');
      return false;
    }
  }

  // Cambiar estado de cita
  Future<bool> updateAppointmentStatus(
      String appointmentId, String status) async {
    try {
      final body = {
        'status': status,
        'userId': 'main',
      };

      final response = await http.put(
        Uri.parse('$_baseUrl/appointments/$appointmentId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print(
            'DEBUG updateAppointmentStatus → Estado de cita actualizado exitosamente');
        return true;
      } else {
        throw Exception(
            'Failed to update appointment status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al actualizar estado de cita: $e');
      return false;
    }
  }

  // Eliminar cita médica
  Future<bool> deleteAppointment(String appointmentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/appointments/$appointmentId?userId=main'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('DEBUG deleteAppointment → Cita eliminada exitosamente');
        return true;
      } else {
        throw Exception('Failed to delete appointment: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al eliminar cita: $e');
      return false;
    }
  }

  // Obtener estadísticas de citas
  Future<Map<String, dynamic>> getAppointmentStatistics(
      DateTime startDate, DateTime endDate) async {
    try {
      final startFormatted = DateFormat('yyyy-MM-dd').format(startDate);
      final endFormatted = DateFormat('yyyy-MM-dd').format(endDate);

      final response = await http.get(
        Uri.parse(
            '$_baseUrl/appointments/stats?userId=main&startDate=$startFormatted&endDate=$endFormatted'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception(
            'Failed to load appointment statistics: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener estadísticas de citas: $e');
      return {};
    }
  }
}
