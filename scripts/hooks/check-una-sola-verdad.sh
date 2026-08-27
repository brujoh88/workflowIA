#!/usr/bin/env bash
#
# Candado de R30 — una verdad del negocio se escribe en un solo lado.
#
# Qué frena: una línea que enumera **dos o más valores de la misma verdad** fuera
# de la casa de esa verdad. Eso es una copia de algo que ya tiene dueño — y el
# modo de falla no es que rompa, es que **se separe en silencio**: la copia que
# quedó vieja sigue compilando, sigue pasando los tests y contesta distinto.
#
# Por qué es un hook y no una convención: R25 (una regla, una casa) estaba escrita
# en el CLAUDE.md desde el primer día y aun así se agregaron la cuarta y la quinta
# copia de la misma lista, en la entrega cuya promesa era justamente esa regla.
# Una regla que depende de acordarse dura hasta la primera sesión sin contexto.
#
# Este script NO sabe nada de tu proyecto. Todo sale de `.claude/project.config.json`,
# bloque "truth" (ver `--config` para el ejemplo). Sin ese bloque no frena nada:
# un repo que todavía no lo declaró no tiene por qué rebotar commits.
#
# Modos (sin argumento: verificar, que es lo que corre el pre-commit):
#   --medir      el reparto de lo que hay, sin frenar nada
#   --listar     el crudo, un renglón por hallazgo
#   --autoridad  qué verdades encontró y con qué valores
#   --inventario regenera el archivo de deuda aceptada
#   --config     imprime un bloque "truth" de ejemplo
#
# Para probarlo sobre un repo sin tocarlo: TRUTH_CONFIG=/otro/lado/truth.json
# Bypass de emergencia (via pre-commit): git commit --no-verify

set -uo pipefail

CONFIG="${TRUTH_CONFIG:-.claude/project.config.json}"
MODO="${1:-verificar}"

# ─────────────────────────────────────────────────────────────────────────────
# 0. La config. Sin bloque "truth" no hay candado — y eso no es un error.
# ─────────────────────────────────────────────────────────────────────────────
if [ "$MODO" = "--config" ]; then
  cat <<'EJEMPLO'
"truth": {
  "enabled": true,
  "authority": [ { "kind": "prisma", "path": "apps/api/prisma/schema.prisma" } ],
  "homes":      ["apps/api/src/domain/*"],
  "scope":      ["apps/api/src", "apps/web/app"],
  "testScope":  ["apps/api/test", "apps/web/test"],
  "testPattern":[".spec.", ".test.", "/test/", "/__tests__/"],
  "extensions": ["ts", "tsx"],
  "exclude":    ["/generated/", "/node_modules/", "/dist/", "/migrations/"],
  "inventory":  "scripts/hooks/verdad-repartida-aceptada.txt",
  "minValues": 2, "minValuesInTests": 2,
  "help": ["Extraela al dominio y que todos la importen.", "Si es frontera entre apps: una casa por app + test de contrato.", "Si tiene que quedar repetida: al inventario con el porque."]
}

- kind: prisma | ts | sql | python. `path` admite comodines.
- homes: donde la verdad SI puede enumerarse (patrones glob sobre el path).
- testPattern: que cuenta como test aunque viva dentro de scope (el spec pegado al codigo).
- minValuesInTests: subilo a 3+ para dejar pasar los casos de prueba concretos y frenar
  solo al test que reescribe la lista entera haciendose pasar por candado.
EJEMPLO
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "check-una-sola-verdad: falta jq, no puedo leer la config. No verifico nada."
  exit 0
fi
if [ ! -f "$CONFIG" ]; then
  echo "check-una-sola-verdad: no hay $CONFIG. Nada que verificar."
  exit 0
fi
if [ "$(jq -r '.truth.enabled // false' "$CONFIG")" != "true" ]; then
  echo "check-una-sola-verdad: sin bloque \"truth\" activo en $CONFIG. Nada que verificar."
  echo "  Para ver como se declara: $0 --config"
  exit 0
