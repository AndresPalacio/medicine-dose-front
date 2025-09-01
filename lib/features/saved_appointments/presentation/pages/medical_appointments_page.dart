import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_text.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_button_round.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_button.dart';
import 'package:vibe_coding_tutorial_weather_app/utils/colors.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/appointment_api_service.dart';

class MedicalAppointmentsPage extends StatefulWidget {
  const MedicalAppointmentsPage({Key? key}) : super(key: key);

  @override
  State<MedicalAppointmentsPage> createState() =>
      _MedicalAppointmentsPageState();
}

class _MedicalAppointmentsPageState extends State<MedicalAppointmentsPage> {
  final AppointmentApiService _appointmentService = AppointmentApiService();
  late DateTime _selectedDate;
  late DateTime _currentMonth;
  List<MedicalAppointment> _appointments = [];
  bool _isLoading = true;
  String? _error;
  bool _isBackendConnected = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    _testBackendConnection();
  }

  Future<void> _testBackendConnection() async {
    try {
      // Intentar obtener citas del mes actual para probar la conexión
      await _appointmentService.getMonthlyAppointments(_currentMonth);
      setState(() {
        _isBackendConnected = true;
      });
      // Si la conexión es exitosa, cargar las citas
      await _loadAppointments();
    } catch (e) {
      setState(() {
        _isBackendConnected = false;
        _error =
            'No se pudo conectar con el backend. Verifica que esté ejecutándose en http://localhost:8080';
        _isLoading = false;
      });
      print('DEBUG _testBackendConnection → Error de conexión: $e');

      // Cargar citas locales si no hay conexión
      _loadLocalAppointments();
    }
  }

  void _loadLocalAppointments() {
    // En modo sin conexión, mostrar citas vacías
    setState(() {
      _appointments = [];
      _isLoading = false;
    });
  }

  Future<void> _testDifferentEndpoints() async {
    print('DEBUG _testDifferentEndpoints → Probando diferentes endpoints...');

    try {
      // Probar endpoint con fecha del mes actual (formato daily)
      print(
          'DEBUG _testDifferentEndpoints → Probando endpoint con fecha del mes...');
      final response1 =
          await _appointmentService.getMonthlyAppointments(_currentMonth);
      print(
          'DEBUG _testDifferentEndpoints → Endpoint mensual: OK - ${response1.length} citas');

      // Probar endpoint con fecha específica (formato daily)
      print(
          'DEBUG _testDifferentEndpoints → Probando endpoint con fecha específica...');
      final today = DateTime.now();
      final response2 = await _appointmentService.getAppointmentsByDate(today);
      print(
          'DEBUG _testDifferentEndpoints → Endpoint con fecha: OK - ${response2.length} citas');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todos los endpoints funcionan correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('DEBUG _testDifferentEndpoints → Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error probando endpoints: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('DEBUG _loadAppointments → Iniciando carga de citas del mes...');

      // Usar el nuevo método que envía fecha como en daily
      final monthAppointments =
          await _appointmentService.getMonthlyAppointments(_currentMonth);
      print(
          'DEBUG _loadAppointments → Citas del mes obtenidas: ${monthAppointments.length}');

      setState(() {
        _appointments = monthAppointments;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      String errorMessage;
      print('DEBUG _loadAppointments → Error completo: $e');

      if (e.toString().contains('Failed to load monthly appointments')) {
        errorMessage =
            'No se pudo conectar con el servidor. Verifica que el backend esté ejecutándose en http://localhost:8080';
      } else if (e.toString().contains('Connection refused')) {
        errorMessage =
            'Error de conexión: El servidor no está respondiendo. Verifica que el backend esté ejecutándose.';
      } else if (e
          .toString()
          .contains('Debe proporcionar date o startDate y endDate')) {
        errorMessage =
            'Error del backend: El servidor requiere parámetros específicos de fecha. Contacta al administrador.';
      } else {
        errorMessage = 'Error al cargar las citas: $e';
      }

      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });

      print('DEBUG _loadAppointments → Error final: $errorMessage');
    }
  }

  void _navigateToMonth(int months) {
    setState(() {
      _currentMonth =
          DateTime(_currentMonth.year, _currentMonth.month + months, 1);
      _selectedDate = _currentMonth;
      _loadAppointments();
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    final citasDelDia = _appointments
        .where((a) =>
            a.dateTime.year == date.year &&
            a.dateTime.month == date.month &&
            a.dateTime.day == date.day)
        .toList();
    if (citasDelDia.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => _ManageAppointmentsDayDialog(
          date: date,
          appointments: citasDelDia,
          onUpdate: (updated) async {
            // Mostrar indicador de carga
            setState(() {
              _isLoading = true;
              _error = null;
            });

            try {
              bool allSuccess = true;

              if (_isBackendConnected) {
                // Actualizar en el backend
                for (final appt in updated) {
                  final success =
                      await _appointmentService.updateAppointment(appt);
                  if (!success) {
                    allSuccess = false;
                    break;
                  }
                }

                if (allSuccess) {
                  // Recargar citas desde el servidor
                  await _loadAppointments();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Estados actualizados correctamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              } else {
                // Modo sin conexión - actualizar localmente
                setState(() {
                  for (final appt in updated) {
                    final idx =
                        _appointments.indexWhere((a) => a.id == appt.id);
                    if (idx != -1) _appointments[idx] = appt;
                  }
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Estados actualizados localmente (sin conexión)'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            } catch (e) {
              setState(() {
                _error = 'Error al actualizar estados: $e';
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } finally {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      );
    }
  }

  void _showAppointmentDetails(MedicalAppointment appt) {
    showDialog(
      context: context,
      builder: (context) => _MedicalAppointmentDetailsDialog(
        appointment: appt,
        onEdit: () => _showEditAppointmentDialog(appt),
        onDelete: () async {
          // Mostrar confirmación antes de eliminar
          final shouldDelete = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirmar eliminación'),
              content: const Text(
                  '¿Estás seguro de que quieres eliminar esta cita?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Eliminar'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          );

          if (shouldDelete == true) {
            setState(() {
              _isLoading = true;
              _error = null;
            });

            try {
              bool success = false;

              if (_isBackendConnected) {
                // Intentar eliminar en el backend
                success = await _appointmentService.deleteAppointment(appt.id);
                if (success) {
                  // Recargar citas desde el servidor
                  await _loadAppointments();
                }
              } else {
                // Modo sin conexión - eliminar localmente
                setState(() {
                  _appointments.removeWhere((a) => a.id == appt.id);
                });
                success = true;
              }

              if (success) {
                Navigator.of(context).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isBackendConnected
                          ? 'Cita eliminada correctamente'
                          : 'Cita eliminada localmente (sin conexión)'),
                      backgroundColor:
                          _isBackendConnected ? Colors.green : Colors.orange,
                    ),
                  );
                }
              } else {
                throw Exception('Error al eliminar la cita');
              }
            } catch (e) {
              setState(() {
                _error = 'Error al eliminar la cita: $e';
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } finally {
              setState(() {
                _isLoading = false;
              });
            }
          }
        },
      ),
    );
  }

  void _showEditAppointmentDialog([MedicalAppointment? appt]) {
    showDialog(
      context: context,
      builder: (context) => _MedicalAppointmentEditDialog(
        appointment: appt,
        onSave: (newAppt) async {
          // Mostrar indicador de carga
          setState(() {
            _isLoading = true;
            _error = null;
          });

          try {
            bool success = false;

            if (_isBackendConnected) {
              // Intentar guardar en el backend
              if (appt == null) {
                // Crear nueva cita
                success = await _appointmentService.createAppointment(newAppt);
              } else {
                // Actualizar cita existente
                success = await _appointmentService.updateAppointment(newAppt);
              }

              if (success) {
                // Recargar citas desde el servidor
                await _loadAppointments();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(appt == null
                          ? 'Cita creada correctamente'
                          : 'Cita actualizada correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                throw Exception('Error al guardar la cita en el servidor');
              }
            } else {
              // Modo sin conexión - guardar localmente
              if (appt == null) {
                // Agregar nueva cita local
                setState(() {
                  _appointments.add(newAppt);
                });
                success = true;
              } else {
                // Actualizar cita local
                final idx = _appointments.indexWhere((a) => a.id == appt.id);
                if (idx != -1) {
                  setState(() {
                    _appointments[idx] = newAppt;
                  });
                  success = true;
                }
              }

              if (success) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(appt == null
                          ? 'Cita creada localmente (sin conexión)'
                          : 'Cita actualizada localmente (sin conexión)'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            }

            if (success) {
              Navigator.of(context).pop();
            } else {
              throw Exception('Error al guardar la cita');
            }
          } catch (e) {
            setState(() {
              _error = 'Error al guardar la cita: $e';
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } finally {
            setState(() {
              _isLoading = false;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = 500.0;
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    final days = <Widget>[];
    for (int i = 1; i < firstWeekday; i++) {
      days.add(_buildEmptyDay());
    }
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isSelected = date.day == _selectedDate.day &&
          date.month == _selectedDate.month &&
          date.year == _selectedDate.year;
      final isToday = date.day == DateTime.now().day &&
          date.month == DateTime.now().month &&
          date.year == DateTime.now().year;
      final hasAppointment = _appointments.any((a) =>
          a.dateTime.year == date.year &&
          a.dateTime.month == date.month &&
          a.dateTime.day == date.day);
      days.add(_buildDay(date, isSelected, isToday, hasAppointment));
    }
    int totalCells = days.length;
    int remainder = totalCells % 7;
    if (remainder != 0) {
      int emptyToAdd = 7 - remainder;
      for (int i = 0; i < emptyToAdd; i++) {
        days.add(_buildEmptyDay());
      }
    }
    // Filtrar citas del mes actual directamente usando DateTime
    final monthAppointments = _appointments
        .where((a) =>
            a.dateTime.year == _currentMonth.year &&
            a.dateTime.month == _currentMonth.month)
        .toList();
    monthAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return Scaffold(
      backgroundColor: selago,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        title: Row(
          children: [
            const ContraText(
              alignment: Alignment.centerLeft,
              text: 'Citas Médicas',
              size: 20,
              weight: FontWeight.bold,
              color: wood_smoke,
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _isBackendConnected ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: wood_smoke),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!_isBackendConnected)
            IconButton(
              icon: const Icon(Icons.refresh, color: wood_smoke),
              onPressed: _testBackendConnection,
              tooltip: 'Reintentar conexión',
            ),
          IconButton(
            icon: const Icon(Icons.bug_report, color: wood_smoke),
            onPressed: _testDifferentEndpoints,
            tooltip: 'Probar endpoints',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: carribean_green,
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.add, color: white),
        onPressed: _isLoading ? null : () => _showEditAppointmentDialog(),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error al cargar las citas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red[600]),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadAppointments,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            color: selago,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ContraButtonRound(
                                      borderColor: wood_smoke,
                                      shadowColor: athens_gray,
                                      color: white,
                                      iconPath: "assets/icons/arrow_back.svg",
                                      callback: () => _navigateToMonth(-1),
                                    ),
                                    Expanded(
                                      child: ContraText(
                                        alignment: Alignment.center,
                                        text: DateFormat('MMMM yyyy', 'es_ES')
                                            .format(_currentMonth),
                                        size: 18,
                                        weight: FontWeight.bold,
                                        color: wood_smoke,
                                      ),
                                    ),
                                    ContraButtonRound(
                                      borderColor: wood_smoke,
                                      shadowColor: athens_gray,
                                      color: white,
                                      iconPath:
                                          "assets/icons/arrow_forward.svg",
                                      callback: () => _navigateToMonth(1),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    'Lun',
                                    'Mar',
                                    'Mié',
                                    'Jue',
                                    'Vie',
                                    'Sáb',
                                    'Dom'
                                  ]
                                      .map((day) => Expanded(
                                            child: Center(
                                              child: ContraText(
                                                alignment: Alignment.center,
                                                text: day,
                                                size: 12,
                                                weight: FontWeight.bold,
                                                color: trout,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                                const SizedBox(height: 8),
                                GridView.count(
                                  crossAxisCount: 7,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: days,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const ContraText(
                            alignment: Alignment.centerLeft,
                            text: 'Citas del Mes',
                            size: 18,
                            weight: FontWeight.bold,
                            color: wood_smoke,
                          ),
                          const SizedBox(height: 12),
                          if (!_isBackendConnected)
                            Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange[300]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber,
                                      color: Colors.orange[700]),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Modo sin conexión',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange[700],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'No se puede conectar con el servidor. Las citas se guardarán localmente.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(
                            height: 350,
                            child: monthAppointments.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.event_busy,
                                          size: 64,
                                          color: trout,
                                        ),
                                        const SizedBox(height: 16),
                                        ContraText(
                                          alignment: Alignment.center,
                                          text: _isBackendConnected
                                              ? 'No hay citas para este mes'
                                              : 'No se pueden cargar las citas',
                                          size: 16,
                                          color: trout,
                                        ),
                                        if (!_isBackendConnected) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            'Verifica la conexión con el backend',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: trout,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: monthAppointments.length,
                                    itemBuilder: (context, index) {
                                      final appt = monthAppointments[index];
                                      return _buildAppointmentCard(appt);
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildDay(
      DateTime date, bool isSelected, bool isToday, bool hasAppointment) {
    return GestureDetector(
      onTap: () => _onDateSelected(date),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? carribean_green : (isToday ? selago : white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? carribean_green : wood_smoke,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: ContraText(
                alignment: Alignment.center,
                text: '${date.day}',
                size: 14,
                weight:
                    isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? white : wood_smoke,
              ),
            ),
            if (hasAppointment)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: moody_blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDay() {
    return Container(
      margin: const EdgeInsets.all(2),
    );
  }

  Widget _buildAppointmentCard(MedicalAppointment appt) {
    final formatter = DateFormat('dd MMMM yyyy, HH:mm', 'es_ES');
    Color statusColor;
    switch (appt.status) {
      case 'Confirmada':
        statusColor = carribean_green;
        break;
      case 'Cancelada':
        statusColor = mona_lisa;
        break;
      case 'Programada':
        statusColor = moody_blue;
        break;
      default:
        statusColor = moody_blue;
    }
    return GestureDetector(
      onTap: () => _showAppointmentDetails(appt),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: wood_smoke, width: 1),
          boxShadow: [
            BoxShadow(
              color: athens_gray.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ContraText(
                    alignment: Alignment.centerLeft,
                    text: formatter.format(appt.dateTime),
                    size: 14,
                    weight: FontWeight.bold,
                    color: wood_smoke,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appt.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ContraText(
              alignment: Alignment.centerLeft,
              text: 'Dr(a): ${appt.doctor}',
              size: 15,
              color: trout,
            ),
            ContraText(
              alignment: Alignment.centerLeft,
              text: 'Especialidad: ${appt.specialty}',
              size: 14,
              color: trout,
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicalAppointmentDetailsDialog extends StatelessWidget {
  final MedicalAppointment appointment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _MedicalAppointmentDetailsDialog({
    Key? key,
    required this.appointment,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMMM yyyy, HH:mm', 'es_ES');
    Color statusColor;
    switch (appointment.status) {
      case 'Confirmada':
        statusColor = carribean_green;
        break;
      case 'Cancelada':
        statusColor = mona_lisa;
        break;
      case 'Programada':
        statusColor = moody_blue;
        break;
      default:
        statusColor = moody_blue;
    }
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, color: statusColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: ContraText(
                    alignment: Alignment.centerLeft,
                    text: formatter.format(appointment.dateTime),
                    size: 18,
                    weight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ContraText(
              alignment: Alignment.centerLeft,
              text: 'Dr(a): ${appointment.doctor}',
              size: 16,
              weight: FontWeight.bold,
              color: wood_smoke,
            ),
            const SizedBox(height: 4),
            ContraText(
              alignment: Alignment.centerLeft,
              text: 'Especialidad: ${appointment.specialty}',
              size: 15,
              color: trout,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appointment.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: carribean_green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                  ),
                  onPressed: onEdit,
                  child: const Text('Editar',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: mona_lisa,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                  ),
                  onPressed: onDelete,
                  child: const Text('Eliminar',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: trout,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicalAppointmentEditDialog extends StatefulWidget {
  final MedicalAppointment? appointment;
  final Function(MedicalAppointment) onSave;
  const _MedicalAppointmentEditDialog(
      {Key? key, this.appointment, required this.onSave})
      : super(key: key);

  @override
  State<_MedicalAppointmentEditDialog> createState() =>
      _MedicalAppointmentEditDialogState();
}

class _MedicalAppointmentEditDialogState
    extends State<_MedicalAppointmentEditDialog> {
  late TextEditingController _doctorController;
  late TextEditingController _specialtyController;
  late DateTime _date;
  late TimeOfDay _time;
  String _status = 'Pendiente';

  @override
  void initState() {
    super.initState();
    final appt = widget.appointment;
    _doctorController = TextEditingController(text: appt?.doctor ?? '');
    _specialtyController = TextEditingController(text: appt?.specialty ?? '');
    _date = appt?.dateTime ?? DateTime.now();
    _time = TimeOfDay.fromDateTime(appt?.dateTime ?? DateTime.now());

    // Validar que el estado esté en la lista de estados válidos
    final validStatuses = [
      'Pendiente',
      'Confirmada',
      'Cancelada',
      'Programada'
    ];
    final apptStatus = appt?.status ?? 'Pendiente';
    _status = validStatuses.contains(apptStatus) ? apptStatus : 'Pendiente';
  }

  @override
  void dispose() {
    _doctorController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  void _save() {
    // Validar que el estado sea válido
    final validStatuses = [
      'Pendiente',
      'Confirmada',
      'Cancelada',
      'Programada'
    ];
    if (!validStatuses.contains(_status)) {
      _status = 'Pendiente'; // Estado por defecto si no es válido
    }

    final dt =
        DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    final newAppt = MedicalAppointment(
      id: widget.appointment?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      dateTime: dt,
      doctor: _doctorController.text,
      specialty: _specialtyController.text,
      status: _status,
      userId: 'main',
    );
    widget.onSave(newAppt);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: athens_gray,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.edit, color: wood_smoke, size: 28),
                  const SizedBox(width: 12),
                  ContraText(
                    alignment: Alignment.centerLeft,
                    text: widget.appointment == null
                        ? 'Nueva cita'
                        : 'Editar cita',
                    size: 18,
                    weight: FontWeight.bold,
                    color: wood_smoke,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInputField(
                label: 'Doctor(a)',
                hint: 'Nombre del doctor(a)',
                controller: _doctorController,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                label: 'Especialidad',
                hint: 'Especialidad',
                controller: _specialtyController,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDatePickerField(
                      label: 'Fecha',
                      value: DateFormat('dd MMM yyyy').format(_date),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 365)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                          locale: const Locale('es', 'ES'),
                        );
                        if (picked != null) setState(() => _date = picked);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDatePickerField(
                      label: 'Hora',
                      value: _time.format(context),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _time,
                        );
                        if (picked != null) setState(() => _time = picked);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Estado',
                value: _status,
                items: const [
                  'Pendiente',
                  'Confirmada',
                  'Cancelada',
                  'Programada'
                ],
                onChanged: (val) =>
                    setState(() => _status = val ?? 'Pendiente'),
              ),
              const SizedBox(height: 32),
              ContraButton(
                borderColor: wood_smoke,
                shadowColor: wood_smoke,
                color: Colors.green,
                textColor: white,
                text: 'Guardar',
                callback: _save,
                iconPath: '',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContraText(
          alignment: Alignment.centerLeft,
          text: label,
          size: 18,
          weight: FontWeight.bold,
          color: wood_smoke,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: ShapeDecoration(
            color: white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: wood_smoke, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            style: const TextStyle(fontSize: 15, color: wood_smoke),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContraText(
          alignment: Alignment.centerLeft,
          text: label,
          size: 18,
          weight: FontWeight.bold,
          color: wood_smoke,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: ShapeDecoration(
            color: white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: wood_smoke, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    IconData icon = label.toLowerCase().contains('hora')
        ? Icons.access_time
        : Icons.calendar_today;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContraText(
          alignment: Alignment.centerLeft,
          text: label,
          size: 18,
          weight: FontWeight.bold,
          color: wood_smoke,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: Container(
              decoration: ShapeDecoration(
                color: white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: wood_smoke, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(fontSize: 15, color: wood_smoke),
                    ),
                  ),
                  Icon(icon, color: wood_smoke, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ManageAppointmentsDayDialog extends StatefulWidget {
  final DateTime date;
  final List<MedicalAppointment> appointments;
  final Function(List<MedicalAppointment>) onUpdate;
  const _ManageAppointmentsDayDialog(
      {Key? key,
      required this.date,
      required this.appointments,
      required this.onUpdate})
      : super(key: key);

  @override
  State<_ManageAppointmentsDayDialog> createState() =>
      _ManageAppointmentsDayDialogState();
}

class _ManageAppointmentsDayDialogState
    extends State<_ManageAppointmentsDayDialog> {
  late List<MedicalAppointment> _appts;

  @override
  void initState() {
    super.initState();
    _appts = widget.appointments
        .map((a) => MedicalAppointment(
              id: a.id,
              dateTime: a.dateTime,
              doctor: a.doctor,
              specialty: a.specialty,
              status: a.status,
              userId: 'main',
            ))
        .toList();
  }

  void _updateStatus(int idx, String newStatus) {
    setState(() {
      final appt = _appts[idx];
      _appts[idx] = MedicalAppointment(
        id: appt.id,
        dateTime: appt.dateTime,
        doctor: appt.doctor,
        specialty: appt.specialty,
        status: newStatus,
        userId: 'main',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMMM yyyy', 'es_ES');
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: athens_gray,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, color: wood_smoke, size: 28),
                const SizedBox(width: 12),
                ContraText(
                  alignment: Alignment.centerLeft,
                  text: formatter.format(widget.date),
                  size: 18,
                  weight: FontWeight.bold,
                  color: wood_smoke,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ..._appts.asMap().entries.map((entry) {
              final i = entry.key;
              final appt = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: wood_smoke, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ContraText(
                      alignment: Alignment.centerLeft,
                      text: 'Dr(a): ${appt.doctor}',
                      size: 16,
                      weight: FontWeight.bold,
                      color: wood_smoke,
                    ),
                    ContraText(
                      alignment: Alignment.centerLeft,
                      text: 'Especialidad: ${appt.specialty}',
                      size: 15,
                      color: trout,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ContraText(
                          alignment: Alignment.centerLeft,
                          text: 'Estado:',
                          size: 15,
                          color: wood_smoke,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            decoration: ShapeDecoration(
                              color: white,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: wood_smoke, width: 2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: appt.status,
                                items: const [
                                  DropdownMenuItem(
                                      value: 'Pendiente',
                                      child: Text('Pendiente')),
                                  DropdownMenuItem(
                                      value: 'Confirmada',
                                      child: Text('Confirmada')),
                                  DropdownMenuItem(
                                      value: 'Cancelada',
                                      child: Text('Cancelada')),
                                  DropdownMenuItem(
                                      value: 'Programada',
                                      child: Text('Programada')),
                                ],
                                onChanged: (val) {
                                  if (val != null) _updateStatus(i, val);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: carribean_green,
                  foregroundColor: white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                onPressed: () {
                  widget.onUpdate(_appts);
                  Navigator.of(context).pop();
                },
                child: const Text('Guardar cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
