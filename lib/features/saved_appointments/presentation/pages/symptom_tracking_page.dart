import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_button.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_text.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/custom_header.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/symptom_models.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/symptom_api_service.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/presentation/pages/add_symptom_page.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/presentation/pages/add_food_page.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/presentation/pages/add_bowel_movement_page.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/presentation/pages/symptom_history_page.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/presentation/pages/symptom_report_page.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/presentation/widgets/symptom_entry_card.dart';
import 'package:vibe_coding_tutorial_weather_app/utils/colors.dart';

class SymptomTrackingPage extends StatefulWidget {
  const SymptomTrackingPage({super.key});

  @override
  State<SymptomTrackingPage> createState() => _SymptomTrackingPageState();
}

class _SymptomTrackingPageState extends State<SymptomTrackingPage>
    with SingleTickerProviderStateMixin {
  final SymptomApiService _symptomService = SymptomApiService();
  late DateTime _selectedDate;
  List<SymptomEntry> _todaySymptoms = [];
  List<FoodEntry> _todayFoods = [];
  List<BowelMovementEntry> _todayBowelMovements = [];
  bool _isLoading = true;
  String? _error;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _tabController = TabController(length: 3, vsync: this);
    _loadTodayData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTodayData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final symptoms =
          await _symptomService.getSymptomEntriesByDate(_selectedDate);
      final foods = await _symptomService.getFoodEntriesByDate(_selectedDate);
      final bowelMovements =
          await _symptomService.getBowelMovementEntriesByDate(_selectedDate);

      setState(() {
        _todaySymptoms = symptoms;
        _todayFoods = foods;
        _todayBowelMovements = bowelMovements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar los datos: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addSymptom() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSymptomPage(selectedDate: _selectedDate),
      ),
    );

    if (result == true) {
      _loadTodayData();
    }
  }

  Future<void> _addFood() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFoodPage(selectedDate: _selectedDate),
      ),
    );

    if (result == true) {
      _loadTodayData();
    }
  }

  Future<void> _addBowelMovement() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBowelMovementPage(selectedDate: _selectedDate),
      ),
    );

    if (result == true) {
      _loadTodayData();
    }
  }

  Future<void> _viewHistory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SymptomHistoryPage(),
      ),
    );
  }

  Future<void> _generateReport() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SymptomReportPage(),
      ),
    );
  }

  Future<void> _testLoadData() async {
    setState(() {
      _selectedDate = DateTime.parse('2025-08-31');
    });
    await _loadTodayData();
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
        title: const ContraText(
          text: 'Tracking de Salud',
          size: 20,
          weight: FontWeight.bold,
          color: wood_smoke,
          alignment: Alignment.center,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: wood_smoke),
            onPressed: _viewHistory,
            tooltip: 'Ver historial',
          ),
          IconButton(
            icon: const Icon(Icons.assessment, color: wood_smoke),
            onPressed: _generateReport,
            tooltip: 'Generar reporte',
          ),
          IconButton(
            icon: const Icon(Icons.bug_report, color: wood_smoke),
            onPressed: _testLoadData,
            tooltip: 'Probar carga de datos',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: wood_smoke,
          unselectedLabelColor: trout,
          indicatorColor: lightening_yellow,
          tabs: const [
            Tab(
              icon: Icon(Icons.health_and_safety),
              text: 'Síntomas',
            ),
            Tab(
              icon: Icon(Icons.restaurant),
              text: 'Alimentación',
            ),
            Tab(
              icon: Icon(Icons.wc),
              text: 'Deposiciones',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Selector de fecha
          Container(
            margin: const EdgeInsets.all(20),
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
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: ContraText(
                      text: DateFormat('EEEE, d MMMM yyyy', 'es_ES')
                          .format(_selectedDate),
                      size: 16,
                      color: wood_smoke,
                      weight: FontWeight.w500,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: wood_smoke),
                  onPressed: _selectDate,
                ),
              ],
            ),
          ),

          // Estadísticas rápidas
          _buildQuickStats(),

          // Contenido de las pestañas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSymptomsTab(),
                _buildFoodTab(),
                _buildBowelMovementsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          switch (_tabController.index) {
            case 0:
              _addSymptom();
              break;
            case 1:
              _addFood();
              break;
            case 2:
              _addBowelMovement();
              break;
          }
        },
        backgroundColor: lightening_yellow,
        child: const Icon(Icons.add, color: wood_smoke, size: 28),
      ),
    );
  }

  Widget _buildQuickStats() {
    final totalSymptoms = _todaySymptoms.length;
    final totalFoods = _todayFoods.length;
    final totalBowelMovements = _todayBowelMovements.length;
    final severeSymptoms = _todaySymptoms
        .where((e) =>
            e.severity.contains('Intenso') ||
            e.severity.contains('Severa') ||
            e.severity.contains('Alta') ||
            e.severity.contains('Extrema'))
        .length;
    final problematicFoods =
        _todayFoods.where((e) => e.causedDiscomfort == true).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: athens_gray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: wood_smoke, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ContraText(
            text: 'Resumen del Día',
            size: 18,
            weight: FontWeight.bold,
            color: wood_smoke,
            alignment: Alignment.centerLeft,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Síntomas',
                  totalSymptoms.toString(),
                  Icons.health_and_safety,
                  Colors.blue,
                  subtitle: '$severeSymptoms graves',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Comidas',
                  totalFoods.toString(),
                  Icons.restaurant,
                  Colors.orange,
                  subtitle: '$problematicFoods problemáticas',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Deposiciones',
                  totalBowelMovements.toString(),
                  Icons.wc,
                  Colors.brown,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: wood_smoke, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          ContraText(
            text: value,
            size: 16,
            weight: FontWeight.bold,
            color: wood_smoke,
            alignment: Alignment.center,
          ),
          ContraText(
            text: title,
            size: 10,
            color: trout,
            alignment: Alignment.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            ContraText(
              text: subtitle,
              size: 8,
              color: trout,
              alignment: Alignment.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSymptomsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: ContraText(
            text: _error!,
            size: 16,
            color: trout,
            alignment: Alignment.center,
          ),
        ),
      );
    }

    if (_todaySymptoms.isEmpty) {
      return _buildEmptyState(
        Icons.health_and_safety,
        'No hay síntomas registrados',
        'Toca el botón + para agregar un síntoma',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _todaySymptoms.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = _todaySymptoms[index];
        return SymptomEntryCard(
          entry: entry,
          onEdit: () => _editSymptom(entry),
          onDelete: () => _deleteSymptom(entry),
        );
      },
    );
  }

  Widget _buildFoodTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_todayFoods.isEmpty) {
      return _buildEmptyState(
        Icons.restaurant,
        'No hay comidas registradas',
        'Toca el botón + para agregar una comida',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _todayFoods.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = _todayFoods[index];
        return _buildFoodCard(entry);
      },
    );
  }

  Widget _buildBowelMovementsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_todayBowelMovements.isEmpty) {
      return _buildEmptyState(
        Icons.wc,
        'No hay deposiciones registradas',
        'Toca el botón + para agregar una deposición',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _todayBowelMovements.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = _todayBowelMovements[index];
        return _buildBowelMovementCard(entry);
      },
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(icon, size: 64, color: trout),
            const SizedBox(height: 16),
            ContraText(
              text: title,
              size: 18,
              color: trout,
              alignment: Alignment.center,
            ),
            const SizedBox(height: 8),
            ContraText(
              text: subtitle,
              size: 14,
              color: trout,
              alignment: Alignment.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodCard(FoodEntry entry) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: entry.causedDiscomfort == true ? Colors.red : wood_smoke,
          width: 2,
        ),
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
              Icon(
                Icons.restaurant,
                color: entry.causedDiscomfort == true ? Colors.red : wood_smoke,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ContraText(
                      text: entry.foodName,
                      size: 18,
                      weight: FontWeight.bold,
                      color: wood_smoke,
                      alignment: Alignment.centerLeft,
                    ),
                    ContraText(
                      text:
                          '${SymptomData.getMealTypeDisplayName(entry.mealType)} - ${entry.time}',
                      size: 14,
                      color: trout,
                      alignment: Alignment.centerLeft,
                    ),
                  ],
                ),
              ),
              if (entry.causedDiscomfort == true)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red, width: 1),
                  ),
                  child: const ContraText(
                    text: '⚠️ Malestar',
                    size: 12,
                    color: Colors.red,
                    alignment: Alignment.center,
                  ),
                ),
            ],
          ),
          if (entry.description != null && entry.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            ContraText(
              text: entry.description!,
              size: 14,
              color: trout,
              alignment: Alignment.centerLeft,
            ),
          ],
          if (entry.ingredients != null && entry.ingredients!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: athens_gray,
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: wood_smoke.withOpacity(0.3), width: 1),
              ),
              child: ContraText(
                text: entry.ingredients!,
                size: 12,
                color: wood_smoke,
                alignment: Alignment.centerLeft,
              ),
            ),
          ],
          if (entry.discomfortNotes != null &&
              entry.discomfortNotes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: Colors.red.withOpacity(0.3), width: 1),
              ),
              child: ContraText(
                text: entry.discomfortNotes!,
                size: 12,
                color: Colors.red,
                alignment: Alignment.centerLeft,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _editFood(entry),
                icon: const Icon(Icons.edit, size: 16, color: wood_smoke),
                label: const ContraText(
                  text: 'Editar',
                  size: 14,
                  color: wood_smoke,
                  alignment: Alignment.center,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _deleteFood(entry),
                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                label: const ContraText(
                  text: 'Eliminar',
                  size: 14,
                  color: Colors.red,
                  alignment: Alignment.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBowelMovementCard(BowelMovementEntry entry) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (entry.hasBlood == true || entry.wasPainful == true)
              ? Colors.red
              : wood_smoke,
          width: 2,
        ),
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
              Icon(
                Icons.wc,
                color: (entry.hasBlood == true || entry.wasPainful == true)
                    ? Colors.red
                    : wood_smoke,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ContraText(
                      text: '${entry.consistency} - ${entry.color}',
                      size: 18,
                      weight: FontWeight.bold,
                      color: wood_smoke,
                      alignment: Alignment.centerLeft,
                    ),
                    ContraText(
                      text: 'Hora: ${entry.time}',
                      size: 14,
                      color: trout,
                      alignment: Alignment.centerLeft,
                    ),
                  ],
                ),
              ),
              if (entry.hasBlood == true || entry.wasPainful == true)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red, width: 1),
                  ),
                  child: const ContraText(
                    text: '⚠️ Atención',
                    size: 12,
                    color: Colors.red,
                    alignment: Alignment.center,
                  ),
                ),
            ],
          ),
          if (entry.hasBlood == true ||
              entry.hasMucus == true ||
              entry.wasPainful == true) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (entry.hasBlood == true)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const ContraText(
                      text: 'Sangre',
                      size: 10,
                      color: Colors.red,
                      alignment: Alignment.center,
                    ),
                  ),
                if (entry.hasMucus == true)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const ContraText(
                      text: 'Moco',
                      size: 10,
                      color: Colors.blue,
                      alignment: Alignment.center,
                    ),
                  ),
                if (entry.wasPainful == true)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ContraText(
                      text: 'Dolor: ${entry.painLevel}',
                      size: 10,
                      color: Colors.orange,
                      alignment: Alignment.center,
                    ),
                  ),
              ],
            ),
          ],
          if (entry.notes != null && entry.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            ContraText(
              text: entry.notes!,
              size: 14,
              color: trout,
              alignment: Alignment.centerLeft,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _editBowelMovement(entry),
                icon: const Icon(Icons.edit, size: 16, color: wood_smoke),
                label: const ContraText(
                  text: 'Editar',
                  size: 14,
                  color: wood_smoke,
                  alignment: Alignment.center,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _deleteBowelMovement(entry),
                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                label: const ContraText(
                  text: 'Eliminar',
                  size: 14,
                  color: Colors.red,
                  alignment: Alignment.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadTodayData();
    }
  }

  Future<void> _editSymptom(SymptomEntry entry) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSymptomPage(
          selectedDate: _selectedDate,
          editingEntry: entry,
        ),
      ),
    );

    if (result == true) {
      _loadTodayData();
    }
  }

  Future<void> _deleteSymptom(SymptomEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: white,
        title:
            const Text('Eliminar Síntoma', style: TextStyle(color: wood_smoke)),
        content: Text(
            '¿Estás seguro de que quieres eliminar el registro de "${entry.symptomNames.isNotEmpty ? entry.symptomNames.first : 'síntoma'}"?',
            style: const TextStyle(color: wood_smoke)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: wood_smoke)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar',
                style: TextStyle(
                    color: carribean_green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _symptomService.deleteSymptomEntry(entry.id);
        _loadTodayData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Síntoma eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editFood(FoodEntry entry) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFoodPage(
          selectedDate: _selectedDate,
          editingEntry: entry,
        ),
      ),
    );

    if (result == true) {
      _loadTodayData();
    }
  }

  Future<void> _deleteFood(FoodEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: white,
        title:
            const Text('Eliminar Comida', style: TextStyle(color: wood_smoke)),
        content: Text(
            '¿Estás seguro de que quieres eliminar el registro de "${entry.foodName}"?',
            style: const TextStyle(color: wood_smoke)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: wood_smoke)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar',
                style: TextStyle(
                    color: carribean_green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _symptomService.deleteFoodEntry(entry.id);
        _loadTodayData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comida eliminada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editBowelMovement(BowelMovementEntry entry) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBowelMovementPage(
          selectedDate: _selectedDate,
          editingEntry: entry,
        ),
      ),
    );

    if (result == true) {
      _loadTodayData();
    }
  }

  Future<void> _deleteBowelMovement(BowelMovementEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: white,
        title: const Text('Eliminar Deposición',
            style: TextStyle(color: wood_smoke)),
        content: const Text(
            '¿Estás seguro de que quieres eliminar este registro?',
            style: TextStyle(color: wood_smoke)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: wood_smoke)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar',
                style: TextStyle(
                    color: carribean_green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _symptomService.deleteBowelMovementEntry(entry.id);
        _loadTodayData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Deposición eliminada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