fi

cfg_lista() { jq -r "$1"' // [] | .[]' "$CONFIG" 2>/dev/null; }

HOMES=$(cfg_lista '.truth.homes')
SCOPE=$(cfg_lista '.truth.scope')
TESTSCOPE=$(cfg_lista '.truth.testScope')
EXTS=$(cfg_lista '.truth.extensions')
EXCLUDE=$(cfg_lista '.truth.exclude')
TESTPAT=$(cfg_lista '.truth.testPattern')
# El spec no siempre vive en una carpeta aparte (NestJS, Jest): también por nombre.
[ -z "$TESTPAT" ] && TESTPAT=$'.spec.\n.test.\n/test/\n/tests/\n/__tests__/'
INVENTARIO=$(jq -r '.truth.inventory // "scripts/hooks/verdad-repartida-aceptada.txt"' "$CONFIG")
MIN=$(jq -r '.truth.minValues // 2' "$CONFIG")
MIN_TEST=$(jq -r '.truth.minValuesInTests // .truth.minValues // 2' "$CONFIG")
[ -z "$EXTS" ] && EXTS="ts"

# ─────────────────────────────────────────────────────────────────────────────
# 1. La autoridad: de dónde salen los valores de cada verdad
#
# Un extractor por lenguaje. Todos escupen lo mismo: "Nombre<TAB>VAL1|VAL2|..."
# La lista no se mantiene a mano en ningún lado — un valor nuevo entra al alcance
# solo, que es la única forma de que el candado no se desactualice.
# ─────────────────────────────────────────────────────────────────────────────

# Los extractores viven aparte: el que sabe de cada lenguaje es lib-verdades.sh,
# y este archivo solo sabe de listas de valores. Agregar un lenguaje se hace allá.
DIR_HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib-verdades.sh
. "$DIR_HOOK/lib-verdades.sh"

verdades() {
  jq -r '.truth.authority[]? | "\(.kind)\t\(.path)"' "$CONFIG" | while IFS=$'\t' read -r kind patron; do
    for archivo in $patron; do
      [ -f "$archivo" ] || continue
      case "$kind" in
        prisma) autoridad_prisma "$archivo" ;;
        ts)     autoridad_ts "$archivo" ;;
        sql)    autoridad_sql "$archivo" ;;
        python) autoridad_python "$archivo" ;;
        *)      echo "check-una-sola-verdad: kind desconocido '$kind' en $CONFIG" >&2 ;;
      esac
    done
  done | sort -u
}

if [ "$MODO" = "--autoridad" ]; then
  verdades | awk -F'\t' '{ n = split($2, a, "|"); printf "%-32s %2d valores  %s\n", $1, n, $2 }'
  exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# 2. Las copias: líneas con N+ valores de la misma verdad, fuera de su casa
