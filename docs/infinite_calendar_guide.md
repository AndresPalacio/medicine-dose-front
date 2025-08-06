# Calendario Infinito de Medicamentos

## Descripción

El calendario infinito es un widget personalizado que permite visualizar las fechas que tienen medicamentos programados. Está diseñado siguiendo los estilos del proyecto y utiliza los modelos de API existentes.

## Características

- **Navegación infinita**: Permite desplazarse entre meses de forma fluida
- **Indicadores visuales**: Muestra puntos de colores en las fechas que tienen eventos
- **Selección de fechas**: Permite seleccionar fechas específicas
- **Lista de eventos**: Muestra los eventos del mes seleccionado
- **Integración con API**: Utiliza el endpoint `/api/medications/calendar`
- **Estilos consistentes**: Sigue el diseño del proyecto usando `ContraText`, `ContraButton`, etc.

## Componentes

### InfiniteCalendarWidget

Widget principal del calendario que maneja:
- Navegación entre meses
- Selección de fechas
- Carga de eventos desde la API
- Visualización de eventos

**Parámetros:**
- `initialDate`: Fecha inicial para mostrar
- `onDateSelected`: Callback cuando se selecciona una fecha
- `onEventSelected`: Callback cuando se selecciona un evento

### CalendarPage

Página completa que integra el calendario con:
- AppBar personalizado
- Información de fecha seleccionada
- Diálogo de detalles de eventos
- Navegación desde la página principal

## Modelos de Datos

### CalendarEventResponse

```dart
class CalendarEventResponse {
  final String id;
  final String title;
  final String start;
  final String description;
  final List<MedicationDoseResponse> doses;
}
```

### MedicationDoseResponse

```dart
class MedicationDoseResponse {
  final int id;
  final int medicationId;
  final String date;
  final String meal;
  final int quantity;
  bool taken;
}
```

## API Endpoints

### GET /api/medications/calendar

Retorna todos los eventos del calendario organizados por fecha:

```json
[
  {
    "id": "day-2024-01-15",
    "title": "3 toma(s)",
    "start": "2024-01-15",
    "description": "Paracetamol - DESAYUNO - 1 unidad(es)\nParacetamol - CENA - 1 unidad(es)",
    "doses": [
      {
        "id": 1,
        "medicationId": 1,
        "date": "2024-01-15",
        "meal": "DESAYUNO",
        "quantity": 1,
        "taken": false
      }
    ]
  }
]
```

## Uso

### Navegación desde la página principal

En `SavedAppointmentsPage`, se agregó un botón "Calendario" que navega a la página del calendario:

```dart
ButtonPlain(
  text: 'Calendario',
  color: carribean_green,
  borderColor: carribean_green,
  textColor: white,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CalendarPage(),
      ),
    );
  },
),
```

### Uso directo del widget

```dart
InfiniteCalendarWidget(
  initialDate: DateTime.now(),
  onDateSelected: (date) {
    print('Fecha seleccionada: $date');
  },
  onEventSelected: (event) {
    print('Evento seleccionado: ${event.title}');
  },
)
```

## Estilos y Colores

El calendario utiliza los colores definidos en `utils/colors.dart`:

- `wood_smoke`: Color principal del texto
- `carribean_green`: Color de selección y elementos activos
- `mona_lisa`: Color de los indicadores de eventos
- `selago`: Color de fondo
- `white`: Color de fondo de las tarjetas
- `athens_gray`: Color de sombras

## Funcionalidades

### Navegación de Meses

- Botones de navegación en el encabezado de cada mes
- Scroll infinito entre meses
- Posicionamiento automático al mes actual

### Indicadores Visuales

- Puntos de colores en fechas con eventos
- Resaltado de fecha seleccionada
- Resaltado de fecha actual
- Estados de carga y error

### Interacción

- Tap en fechas para seleccionarlas
- Tap en eventos para ver detalles
- Diálogo con información detallada de dosis
- Estados de dosis (tomada/pendiente)

## Estados de Carga

El widget maneja diferentes estados usando `DataState`:

- **Loading**: Muestra un indicador de carga
- **Success**: Muestra los eventos o mensaje de "sin eventos"
- **Error**: Muestra mensaje de error con botón de reintentar

## Responsive Design

- Adaptable a diferentes tamaños de pantalla
- Grid de 7 columnas para los días de la semana
- Altura fija para cada mes (300px)
- Scroll horizontal para navegación de fechas

## Dependencias

- `intl`: Para formateo de fechas en español
- `flutter_svg`: Para iconos SVG
- `http`: Para llamadas a la API
- `freezed`: Para modelos de datos inmutables

## Próximas Mejoras

- [ ] Filtros por tipo de medicamento
- [ ] Vista semanal
- [ ] Notificaciones push
- [ ] Exportar calendario
- [ ] Temas personalizables
- [ ] Búsqueda de eventos 