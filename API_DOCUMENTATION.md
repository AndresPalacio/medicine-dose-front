# API Documentation - Módulo de Síntomas y Alimentos

## Descripción General

Esta API maneja el tracking de síntomas y alimentos para una aplicación de salud. Permite a los usuarios registrar síntomas múltiples, alimentos consumidos, y relacionar medicamentos con sus condiciones de salud.

## Base URL

```
https://tu-api-gateway-url/prod/
```

## Autenticación

Todos los endpoints requieren autenticación JWT. Incluye el token en el header:

```
Authorization: Bearer tu-token-jwt
```

---

## 🏥 Módulo de Síntomas

### 1. Crear/Agregar Síntoma

**Endpoint:** `POST /symptoms`

**Descripción:** Crea un nuevo registro de síntomas. Soporta múltiples síntomas en un solo registro.

**Headers:**
```
Content-Type: application/json
Authorization: Bearer tu-token-jwt
```

**Body:**
```json
{
  "symptomId": "dolor_cabeza,nauseas",
  "symptomName": "Dolor de cabeza, Náuseas",
  "severity": "Moderado",
  "notes": "Dolor intenso en la parte frontal de la cabeza",
  "date": "2024-01-15",
  "time": "14:30",
  "relatedMedications": ["Paracetamol", "Ibuprofeno"],
  "userId": "user123"
}
```

**Respuesta exitosa (200):**
```json
{
  "statusCode": 200,
  "body": {
    "id": "1705312200000_dolor_cabeza",
    "userId": "user123",
    "symptomId": "dolor_cabeza,nauseas",
    "symptomName": "Dolor de cabeza, Náuseas",
    "severity": "Moderado",
    "notes": "Dolor intenso en la parte frontal de la cabeza",
    "date": "2024-01-15",
    "time": "14:30",
    "relatedMedications": ["Paracetamol", "Ibuprofeno"],
    "createdAt": "2024-01-15T14:30:00Z",
    "updatedAt": "2024-01-15T14:30:00Z"
  }
}
```

**cURL:**
```bash
curl -X POST https://tu-api-gateway-url/prod/symptoms \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer tu-token-jwt" \
  -d '{
    "symptomId": "dolor_cabeza,nauseas",
    "symptomName": "Dolor de cabeza, Náuseas",
    "severity": "Moderado",
    "notes": "Dolor intenso en la parte frontal de la cabeza",
    "date": "2024-01-15",
    "time": "14:30",
    "relatedMedications": ["Paracetamol", "Ibuprofeno"],
    "userId": "user123"
  }'
```

### 2. Obtener Síntomas por Usuario y Fecha

**Endpoint:** `GET /symptoms`

**Descripción:** Obtiene todos los síntomas de un usuario para una fecha específica.

**Query Parameters:**
- `userId` (required): ID del usuario
- `date` (required): Fecha en formato YYYY-MM-DD

**Headers:**
```
Authorization: Bearer tu-token-jwt
```

**Respuesta exitosa (200):**
```json
{
  "statusCode": 200,
  "body": [
    {
      "id": "1705312200000_dolor_cabeza",
      "userId": "user123",
      "symptomId": "dolor_cabeza,nauseas",
      "symptomName": "Dolor de cabeza, Náuseas",
      "severity": "Moderado",
      "notes": "Dolor intenso en la parte frontal de la cabeza",
      "date": "2024-01-15",
      "time": "14:30",
      "relatedMedications": ["Paracetamol", "Ibuprofeno"],
      "createdAt": "2024-01-15T14:30:00Z",
      "updatedAt": "2024-01-15T14:30:00Z"
    }
  ]
}
```

**cURL:**
```bash
curl -X GET "https://tu-api-gateway-url/prod/symptoms?userId=user123&date=2024-01-15" \
  -H "Authorization: Bearer tu-token-jwt"
```

### 3. Obtener Síntomas por Rango de Fechas

**Endpoint:** `GET /symptoms`

**Descripción:** Obtiene todos los síntomas de un usuario en un rango de fechas.

**Query Parameters:**
- `userId` (required): ID del usuario
- `startDate` (required): Fecha inicial en formato YYYY-MM-DD
- `endDate` (required): Fecha final en formato YYYY-MM-DD

