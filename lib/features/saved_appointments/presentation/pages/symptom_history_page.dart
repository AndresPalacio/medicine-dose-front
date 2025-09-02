import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_text.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/symptom_models.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/data/symptom_api_service.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/presentation/widgets/symptom_entry_card.dart';
import 'package:vibe_coding_tutorial_weather_app/utils/colors.dart';

class SymptomHistoryPage extends StatefulWidget {
  const SymptomHistoryPage({super.key});

  @override
  State<SymptomHistoryPage> createState() => _SymptomHistoryPageState();
}

class _SymptomHistoryPageState extends State<SymptomHistoryPage> {
  final SymptomApiService _symptomService = SymptomApiService();
  List<SymptomEntry> _allEntries = [];
  List<SymptomEntry> _filteredEntries = [];
  bool _isLoading = true;
  String? _error;

  String _selectedFilter = 'all'; // all, week, month, custom
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Usar endpoint por mes para obtener síntomas del mes actual (más rápido)
      final entries = await _symptomService.getAllSymptomEntries();
      setState(() {
        _allEntries = entries;
        _filteredEntries = entries;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() {
        _error = 'Error al cargar el historial: $e';
        _isLoading = false;
      });
    }
  }

  // Cargar entradas por rango de fechas usando endpoint inteligente
  Future<void> _loadEntriesByDateRange(
      DateTime startDate, DateTime endDate) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Usar endpoint por rango de fechas (inteligente)
      final entries = await _symptomService.getSymptomEntriesByDateRange(
          startDate, endDate);
      setState(() {
        _allEntries = entries;
        _filteredEntries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar el historial por rango de fechas: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<SymptomEntry> filtered = List.from(_allEntries);

    // Aplicar filtro de fecha
    if (_selectedFilter == 'week') {
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      filtered =
          filtered.where((entry) => entry.date.isAfter(weekAgo)).toList();
    } else if (_selectedFilter == 'month') {
      final monthAgo = DateTime.now().subtract(const Duration(days: 30));
      filtered =
          filtered.where((entry) => entry.date.isAfter(monthAgo)).toList();
    } else if (_selectedFilter == 'custom' &&
        _startDate != null &&
        _endDate != null) {
      // Para filtros personalizados, usar endpoint por rango de fechas (inteligente)
      _loadEntriesByDateRange(_startDate!, _endDate!);
      return; // Salir temprano ya que se cargarán nuevos datos
    }

    // Aplicar filtro de búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((entry) =>
              entry.symptomNames.any((name) =>
                  name.toLowerCase().contains(_searchQuery.toLowerCase())) ||
              (entry.notes
                      ?.toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false))
          .toList();
    }

    setState(() {
      _filteredEntries = filtered;
    });
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
          text: 'Historial de Síntomas',
          size: 20,
          weight: FontWeight.bold,
          color: wood_smoke,
          alignment: Alignment.center,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: wood_smoke),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          _buildSearchBar(),

          // Filtros activos
          _buildActiveFilters(),

          // Lista de síntomas
          Expanded(
            child: _buildSymptomList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          _applyFilters();
        },
        decoration: InputDecoration(
          hintText: 'Buscar síntomas...',
          prefixIcon: const Icon(Icons.search, color: trout),
          filled: true,
          fillColor: athens_gray,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: wood_smoke, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: wood_smoke, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: lightening_yellow, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilters() {
    String filterText = '';
    switch (_selectedFilter) {
      case 'week':
        filterText = 'Última semana';
        break;
      case 'month':
        filterText = 'Último mes';
        break;
      case 'custom':
        if (_startDate != null && _endDate != null) {
          filterText =
              '${DateFormat('dd/MM').format(_startDate!)} - ${DateFormat('dd/MM').format(_endDate!)}';
        }
        break;
      default:
        filterText = 'Todos los registros';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 16, color: trout),
          const SizedBox(width: 8),
          ContraText(
            text: filterText,
            size: 14,
            color: trout,
            alignment: Alignment.centerLeft,
          ),
          const Spacer(),
          ContraText(
            text: '${_filteredEntries.length} registros',
            size: 14,
            color: trout,
            alignment: Alignment.centerRight,
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ContraText(
            text: _error!,
            size: 16,
            color: trout,
            alignment: Alignment.center,
          ),
        ),
      );
    }

    if (_filteredEntries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(Icons.history, size: 64, color: trout),
              const SizedBox(height: 16),
              const ContraText(
                text: 'No hay registros',
                size: 18,
                color: trout,
                alignment: Alignment.center,
              ),
              const SizedBox(height: 8),
              const ContraText(
                text: 'Intenta cambiar los filtros',
                size: 14,
                color: trout,
                alignment: Alignment.center,
              ),
            ],
          ),
        ),
      );
    }

    // Agrupar por fecha
    final Map<String, List<SymptomEntry>> groupedEntries = {};
    for (final entry in _filteredEntries) {
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.date);
      if (!groupedEntries.containsKey(dateKey)) {
        groupedEntries[dateKey] = [];
      }
      groupedEntries[dateKey]!.add(entry);
    }

    // Ordenar fechas (más reciente primero)
    final sortedDates = groupedEntries.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final date = DateTime.parse(dateKey);
        final entries = groupedEntries[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado de fecha
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: lightening_yellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: lightening_yellow, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: wood_smoke),
                  const SizedBox(width: 8),
                  ContraText(
                    text: DateFormat('EEEE, d MMMM yyyy', 'es_ES').format(date),
                    size: 16,
                    weight: FontWeight.bold,
                    color: wood_smoke,
                    alignment: Alignment.centerLeft,
                  ),
                  const Spacer(),
                  ContraText(
                    text: '${entries.length} síntomas',
                    size: 14,
                    color: trout,
                    alignment: Alignment.centerRight,
                  ),
                ],
              ),
            ),

            // Lista de síntomas del día
            ...entries
                .map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SymptomEntryCard(
                        entry: entry,
                        onEdit: () => _editSymptom(entry),
                        onDelete: () => _deleteSymptom(entry),
                      ),
                    ))
                .toList(),

            if (index < sortedDates.length - 1)
              const Divider(height: 32, color: athens_gray),
          ],
        );
      },
    );
  }

  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: white,
        title: const Text('Filtrar Historial',
            style: TextStyle(color: wood_smoke)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Todos los registros',
                  style: TextStyle(color: wood_smoke)),
              value: 'all',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                  _startDate = null;
                  _endDate = null;
                });
                Navigator.of(context).pop();
                _applyFilters();
              },
            ),
            RadioListTile<String>(
              title: const Text('Última semana',
                  style: TextStyle(color: wood_smoke)),
              value: 'week',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                  _startDate = null;
                  _endDate = null;
                });
                Navigator.of(context).pop();
                _applyFilters();
              },
            ),
            RadioListTile<String>(
              title:
                  const Text('Último mes', style: TextStyle(color: wood_smoke)),
              value: 'month',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                  _startDate = null;
                  _endDate = null;
                });
                Navigator.of(context).pop();
                _applyFilters();
              },
            ),
            RadioListTile<String>(
              title: const Text('Rango personalizado'),
              value: 'custom',
              groupValue: _selectedFilter,
              onChanged: (value) async {
                Navigator.of(context).pop();
                await _selectDateRange();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : DateTimeRange(
              start: DateTime.now().subtract(const Duration(days: 7)),
              end: DateTime.now(),
            ),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      setState(() {
        _selectedFilter = 'custom';
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _applyFilters();
    }
  }

  Future<void> _editSymptom(SymptomEntry entry) async {
    // Por ahora solo mostramos un mensaje, en una implementación completa
    // navegaríamos a la página de edición
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de edición en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // Recargar datos manteniendo el filtro activo
  Future<void> _reloadDataWithCurrentFilter() async {
    if (_selectedFilter == 'custom' && _startDate != null && _endDate != null) {
      // Si hay un filtro personalizado activo, usar endpoint por rango
      await _loadEntriesByDateRange(_startDate!, _endDate!);
    } else {
      // Si no hay filtro personalizado, usar endpoint por mes (más rápido)
      await _loadEntries();
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

        // Recargar datos manteniendo el filtro activo
        _reloadDataWithCurrentFilter();
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
}
