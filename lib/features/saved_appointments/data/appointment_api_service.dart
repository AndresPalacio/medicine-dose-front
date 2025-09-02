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
    // Validar que dateTime esté presente y sea válido
    DateTime dateTime;
    try {
      dateTime = DateTime.parse(json['dateTime'] ?? '');
    } catch (e) {
      print('Error parsing dateTime: ${json['dateTime']}, using current time');
      dateTime = DateTime.now();
    }

    return MedicalAppointment(
      id: json['id'] ?? '',
      dateTime: dateTime,
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
  String _baseUrl = 'https://3lp396k7td.execute-api.us-east-1.amazonaws.com/prod/api';

  // Obtener todas las citas médicas (usando fecha del mes actual como en daily)
  Future<List<MedicalAppointment>> getAllAppointments() async {
    try {
      // Usar fecha del mes actual como en el sistema daily
      final currentDate = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

      print(
          'DEBUG getAllAppointments → Intentando obtener citas de: $_baseUrl/appointments?date=$formattedDate&userId=main');

      final response = await http.get(
        Uri.parse('$_baseUrl/appointments?date=$formattedDate&userId=main'),
        headers: {'Content-Type': 'application/json'},
      );

      print('DEBUG getAllAppointments → Status: ${response.statusCode}');
      print('DEBUG getAllAppointments → Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        print('DEBUG getAllAppointments → Citas obtenidas: ${body.length}');

        final appointments = body
            .map((dynamic item) => MedicalAppointment.fromJson(item))
            .toList();

        print(
            'DEBUG getAllAppointments → Citas parseadas exitosamente: ${appointments.length}');
        return appointments;
      } else {
        throw Exception(
            'Failed to load appointments: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error al obtener citas médicas: $e');
      return [];
    }
  }

  // Obtener citas por fecha (formato daily)
  Future<List<MedicalAppointment>> getAppointmentsByDate(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      print(
          'DEBUG getAppointmentsByDate → Obteniendo citas para fecha: $formattedDate');

      final response = await http.get(
        Uri.parse('$_baseUrl/appointments?date=$formattedDate&userId=main'),
        headers: {'Content-Type': 'application/json'},
      );

      print('DEBUG getAppointmentsByDate → Status: ${response.statusCode}');
      print('DEBUG getAppointmentsByDate → Response: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        final appointments = body
            .map((dynamic item) => MedicalAppointment.fromJson(item))
            .toList();
        print(
            'DEBUG getAppointmentsByDate → Citas obtenidas: ${appointments.length}');
        return appointments;
      } else {
        throw Exception(
            'Failed to load appointments by date: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error al obtener citas por fecha: $e');
      return [];
    }
  }

  // Obtener citas del mes (formato daily)
  Future<List<MedicalAppointment>> getMonthlyAppointments(
      DateTime month) async {
    try {
      // Usar el primer día del mes como en el sistema daily
      final firstDayOfMonth = DateTime(month.year, month.month, 1);
      final formattedDate = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);

      print(
          'DEBUG getMonthlyAppointments → Obteniendo citas del mes: $formattedDate');

      final response = await http.get(
        Uri.parse('$_baseUrl/appointments?date=$formattedDate&userId=main'),
        headers: {'Content-Type': 'application/json'},
      );

      print('DEBUG getMonthlyAppointments → Status: ${response.statusCode}');
      print('DEBUG getMonthlyAppointments → Response: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        final appointments = body
            .map((dynamic item) => MedicalAppointment.fromJson(item))
            .toList();
        print(
            'DEBUG getMonthlyAppointments → Citas obtenidas: ${appointments.length}');
        return appointments;
      } else {
        throw Exception(
            'Failed to load monthly appointments: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error al obtener citas del mes: $e');
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