**cURL:**
```bash
curl -X GET "https://tu-api-gateway-url/prod/symptoms?userId=user123&startDate=2024-01-01&endDate=2024-01-31" \
  -H "Authorization: Bearer tu-token-jwt"
```

### 4. Obtener Síntoma Específico

**Endpoint:** `GET /symptoms/{symptomId}`

**Descripción:** Obtiene un síntoma específico por su ID.

**Path Parameters:**
- `symptomId` (required): ID único del síntoma

**cURL:**
```bash
curl -X GET "https://tu-api-gateway-url/prod/symptoms/1705312200000_dolor_cabeza" \
  -H "Authorization: Bearer tu-token-jwt"
```

### 5. Actualizar Síntoma

**Endpoint:** `PUT /symptoms/{symptomId}`

**Descripción:** Actualiza un síntoma existente.

**Headers:**
```
Content-Type: application/json
Authorization: Bearer tu-token-jwt
```

**Body:**
```json
{
  "symptomId": "dolor_cabeza,nauseas,mareos",
  "symptomName": "Dolor de cabeza, Náuseas, Mareos",
  "severity": "Severo",
  "notes": "Dolor intenso con náuseas y mareos",
  "date": "2024-01-15",
  "time": "14:30",
  "relatedMedications": ["Paracetamol", "Ibuprofeno", "Ondansetrón"],
  "userId": "user123"
}
```

**cURL:**
```bash
curl -X PUT https://tu-api-gateway-url/prod/symptoms/1705312200000_dolor_cabeza \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer tu-token-jwt" \
  -d '{
    "symptomId": "dolor_cabeza,nauseas,mareos",
    "symptomName": "Dolor de cabeza, Náuseas, Mareos",
    "severity": "Severo",
    "notes": "Dolor intenso con náuseas y mareos",
    "date": "2024-01-15",
    "time": "14:30",
    "relatedMedications": ["Paracetamol", "Ibuprofeno", "Ondansetrón"],
    "userId": "user123"
  }'
```

### 6. Eliminar Síntoma

**Endpoint:** `DELETE /symptoms/{symptomId}`

**Descripción:** Elimina un síntoma específico.

**Query Parameters:**
- `userId` (required): ID del usuario para validación

**cURL:**
```bash
curl -X DELETE "https://tu-api-gateway-url/prod/symptoms/1705312200000_dolor_cabeza?userId=user123" \
  -H "Authorization: Bearer tu-token-jwt"
```

### 7. Obtener Estadísticas de Síntomas

**Endpoint:** `GET /symptoms/stats`

**Descripción:** Obtiene estadísticas de síntomas para un período.

**Query Parameters:**
- `userId` (required): ID del usuario
- `startDate` (required): Fecha inicial
- `endDate` (required): Fecha final

**Respuesta:**
```json
{
  "statusCode": 200,
  "body": {
    "totalSymptoms": 15,
    "mostCommonSymptoms": ["Dolor de cabeza", "Náuseas", "Fatiga"],
    "severityDistribution": {
      "Leve": 5,
      "Moderado": 7,
      "Severo": 3
    },
    "symptomsByDate": {
      "2024-01-15": 3,
      "2024-01-16": 2,
      "2024-01-17": 1
    }
  }
}
```

**cURL:**
```bash
curl -X GET "https://tu-api-gateway-url/prod/symptoms/stats?userId=user123&startDate=2024-01-01&endDate=2024-01-31" \
  -H "Authorization: Bearer tu-token-jwt"
```

---

## 🍽️ Módulo de Alimentos

### 1. Crear/Agregar Alimento

**Endpoint:** `POST /foods`

**Descripción:** Crea un nuevo registro de alimento consumido.

**Headers:**
```
Content-Type: application/json
Authorization: Bearer tu-token-jwt
```

**Body:**
```json
{
  "mealType": "Almuerzo",
  "foodName": "Ensalada César",
  "description": "Lechuga, crutones, parmesano, aderezo César",
  "date": "2024-01-15",
  "time": "13:00",
  "portion": "1 plato grande",
  "ingredients": ["Lechuga", "Crutones", "Parmesano", "Aderezo César"],
  "causedDiscomfort": false,
  "discomfortNotes": null,
  "userId": "user123"
}
```

