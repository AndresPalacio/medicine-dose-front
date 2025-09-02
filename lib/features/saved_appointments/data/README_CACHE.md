# Sistema de Caché para Medicamentos Mensuales

Este documento explica cómo usar el nuevo sistema de caché implementado para optimizar las consultas de medicamentos mensuales.

## Funcionalidad

El sistema de caché permite:
- Obtener todos los medicamentos de un mes completo con una sola petición HTTP
- Almacenar los datos en memoria para consultas posteriores
- Filtrar datos por día específico sin hacer nuevas peticiones
- Limpiar automáticamente la caché cuando se modifican los datos

## Métodos Disponibles

### 1. `getMonthlyDetail(DateTime date)`

Obtiene todos los medicamentos de un mes completo con caché.

```dart
final apiService = MedicationApiService();

// Primera llamada: hace petición HTTP y guarda en caché
final augustMedications = await apiService.getMonthlyDetail(DateTime(2025, 8, 1));

// Segunda llamada: devuelve datos desde caché (sin petición HTTP)
final augustMedicationsCached = await apiService.getMonthlyDetail(DateTime(2025, 8, 15));

// Cambio de mes: hace nueva petición HTTP
final septemberMedications = await apiService.getMonthlyDetail(DateTime(2025, 9, 1));
```

### 2. `getDailyDetailFromCache(DateTime date)`

Obtiene medicamentos de un día específico usando la caché mensual.

```dart
final apiService = MedicationApiService();

// Obtiene medicamentos del 15 de agosto
// Si no hay caché, hace petición completa del mes y filtra
final dailyMedications = await apiService.getDailyDetailFromCache(DateTime(2025, 8, 15));
```

### 3. `clearMonthlyCache()`

Limpia manualmente la caché.

```dart
final apiService = MedicationApiService();

// Limpiar caché manualmente
apiService.clearMonthlyCache();
```

## Implementación en SavedAppointmentsPage

La página `saved_appointments_page.dart` ha sido optimizada para usar el sistema de caché:

### Variables de Caché Local

```dart
class _SavedAppointmentsPageState extends State<SavedAppointmentsPage> {
  // Variables para la caché optimizada
  List<MedicationDoseResponse> _monthlyData = [];
  DateTime? _currentCachedMonth;
}
```

### Método Optimizado para Obtener Dosis Diarias

```dart
Future<void> _fetchDailyDoses(DateTime date) async {
  setState(() {
    _isLoading = true;
    _error = null;
  });
  try {
    // Verificar si necesitamos cargar datos del mes
    final currentMonth = DateTime(date.year, date.month, 1);
    if (_currentCachedMonth == null || 
        _currentCachedMonth!.year != currentMonth.year || 
        _currentCachedMonth!.month != currentMonth.month) {
      
      // Cargar datos del mes completo (con caché del servicio)
      _monthlyData = await _apiService.getMonthlyDetail(date);
      _currentCachedMonth = currentMonth;
      
      // DEBUG
      print('DEBUG _fetchDailyDoses → Loaded monthly data for ${currentMonth.year}-${currentMonth.month} (${_monthlyData.length} items)');
    }
    
    // Filtrar datos del día específico
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final dailyDoses = _monthlyData.where((medication) {
      return medication.date == formattedDate;
    }).toList();
    
    if (mounted) {
      setState(() {
        _dailyDoses = dailyDoses;
      });
    }
    
    // DEBUG
    print('DEBUG _fetchDailyDoses → Filtered ${dailyDoses.length} items for date: $formattedDate');
    
  } catch (e) {
    // Manejo de errores...
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
```

### Actualización de Caché Local (Optimizada)

```dart
/// Actualiza la caché local cuando se marca una dosis como tomada
void _updateLocalCache(String doseId, bool isTaken) {
  if (_monthlyData.isNotEmpty) {
    // Buscar la dosis en la caché local y actualizarla
    final doseIndex = _monthlyData.indexWhere((dose) => dose.id == doseId);
    if (doseIndex != -1) {
      // Crear una nueva instancia con el estado actualizado
      final updatedDose = MedicationDoseResponse(
        id: _monthlyData[doseIndex].id,
        medicationId: _monthlyData[doseIndex].medicationId,
        medicationName: _monthlyData[doseIndex].medicationName,
        date: _monthlyData[doseIndex].date,
        meal: _monthlyData[doseIndex].meal,
        quantity: _monthlyData[doseIndex].quantity,
        taken: isTaken,
        mealTiming: _monthlyData[doseIndex].mealTiming,
        timeBeforeAfter: _monthlyData[doseIndex].timeBeforeAfter,
        timeUnit: _monthlyData[doseIndex].timeUnit,
      );
      
      // Actualizar la dosis en la caché
      _monthlyData[doseIndex] = updatedDose;
      
      // DEBUG
      print('DEBUG _updateLocalCache → Updated dose $doseId to taken=$isTaken');
    }
  }
}

/// Limpia la caché local cuando se modifican los medicamentos
void _clearLocalCache() {
  _monthlyData.clear();
  _currentCachedMonth = null;
  // DEBUG
  print('DEBUG _clearLocalCache → Local cache cleared');
}
```

### Uso en Eventos de Modificación

