---
paths:
  - "src/database/**"
  - "db/**"
  - "**/*.sql"
---

# Reglas de Base de Datos

## Migraciones
- NUNCA modificar migraciones ya aplicadas
- Crear nueva migración para cambios adicionales
- Nombrar migraciones descriptivamente: `YYYYMMDD_descripcion`

## Queries
- Usar ORM para queries simples (CRUD básico)
- SQL raw solo para reporting y queries complejas
- SIEMPRE parametrizar queries (nunca concatenar strings)
- Usar LIMIT en queries que pueden retornar muchos registros
- Incluir índices para campos usados en WHERE y JOIN

## Transacciones
- Usar transacciones para operaciones que modifican múltiples tablas
- Mantener transacciones cortas para evitar locks

## Convenciones de Nombrado
- Tablas: plural, snake_case (`users`, `order_items`)
- Columnas: snake_case (`created_at`, `user_id`)
- Índices: `idx_tabla_columna`
- Foreign keys: `fk_tabla_referencia`