**Respuesta exitosa (200):**
```json
{
  "statusCode": 200,
  "body": {
    "id": "1705312200000_ensalada_cesar",
    "userId": "user123",
    "mealType": "Almuerzo",
    "foodName": "Ensalada César",
    "description": "Lechuga, crutones, parmesano, aderezo César",
    "date": "2024-01-15",
    "time": "13:00",
    "portion": "1 plato grande",
    "ingredients": ["Lechuga", "Crutones", "Parmesano", "Aderezo César"],
    "causedDiscomfort": false,
    "discomfortNotes": null,
    "createdAt": "2024-01-15T13:00:00Z",
    "updatedAt": "2024-01-15T13:00:00Z"
  }
}
```

**cURL:**
```bash
curl -X POST https://tu-api-gateway-url/prod/foods \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer tu-token-jwt" \
  -d '{
    "mealType": "Almuerzo",
    "foodName": "Ensalada César",
    "description": "Lechuga, crutones, parmesano, aderezo César",
    "date": "2024-01-15",
    "time": "13:00",
    "portion": "1 plato grande",
    "ingredients": ["Lechuga", "Crutones", "Parmesano", "Aderezo César"],
    "causedDiscomfort": false,
    "discomfortNotes": null,
    "userId": "user123"
  }'
```

### 2. Obtener Alimentos por Usuario y Fecha

**Endpoint:** `GET /foods`

**Descripción:** Obtiene todos los alimentos de un usuario para una fecha específica.

**Query Parameters:**
- `userId` (required): ID del usuario
- `date` (required): Fecha en formato YYYY-MM-DD

**cURL:**
```bash
curl -X GET "https://tu-api-gateway-url/prod/foods?userId=user123&date=2024-01-15" \
  -H "Authorization: Bearer tu-token-jwt"
```

### 3. Obtener Alimentos por Rango de Fechas

**Endpoint:** `GET /foods`

**Query Parameters:**
- `userId` (required): ID del usuario
- `startDate` (required): Fecha inicial
- `endDate` (required): Fecha final

**cURL:**
```bash
curl -X GET "https://tu-api-gateway-url/prod/foods?userId=user123&startDate=2024-01-01&endDate=2024-01-31" \
  -H "Authorization: Bearer tu-token-jwt"
```

### 4. Obtener Alimento Específico

**Endpoint:** `GET /foods/{foodId}`

**cURL:**
```bash
curl -X GET "https://tu-api-gateway-url/prod/foods/1705312200000_ensalada_cesar" \
  -H "Authorization: Bearer tu-token-jwt"
```

### 5. Actualizar Alimento

**Endpoint:** `PUT /foods/{foodId}`

**cURL:**
```bash
curl -X PUT https://tu-api-gateway-url/prod/foods/1705312200000_ensalada_cesar \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer tu-token-jwt" \
  -d '{
    "mealType": "Almuerzo",
    "foodName": "Ensalada César con Pollo",
    "description": "Lechuga, crutones, parmesano, aderezo César, pechuga de pollo",
    "date": "2024-01-15",
    "time": "13:00",
    "portion": "1 plato grande",
    "ingredients": ["Lechuga", "Crutones", "Parmesano", "Aderezo César", "Pollo"],
    "causedDiscomfort": false,
    "discomfortNotes": null,
    "userId": "user123"
  }'
```

### 6. Eliminar Alimento

**Endpoint:** `DELETE /foods/{foodId}`

**cURL:**
```bash
curl -X DELETE "https://tu-api-gateway-url/prod/foods/1705312200000_ensalada_cesar?userId=user123" \
  -H "Authorization: Bearer tu-token-jwt"
```

### 7. Obtener Estadísticas de Alimentos

**Endpoint:** `GET /foods/stats`

**cURL:**
```bash
curl -X GET "https://tu-api-gateway-url/prod/foods/stats?userId=user123&startDate=2024-01-01&endDate=2024-01-31" \
  -H "Authorization: Bearer tu-token-jwt"
```

---

## 🗄️ Estructura de Base de Datos (DynamoDB)

### Tabla: Symptoms

