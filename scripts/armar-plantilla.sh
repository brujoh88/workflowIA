#!/bin/bash
# armar-plantilla.sh — genera plantilla/: la versión del workflow que se clona sin el plugin wf.
#
# El plugin es la única fuente. plantilla/ se GENERA, nunca se edita a mano: el pre-commit de
# este repo (.githooks/pre-commit) la vuelve a generar y corta el commit si quedó distinta.
#
#   scripts/armar-plantilla.sh            regenera plantilla/
#   scripts/armar-plantilla.sh <carpeta>  la genera en otra carpeta (la usa el candado)
#
# Qué va dónde (todo relativo a la raíz del proyecto que se clona):
#   plantillas/*            -> mismo lugar      (git-hooks/ -> scripts/hooks/, gitignore -> .gitignore)
#   skills/  agents/        -> .claude/skills/  .claude/agents/
#   scripts/claude-*.sh     -> .claude/wf/scripts/   (los hooks de Claude Code)
#   reglas/  docs/          -> .claude/wf/reglas/  .claude/wf/docs/
#   bin/context-lock        -> .claude/wf/bin/       (wf-plantillas no: es del plugin)
#   hooks/hooks.json        -> bloque "hooks" de .claude/settings.json, con la ruta del proyecto
#
# Las reglas WF-R… llegan igual que con el plugin: claude-reglas.sh inyecta el índice al arrancar.
# Una sola forma de recibirlas, venga del plugin o de la plantilla.

set -euo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DESTINO="${1:-$RAIZ/plantilla}"
WF=".claude/wf"

command -v jq >/dev/null 2>&1 || { echo "armar-plantilla: necesito jq" >&2; exit 1; }

rm -rf "$DESTINO"
mkdir -p "$DESTINO"

