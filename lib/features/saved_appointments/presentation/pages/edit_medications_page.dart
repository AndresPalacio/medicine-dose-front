import 'package:flutter/material.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/medication_api_models.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/medication_api_service.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/custom_header.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_text.dart';
import 'package:vibe_coding_tutorial_weather_app/utils/colors.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_input_field.dart';

class EditMedicationsPage extends StatefulWidget {
  const EditMedicationsPage({Key? key}) : super(key: key);

  @override
  State<EditMedicationsPage> createState() => _EditMedicationsPageState();
}

class _EditMedicationsPageState extends State<EditMedicationsPage> {
  final MedicationApiService _apiService = MedicationApiService();
  List<MedicationResponse> _medications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMedications();
  }

  Future<void> _fetchMedications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final meds = await _apiService.getAllMedications();
      setState(() {
        _medications = meds;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar los medicamentos.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteMedication(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: white,
        title: const Text('Confirmar borrado', style: TextStyle(color: wood_smoke)),
        content:
            const Text('¿Estás seguro de que deseas borrar este tratamiento?', style: TextStyle(color: wood_smoke)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: wood_smoke)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar', style: TextStyle(color: carribean_green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _apiService.deleteMedication(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tratamiento borrado correctamente.')),
        );
        _fetchMedications();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error al borrar el tratamiento.'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _editMedication(MedicationResponse medication) async {
    // Navegar a la pantalla de edición (esqueleto)
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMedicationFormPage(medication: medication),
      ),
    );
    _fetchMedications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: athens_gray,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back, color: wood_smoke),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomHeader(
                      lineOneText: "Editar",
                      lineTwotext: "Tratamientos",
                      color: wood_smoke,
                      fg_color: wood_smoke,
                      bg_color: athens_gray,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: ContraText(
                              text: _error!,
                              size: 18,
                              color: trout,
                              alignment: Alignment.center))
                      : Expanded(
                          child: ListView.separated(
                            itemCount: _medications.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final med = _medications[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: white,
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(color: wood_smoke, width: 1.5),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ContraText(
                                            text: med.name,
                                            size: 20,
                                            weight: FontWeight.bold,
                                            color: wood_smoke,
                                            alignment: Alignment.centerLeft,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: moody_blue),
                                          tooltip: 'Editar',
                                          onPressed: () => _editMedication(med),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: alizarin_crimson),
                                          tooltip: 'Borrar',
                                          onPressed: () =>
                                              _deleteMedication(med.id),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ContraText(
                                      text:
                                          'Cantidad total: ${med.totalQuantity}',
                                      size: 16,
                                      color: trout,
                                      alignment: Alignment.centerLeft,
                                    ),
                                    ContraText(
                                      text:
                                          'Frecuencia: cada ${med.frequency} día(s)',
                                      size: 16,
                                      color: trout,
                                      alignment: Alignment.centerLeft,
                                    ),
                                    ContraText(
                                      text:
                                          'Duración: ${med.duration} ${med.durationType.toLowerCase()}',
                                      size: 16,
                                      color: trout,
                                      alignment: Alignment.centerLeft,
                                    ),
                                    ContraText(
                                      text:
                                          'Inicio del medicamento: ${med.startDate.toLocal().toString().split(' ')[0]}',
                                      size: 16,
                                      color: trout,
                                      alignment: Alignment.centerLeft,
                                    ),
                                    ContraText(
                                      text:
                                          'Fin: ${med.endDate.toLocal().toString().split(' ')[0]}',
                                      size: 16,
                                      color: trout,
                                      alignment: Alignment.centerLeft,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}

// Esqueleto del formulario de edición
class EditMedicationFormPage extends StatefulWidget {
  final MedicationResponse medication;
  const EditMedicationFormPage({Key? key, required this.medication})
      : super(key: key);

  @override
  State<EditMedicationFormPage> createState() => _EditMedicationFormPageState();
}

class _EditMedicationFormPageState extends State<EditMedicationFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _totalQuantityController;
  late TextEditingController _frequencyController;
  late TextEditingController _durationController;
  late String _durationType;
  late String _mealTiming;
  late String _timeUnit;
  late TextEditingController _timeBeforeAfterController;
  DateTime? _startDate;
  bool _isSaving = false;
  late TextEditingController _quantityPerDoseController;
  bool _desayuno = false;
  bool _almuerzo = false;
  bool _cena = false;

  final MedicationApiService _apiService = MedicationApiService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication.name);
    _totalQuantityController =
        TextEditingController(text: widget.medication.totalQuantity.toString());
    _frequencyController =
        TextEditingController(text: widget.medication.frequency.toString());
    _durationController =
        TextEditingController(text: widget.medication.duration.toString());
    _durationType = widget.medication.durationType;
    _mealTiming = widget.medication.mealTiming;
    _timeUnit = widget.medication.timeUnit ?? 'MINUTOS';
    _timeBeforeAfterController = TextEditingController(
        text: _getTimeBeforeAfterText(widget.medication.timeBeforeAfter));
    _startDate = widget.medication.startDate;
    _quantityPerDoseController = TextEditingController(
        text: widget.medication.quantityPerDose?.toString() ?? '');
    // Inicializar meals
    final meals = widget.medication.meals ?? [];
    _desayuno = meals.contains('DESAYUNO');
    _almuerzo = meals.contains('ALMUERZO');
    _cena = meals.contains('CENA');
  }

  String _getTimeBeforeAfterText(dynamic timeBeforeAfter) {
    if (timeBeforeAfter == null) return '0';
    if (timeBeforeAfter is int) return timeBeforeAfter.toString();
    if (timeBeforeAfter is String) {
      // Si es "INDIFERENTE" o similar, devolver 0
      if (timeBeforeAfter == 'INDIFERENTE' ||
          timeBeforeAfter == 'EN_AYUNAS' ||
          timeBeforeAfter == 'CON_COMIDA') {
        return '0';
      }
      // Intentar parsear como número
      return int.tryParse(timeBeforeAfter)?.toString() ?? '0';
    }
    return '0';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalQuantityController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();
    _quantityPerDoseController.dispose();
    _timeBeforeAfterController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
    });
    try {
      final List<String> meals = [];
      if (_desayuno) meals.add('DESAYUNO');
      if (_almuerzo) meals.add('ALMUERZO');
      if (_cena) meals.add('CENA');
      final body = {
        'name': _nameController.text,
        'totalQuantity': int.parse(_totalQuantityController.text),
        'quantityPerDose': int.parse(_quantityPerDoseController.text),
        'frequency': int.parse(_frequencyController.text),
        'duration': int.parse(_durationController.text),
        'durationType': _durationType,
        'startDate': _startDate!.toIso8601String().split('T')[0],
        'meals': meals,
        'mealTiming': _mealTiming,
        'timeBeforeAfter': (_mealTiming == 'ANTES' || _mealTiming == 'DESPUES')
            ? int.parse(_timeBeforeAfterController.text)
            : 0,
        'timeUnit': (_mealTiming == 'ANTES' || _mealTiming == 'DESPUES')
            ? _timeUnit
            : 'MINUTOS',
      };
      final response =
          await _apiService.updateMedication(widget.medication.id, body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tratamiento actualizado correctamente.'),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error al actualizar el tratamiento.'),
            backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: athens_gray,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.arrow_back, color: wood_smoke),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ContraText(
                        text: 'Editar Tratamiento',
                        size: 24,
                        weight: FontWeight.bold,
                        color: wood_smoke,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ContraText(
                  text: 'Nombre',
                  size: 18,
                  color: wood_smoke,
                  alignment: Alignment.centerLeft,
                ),
                const SizedBox(height: 8),
                ContraInputField(
                  hintText: 'Nombre del medicamento',
                  controller: _nameController,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                ContraText(
                  text: 'Cantidad total',
                  size: 18,
                  color: wood_smoke,
                  alignment: Alignment.centerLeft,
                ),
                const SizedBox(height: 8),
                ContraInputField(
                  hintText: 'Ej. 20',
                  controller: _totalQuantityController,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                ContraText(
                  text: 'Frecuencia (cada cuántos días)',
                  size: 18,
                  color: wood_smoke,
                  alignment: Alignment.centerLeft,
                ),
                const SizedBox(height: 8),
                ContraInputField(
                  hintText: 'Ej. 1 para diario',
                  controller: _frequencyController,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ContraText(
                            text: 'Duración',
                            size: 18,
                            color: wood_smoke,
                            alignment: Alignment.centerLeft,
                          ),
                          const SizedBox(height: 8),
                          ContraInputField(
                            hintText: 'Ej. 7',
                            controller: _durationController,
                            keyboardType: TextInputType.number,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Campo requerido'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ContraText(
                            text: 'Tipo de duración',
                            size: 18,
                            color: wood_smoke,
                            alignment: Alignment.centerLeft,
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _durationType,
                            items: const [
                              DropdownMenuItem(
                                  value: 'DAYS', child: Text('Días')),
                              DropdownMenuItem(
                                  value: 'WEEKS', child: Text('Semanas')),
                              DropdownMenuItem(
                                  value: 'MONTHS', child: Text('Meses')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _durationType = value!;
                              });
                            },
                            decoration: const InputDecoration(
                                border: OutlineInputBorder()),
                            dropdownColor: white,
                            icon: const Icon(Icons.arrow_drop_down, color: wood_smoke),
                            style: const TextStyle(color: wood_smoke),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ContraText(
                  text: 'Fecha de inicio del medicamento',
                  size: 18,
                  color: wood_smoke,
                  alignment: Alignment.centerLeft,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      locale: const Locale('es', 'ES'),
                    );
                    if (picked != null) {
                      setState(() {
                        _startDate = picked;
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: ContraInputField(
                      hintText: 'Ej. 2024-06-01',
                      controller: TextEditingController(
                          text: _startDate != null
                              ? _startDate!.toString().split(' ')[0]
                              : ''),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Campo requerido'
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ContraText(
                  text: 'Cantidad por toma',
                  size: 18,
                  color: wood_smoke,
                  alignment: Alignment.centerLeft,
                ),
                const SizedBox(height: 8),
                ContraInputField(
                  hintText: 'Ej. 1',
                  controller: _quantityPerDoseController,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                ContraText(
                  text: 'Horarios de toma',
                  size: 18,
                  color: wood_smoke,
                  alignment: Alignment.centerLeft,
                ),
                CheckboxListTile(
                  title: const Text('Desayuno'),
                  value: _desayuno,
                  onChanged: (val) => setState(() => _desayuno = val ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  title: const Text('Almuerzo'),
                  value: _almuerzo,
                  onChanged: (val) => setState(() => _almuerzo = val ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  title: const Text('Cena'),
                  value: _cena,
                  onChanged: (val) => setState(() => _cena = val ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ContraText(
                            text: 'Timing de comida',
                            size: 18,
                            color: wood_smoke,
                            alignment: Alignment.centerLeft,
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _mealTiming,
                            items: const [
                              DropdownMenuItem(
                                  value: 'ANTES', child: Text('Antes')),
                              DropdownMenuItem(
                                  value: 'DESPUES', child: Text('Después')),
                              DropdownMenuItem(
                                  value: 'INDIFERENTE',
                                  child: Text('Indiferente')),
                              DropdownMenuItem(
                                  value: 'EN_AYUNAS', child: Text('En ayunas')),
                              DropdownMenuItem(
                                  value: 'CON_COMIDA',
                                  child: Text('Con comida')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _mealTiming = value!;
                              });
                            },
                            decoration: const InputDecoration(
                                border: OutlineInputBorder()),
                            dropdownColor: white,
                            icon: const Icon(Icons.arrow_drop_down, color: wood_smoke),
                            style: const TextStyle(color: wood_smoke),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ContraText(
                            text: 'Tiempo',
                            size: 18,
                            color: wood_smoke,
                            alignment: Alignment.centerLeft,
                          ),
                          const SizedBox(height: 8),
                          ContraInputField(
                            hintText: 'Ej. 30',
                            controller: _timeBeforeAfterController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (_mealTiming == 'ANTES' ||
                                  _mealTiming == 'DESPUES') {
                                if (value == null || value.isEmpty) {
                                  return 'Campo requerido';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ContraText(
                            text: 'Unidad',
                            size: 18,
                            color: wood_smoke,
                            alignment: Alignment.centerLeft,
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _timeUnit,
                            items: const [
                              DropdownMenuItem(
                                  value: 'MINUTOS', child: Text('Minutos')),
                              DropdownMenuItem(
                                  value: 'HORAS', child: Text('Horas')),
                              DropdownMenuItem(
                                  value: 'DIAS', child: Text('Días')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _timeUnit = value!;
                              });
                            },
                            dropdownColor: white,
                            icon: const Icon(Icons.arrow_drop_down, color: wood_smoke),
                            style: const TextStyle(color: wood_smoke),
                            decoration: const InputDecoration(
                                border: OutlineInputBorder()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: moody_blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Guardar cambios',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