```json
{
  "TableName": "Symptoms",
  "KeySchema": [
    {
      "AttributeName": "userId",
      "KeyType": "HASH"
    },
    {
      "AttributeName": "symptomId",
      "KeyType": "RANGE"
    }
  ],
  "AttributeDefinitions": [
    {
      "AttributeName": "userId",
      "AttributeType": "S"
    },
    {
      "AttributeName": "symptomId",
      "AttributeType": "S"
    },
    {
      "AttributeName": "date",
      "AttributeType": "S"
    }
  ],
  "GlobalSecondaryIndexes": [
    {
      "IndexName": "DateIndex",
      "KeySchema": [
        {
          "AttributeName": "userId",
          "KeyType": "HASH"
        },
        {
          "AttributeName": "date",
          "KeyType": "RANGE"
        }
      ],
      "Projection": {
        "ProjectionType": "ALL"
      }
    }
  ]
}
```

### Tabla: Foods

```json
{
  "TableName": "Foods",
  "KeySchema": [
    {
      "AttributeName": "userId",
      "KeyType": "HASH"
    },
    {
      "AttributeName": "foodId",
      "KeyType": "RANGE"
    }
  ],
  "AttributeDefinitions": [
    {
      "AttributeName": "userId",
      "AttributeType": "S"
    },
    {
      "AttributeName": "foodId",
      "AttributeType": "S"
    },
    {
      "AttributeName": "date",
      "AttributeType": "S"
    }
  ],
  "GlobalSecondaryIndexes": [
    {
      "IndexName": "DateIndex",
      "KeySchema": [
        {
          "AttributeName": "userId",
          "KeyType": "HASH"
        },
        {
          "AttributeName": "date",
          "KeyType": "RANGE"
        }
      ],
      "Projection": {
        "ProjectionType": "ALL"
      }
    }
  ]
}
```

---

## ⚠️ Códigos de Error

### Errores Comunes

| Código | Descripción |
|--------|-------------|
| 400 | Bad Request - Datos inválidos |
| 401 | Unauthorized - Token inválido o expirado |
| 403 | Forbidden - Usuario no autorizado |
| 404 | Not Found - Recurso no encontrado |
| 409 | Conflict - Recurso ya existe |
| 500 | Internal Server Error - Error del servidor |

### Ejemplo de Error

```json
{
  "statusCode": 400,
  "body": {
    "error": "ValidationError",
    "message": "El campo 'date' es requerido",
    "details": {
      "field": "date",
      "value": null,
      "constraint": "required"
    }
  }
}
```

---

## 🔒 Consideraciones de Seguridad

1. **Autenticación JWT**: Todos los endpoints requieren un token JWT válido
2. **Validación de Usuario**: El `userId` del token debe coincidir con el de la petición
3. **Sanitización**: Validar y sanitizar todos los inputs
4. **Rate Limiting**: Implementar límites de velocidad para prevenir abuso
5. **Logging**: Registrar todas las operaciones para auditoría

---

## 🚀 Variables de Entorno

```bash
# API Gateway
API_GATEWAY_URL=https://tu-api-gateway-url/prod/

# DynamoDB
DYNAMODB_SYMPTOMS_TABLE=Symptoms
DYNAMODB_FOODS_TABLE=Foods
DYNAMODB_REGION=us-east-1

# JWT
JWT_SECRET=tu-jwt-secret-super-seguro
JWT_EXPIRATION=24h

# Lambda
LAMBDA_FUNCTION_NAME=health-tracker-api
LAMBDA_TIMEOUT=30
LAMBDA_MEMORY=512
```

---

## 📋 Checklist de Implementación

- [ ] Configurar tablas DynamoDB
- [ ] Implementar funciones Lambda
- [ ] Configurar API Gateway
- [ ] Implementar autenticación JWT
- [ ] Agregar validación de datos
- [ ] Implementar manejo de errores
- [ ] Configurar CORS
- [ ] Implementar logging
- [ ] Configurar rate limiting
- [ ] Realizar pruebas de integración
- [ ] Documentar endpoints adicionales

---

## 📞 Soporte

Para soporte técnico o preguntas sobre la implementación, contacta al equipo de desarrollo.
