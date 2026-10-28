---
name: mcp
description: Buscar, explorar e instalar MCP servers
argument-hint: <search|info|install|suggest> [nombre]
allowed-tools: WebSearch, WebFetch, Read, Write, Edit, Bash(npx:*), Bash(npm:*), AskUserQuestion
---

# MCP Server Manager

Gestiona MCP (Model Context Protocol) servers para extender las capacidades de Claude.

## Uso

```
/mcp search <término>     # Buscar MCP servers
/mcp info <nombre>        # Ver información detallada de un MCP
/mcp install <nombre>     # Instalar y configurar un MCP
/mcp suggest              # Sugerir MCPs según el proyecto
/mcp list                 # Listar MCPs instalados en el proyecto
```

## Comandos

### 1. Search - Buscar MCP Servers

**Argumento**: `/mcp search <término>`

Buscar en:
1. **GitHub**: `site:github.com mcp-server <término>` o `site:github.com modelcontextprotocol <término>`
2. **npm**: `site:npmjs.com mcp <término>`
3. **Awesome MCP**: `site:github.com awesome-mcp`

Presentar resultados en formato:

```
## Resultados para "<término>"

| # | Nombre | Descripción | Fuente |
|---|--------|-------------|--------|
| 1 | @modelcontextprotocol/server-filesystem | Acceso a sistema de archivos | npm |
| 2 | mcp-server-sqlite | Base de datos SQLite | GitHub |
...

¿Querés más info de alguno? Usa `/mcp info <nombre>`
```

### 2. Info - Información Detallada

**Argumento**: `/mcp info <nombre>`

Buscar información del MCP server:
1. Buscar en npm/GitHub el paquete
2. Obtener README y documentación
3. Extraer configuración necesaria

Presentar:

```
## <nombre>

**Descripción**: ...
**Instalación**: npx / npm install
**Repositorio**: https://github.com/...

### Configuración Requerida

{
  "mcpServers": {
    "<nombre>": {
      "command": "npx",
      "args": ["-y", "<paquete>"],
      "env": {
        "VARIABLE": "valor"
      }
    }
  }
}

### Variables de Entorno
- `VARIABLE`: Descripción de qué hace

### Capabilities
- Tool 1: descripción
- Tool 2: descripción

¿Querés instalarlo? Usa `/mcp install <nombre>`
```

### 3. Install - Instalar MCP Server

**Argumento**: `/mcp install <nombre>`

Proceso:
1. Obtener información del MCP (como en `info`)
2. Preguntar valores para variables de entorno requeridas
3. Agregar configuración a `.claude/settings.local.json`
4. Registrar en `project.config.json` → `mcp.installed`
5. Mostrar instrucciones post-instalación si las hay

**Actualizar `.claude/settings.local.json`**:

```json
{
  "permissions": { ... },
  "mcpServers": {
    "<nombre>": {
      "command": "npx",
      "args": ["-y", "<paquete>"],
      "env": {
        "VARIABLE": "valor-ingresado"
      }
    }
  }
}
```

**Actualizar `project.config.json`**:

```json
{
  "mcp": {
    "installed": [
      {
        "name": "<nombre>",
        "package": "<paquete>",
        "installedAt": "2024-01-15"
      }
    ]
  }
}
```

### 4. Suggest - Sugerir MCPs

**Argumento**: `/mcp suggest`

Leer `project.config.json` y analizar:
- `project.stack` - Stack tecnológico
- `project.description` - Descripción del proyecto

**Mapeo de sugerencias**:

| Stack/Keyword | MCP Sugerido |
|---------------|--------------|
| PostgreSQL, MySQL, DB | `@modelcontextprotocol/server-postgres`, `mcp-server-sqlite` |
| GitHub, git | `@modelcontextprotocol/server-github` |
| filesystem, archivos | `@modelcontextprotocol/server-filesystem` |
| Slack | `@modelcontextprotocol/server-slack` |
| Google Drive | `@modelcontextprotocol/server-gdrive` |
| Puppeteer, browser, web scraping | `@modelcontextprotocol/server-puppeteer` |
| Memory, RAG, knowledge | `@modelcontextprotocol/server-memory` |
| Docker, containers | MCP servers relacionados |
| AWS, cloud | MCP servers de AWS |

Presentar:

```
## MCPs Sugeridos para tu Proyecto

Basado en: {stack} - {description}

| MCP | Por qué | Comando |
|-----|---------|---------|
| server-postgres | Usas PostgreSQL | `/mcp install @modelcontextprotocol/server-postgres` |
| server-github | Proyecto en GitHub | `/mcp install @modelcontextprotocol/server-github` |

¿Querés instalar alguno?
```

### 5. List - Listar Instalados

**Argumento**: `/mcp list`

Leer `project.config.json` → `mcp.installed` y mostrar:

```
## MCPs Instalados

| Nombre | Paquete | Instalado |
|--------|---------|-----------|
| postgres | @modelcontextprotocol/server-postgres | 2024-01-15 |

Total: 1 MCP(s) configurado(s)
```

Si no hay ninguno:

```
No hay MCPs instalados.

Usa `/mcp suggest` para ver recomendaciones
o `/mcp search <término>` para buscar.
```

## MCP Servers Conocidos

Referencia rápida de MCPs oficiales y populares:

### Oficiales (@modelcontextprotocol)
- `server-filesystem` - Acceso a archivos locales
- `server-github` - Integración con GitHub API
- `server-postgres` - Consultas PostgreSQL
- `server-sqlite` - Base de datos SQLite
- `server-slack` - Integración Slack
- `server-memory` - Almacenamiento de conocimiento
- `server-puppeteer` - Automatización de browser
- `server-gdrive` - Google Drive
- `server-brave-search` - Búsqueda web con Brave

### Comunidad
- `mcp-server-docker` - Gestión de containers
- `mcp-server-kubernetes` - K8s management
- `mcp-server-notion` - Integración Notion

## Notas

- Los MCPs se configuran en `.claude/settings.local.json` (no se commitea)
- Algunas configuraciones requieren API keys o tokens
- Reiniciar Claude Code después de instalar un MCP para que tome efecto
