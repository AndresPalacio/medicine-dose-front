# Configuración de Amplify Gen2 para Flutter

## Descripción

Este documento describe cómo configurar AWS Amplify Gen2 para tu aplicación Flutter, incluyendo autenticación, base de datos y API.

## Estado Actual

✅ **Sandbox configurado exitosamente**
✅ **Autenticación configurada**
✅ **Base de datos configurada**
✅ **API GraphQL configurada**

## Configuración del Sandbox

### Información del Sandbox

- **Identificador**: USUARIO
- **Stack**: amplify-medicinedosefront-USUARIO-sandbox-56a86f9d03
- **Región**: us-east-1
- **Estado**: Activo y funcionando

### Credenciales de Autenticación

- **User Pool ID**: us-east-1_j6l5AqE8f
- **App Client ID**: 3c31dfcufou80ktb9vejpfcenu
- **Identity Pool ID**: us-east-1:5fc809e3-5843-4540-a3a5-47531544c4b2

### Endpoint de API

- **GraphQL**: https://u4e7d3gya5g57jm73knprlzzra.appsync-api.us-east-1.amazonaws.com/graphql

### Política de Contraseñas

- **Longitud mínima**: 8 caracteres
- **Requiere minúsculas**: Sí
- **Requiere mayúsculas**: Sí
- **Requiere números**: Sí
- **Requiere símbolos**: Sí

## Pasos de Configuración Completados

### 1. ✅ Instalación del CLI de Amplify

```bash
npm create amplify@latest
```

### 2. ✅ Estructura del Proyecto

Se creó la siguiente estructura:

```
amplify/
├── auth/
│   └── resource.ts          # Configuración de autenticación
├── data/
│   └── resource.ts          # Esquema de base de datos
├── backend.ts               # Configuración principal del backend
├── package.json
└── tsconfig.json
```

### 3. ✅ Configuración de Autenticación

El archivo `amplify/auth/resource.ts` está configurado con:

- **Login con email**
- **Atributos de usuario personalizables**:
  - Email (requerido)
  - Nombre y apellido (opcionales)
  - Número de teléfono (opcional)
- **Verificación de email habilitada**
- **Recuperación de contraseña por email**
- **MFA deshabilitado**

### 4. ✅ Esquema de Base de Datos

El archivo `amplify/data/resource.ts` incluye:

- **Modelo User**: Perfil completo del usuario
- **Modelo Appointment**: Para citas médicas
- **Autorización basada en propietario**
- **Campos de auditoría** (createdAt, updatedAt)

### 5. ✅ Sandbox Ejecutándose

```bash
npx ampx sandbox
```

El sandbox está funcionando y generando la configuración automáticamente.

## Archivos de Configuración Generados

### 1. `amplify_outputs.json`
Contiene toda la configuración del backend en formato JSON.

### 2. `amplify_outputs.dart`
Contiene la configuración en formato Dart (básico).

### 3. `lib/core/amplify_sandbox_config.dart`
Configuración específica para Flutter con todas las credenciales.

## Integración con Flutter

### 1. Dependencias

Asegúrate de tener estas dependencias en tu `pubspec.yaml`:

```yaml
dependencies:
  amplify_flutter: ^1.6.0
  amplify_auth_cognito: ^1.6.0
  amplify_storage_s3: ^1.6.0
  amplify_api: ^1.6.0
  provider: ^6.1.1
```

### 2. Configuración en Flutter

El archivo `lib/core/amplify_config.dart` está configurado para usar el sandbox.

### 3. Uso del Cliente de Datos

```dart
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';

// Generar cliente de datos
final dataClient = Amplify.Data;

// Ejemplo de uso
try {
  final users = await dataClient.query(
    ModelQueries.list(User.classType),
  );
  print('Usuarios: ${users.data}');
} catch (e) {
  print('Error: $e');
}
```

## Comandos Útiles

### Ejecutar Sandbox
```bash
npx ampx sandbox
```

### Detener Sandbox
```bash
npx ampx sandbox delete
```

### Generar Cliente GraphQL
```bash
npx ampx generate graphql-client-code
```

### Ver Estado del Sandbox
```bash
npx ampx status
```

## Próximos Pasos

1. **✅ Sandbox funcionando** - Completado
2. **✅ Configuración generada** - Completado
3. **🔄 Probar autenticación** - En progreso
4. **⏳ Integrar con app Flutter** - Pendiente
5. **⏳ Probar operaciones CRUD** - Pendiente

## Troubleshooting

### 1. Errores Comunes

- **Múltiples instancias de sandbox**: Usar `npx ampx sandbox delete`
- **Errores de TypeScript**: Verificar sintaxis en `resource.ts`
- **Procesos bloqueados**: Terminar procesos de Node.js

### 2. Logs y Debug

```bash
npx ampx sandbox --debug
```

### 3. Limpiar y Recrear

```bash
npx ampx sandbox delete --yes
npx ampx sandbox
```

## Recursos Adicionales

- [Documentación oficial de Amplify Gen2](https://docs.amplify.aws/gen2/)
- [Guía de autenticación](https://docs.amplify.aws/gen2/build-a-backend/auth/)
- [Guía de datos](https://docs.amplify.aws/gen2/build-a-backend/data/)
- [CLI de Amplify](https://docs.amplify.aws/cli/)

## Conclusión

El sandbox de Amplify Gen2 está funcionando correctamente y proporciona:

- ✅ Autenticación completa con Cognito
- ✅ Base de datos GraphQL con AppSync
- ✅ API RESTful configurada
- ✅ Configuración automática para Flutter
- ✅ Entorno de desarrollo aislado

La aplicación Flutter ahora puede conectarse directamente al backend de Amplify Gen2 usando las credenciales del sandbox.