```dart
onToggle: () async {
  final originalState = dose.taken;
  setState(() {
    dose.taken = !originalState;
  });
  try {
    await _apiService.markDoseAsTaken(dose.id, !originalState);
    // Actualizar caché local después de marcar dosis (más eficiente)
    _updateLocalCache(dose.id, !originalState);
  } catch (e) {
    // Manejo de errores...
  }
},
```

## Uso en la Aplicación

### Ejemplo: Calendario con Paginación

```dart
class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final MedicationApiService _apiService = MedicationApiService();
  List<MedicationDoseResponse> _monthlyData = [];
  DateTime _currentMonth = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMonthlyData();
  }

  Future<void> _loadMonthlyData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Carga todos los datos del mes (con caché)
      final monthlyData = await _apiService.getMonthlyDetail(_currentMonth);
      setState(() {
        _monthlyData = monthlyData;
      });
    } catch (e) {
      print('Error cargando datos mensuales: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Obtener medicamentos de un día específico
  List<MedicationDoseResponse> getDailyMedications(DateTime date) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    return _monthlyData.where((medication) {
      return medication.date == formattedDate;
    }).toList();
  }

  // Cambiar de mes
  void _changeMonth(DateTime newMonth) {
    setState(() {
      _currentMonth = newMonth;
    });
    _loadMonthlyData(); // La caché se maneja automáticamente
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calendario de Medicamentos')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: 31, // Días del mes
              itemBuilder: (context, index) {
                final day = DateTime(_currentMonth.year, _currentMonth.month, index + 1);
                final dailyMedications = getDailyMedications(day);
                
                return Card(
                  child: ListTile(
                    title: Text('${day.day}/${day.month}/${day.year}'),
                    subtitle: Text('${dailyMedications.length} medicamentos'),
                    trailing: dailyMedications.isNotEmpty
                        ? Icon(Icons.medication)
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
```

### Ejemplo: Lista de Medicamentos Diarios

```dart
class DailyMedicationsWidget extends StatelessWidget {
  final DateTime date;
  final MedicationApiService apiService;

  const DailyMedicationsWidget({
    Key? key,
    required this.date,
    required this.apiService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MedicationDoseResponse>>(
      future: apiService.getDailyDetailFromCache(date),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final medications = snapshot.data ?? [];
        
        if (medications.isEmpty) {
          return Center(child: Text('No hay medicamentos para este día'));
        }
        
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: medications.length,
          itemBuilder: (context, index) {
            final medication = medications[index];
            return ListTile(
              leading: Icon(Icons.medication),
              title: Text(medication.medicationName),
              subtitle: Text('${medication.meal} - ${medication.quantity} dosis'),
              trailing: Icon(
                medication.taken ? Icons.check_circle : Icons.radio_button_unchecked,
                color: medication.taken ? Colors.green : Colors.grey,
              ),
            );
          },
        );
      },
    );
  }
}
```

## Ventajas del Sistema de Caché

1. **Rendimiento**: Reduce significativamente las peticiones HTTP
2. **Experiencia de Usuario**: Navegación más fluida entre días del mismo mes
3. **Eficiencia**: Una sola petición carga todos los datos del mes
4. **Consistencia**: Los datos se mantienen sincronizados automáticamente

## Optimización de Actualización de Caché

### Antes (Limpieza Completa)
```dart
// Al marcar una dosis como tomada:
await _apiService.markDoseAsTaken(dose.id, !originalState);
_clearLocalCache(); // ❌ Limpia toda la caché
// La próxima navegación requiere nueva petición HTTP
```

### Ahora (Actualización Selectiva)
```dart
// Al marcar una dosis como tomada:
await _apiService.markDoseAsTaken(dose.id, !originalState);
_updateLocalCache(dose.id, !originalState); // ✅ Actualiza solo esa dosis
// La caché se mantiene, no se requieren nuevas peticiones HTTP
```

### Beneficios de la Optimización:
- **Máxima Eficiencia**: No se requieren nuevas peticiones HTTP al navegar
- **Actualización Instantánea**: Los cambios se reflejan inmediatamente
- **Consistencia de Datos**: La caché siempre está sincronizada
- **Mejor UX**: Sin delays al cambiar entre días del mismo mes

## Consideraciones

- La caché se limpia automáticamente cuando se modifican medicamentos
- Los datos se almacenan en memoria (se pierden al cerrar la app)
- Para aplicaciones web, la caché persiste durante la sesión del navegador
- El sistema es transparente para el desarrollador

## Debug

El sistema incluye logs de debug para monitorear el funcionamiento:

```
DEBUG getMonthlyDetail → Checking cache for month: 2025-08
DEBUG getMonthlyDetail → GET http://localhost:8080/api/medications/monthly-detail?date=2025-08-11&userId=main
DEBUG getMonthlyDetail ← Cached data for month: 2025-08 (150 items)
DEBUG _fetchDailyDoses → Loaded monthly data for 2025-8 (150 items)
DEBUG _fetchDailyDoses → Filtered 5 items for date: 2025-08-11
DEBUG _updateLocalCache → Updated dose dose_123 to taken=true
DEBUG _updateLocalCache → Updated dose dose_456 to taken=false
```
