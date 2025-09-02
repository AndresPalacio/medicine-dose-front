# Modelos de Calendario para Dosis de Medicamentos

Este documento explica cómo usar los nuevos modelos para manejar las respuestas del calendario de dosis de medicamentos.

## Estructura de Datos

Los datos del calendario tienen la siguiente estructura:

```json
[
    {
        "id": "f105b9aa-1428-49b6-a9d8-bad24d223ea5_2025-08-01_DESAYUNO",
        "medicationId": "f105b9aa-1428-49b6-a9d8-bad24d223ea5",
        "medicationName": "ESOZ 40MG",
        "date": "2025-08-01",
        "meal": "DESAYUNO",
        "status": "PENDING",
        "expectedTime": null
    }
]
```

## Modelos Disponibles

### 1. CalendarDoseResponse

Representa una dosis individual del calendario.

```dart
class CalendarDoseResponse {
  final String id;
  final String medicationId;
  final String medicationName;
  final String date;
  final String meal;
  final String status;
  final String? expectedTime;
}
```

**Propiedades útiles:**
- `dateTime`: Convierte la fecha string a DateTime
- `isPending`: Verifica si la dosis está pendiente
- `isCompleted`: Verifica si la dosis está completada
- `mealInSpanish`: Obtiene el nombre de la comida en español

### 2. CalendarResponse

Maneja la lista completa de dosis del calendario.

```dart
class CalendarResponse {
  final List<CalendarDoseResponse> doses;
}
```

**Métodos útiles:**
- `getDosesByDate(String date)`: Obtiene dosis por fecha
- `getDosesByMedication(String medicationId)`: Obtiene dosis por medicamento
- `getPendingDoses()`: Obtiene dosis pendientes
- `getCompletedDoses()`: Obtiene dosis completadas
- `getTodayDoses()`: Obtiene dosis de hoy
- `getDosesForWeek(DateTime weekStart)`: Obtiene dosis de una semana
- `getDosesForMonth(int year, int month)`: Obtiene dosis de un mes

## Uso Básico

### 1. Procesar datos JSON

```dart
import 'dart:convert';
import 'medication_api_models.dart';

// Datos JSON del calendario
String jsonData = '[...]';

// Procesar los datos
final List<dynamic> jsonList = json.decode(jsonData);
final CalendarResponse calendar = CalendarResponse.fromJson(jsonList);
```

### 2. Obtener dosis específicas

```dart
// Dosis de hoy
final todayDoses = calendar.getTodayDoses();

// Dosis pendientes
final pendingDoses = calendar.getPendingDoses();

// Dosis de una fecha específica
final specificDoses = calendar.getDosesByDate('2025-08-01');

// Dosis de un medicamento específico
final medicationDoses = calendar.getDosesByMedication('medication-id');
```

### 3. Obtener estadísticas

```dart
// Usar la clase utilitaria
final statistics = CalendarExample.getDoseStatistics(calendar);

// Acceder a las estadísticas
final totalDoses = statistics['totalDoses'];
final pendingDoses = statistics['pendingDoses'];
final completedDoses = statistics['completedDoses'];
final dosesByMedication = statistics['dosesByMedication'];
final dosesByMeal = statistics['dosesByMeal'];
```

## Widgets Disponibles

### 1. CalendarDoseWidget

Muestra una dosis individual con información detallada.

```dart
CalendarDoseWidget(
  dose: calendarDose,
  onTap: () {
    // Manejar tap en la dosis
  },
  showDetails: true,
)
```

### 2. CalendarDoseListWidget

Muestra una lista de dosis con título.

```dart
CalendarDoseListWidget(
  title: 'Dosis de Hoy',
  doses: calendar.getTodayDoses(),
  onDoseTap: () {
    // Manejar tap en una dosis
  },
)
```

## Estados de Dosis

Los estados disponibles son:
- `PENDING`: Pendiente
- `COMPLETED`: Completada
- `MISSED`: Perdida
- `SKIPPED`: Omitida

## Comidas

Las comidas disponibles son:
- `DESAYUNO`: Desayuno
- `ALMUERZO`: Almuerzo
- `CENA`: Cena

## Ejemplo Completo

Ver el archivo `calendar_example_page.dart` para un ejemplo completo de implementación.

## Integración con API

Para integrar con tu API, simplemente reemplaza los datos de ejemplo con la respuesta real de tu endpoint:

```dart
// En tu servicio API
Future<CalendarResponse> getCalendarData() async {
  final response = await http.get(Uri.parse('your-api-endpoint'));
  final List<dynamic> jsonList = json.decode(response.body);
  return CalendarResponse.fromJson(jsonList);
}
```
