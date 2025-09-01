import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_button.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_text.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/custom_header.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/symptom_models.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/symptom_service.dart';
import 'package:vibe_coding_tutorial_weather_app/utils/colors.dart';

class AddFoodPage extends StatefulWidget {
  final DateTime selectedDate;
  final FoodEntry? editingEntry;

  const AddFoodPage({
    super.key,
    required this.selectedDate,
    this.editingEntry,
  });

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  final SymptomService _symptomService = SymptomService();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _portionController;

  String _selectedMealType = '';
  String _foodName = '';
  String _description = '';
  String _time = '';
  String _portion = '';
  List<String> _ingredients = [];
  bool _causedDiscomfort = false;
  String _discomfortNotes = '';

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _time = DateFormat('HH:mm').format(DateTime.now());
    _descriptionController = TextEditingController(text: _description);
    _portionController = TextEditingController(text: _portion);

    if (widget.editingEntry != null) {
      _loadEditingData();
    }
  }

  void _loadEditingData() {
    final entry = widget.editingEntry!;
    _selectedMealType = entry.mealType;
    _foodName = entry.foodName;
    _description = entry.description ?? '';
    _descriptionController.text = _description;
    _time = entry.time;
    _portion = entry.portion ?? '';
    _portionController.text = _portion;
    _ingredients = entry.ingredients ?? [];
    _causedDiscomfort = entry.causedDiscomfort ?? false;
    _discomfortNotes = entry.discomfortNotes ?? '';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _portionController.dispose();
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
          text:
              widget.editingEntry != null ? 'Editar Comida' : 'Agregar Comida',
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
                lineTwotext: "Comida",
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

              // Tipo de comida
              _buildMealTypeSelector(),
              const SizedBox(height: 24),

              // Nombre del alimento
              _buildFoodNameField(),
              const SizedBox(height: 24),

              // Descripción
              _buildDescriptionField(),
              const SizedBox(height: 24),

              // Hora
              _buildTimeSelector(),
              const SizedBox(height: 24),

              // Porción
              _buildPortionField(),
              const SizedBox(height: 24),

              // Ingredientes
              _buildIngredientsField(),
              const SizedBox(height: 24),

              // Causó malestar
              _buildDiscomfortSection(),
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

  Widget _buildMealTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ContraText(
          text: 'Tipo de Comida',
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
            value: _selectedMealType.isEmpty ? null : _selectedMealType,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            hint: const ContraText(
              text: 'Seleccionar tipo de comida',
              size: 16,
              color: trout,
              alignment: Alignment.centerLeft,
            ),
            dropdownColor: white,
            icon: const Icon(Icons.arrow_drop_down, color: wood_smoke),
            style: const TextStyle(color: wood_smoke),
            items: SymptomData.mealTypes.map((mealType) {
              return DropdownMenuItem(
                value: mealType,
                child: ContraText(
                  text: mealType,
                  size: 16,
                  color: wood_smoke,
                  alignment: Alignment.centerLeft,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedMealType = value ?? '';
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor selecciona el tipo de comida';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFoodNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ContraText(
          text: 'Nombre del Alimento',
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
          child: _foodName.isNotEmpty &&
                  !SymptomData.commonFoods.contains(_foodName)
              ? // Mostrar campo de texto editable para alimentos personalizados
              Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: ContraText(
                          text: _foodName,
                          size: 16,
                          color: wood_smoke,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: wood_smoke),
                      onPressed: () => _showCustomFoodDialog(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear, color: wood_smoke),
                      onPressed: () {
                        setState(() {
                          _foodName = '';
                        });
                      },
                    ),
                  ],
                )
              : // Mostrar dropdown para alimentos predefinidos
              DropdownButtonFormField<String>(
                  value: _foodName.isEmpty
                      ? null
                      : (SymptomData.commonFoods.contains(_foodName)
                          ? _foodName
                          : null),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  hint: ContraText(
                    text: _foodName.isEmpty
                        ? 'Seleccionar o escribir alimento'
                        : _foodName,
                    size: 16,
                    color: _foodName.isEmpty ? trout : wood_smoke,
                    alignment: Alignment.centerLeft,
                  ),
                  dropdownColor: white,
                  icon: const Icon(Icons.arrow_drop_down, color: wood_smoke),
                  style: const TextStyle(color: wood_smoke),
                  items: [
                    ...SymptomData.commonFoods.map((food) {
                      return DropdownMenuItem(
                        value: food,
                        child: ContraText(
                          text: food,
                          size: 16,
                          color: wood_smoke,
                          alignment: Alignment.centerLeft,
                        ),
                      );
                    }),
                    const DropdownMenuItem(
                      value: 'custom',
                      child: ContraText(
                        text: 'Otro (escribir)',
                        size: 16,
                        color: wood_smoke,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      if (value == 'custom') {
                        _showCustomFoodDialog();
                      } else {
                        _foodName = value ?? '';
                      }
                    });
                  },
                  validator: (value) {
                    if (_foodName.isEmpty) {
                      return 'Por favor selecciona o escribe el alimento';
                    }
                    return null;
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ContraText(
          text: 'Descripción (opcional)',
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
            controller: _descriptionController,
            style: const TextStyle(
              color: wood_smoke,
              fontSize: 16,
            ),
            decoration: const InputDecoration(
              hintText: 'Describe la preparación, condimentos, etc...',
              hintStyle: TextStyle(
                color: trout,
                fontSize: 16,
              ),
              border: InputBorder.none,
            ),
            maxLines: 3,
            onChanged: (value) {
              setState(() {
                _description = value;
              });
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

  Widget _buildPortionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ContraText(
          text: 'Porción (opcional)',
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
            controller: _portionController,
            style: const TextStyle(
              color: wood_smoke,
              fontSize: 16,
            ),
            decoration: const InputDecoration(
              hintText: 'Ej: 1 taza, 200g, 1 porción...',
              hintStyle: TextStyle(
                color: trout,
                fontSize: 16,
              ),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              setState(() {
                _portion = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ContraText(
          text: 'Ingredientes (opcional)',
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
          child: Column(
            children: [
              TextField(
                style: const TextStyle(color: wood_smoke),
                decoration: const InputDecoration(
                  hintText: 'Agregar ingrediente...',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: trout,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty && !_ingredients.contains(value)) {
                    setState(() {
                      _ingredients.add(value);
                    });
                  }
                },
              ),
              if (_ingredients.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _ingredients
                      .map((ingredient) => Chip(
                            label: ContraText(
                              text: ingredient,
                              size: 12,
                              color: wood_smoke,
                              alignment: Alignment.center,
                            ),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() {
                                _ingredients.remove(ingredient);
                              });
                            },
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiscomfortSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ContraText(
          text: 'Malestar',
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: _causedDiscomfort ? lightening_yellow : white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _causedDiscomfort
                              ? lightening_yellow
                              : wood_smoke,
                          width: 2,
                        ),
                      ),
                      child: Checkbox(
                        value: _causedDiscomfort,
                        onChanged: (value) {
                          setState(() {
                            _causedDiscomfort = value ?? false;
                            if (!value!) {
                              _discomfortNotes = '';
                            }
                          });
                          if (value == true) {
                            _showDiscomfortDialog();
                          }
                        },
                        activeColor: lightening_yellow,
                        checkColor: wood_smoke,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _causedDiscomfort = !_causedDiscomfort;
                            if (!_causedDiscomfort) {
                              _discomfortNotes = '';
                            }
                          });
                          if (_causedDiscomfort) {
                            _showDiscomfortDialog();
                          }
                        },
                        child: const ContraText(
                          text: '¿Esta comida causó malestar?',
                          size: 16,
                          weight: FontWeight.w500,
                          color: wood_smoke,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_causedDiscomfort && _discomfortNotes.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: wood_smoke, width: 1),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ContraText(
                            text: _discomfortNotes,
                            size: 14,
                            color: wood_smoke,
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: wood_smoke, size: 20),
                          onPressed: () => _showDiscomfortDialog(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear,
                              color: wood_smoke, size: 20),
                          onPressed: () {
                            setState(() {
                              _discomfortNotes = '';
                              _causedDiscomfort = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ContraButton(
      text: widget.editingEntry != null ? 'Actualizar' : 'Guardar',
      iconPath: 'assets/icons/ic_add.svg',
      callback: _saveFood,
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

  void _showDiscomfortDialog() {
    final TextEditingController controller =
        TextEditingController(text: _discomfortNotes);
    bool hasText = _discomfortNotes.isNotEmpty;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const ContraText(
            text: 'Describir Malestar',
            size: 18,
            weight: FontWeight.bold,
            color: wood_smoke,
            alignment: Alignment.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: athens_gray,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: wood_smoke, width: 2),
                ),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  maxLines: 4,
                  style: const TextStyle(
                    color: wood_smoke,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Describe el malestar que causó esta comida...',
                    hintStyle: TextStyle(
                      color: trout,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    setDialogState(() {
                      hasText = value.trim().isNotEmpty;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ContraButton(
                      text: 'Cancelar',
                      iconPath: 'assets/icons/ic_add.svg',
                      callback: () {
                        Navigator.of(context).pop();
                      },
                      color: athens_gray,
                      textColor: wood_smoke,
                      borderColor: wood_smoke,
                      shadowColor: athens_gray,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ContraButton(
                      text: 'Guardar',
                      iconPath: 'assets/icons/ic_add.svg',
                      callback: hasText
                          ? () {
                              final value = controller.text.trim();
                              setState(() {
                                _discomfortNotes = value;
                              });
                              Navigator.of(context).pop();
                            }
                          : () {},
                      color: hasText ? lightening_yellow : athens_gray,
                      textColor: hasText ? wood_smoke : trout,
                      borderColor: wood_smoke,
                      shadowColor: athens_gray,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomFoodDialog() {
    final TextEditingController controller =
        TextEditingController(text: _foodName);
    bool hasText = _foodName.isNotEmpty;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const ContraText(
            text: 'Agregar Alimento Personalizado',
            size: 18,
            weight: FontWeight.bold,
            color: wood_smoke,
            alignment: Alignment.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: athens_gray,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: wood_smoke, width: 2),
                ),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  style: const TextStyle(
                    color: wood_smoke,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Nombre del alimento',
                    hintStyle: TextStyle(
                      color: trout,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    setDialogState(() {
                      hasText = value.trim().isNotEmpty;
                    });
                  },
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      setState(() {
                        _foodName = value.trim();
                      });
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ContraButton(
                      text: 'Cancelar',
                      iconPath: 'assets/icons/ic_add.svg',
                      callback: () {
                        // Reset the food name if user cancels
                        setState(() {
                          _foodName = '';
                        });
                        Navigator.of(context).pop();
                      },
                      color: athens_gray,
                      textColor: wood_smoke,
                      borderColor: wood_smoke,
                      shadowColor: athens_gray,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ContraButton(
                      text: 'Agregar',
                      iconPath: 'assets/icons/ic_add.svg',
                      callback: hasText
                          ? () {
                              final value = controller.text.trim();
                              if (value.isNotEmpty) {
                                setState(() {
                                  _foodName = value;
                                });
                                Navigator.of(context).pop();
                              }
                            }
                          : () {},
                      color: hasText ? lightening_yellow : athens_gray,
                      textColor: hasText ? wood_smoke : trout,
                      borderColor: wood_smoke,
                      shadowColor: athens_gray,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveFood() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final entry = FoodEntry(
        id: widget.editingEntry?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        mealType: _selectedMealType,
        foodName: _foodName,
        description: _description.isEmpty ? null : _description,
        date: widget.selectedDate,
        time: _time,
        ingredients: _ingredients.isEmpty ? null : _ingredients,
        portion: _portion.isEmpty ? null : _portion,
        causedDiscomfort: _causedDiscomfort ? true : null,
        discomfortNotes: _discomfortNotes.isEmpty ? null : _discomfortNotes,
      );

      // DEBUG: Log del modelo antes de guardar
      print('DEBUG _saveFood → Modelo a guardar:');
      print('  - ID: ${entry.id}');
      print('  - MealType: ${entry.mealType}');
      print('  - FoodName: ${entry.foodName}');
      print('  - Description: ${entry.description}');
      print('  - Date: ${entry.date}');
      print('  - Time: ${entry.time}');
      print('  - Ingredients: ${entry.ingredients}');
      print('  - Portion: ${entry.portion}');
      print('  - CausedDiscomfort: ${entry.causedDiscomfort}');
      print('  - DiscomfortNotes: ${entry.discomfortNotes}');
      print('  - JSON completo: ${entry.toJson()}');

      bool success;
      if (widget.editingEntry != null) {
        success = await _symptomService.updateFoodEntry(entry);
      } else {
        success = await _symptomService.addFoodEntry(entry);
      }

      if (success) {
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.editingEntry != null
                  ? 'Comida actualizada correctamente'
                  : 'Comida guardada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Error al guardar la comida');
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