#
# Salida: "archivo<TAB>verdad<TAB>renglón<TAB>texto<TAB>zona"  (zona: src | test)
# ─────────────────────────────────────────────────────────────────────────────
copias_encontradas() {
  local incluye="" dirs="" testdirs=""
  for e in $EXTS; do incluye="$incluye --include=*.$e"; done
  for d in $SCOPE;     do [ -d "$d" ] && dirs="$dirs $d"; done
  for d in $TESTSCOPE; do [ -d "$d" ] && testdirs="$testdirs $d"; done
  [ -z "$dirs$testdirs" ] && return 0

  local homes_re; homes_re=$(echo "$HOMES" | tr '\n' '|')

  verdades | while IFS=$'\t' read -r nombre valores; do
    case "$valores" in *"|"*) ;; *) continue ;; esac   # una verdad de un valor no se "enumera"

    # shellcheck disable=SC2086
    { [ -n "$dirs" ]     && grep -rnE "['\"\`]($valores)['\"\`]" $dirs     $incluye 2>/dev/null | sed 's/$/\tsrc/'
      [ -n "$testdirs" ] && grep -rnE "['\"\`]($valores)['\"\`]" $testdirs $incluye 2>/dev/null | sed 's/$/\ttest/'
    } | awk -F: -v verdad="$nombre" -v vals="$valores" -v homes="$homes_re" \
              -v excl="$(echo "$EXCLUDE" | tr '\n' '|')" \
              -v testpat="$(echo "$TESTPAT" | tr '\n' '|')" '
        function es_casa(archivo,   i, n, p) {
          n = split(homes, p, "|")
          for (i = 1; i <= n; i++) if (p[i] != "" && archivo ~ ("^" glob(p[i]))) return 1
          return 0
        }
        # Glob de shell → regex. Se traduce a mano porque los patrones de casa se
        # escriben como paths (`backend/src/*/domain/*`), no como expresiones.
        function glob(p,   r) {
          r = p
          gsub(/\./, "\\.", r); gsub(/\*/, "[^\\n]*", r)
          return r
        }
        function es_test(archivo,   i, n, p) {
          n = split(testpat, p, "|")
          for (i = 1; i <= n; i++) if (p[i] != "" && index(archivo, p[i])) return 1
          return 0
        }
        function excluido(archivo,   i, n, p) {
          n = split(excl, p, "|")
          for (i = 1; i <= n; i++) if (p[i] != "" && index(archivo, p[i])) return 1
          return 0
        }
        {
          archivo = $1; nro = $2
          # Recortado por posición y no con sub(): un path con corchetes
          # (`app/[salon]/...`) se leería como clase de caracteres y no matchearía.
          resto = substr($0, length(archivo) + length(nro) + 3)
          zona = resto; sub(/.*\t/, "", zona)
          texto = resto; sub(/\t[^\t]*$/, "", texto)

          if (excluido(archivo)) next
          if (es_casa(archivo)) next          # ahí es donde tiene que estar
          if (es_test(archivo)) zona = "test"

          limpio = texto
          gsub(/^[ \t]+/, "", limpio)
          # Un comentario que nombra valores no es una copia: es prosa.
          if (limpio ~ /^\/\// || limpio ~ /^\*/ || limpio ~ /^\/\*/ || limpio ~ /^#/ || limpio ~ /^--/) next

          n = 0
          split(vals, a, "|")
          for (i in a) if (texto ~ ("[\047\"\140]" a[i] "[\047\"\140]")) n++
          umbral = (zona == "test" ? '"$MIN_TEST"' : '"$MIN"')
          if (n >= umbral) printf "%s\t%s\t%s\t%s\t%s\n", archivo, verdad, nro, limpio, zona
        }
      '
  done
}

if [ "$MODO" = "--listar" ]; then
  copias_encontradas
  exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# 2b. Modo --medir: el reparto, sin frenar nada. Es el número que decide si acá
#     conviene el candado, o si el proyecto ya está sano y no hace falta.
# ─────────────────────────────────────────────────────────────────────────────
if [ "$MODO" = "--medir" ]; then
  TMP=$(mktemp); copias_encontradas > "$TMP"
  echo "Verdades con autoridad:  $(verdades | wc -l)"
  echo "Líneas que las repiten:  $(wc -l < "$TMP")"
  echo "  en código:             $(awk -F'\t' '$5=="src"'  "$TMP" | wc -l)"
  echo "  en tests:              $(awk -F'\t' '$5=="test"' "$TMP" | wc -l)"
  echo "Archivos alcanzados:     $(awk -F'\t' '{print $1}' "$TMP" | sort -u | wc -l)"
  echo "Pares archivo+verdad:    $(awk -F'\t' '{print $1"\t"$2}' "$TMP" | sort -u | wc -l)"
  echo ""
  echo "Las verdades más repartidas:"
  awk -F'\t' '{print $2}' "$TMP" | sort | uniq -c | sort -rn | head -10 | sed 's/^/  /'
  echo ""
  echo "Los archivos con más copias:"
  awk -F'\t' '{print $1}' "$TMP" | sort | uniq -c | sort -rn | head -10 | sed 's/^/  /'
  echo ""
  echo "Tres ejemplos reales:"
  awk -F'\t' '$5=="src"' "$TMP" | head -3 | awk -F'\t' '{ printf "  %s:%s  [%s]\n    %s\n", $1, $3, $2, substr($4,1,110) }'
  rm -f "$TMP"
  exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# 3. Modo --inventario: escribe la deuda que ya estaba el día que esto nació
