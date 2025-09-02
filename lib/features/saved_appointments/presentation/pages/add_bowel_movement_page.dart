import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_button.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_text.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/custom_header.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/symptom_models.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/symptom_api_service.dart';
import 'package:vibe_coding_tutorial_weather_app/utils/colors.dart';

class AddBowelMovementPage extends StatefulWidget {
  final DateTime selectedDate;
  final BowelMovementEntry? editingEntry;

  const AddBowelMovementPage({
    super.key,
    required this.selectedDate,
    this.editingEntry,
  });

  @override
  State<AddBowelMovementPage> createState() => _AddBowelMovementPageState();
}

class _AddBowelMovementPageState extends State<AddBowelMovementPage> {
  final SymptomApiService _symptomService = SymptomApiService();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _notesController;

  String _selectedConsistency = '';
  String _selectedColor = '';
  String _time = '';
  String _notes = '';
  bool _hasBlood = false;
  bool _hasMucus = false;
  bool _wasPainful = false;
  String _painLevel = '';

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _time = DateFormat('HH:mm').format(DateTime.now());
    _notesController = TextEditingController(text: _notes);

    if (widget.editingEntry != null) {
      _loadEditingData();
    }
  }

  void _loadEditingData() {
    final entry = widget.editingEntry!;

    // DEBUG: Log de los valores que vienen del backend
    print('DEBUG _loadEditingData → Valores del backend:');
    print('  - Color original: ${entry.color}');
    print('  - Consistencia original: ${entry.consistency}');
    print('  - HasBlood original: ${entry.hasBlood}');
    print('  - HasMucus original: ${entry.hasMucus}');
    print('  - WasPainful original: ${entry.wasPainful}');
    print('  - PainLevel original: ${entry.painLevel}');
    print('  - JSON completo: ${entry.toJson()}');

    _selectedConsistency = entry.consistency;
    _selectedColor = SymptomData.getStoolColorDisplayName(entry.color);

    // DEBUG: Log de los valores convertidos
    print('DEBUG _loadEditingData → Valores convertidos:');
    print('  - Color convertido: $_selectedColor');
    print('  - Consistencia: $_selectedConsistency');

    _time = entry.time;
    _notes = entry.notes ?? '';
    _notesController.text = _notes;
    _hasBlood = entry.hasBlood ?? false;
    _hasMucus = entry.hasMucus ?? false;
    _wasPainful = entry.wasPainful ?? false;
    _painLevel = entry.painLevel ?? '';

    // DEBUG: Log de los valores finales del estado
    print('DEBUG _loadEditingData → Estado final:');
    print('  - _hasBlood: $_hasBlood');
    print('  - _hasMucus: $_hasMucus');
    print('  - _wasPainful: $_wasPainful');
    print('  - _painLevel: $_painLevel');
  }

  @override
  void dispose() {
    _notesController.dispose();
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
              ? 'Editar Deposición'
              : 'Agregar Deposición',
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
                lineOneText: widget.editingEntry != null ? "Editar" : "Nueva",
                lineTwotext: "Deposición",
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

              // Hora
              _buildTimeSelector(),
              const SizedBox(height: 24),

              // Consistencia (Escala de Bristol)
              _buildConsistencySelector(),
              const SizedBox(height: 24),

              // Color
              _buildColorSelector(),
              const SizedBox(height: 24),

              // Características especiales
              _buildSpecialCharacteristics(),
              const SizedBox(height: 24),

              // Dolor
              _buildPainSection(),
              const SizedBox(height: 24),

              // Notas
              _buildNotesField(),
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

  Widget _buildConsistencySelector() {
    // Validar que la consistencia seleccionada esté en la lista disponible
    String? validConsistency =
        _selectedConsistency.isEmpty ? null : _selectedConsistency;
    if (validConsistency != null &&
        !SymptomData.bristolStoolScale
            .any((stool) => stool['type'] == validConsistency)) {
      validConsistency = 'Tipo 4'; // Valor por defecto seguro
      _selectedConsistency = validConsistency;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ContraText(
          text: 'Consistencia (Escala de Bristol)',
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
            value: validConsistency,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            hint: const ContraText(
              text: 'Seleccionar consistencia',
              size: 16,
              color: trout,
              alignment: Alignment.centerLeft,
            ),
            dropdownColor: white,
            icon: const Icon(Icons.arrow_drop_down, color: wood_smoke),
            style: const TextStyle(color: wood_smoke),
            items: SymptomData.bristolStoolScale.map((stool) {
              return DropdownMenuItem<String>(
                value: stool['type'] as String,
                child: ContraText(
                  text: '${stool['type']} - ${stool['description']}',
                  size: 16,
                  color: wood_smoke,
                  alignment: Alignment.centerLeft,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedConsistency = value ?? '';
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor selecciona la consistencia';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    // Validar que el color seleccionado esté en la lista de colores disponibles
    String? validColor = _selectedColor.isEmpty ? null : _selectedColor;
    if (validColor != null && !SymptomData.stoolColors.contains(validColor)) {
      validColor = 'Marrón normal'; // Valor por defecto seguro
      _selectedColor = validColor;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ContraText(
          text: 'Color',
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
            value: validColor,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            hint: const ContraText(
              text: 'Seleccionar color',
              size: 16,
              color: trout,
              alignment: Alignment.centerLeft,
            ),
            dropdownColor: white,
            icon: const Icon(Icons.arrow_drop_down, color: wood_smoke),
            style: const TextStyle(color: wood_smoke),
            items: SymptomData.stoolColors.map((color) {
              return DropdownMenuItem(
                value: color,
                child: ContraText(
                  text: color,
                  size: 16,
                  color: wood_smoke,
                  alignment: Alignment.centerLeft,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedColor = value ?? '';
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor selecciona el color';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialCharacteristics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ContraText(
          text: 'Características Especiales',
          size: 16,
          weight: FontWeight.bold,
          color: wood_smoke,
          alignment: Alignment.centerLeft,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: athens_gray,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: wood_smoke, width: 2),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _hasBlood,
                    onChanged: (value) {
                      setState(() {
                        _hasBlood = value ?? false;
                      });
                    },
                    activeColor: Colors.red,
                    checkColor: Colors.white,
                    side: const BorderSide(color: wood_smoke, width: 2),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const Expanded(
                    child: ContraText(
                      text: 'Presencia de sangre',
                      size: 16,
                      color: wood_smoke,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _hasMucus,
                    onChanged: (value) {
                      setState(() {
                        _hasMucus = value ?? false;
                      });
                    },
                    activeColor: Colors.blue,
                    checkColor: Colors.white,
                    side: const BorderSide(color: wood_smoke, width: 2),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const Expanded(
                    child: ContraText(
                      text: 'Presencia de moco',
                      size: 16,
                      color: wood_smoke,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPainSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: athens_gray,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: wood_smoke, width: 2),
          ),
          child: Row(
            children: [
              Checkbox(
                value: _wasPainful,
                onChanged: (value) {
                  setState(() {
                    _wasPainful = value ?? false;
                  });
                },
                activeColor: lightening_yellow,
                checkColor: wood_smoke,
                side: const BorderSide(color: wood_smoke, width: 2),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const Expanded(
                child: ContraText(
                  text: '¿Fue doloroso?',
                  size: 16,
                  weight: FontWeight.bold,
                  color: wood_smoke,
                  alignment: Alignment.centerLeft,
                ),
              ),
            ],
          ),
        ),
        if (_wasPainful) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: athens_gray,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: wood_smoke, width: 2),
            ),
            child: DropdownButtonFormField<String>(
              value: _painLevel.isEmpty ? null : _painLevel,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              hint: const ContraText(
                text: 'Seleccionar nivel de dolor',
                size: 16,
                color: trout,
                alignment: Alignment.centerLeft,
              ),
              dropdownColor: white,
              icon: const Icon(Icons.arrow_drop_down, color: wood_smoke),
              style: const TextStyle(color: wood_smoke),
              items: ['Leve', 'Moderado', 'Intenso', 'Severo'].map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: ContraText(
                    text: level,
                    size: 16,
                    color: wood_smoke,
                    alignment: Alignment.centerLeft,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _painLevel = value ?? '';
                });
              },
              validator: (value) {
                if (_wasPainful && (value == null || value.isEmpty)) {
                  return 'Por favor selecciona el nivel de dolor';
                }
                return null;
              },
            ),
          ),
        ],
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
              hintText: 'Observaciones adicionales...',
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

  Widget _buildSaveButton() {
    return ContraButton(
      text: widget.editingEntry != null ? 'Actualizar' : 'Guardar',
      iconPath: 'assets/icons/ic_add.svg',
      callback: _saveBowelMovement,
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

  Future<void> _saveBowelMovement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final entry = BowelMovementEntry(
        id: widget.editingEntry?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        date: widget.selectedDate,
        time: _time,
        consistency: _selectedConsistency,
        color: SymptomData.getStoolColorBackendValue(_selectedColor),
        hasBlood: _hasBlood ? true : null,
        hasMucus: _hasMucus ? true : null,
        notes: _notes.isEmpty ? null : _notes,
        wasPainful: _wasPainful ? true : null,
        painLevel: _painLevel.isEmpty ? null : _painLevel,
      );

      // DEBUG: Log del modelo antes de guardar
      print('DEBUG _saveBowelMovement → Modelo a guardar:');
      print('  - ID: ${entry.id}');
      print('  - Date: ${entry.date}');
      print('  - Time: ${entry.time}');
      print('  - Consistency: ${entry.consistency}');
      print('  - Color: ${entry.color}');
      print('  - HasBlood: ${entry.hasBlood}');
      print('  - HasMucus: ${entry.hasMucus}');
      print('  - Notes: ${entry.notes}');
      print('  - WasPainful: ${entry.wasPainful}');
      print('  - PainLevel: ${entry.painLevel}');
      print('  - JSON completo: ${entry.toJson()}');

      bool success;
      if (widget.editingEntry != null) {
        success = await _symptomService.updateBowelMovementEntry(entry);
      } else {
        success = await _symptomService.addBowelMovementEntry(entry);
      }

      if (success) {
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.editingEntry != null
                  ? 'Deposición actualizada correctamente'
                  : 'Deposición guardada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Error al guardar la deposición');
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
