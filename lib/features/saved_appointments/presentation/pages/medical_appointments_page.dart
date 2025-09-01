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

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Obtener citas del mes actual
      final startDate = DateTime(_currentMonth.year, _currentMonth.month, 1);
      final endDate = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

      final appointments = await _appointmentService.getAppointmentsByDateRange(
          startDate, endDate);

      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar las citas: $e';
        _isLoading = false;
      });
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
          onUpdate: (updated) {
            setState(() {
              for (final appt in updated) {
                final idx = _appointments.indexWhere((a) => a.id == appt.id);
                if (idx != -1) _appointments[idx] = appt;
              }
            });
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
        onDelete: () => setState(() {
          _appointments.removeWhere((a) => a.id == appt.id);
          Navigator.of(context).pop();
        }),
      ),
    );
  }

  void _showEditAppointmentDialog([MedicalAppointment? appt]) {
    showDialog(
      context: context,
      builder: (context) => _MedicalAppointmentEditDialog(
        appointment: appt,
        onSave: (newAppt) {
          setState(() {
            if (appt == null) {
              _appointments.add(newAppt);
            } else {
              final idx = _appointments.indexWhere((a) => a.id == appt.id);
              if (idx != -1) _appointments[idx] = newAppt;
            }
          });
          Navigator.of(context).pop();
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
    final monthString = DateFormat('yyyy-MM').format(_currentMonth);
    final monthAppointments = _appointments
        .where((a) => DateFormat('yyyy-MM').format(a.dateTime) == monthString)
        .toList();
    monthAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return Scaffold(
      backgroundColor: selago,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        title: const ContraText(
          alignment: Alignment.centerLeft,
          text: 'Citas Médicas',
          size: 20,
          weight: FontWeight.bold,
          color: wood_smoke,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: wood_smoke),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: carribean_green,
        child: const Icon(Icons.add, color: white),
        onPressed: () => _showEditAppointmentDialog(),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: selago,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            iconPath: "assets/icons/arrow_forward.svg",
                            callback: () => _navigateToMonth(1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children:
                            ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom']
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
                SizedBox(
                  height: 350,
                  child: monthAppointments.isEmpty
                      ? Center(
                          child: ContraText(
                            alignment: Alignment.center,
                            text: 'No hay citas para este mes',
                            size: 16,
                            color: trout,
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
    _status = appt?.status ?? 'Pendiente';
  }

  @override
  void dispose() {
    _doctorController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  void _save() {
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
                items: const ['Pendiente', 'Confirmada', 'Cancelada'],
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
