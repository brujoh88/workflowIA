---
paths:
  - "src/components/**"
  - "src/pages/**"
  - "src/views/**"
  - "**/*.tsx"
  - "**/*.vue"
  - "**/*.jsx"
---

# Reglas de Frontend

## Estructura de Componentes
- Un componente por archivo
- Componentes en PascalCase: `UserCard.tsx`
- Colocar en carpetas por feature o dominio

## Estado y Props
- Props explícitas con tipos definidos
- Estado local para UI, global para datos compartidos
- Evitar prop drilling excesivo (usar context/store)

## Estilos
- Usar sistema de diseño existente
- Clases utilitarias sobre CSS custom cuando sea posible
- Responsive: mobile-first

## Accesibilidad
- Usar elementos semánticos (`button`, `nav`, `main`)
- Labels en todos los inputs
- Alt text en imágenes
- Contraste adecuado

## Performance
- Lazy loading para rutas y componentes pesados
- Memoizar componentes costosos
- Evitar re-renders innecesarios
- Optimizar imágenes
