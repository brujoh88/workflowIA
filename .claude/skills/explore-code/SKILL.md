---
name: explore-code
description: Explorar y entender código del proyecto
argument-hint: [qué explorar]
context: fork
agent: Explore
---

# Explorar: $ARGUMENTS

## Proceso de Investigación

1. **Búsqueda inicial**
   - Encontrar archivos relevantes por nombre
   - Buscar términos clave en el código
   - Identificar módulos relacionados

2. **Trazar el flujo**
   - Punto de entrada
   - Llamadas entre módulos
   - Dependencias externas

3. **Documentar hallazgos**
   - Archivos principales con líneas relevantes
   - Patrones identificados
   - Puntos de extensión

## Output Esperado

Resumen con:
- Lista de archivos relevantes (`archivo:línea`)
- Diagrama del flujo (texto)
- Observaciones importantes
- Posibles gotchas o deuda técnica