# ─────────────────────────────────────────────────────────────────────────────
if [ "$MODO" = "--inventario" ]; then
  {
    echo "# Verdad repartida que ya estaba escrita — el inventario de R30."
    echo "#"
    echo "# Una línea por archivo y verdad: 'archivo<TAB>Verdad<TAB># por qué se acepta'."
    echo "# Sin número de renglón a propósito: cambiaría con cualquier edición y el"
    echo "# candado empezaría a frenar por ruido en vez de por deuda."
    echo "#"
    echo "# Esto NO es una lista de perdones: es la deuda contada. Sacar una línea es"
    echo "# trabajo medible; agregar una es una decisión que alguien escribe."
    echo "#"
    echo "# Los porqués van a mano — una razón autogenerada no es una razón. Lo que"
    echo "# quede en 'pendiente de explicar' es justamente lo que falta pensar."
    echo ""
    copias_encontradas | awk -F'\t' '{ print $1 "\t" $2 }' | sort -u |
      awk -F'\t' '{ printf "%s\t%s\t# pendiente de explicar\n", $1, $2 }'
  } > "$INVENTARIO"
  echo "check-una-sola-verdad: inventario escrito en $INVENTARIO"
  awk '!/^#/ && NF' "$INVENTARIO" | wc -l | xargs echo "  entradas:"
  exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# 4. Verificar: todo lo que no esté inventariado es un hallazgo que frena
# ─────────────────────────────────────────────────────────────────────────────
aceptada() {
  [ -f "$INVENTARIO" ] || return 1
  awk -F'\t' -v archivo="$1" -v verdad="$2" '
    !/^#/ && NF && $1 == archivo && $2 == verdad { ok = 1 }
    END { exit(ok ? 0 : 1) }
  ' "$INVENTARIO"
}

ERRORES=0
while IFS=$'\t' read -r archivo verdad nro texto zona; do
  [ -z "${archivo:-}" ] && continue
  if ! aceptada "$archivo" "$verdad"; then
    if [ "$ERRORES" -eq 0 ]; then
      echo "" >&2
      echo "  ✘ Verdad del negocio escrita fuera de su casa (R30):" >&2
    fi
    echo "      $archivo:$nro  [$verdad]" >&2
    echo "        $texto" >&2
    ERRORES=$((ERRORES + 1))
  fi
done < <(copias_encontradas)

if [ "$ERRORES" -gt 0 ]; then
  echo "" >&2
  echo "check-una-sola-verdad: $ERRORES línea(s) repiten una verdad del negocio. El commit no entra." >&2
  echo "" >&2
  echo "  Las salidas, en orden de preferencia:" >&2
  AYUDA=$(cfg_lista '.truth.help')
  if [ -n "$AYUDA" ]; then
    echo "$AYUDA" | awk '{ printf "    %d. %s\n", NR, $0 }' >&2
  else
    echo "    1. Si contesta una pregunta del negocio, va como función pura en la casa" >&2
    echo "       del dominio con su spec, y todos los que la necesiten la importan." >&2
    echo "    2. Si es la frontera entre dos apps que no comparten código, la lista va" >&2
    echo "       en un solo archivo por app y lleva un test de contrato que lee el" >&2
    echo "       fuente del otro lado." >&2
    echo "    3. Si de verdad tiene que quedar repetida, se anota en" >&2
    echo "       $INVENTARIO con el porqué escrito." >&2
  fi
  echo "" >&2
  exit 1
fi

echo "check-una-sola-verdad: cada verdad del negocio vive en un solo lado."
exit 0