# 1. Lo que /wf:setup copia a cada proyecto
while IFS= read -r -d '' f; do
  rel="${f#"$RAIZ/plantillas/"}"
  case "$rel" in
    git-hooks/*) a="scripts/hooks/${rel#git-hooks/}" ;;
    gitignore)   a=".gitignore" ;;
    *)           a="$rel" ;;
  esac
  mkdir -p "$(dirname "$DESTINO/$a")"
  cp -p "$f" "$DESTINO/$a"
done < <(find "$RAIZ/plantillas" -type f -print0 | sort -z)
chmod +x "$DESTINO"/scripts/hooks/*

# 2. Lo que trae el plugin
mkdir -p "$DESTINO/.claude" "$DESTINO/$WF/scripts" "$DESTINO/$WF/bin"
cp -rp "$RAIZ/skills" "$DESTINO/.claude/skills"
cp -rp "$RAIZ/agents" "$DESTINO/.claude/agents"
cp -rp "$RAIZ/reglas" "$DESTINO/$WF/reglas"
cp -rp "$RAIZ/docs"   "$DESTINO/$WF/docs"
cp -p "$RAIZ"/scripts/claude-*.sh "$DESTINO/$WF/scripts/"
cp -p "$RAIZ/bin/context-lock"    "$DESTINO/$WF/bin/"

# 3. settings.json: sin la tienda ni el plugin, con los hooks del plugin apuntando al proyecto
jq --slurpfile h "$RAIZ/hooks/hooks.json" '
  del(.extraKnownMarketplaces)
  | .enabledPlugins |= del(.["wf@workflowia"])
  | if .enabledPlugins == {} then del(.enabledPlugins) else . end
  | .hooks = ($h[0].hooks | walk(
      if type == "string" then sub("\"\\$\\{CLAUDE_PLUGIN_ROOT\\}\""; "\"$CLAUDE_PROJECT_DIR\"/.claude/wf") else . end))
' "$RAIZ/plantillas/.claude/settings.json" > "$DESTINO/.claude/settings.json"

# 4. Textos: sin el plugin no hay prefijo /wf: ni wf:<agente>, ni ${CLAUDE_PLUGIN_ROOT}, ni bin/
#    en el PATH. docs/ queda como está: el MANUAL describe el plugin y tiene su sección sin plugin.
find "$DESTINO/.claude/skills" "$DESTINO/.claude/agents" "$DESTINO/$WF/reglas" -type f -name '*.md' -print0 |
  xargs -0 sed -i \
    -e 's#/wf:#/#g' \
    -e 's#`wf:\([a-z]\)#`\1#g' \
    -e 's#\${CLAUDE_PLUGIN_ROOT}#$CLAUDE_PROJECT_DIR/.claude/wf#g' \
    -e 's#\bcontext-lock \(acquire\|release\|check\)#.claude/wf/bin/context-lock \1#g'
sed -i 's#(injected by the wf plugin)#(injected from .claude/wf)#' "$DESTINO/$WF/scripts/claude-reglas.sh"

# 5. /setup: el paso 0 del plugin copia plantillas; acá ya están en su lugar
SETUP="$DESTINO/.claude/skills/setup/SKILL.md"
PASO0=$(mktemp)
cat > "$PASO0" <<'EOF'
### 0. Hook Up the Git Hooks

This project was cloned from the workflowIA template (no plugin): every file is already in place,
and the framework lives in `.claude/wf/` (rules, hook scripts, docs). Only the git hooks need
enabling, since git never carries that setting with a clone:

```bash
chmod +x scripts/hooks/* .claude/wf/scripts/* .claude/wf/bin/*
git config core.hooksPath scripts/hooks
```

Skip anything below about installing the wf plugin or declaring its store: this copy does not use
it. Its Claude Code hooks are already in `.claude/settings.json`.

EOF
awk -v paso0="$PASO0" '
  /^Interactive wizard to configure a project that uses the workflowIA plugin/ {
    print "Interactive wizard to configure a project cloned from the workflowIA template (no plugin)."; next
  }
  /^### 0\. / { while ((getline l < paso0) > 0) print l; saltar = 1; next }
  saltar && /^### / { saltar = 0 }
  !saltar
' "$SETUP" > "$SETUP.nuevo" && mv "$SETUP.nuevo" "$SETUP"
rm -f "$PASO0"

# 6. CLAUDE.md: las reglas no vienen del plugin sino de .claude/wf/
CLAUDE_MD="$DESTINO/CLAUDE.md"
awk '
  /^> The workflow rules/ {
    print "> The workflow rules (`WF-R1…WF-R26`), the document routing table and the agent delegation live"
    print "> in `.claude/wf/reglas/REGLAS.md`: a SessionStart hook injects their index at the start of every"
    print "> session. Do not copy them here. This file holds only what belongs to this project. Its own"
    print "> rules start at **R27**."
    saltar = 1; next
  }
  saltar && /^>/ { next }
  { saltar = 0; print }
' "$CLAUDE_MD" > "$CLAUDE_MD.nuevo" && mv "$CLAUDE_MD.nuevo" "$CLAUDE_MD"

# 7. Marca de origen
VERSION=$(jq -r .version "$RAIZ/.claude-plugin/plugin.json")
cat > "$DESTINO/$WF/LEEME.md" <<EOF
# workflowIA $VERSION — copia sin plugin

Generada por \`scripts/armar-plantilla.sh\` del repo workflowIA. **No se edita a mano**: los cambios
se hacen en el plugin y se regenera. Para actualizar un proyecto clonado de acá, conviene pasarse al
plugin (\`claude plugin install wf@workflowia -s project\`).

Para arrancar un proyecto nuevo:

    npx degit brujoh88/workflowIA/plantilla mi-proyecto
    cd mi-proyecto && git init && claude      # y adentro: /setup
EOF

echo "plantilla generada en ${DESTINO#"$RAIZ/"} ($(find "$DESTINO" -type f | wc -l) archivos)"
