---
name: deploy
description: Deploy a ambiente staging o production
argument-hint: [staging|production]
disable-model-invocation: true
allowed-tools: Bash(npm:*), Bash(git:*)
---

# Deploy a $ARGUMENTS

## Pre-deploy Checks

### Estado del repositorio
!`git status --porcelain`

### Branch actual
!`git branch --show-current`

## Proceso

### 1. Verificaciones previas
- [ ] Branch correcta (main/master para production)
- [ ] Sin cambios pendientes (working directory limpio)
- [ ] Último pull realizado

### 2. Tests
```bash
npm test
```
- [ ] Todos los tests pasan

### 3. Build
```bash
npm run build
```
- [ ] Build exitoso sin errores

### 4. Deploy
```bash
npm run deploy:$ARGUMENTS
```

### 5. Verificación post-deploy
- [ ] Aplicación accesible
- [ ] Funcionalidad crítica operativa
- [ ] Logs sin errores

## Rollback (si es necesario)
```bash
npm run rollback:$ARGUMENTS
```
