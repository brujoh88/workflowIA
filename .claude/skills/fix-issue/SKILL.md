---
name: fix-issue
description: Resolver un issue de GitHub
argument-hint: [issue-number]
disable-model-invocation: true
---

# Resolver Issue #$ARGUMENTS

## Contexto del Issue
!`gh issue view $ARGUMENTS --json title,body,labels,comments`

## Proceso

1. **Analizar el issue**
   - Leer título, descripción y comentarios
   - Identificar tipo: bug, feature, mejora
   - Entender el resultado esperado

2. **Localizar código afectado**
   - Buscar archivos mencionados en el issue
   - Trazar el flujo del problema
   - Identificar tests relacionados

3. **Implementar solución**
   - Solución mínima que resuelva el problema
   - Seguir convenciones del proyecto
   - No refactorizar código no relacionado

4. **Verificar**
   - Ejecutar tests existentes
   - Agregar tests si es necesario
   - Verificar que no rompe funcionalidad existente

5. **Commit**
   - Mensaje siguiendo Conventional Commits
   - Referenciar el issue: `fix: descripción (closes #$ARGUMENTS)`
