# Weather App Tutorial

A Flutter weather application built using clean architecture principles. This is the starter project for the tutorial series.

## Getting Started

This project is a starting point for building a weather application in Flutter. The tutorial will guide you through implementing features step by step.

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- An IDE (VS Code or Android Studio)

### Installation

1. Clone the repository
```bash
git clone https://github.com/YOUR_USERNAME/vibe_coding_tutorial_weather_app.git
```

2. Navigate to project directory
```bash
cd vibe_coding_tutorial_weather_app
```

3. Get dependencies
```bash
flutter pub get
```

4. Run the app
```bash
flutter run
```

## Project Structure

The project follows clean architecture principles with the following structure:

```
lib/
├── main.dart              # Application entry point
├── core/
│   ├── data_state.dart    # Data state management with Freezed
│   └── README.md          # Core components documentation
└── docs/
    └── freezed_troubleshooting.md  # Freezed troubleshooting guide
```

## Core Components

### DataState Pattern

The project uses a `DataState<T>` pattern for managing data states throughout the application. This pattern provides:

- **Type-safe state management** using Freezed
- **Four distinct states**: Initial, Loading, Success, Failure
- **Easy state checking** with extension methods
- **Clean error handling**

For detailed documentation, see:
- [Core Components Documentation](lib/core/README.md)
- [Freezed Troubleshooting Guide](docs/freezed_troubleshooting.md)

## Development Workflow

### Working with Freezed

When modifying classes that use Freezed annotations:

1. Edit the source file (e.g., `data_state.dart`)
2. Run the build runner to generate code:
   ```bash
   flutter packages pub run build_runner build
   ```
3. Verify that the generated file (e.g., `data_state.freezed.dart`) was created
4. The errors should disappear

### Useful Commands

```bash
# Generate Freezed files
flutter packages pub run build_runner build

# Generate and clean conflicting outputs
flutter packages pub run build_runner build --delete-conflicting-outputs

# Watch mode for development
flutter packages pub run build_runner watch

# Analyze specific files
flutter analyze lib/core/data_state.dart
```

## Features to be Implemented

Throughout the tutorial, we will implement:

- ✅ Clean Architecture setup
- ✅ Data state management with Freezed
- 🔄 Weather data fetching
- 🔄 State management with BLoC
- 🔄 Error handling
- 🔄 Unit and widget testing
- 🔄 UI implementation
- 🔄 API integration

## Documentation

- [Core Components](lib/core/README.md) - Documentation for core components
- [Freezed Troubleshooting](docs/freezed_troubleshooting.md) - Common issues and solutions with Freezed

## Contributing

This is a tutorial project. Feel free to fork and use it for learning purposes.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

# Core - Componentes Principales

Este directorio contiene los componentes fundamentales de la aplicación.

## DataState

La clase `DataState<T>` es un patrón de diseño que maneja los diferentes estados de los datos en la aplicación de manera type-safe usando Freezed.

### Propósito

`DataState` encapsula los cuatro estados posibles de cualquier operación de datos:
- **Initial**: Estado inicial antes de cualquier operación
- **Loading**: Operación en progreso
- **Success**: Operación completada exitosamente con datos
- **Failure**: Operación fallida con error

### Uso Básico

```dart
// Crear estados
final initialState = DataState.initial();
final loadingState = DataState.loading();
final successState = DataState.success(value: "Datos obtenidos");
final failureState = DataState.failure("Error de conexión");

// Verificar estados
if (dataState.isLoading) {
  // Mostrar loading
}

if (dataState.isSuccess) {
  final data = dataState.value; // Acceder a los datos
}

if (dataState.hasFailure) {
  final error = dataState.error; // Acceder al error
}
```

### Extensiones Útiles

La clase incluye extensiones que facilitan el trabajo con los estados:

```dart
// Verificaciones de estado
dataState.isInitial        // true si es estado inicial
dataState.isInitialOrLoading // true si es inicial o cargando
dataState.isLoading        // true si está cargando
dataState.isSuccess        // true si fue exitoso
dataState.hasFailure       // true si falló

// Acceso a datos
dataState.value            // T? - datos si es success, null en otros casos
dataState.error            // Object? - error si es failure, null en otros casos
```

### Ejemplo Completo

```dart
class WeatherRepository {
  Future<DataState<Weather>> getWeather(String city) async {
    try {
      // Simular carga
      await Future.delayed(Duration(seconds: 2));
      
      // Simular datos exitosos
      final weather = Weather(temperature: 25, condition: "Soleado");
      return DataState.success(value: weather);
      
    } catch (e) {
      return DataState.failure(e);
    }
  }
}

// Uso en UI
Widget buildWeatherWidget(DataState<Weather> weatherState) {
  return weatherState.when(
    initial: () => Text("Presiona para cargar el clima"),
    loading: () => CircularProgressIndicator(),
    success: (weather) => Text("${weather.temperature}°C - ${weather.condition}"),
    failure: (error) => Text("Error: $error"),
  );
}
```

### Archivos Relacionados

- `data_state.dart` - Código fuente con anotaciones Freezed
- `data_state.freezed.dart` - Código generado automáticamente (NO editar)

### Notas de Desarrollo

1. **Generación de código**: Después de modificar `data_state.dart`, ejecuta:
   ```bash
   flutter packages pub run build_runner build
   ```

2. **No editar archivos generados**: El archivo `data_state.freezed.dart` se regenera automáticamente.

3. **Type Safety**: Freezed proporciona type safety completo y métodos como `when()`, `maybeWhen()`, `map()`, etc.

### Referencias

- [Documentación de Freezed](https://pub.dev/packages/freezed)
- [Patrón Result/Either](https://dart.dev/codelabs/async-await#handling-errors)
- [Solución de problemas con Freezed](./docs/freezed_troubleshooting.md) 