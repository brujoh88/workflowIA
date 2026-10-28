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

# Seguro: sólo se borra una carpeta vacía o una plantilla ya generada (con su LEEME).
if [ -e "$DESTINO" ] && [ -n "$(ls -A "$DESTINO" 2>/dev/null)" ] && [ ! -f "$DESTINO/$WF/LEEME.md" ]; then
  echo "armar-plantilla: $DESTINO no está vacía y no es una plantilla generada; no la borro." >&2
  exit 1
fi
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

# Reemplazos de texto: cada uno tiene que encontrar lo que busca. Si el original cambió de
# redacción, el generador corta acá en vez de dejar una plantilla a medio adaptar (el candado no lo
# notaría: compara el generador contra sí mismo).
cambiar() {  # cambiar <archivo> <texto exacto> <reemplazo>
  python3 - "$@" <<'PY' || { echo "armar-plantilla: no encontré el texto a cambiar en ${1#"$DESTINO/"}:" >&2; printf '  %s\n' "$2" | head -3 >&2; exit 1; }
import sys
ruta, viejo, nuevo = sys.argv[1:4]
s = open(ruta, encoding="utf-8").read()
if viejo not in s: sys.exit(1)
open(ruta, "w", encoding="utf-8").write(s.replace(viejo, nuevo))
PY
}
cambiar_seccion() {  # cambiar_seccion <archivo> <encabezado "### N. "> : el texto nuevo llega por stdin
  local nuevo; nuevo=$(cat)
  python3 - "$1" "$2" "$nuevo" <<'PY' || { echo "armar-plantilla: no encontré la sección '$2' en ${1#"$DESTINO/"}" >&2; exit 1; }
import sys, re
ruta, encabezado, nuevo = sys.argv[1:4]
s = open(ruta, encoding="utf-8").read()
m = re.search(r"^" + re.escape(encabezado) + r".*?(?=^### |\Z)", s, re.S | re.M)
if not m: sys.exit(1)
open(ruta, "w", encoding="utf-8").write(s[:m.start()] + nuevo.rstrip("\n") + "\n\n" + s[m.end():])
PY
}

# 4. Textos: sin el plugin no hay prefijo /wf: ni wf:<agente>, ni ${CLAUDE_PLUGIN_ROOT}, ni bin/
#    en el PATH. docs/ queda como está: el MANUAL describe el plugin y tiene su sección sin plugin.
find "$DESTINO/.claude/skills" "$DESTINO/.claude/agents" "$DESTINO/$WF/reglas" -type f -name '*.md' -print0 |
  xargs -0 sed -i \
    -e 's#/wf:#/#g' \
    -e 's#`wf:\([a-z]\)#`\1#g' \
    -e 's#\${CLAUDE_PLUGIN_ROOT}#$CLAUDE_PROJECT_DIR/.claude/wf#g' \
    -e 's#\bcontext-lock \(acquire\|release\|check\)#.claude/wf/bin/context-lock \1#g' \
    -e 's#Bash(context-lock:\*)#Bash(.claude/wf/bin/context-lock:*)#g'

REGLAS="$DESTINO/$WF/reglas/REGLAS.md"
cambiar "$REGLAS" "\`docs/QUALITY-SKILLS-CONTRACT.md\` in the plugin" "\`.claude/wf/docs/QUALITY-SKILLS-CONTRACT.md\`"
cambiar "$REGLAS" "\`context-lock\` (on the PATH, comes
  with the wf plugin)" "\`.claude/wf/bin/context-lock\`"
cambiar "$REGLAS" "The Claude Code hooks come with the **wf plugin** and fire whenever it is enabled." \
  "The Claude Code hooks live in \`.claude/wf/scripts/\` and are declared in \`.claude/settings.json\`."

# 5. /setup: los pasos del plugin (copiar plantillas, declararlo, instalarlo) no aplican a un clon
SETUP="$DESTINO/.claude/skills/setup/SKILL.md"
cambiar "$SETUP" "Bash(wf-plantillas:*), " ""
cambiar "$SETUP" "Interactive wizard to configure a project that uses the workflowIA plugin (\`wf\`)." \
  "Interactive wizard to configure a project cloned from the workflowIA template (no plugin)."
cambiar "$SETUP" "the files \`wf-plantillas\` copied, " "the files that came with the template, "
cambiar "$SETUP" ".claude/settings.json (declares the wf plugin for the team)" \
  ".claude/settings.json (declares the workflow's Claude Code hooks)"
cambiar "$SETUP" "are not copied: they come with the plugin and fire whenever it is enabled." \
  "live in \`.claude/wf/scripts/\` and are declared in \`.claude/settings.json\`."
cambiar_seccion "$SETUP" "### 0. " <<'EOF'
### 0. Hook Up the Git Hooks

This project was cloned from the workflowIA template (no plugin): every file is already in place,
and the framework lives in `.claude/wf/` (rules, hook scripts, docs). Only the git hooks need
enabling, since git never carries that setting with a clone:

```bash
chmod +x scripts/hooks/* .claude/wf/scripts/* .claude/wf/bin/*
git config core.hooksPath scripts/hooks
```
EOF
cambiar_seccion "$SETUP" "### 7. " <<'EOF'
### 7. Check settings.json

`.claude/settings.json` declares the workflow's Claude Code hooks (`hooks` block, pointing at
`.claude/wf/scripts/`). Keep that block. Do **not** install the wf plugin on top of this copy:
every guard would fire twice. Moving to the plugin means removing `.claude/wf/`, the `hooks` block,
`.claude/skills/` and `.claude/agents/` first.
EOF
cambiar_seccion "$SETUP" "### 7.6. " <<'EOF'
### 7.6. README: how someone who clones gets started

Git never enables hooks on its own, so the step goes in the project's README, near the top. Add
this section (create the README if there is none; do not duplicate it if it is already there):

```markdown
## Working on this project with Claude Code

Once per clone, from the project folder:

    git config core.hooksPath scripts/hooks

Then open Claude. The workflow commands are `/start`, `/finish`, `/review-code`.
```
EOF

# 6. CLAUDE.md: las reglas no vienen del plugin sino de .claude/wf/
cambiar "$DESTINO/CLAUDE.md" "come
> with the **wf plugin**: it injects them at the start of every session." "live
> in \`.claude/wf/reglas/REGLAS.md\`: a SessionStart hook injects their index at the start of every session."

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
