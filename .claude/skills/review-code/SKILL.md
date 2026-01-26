---
name: review-code
description: Revisar código para calidad y bugs
context: fork
agent: Explore
allowed-tools: Read, Grep, Glob
---

# Code Review

## Cambios a Revisar
!`git diff --stat HEAD~5`

## Checklist de Revisión

### Correctitud
- [ ] Lógica correcta para todos los casos
- [ ] Manejo de casos edge
- [ ] Manejo de errores apropiado
- [ ] No hay bugs obvios

### Seguridad
- [ ] Inputs validados y sanitizados
- [ ] Sin vulnerabilidades de inyección (SQL, XSS, etc.)
- [ ] Autenticación/autorización correcta
- [ ] Sin exposición de datos sensibles

### Performance
- [ ] Queries eficientes (sin N+1)
- [ ] Sin loops innecesarios
- [ ] Uso apropiado de caché
- [ ] Sin memory leaks

### Mantenibilidad
- [ ] Código legible y bien estructurado
- [ ] Nombrado claro
- [ ] Sin duplicación innecesaria
- [ ] Tests adecuados

## Formato de Output

### Crítico (bloquea merge)
- Archivo:línea - Descripción del problema
- Sugerencia de solución

### Importante (debería arreglarse)
- Archivo:línea - Descripción
- Sugerencia

### Sugerencia (mejora opcional)
- Archivo:línea - Descripción
