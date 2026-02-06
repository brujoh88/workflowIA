---
paths:
  - "src/api/**"
  - "src/controllers/**"
  - "src/routes/**"
---

# Reglas de API

## Estructura de URLs
- Base: `/api/[version]/[recurso]` (e.g., `/api/v1/`)
- Plural para colecciones: `/api/{v}/users`
- Singular con ID: `/api/{v}/users/:id`
- Acciones: `/api/{v}/users/:id/activate`

## Formato de Respuestas

### Éxito
```json
{
  "data": { ... },
  "meta": { "total": 100, "page": 1 }
}
```

### Error
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email is required",
    "details": [...]
  }
}
```

## Códigos HTTP
- 200: OK (GET, PUT, PATCH)
- 201: Created (POST)
- 204: No Content (DELETE)
- 400: Bad Request (validación)
- 401: Unauthorized
- 403: Forbidden
- 404: Not Found
- 500: Internal Server Error

## Seguridad
- Validar TODOS los inputs
- Usar middleware para autenticación
- Rate limiting en endpoints públicos
- No exponer IDs internos sensibles
