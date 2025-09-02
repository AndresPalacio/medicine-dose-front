import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_button.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_text.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/custom_header.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/symptom_models.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/symptom_api_service.dart';
import 'package:vibe_coding_tutorial_weather_app/utils/colors.dart';

class AddSymptomPage extends StatefulWidget {
  final DateTime selectedDate;
  final SymptomEntry? editingEntry;

  const AddSymptomPage({
    super.key,
    required this.selectedDate,
    this.editingEntry,
  });

  @override
  State<AddSymptomPage> createState() => _AddSymptomPageState();
}

class _AddSymptomPageState extends State<AddSymptomPage> {
  final SymptomApiService _symptomService = SymptomApiService();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _notesController;
  late TextEditingController _medicationsController;

  List<Symptom> _selectedSymptoms = [];
  String _selectedSeverity = '';
  String _notes = '';
  String _time = '';
  String _relatedMedications = '';
  String _otherSymptom = '';

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _time = DateFormat('HH:mm').format(DateTime.now());
    _notesController = TextEditingController(text: _notes);
    _medicationsController = TextEditingController(text: _relatedMedications);

    if (widget.editingEntry != null) {
      _loadEditingData();
    }
  }

  void _loadEditingData() {
    final entry = widget.editingEntry!;

    // Cargar síntomas usando la nueva estructura de symptoms
    _selectedSymptoms = entry.symptoms
        .map((symptomData) =>
            SymptomData.getSymptomById(symptomData['id'] as int))
        .where((symptom) => symptom != null)
        .cast<Symptom>()
        .toList();

    _selectedSeverity = entry.severity;
    _notes = entry.notes ?? '';
    _notesController.text = _notes;
    _time = entry.time;

    // relatedMedications ahora es un string, no una lista
    _relatedMedications = entry.relatedMedications ?? '';
    _medicationsController.text = _relatedMedications;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _medicationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: wood_smoke),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: ContraText(
          text: widget.editingEntry != null
              ? 'Editar Síntoma'
              : 'Agregar Síntoma',
          size: 20,
          weight: FontWeight.bold,
          color: wood_smoke,
          alignment: Alignment.center,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomHeader(
                lineOneText: widget.editingEntry != null ? "Editar" : "Nuevo",
                lineTwotext: "Síntoma",
                color: wood_smoke,
                fg_color: wood_smoke,
                bg_color: athens_gray,
              ),
              const SizedBox(height: 24),

              // Fecha
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: athens_gray,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: wood_smoke, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: wood_smoke),
                    const SizedBox(width: 12),
                    ContraText(
                      text: DateFormat('EEEE, d MMMM yyyy', 'es_ES')
                          .format(widget.selectedDate),
                      size: 16,
                      color: wood_smoke,
                      weight: FontWeight.w500,
                      alignment: Alignment.centerLeft,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Selector de síntoma
              _buildSymptomSelector(),
              const SizedBox(height: 24),

              // Selector de severidad
              if (_selectedSymptoms.isNotEmpty) ...[
                _buildSeveritySelector(),
                const SizedBox(height: 24),
              ],

              // Hora
              _buildTimeSelector(),
              const SizedBox(height: 24),

              // Notas
              _buildNotesField(),
              const SizedBox(height: 24),

              // Medicamentos relacionados
              _buildMedicationsField(),
              const SizedBox(height: 32),

              // Botón de guardar
              _buildSaveButton(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSymptomSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ContraText(
          text: 'Síntomas',
          size: 16,
          weight: FontWeight.bold,
          color: wood_smoke,
          alignment: Alignment.centerLeft,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: athens_gray,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: wood_smoke, width: 2),
          ),
          child: ExpansionTile(
            title: ContraText(
              text: _selectedSymptoms.isEmpty
                  ? 'Seleccionar síntomas'
                  : '${_selectedSymptoms.length} síntoma${_selectedSymptoms.length > 1 ? 's' : ''} seleccionado${_selectedSymptoms.length > 1 ? 's' : ''}',
              size: 16,
              color: _selectedSymptoms.isNotEmpty ? wood_smoke : trout,
              alignment: Alignment.centerLeft,
            ),
            leading: _selectedSymptoms.isNotEmpty
                ? Icon(Icons.health_and_safety, color: wood_smoke)
                : const Icon(Icons.health_and_safety, color: trout),
            children: [
              ...SymptomData.categories
                  .map((category) => _buildCategorySection(category)),
              _buildOtherSymptomOption(),
            ],
          ),
        ),
        // Mostrar síntomas seleccionados
        if (_selectedSymptoms.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedSymptoms
                .map((symptom) => Chip(
                      backgroundColor: wood_smoke,
                      label: ContraText(
                        text: symptom.name,
                        size: 12,
                        color: white,
                        alignment: Alignment.center,
                      ),
                      deleteIcon:
                          const Icon(Icons.close, size: 16, color: white),
                      onDeleted: () {
                        setState(() {
                          _selectedSymptoms.remove(symptom);
                        });
                      },
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildCategorySection(SymptomCategory category) {
    final symptoms = SymptomData.getSymptomsByCategory(category.id);

    return ExpansionTile(
      title: Row(
        children: [
          Icon(category.icon, color: category.color, size: 20),
          const SizedBox(width: 8),
          ContraText(
            text: category.name,
            size: 14,
            weight: FontWeight.w500,
            color: wood_smoke,
            alignment: Alignment.centerLeft,
          ),
        ],
      ),
      children:
          symptoms.map((symptom) => _buildSymptomOption(symptom)).toList(),
    );
  }

  Widget _buildSymptomOption(Symptom symptom) {
    final isSelected = _selectedSymptoms.any((s) => s.id == symptom.id);

    return ListTile(
      leading: Icon(symptom.icon,
          color: isSelected ? lightening_yellow : wood_smoke),
      title: ContraText(
        text: symptom.name,
        size: 14,
        color: isSelected ? lightening_yellow : wood_smoke,
        alignment: Alignment.centerLeft,
      ),
      subtitle: ContraText(
        text: symptom.description,
        size: 12,
        color: trout,
        alignment: Alignment.centerLeft,
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: lightening_yellow)
          : null,
      selected: isSelected,
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedSymptoms.removeWhere((s) => s.id == symptom.id);
          } else {
            _selectedSymptoms.add(symptom);
          }
          _selectedSeverity = ''; // Reset severity when symptoms change
        });
      },
    );
  }

  Widget _buildOtherSymptomOption() {
    return ExpansionTile(
      title: Row(
        children: [
          const Icon(Icons.add_circle_outline, color: wood_smoke, size: 20),
          const SizedBox(width: 8),
          const ContraText(
            text: 'Otro',
            size: 14,
            weight: FontWeight.w500,
            color: wood_smoke,
            alignment: Alignment.centerLeft,
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: athens_gray,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: wood_smoke, width: 2),
                ),
                child: TextField(
                  style: const TextStyle(
                    color: wood_smoke,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Escribir síntoma personalizado...',
                    hintStyle: TextStyle(
                      color: trout,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _otherSymptom = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ContraButton(
                  text: 'Agregar',
                  iconPath: 'assets/icons/ic_add.svg',
                  callback: _otherSymptom.isNotEmpty
                      ? () {
                          setState(() {
                            // Crear un síntoma personalizado
                            final customSymptom = Symptom(
                              id: DateTime.now().millisecondsSinceEpoch,
                              name: _otherSymptom,
                              description: 'Síntoma personalizado',
                              category: 'personalizado',
                              icon: Icons.medical_services,
                              severityLevels: ['Leve', 'Moderado', 'Severo'],
                            );
                            _selectedSymptoms.add(customSymptom);
                            _otherSymptom = '';
                          });
                        }
                      : () {},
                  color: _otherSymptom.isNotEmpty
                      ? lightening_yellow
                      : athens_gray,
                  textColor: _otherSymptom.isNotEmpty ? wood_smoke : trout,
                  borderColor: wood_smoke,
                  shadowColor: athens_gray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeveritySelector() {
    // Usar los niveles de severidad del primer síntoma seleccionado
    final severityLevels = _selectedSymptoms.isNotEmpty
        ? _selectedSymptoms.first.severityLevels
        : ['Leve', 'Moderado', 'Severo'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ContraText(
          text: 'Severidad',
          size: 16,
          weight: FontWeight.bold,
          color: wood_smoke,
          alignment: Alignment.centerLeft,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: athens_gray,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: wood_smoke, width: 2),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedSeverity.isEmpty ? null : _selectedSeverity,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            hint: const ContraText(
              text: 'Seleccionar severidad',
              size: 16,
              color: trout,
              alignment: Alignment.centerLeft,
            ),
            dropdownColor: white,
            icon: const Icon(Icons.arrow_drop_down, color: wood_smoke),
            style: const TextStyle(color: wood_smoke),
            items: severityLevels.map((severity) {
              return DropdownMenuItem(
                value: severity,
                child: ContraText(
                  text: severity,
                  size: 16,
                  color: wood_smoke,
                  alignment: Alignment.centerLeft,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSeverity = value ?? '';
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor selecciona la severidad';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ContraText(
          text: 'Hora',
          size: 16,
          weight: FontWeight.bold,
          color: wood_smoke,
          alignment: Alignment.centerLeft,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectTime,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: athens_gray,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: wood_smoke, width: 2),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: wood_smoke),
                const SizedBox(width: 12),
                ContraText(
                  text: _time,
                  size: 16,
                  color: wood_smoke,
                  weight: FontWeight.w500,
                  alignment: Alignment.centerLeft,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ContraText(
          text: 'Notas (opcional)',
          size: 16,
          weight: FontWeight.bold,
          color: wood_smoke,
          alignment: Alignment.centerLeft,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: athens_gray,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: wood_smoke, width: 2),
          ),
          child: TextField(
            controller: _notesController,
            style: const TextStyle(
              color: wood_smoke,
              fontSize: 16,
            ),
            decoration: const InputDecoration(
              hintText: 'Describe cómo te sientes...',
              hintStyle: TextStyle(
                color: trout,
                fontSize: 16,
              ),
              border: InputBorder.none,
            ),
            maxLines: 3,
            onChanged: (value) {
              setState(() {
                _notes = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ContraText(
          text: 'Medicamentos relacionados (opcional)',
          size: 16,
          weight: FontWeight.bold,
          color: wood_smoke,
          alignment: Alignment.centerLeft,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: athens_gray,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: wood_smoke, width: 2),
          ),
          child: TextField(
            controller: _medicationsController,
            style: const TextStyle(
              color: wood_smoke,
              fontSize: 16,
            ),
            decoration: const InputDecoration(
              hintText: 'Escribir medicamentos o tratamientos...',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
              border: InputBorder.none,
            ),
            maxLines: 3,
            textAlign: TextAlign.left,
            onChanged: (value) {
              setState(() {
                _relatedMedications = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ContraButton(
      text: widget.editingEntry != null ? 'Actualizar' : 'Guardar',
      iconPath: 'assets/icons/ic_add.svg',
      callback: _saveSymptom,
      color: lightening_yellow,
      textColor: wood_smoke,
      borderColor: wood_smoke,
      shadowColor: athens_gray,
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateFormat('HH:mm').parse(_time)),
    );

    if (picked != null) {
      setState(() {
        _time =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _saveSymptom() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona al menos un síntoma'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Crear arrays de síntomas con la nueva estructura
      final symptomNames = _selectedSymptoms.map((s) => s.name).toList();
      final symptoms = _selectedSymptoms
          .map((s) => {
                'id': s.id,
                'category': s.category,
                'name': s.name,
              })
          .toList();

      // relatedMedications ya es un string, solo verificar si está vacío
      final medicationsString = _relatedMedications.trim().isEmpty
          ? null
          : _relatedMedications.trim();

      final entry = SymptomEntry(
        id: widget.editingEntry?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        symptoms: symptoms,
        symptomNames: symptomNames,
        severity: _selectedSeverity,
        notes: _notes.isEmpty ? null : _notes,
        date: widget.selectedDate,
        time: _time,
        relatedMedications: medicationsString,
      );

      // DEBUG: Log del modelo antes de guardar
      print('DEBUG _saveSymptom → Modelo a guardar:');
      print('  - ID: ${entry.id}');
      print('  - Symptoms: ${entry.symptoms}');
      print('  - SymptomNames: ${entry.symptomNames}');
      print('  - Severity: ${entry.severity}');
      print('  - Notes: ${entry.notes}');
      print('  - Date: ${entry.date}');
      print('  - Time: ${entry.time}');
      print('  - RelatedMedications: ${entry.relatedMedications}');
      print('  - JSON completo: ${entry.toJson()}');

      bool success;
      if (widget.editingEntry != null) {
        success = await _symptomService.updateSymptomEntry(entry);
      } else {
        success = await _symptomService.addSymptomEntry(entry);
      }

      if (success) {
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.editingEntry != null
                  ? 'Síntoma actualizado correctamente'
                  : 'Síntoma guardado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Error al guardar el síntoma');
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
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
}
