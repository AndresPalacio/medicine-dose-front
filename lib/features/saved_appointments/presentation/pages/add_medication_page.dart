import 'package:flutter/material.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_button.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_input_field.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_text.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/custom_header.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/medication_model.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/presentation/pages/medication_plan_result_page.dart';
import 'package:vibe_coding_tutorial_weather_app/utils/colors.dart';

class AddMedicationPage extends StatefulWidget {
  const AddMedicationPage({super.key});

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  String _tipoDuracion = 'Días';
  String _unidadRepeticion = 'Días';
  String _mealTiming = 'INDIFERENTE';
  String _timeUnit = 'MINUTOS';
  bool _desayuno = false;
  bool _almuerzo = false;
  bool _cena = false;

  final _nombreController = TextEditingController();
  final _cantidadTotalController = TextEditingController();
  final _cantidadPorTomaController = TextEditingController();
  final _frecuenciaController = TextEditingController();
  final _duracionController = TextEditingController();
  final _cantidadRepeticionesController = TextEditingController();
  final _fechaInicioController = TextEditingController();
  final _timeBeforeAfterController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadTotalController.dispose();
    _cantidadPorTomaController.dispose();
    _frecuenciaController.dispose();
    _duracionController.dispose();
    _cantidadRepeticionesController.dispose();
    _fechaInicioController.dispose();
    _timeBeforeAfterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: athens_gray,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: wood_smoke,
                ),
              ),
              const SizedBox(height: 16),
              CustomHeader(
                lineOneText: "Agregar",
                lineTwotext: "Medicamento",
                color: wood_smoke,
                fg_color: wood_smoke,
                bg_color: athens_gray,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                  label: 'Nombre del Medicamento',
                  hint: 'Ej. Ifaxim',
                  controller: _nombreController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es requerido';
                    }
                    return null;
                  }),
              const SizedBox(height: 16),
              _buildTextField(
                  label: 'Cantidad Total Disponible (Total pastillas a tomar)',
                  hint: 'Ej. 30',
                  keyboardType: TextInputType.number,
                  controller: _cantidadTotalController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es requerido';
                    }
                    return null;
                  }),
              const SizedBox(height: 16),
              _buildTextField(
                  label: 'Cantidad por Toma (Cuantas tomar cada dia)',
                  hint: 'Ej. 1',
                  keyboardType: TextInputType.number,
                  controller: _cantidadPorTomaController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es requerido';
                    }
                    return null;
                  }),
              const SizedBox(height: 16),
              _buildTextField(
                  label: 'Frecuencia (cada cuántos días)',
                  hint: 'Ej. 1 para diario, 2 para día por medio',
                  keyboardType: TextInputType.number,
                  controller: _frecuenciaController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es requerido';
                    }
                    return null;
                  }),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                        label: 'Duración (Cuandos dias tomar el medicamento)',
                        hint: 'Ej. 7',
                        keyboardType: TextInputType.number,
                        controller: _duracionController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Este campo es requerido';
                          }
                          return null;
                        }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField(
                      label:
                          'Tipo de Duración (Tipo de duracion del tratamiento en total)',
                      value: _tipoDuracion,
                      items: ['Días', 'Semanas', 'Meses'],
                      onChanged: (value) {
                        setState(() {
                          _tipoDuracion = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDatePickerField(
                  label: 'Fecha de Inicio del Medicamento', context: context),
              const SizedBox(height: 24),
              const ContraText(
                alignment: Alignment.centerLeft,
                text: 'Horarios de Toma',
                size: 18,
                weight: FontWeight.bold,
              ),
              _buildCheckbox(
                  title: 'Desayuno',
                  value: _desayuno,
                  onChanged: (val) => setState(() => _desayuno = val!)),
              _buildCheckbox(
                  title: 'Almuerzo',
                  value: _almuerzo,
                  onChanged: (val) => setState(() => _almuerzo = val!)),
              _buildCheckbox(
                  title: 'Cena',
                  value: _cena,
                  onChanged: (val) => setState(() => _cena = val!)),
              const SizedBox(height: 24),
              const ContraText(
                alignment: Alignment.centerLeft,
                text: 'Timing de Comidas',
                size: 18,
                weight: FontWeight.bold,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Cuándo tomar',
                      value: _mealTiming,
                      items: [
                        'INDIFERENTE',
                        'ANTES',
                        'DESPUES',
                        'EN_AYUNAS',
                        'CON_COMIDA'
                      ],
                      onChanged: (value) {
                        setState(() {
                          _mealTiming = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                        label: 'Tiempo',
                        hint: 'Ej. 30',
                        keyboardType: TextInputType.number,
                        controller: _timeBeforeAfterController,
                        validator: (value) {
                          if (_mealTiming == 'ANTES' ||
                              _mealTiming == 'DESPUES') {
                            if (value == null || value.isEmpty) {
                              return 'Campo requerido';
                            }
                          }
                          return null;
                        }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Unidad',
                      value: _timeUnit,
                      items: ['MINUTOS', 'HORAS', 'DIAS'],
                      onChanged: (value) {
                        setState(() {
                          _timeUnit = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ContraButton(
                borderColor: wood_smoke,
                shadowColor: wood_smoke,
                color: Colors.green,
                textColor: white,
                text: 'Ver Resumen y Calendario',
                callback: () async {
                  if (_formKey.currentState!.validate()) {
                    final plan = MedicationPlan(
                      // userId: "1", // No se requiere para el backend
                      medicamento: _nombreController.text,
                      cantidadTotal:
                          int.tryParse(_cantidadTotalController.text) ?? 0,
                      cantidadPorToma:
                          int.tryParse(_cantidadPorTomaController.text) ?? 0,
                      frecuenciaDias:
                          int.tryParse(_frecuenciaController.text) ?? 1,
                      duracion: int.tryParse(_duracionController.text) ?? 0,
                      tipoDuracion: _tipoDuracion,
                      unidadRepeticion: _unidadRepeticion,
                      cantidadRepeticiones:
                          int.tryParse(_cantidadRepeticionesController.text) ??
                              0,
                      fechaInicio: _selectedDate ?? DateTime.now(),
                      tomaDesayuno: _desayuno,
                      tomaAlmuerzo: _almuerzo,
                      tomaCena: _cena,
                      mealTiming: _mealTiming,
                      timeBeforeAfter: (_mealTiming == 'ANTES' ||
                              _mealTiming == 'DESPUES')
                          ? (int.tryParse(_timeBeforeAfterController.text) ?? 0)
                          : 0,
                      timeUnit:
                          (_mealTiming == 'ANTES' || _mealTiming == 'DESPUES')
                              ? _timeUnit
                              : 'MINUTOS',
                    );

                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            MedicationPlanResultPage(plan: plan),
                      ),
                    );

                    if (result == true && mounted) {
                      Navigator.of(context).pop(true);
                    }
                  }
                },
                iconPath: '',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required String label,
      required String hint,
      TextInputType? keyboardType,
      TextEditingController? controller,
      FormFieldValidator<String>? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContraText(
          alignment: Alignment.centerLeft,
          text: label,
          size: 18,
          weight: FontWeight.bold,
        ),
        const SizedBox(height: 8),
        ContraInputField(
          hintText: hint,
          keyboardType: keyboardType,
          controller: controller,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField(
      {required String label,
      required String value,
      required List<String> items,
      required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContraText(
          alignment: Alignment.centerLeft,
          text: label,
          size: 18,
          weight: FontWeight.bold,
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

  Widget _buildDatePickerField(
      {required String label, required BuildContext context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContraText(
          alignment: Alignment.centerLeft,
          text: label,
          size: 18,
          weight: FontWeight.bold,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              locale: const Locale('es', 'ES'),
            );
            if (pickedDate != null) {
              setState(() {
                _selectedDate = pickedDate;
                _fechaInicioController.text =
                    "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
              });
            }
          },
          child: AbsorbPointer(
            child: ContraInputField(
              hintText: 'Ej. 2025-06-22',
              controller: _fechaInicioController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Este campo es requerido';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox(
      {required String title,
      required bool value,
      required ValueChanged<bool?> onChanged}) {
    return CheckboxListTile(
      title: ContraText(
        text: title,
        size: 16,
        alignment: Alignment.centerLeft,
        weight: FontWeight.normal,
      ),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: lightening_yellow,
      checkColor: wood_smoke,
      contentPadding: EdgeInsets.zero,
    );
  }
}
