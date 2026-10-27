#!/usr/bin/env bash
#
# Los extractores de autoridad de check-una-sola-verdad.sh — uno por lenguaje.
#
# Todos escupen lo mismo, pase lo que pase adentro: "Nombre<TAB>VAL1|VAL2|...".
# Esa es la única forma de que el candado sea agnóstico: el que sabe de Prisma o
# de Python es este archivo, y el candado solo sabe de listas de valores.
#
# Agregar un lenguaje es agregar una función acá y un `case` en `verdades()`.
# Ninguna mantiene una lista a mano: leen el fuente, así que un valor nuevo entra
# al alcance solo. Una lista paralela se desactualiza, y el problema vuelve por
# otra puerta.

# `enum Nombre { VALOR ... }` de un schema de Prisma.
autoridad_prisma() {
  awk '
    /^enum [A-Za-z_][A-Za-z0-9_]* *\{/ { nombre = $2; vals = ""; dentro = 1; next }
    dentro && /^\}/ { if (vals != "") print nombre "\t" vals; dentro = 0; next }
    dentro {
      l = $1
      if (l ~ /^\/\// || l ~ /^@@/ || l == "") next
      vals = (vals == "" ? l : vals "|" l)
    }
  ' "$1"
}

# TypeScript, las tres formas: `type X = "a" | "b"`, `const X = ["a","b"] as const`,
# `enum X { A = "a" }`. Se lee el archivo entero de una porque las tres se escriben
# repartidas en varios renglones tanto como en uno solo.
autoridad_ts() {
  awk '
    function valores(decl,   vals, resto, v) {
      vals = ""; resto = decl
      while (match(resto, "\047[^\047]*\047|\"[^\"]*\"")) {
        v = substr(resto, RSTART + 1, RLENGTH - 2)
        resto = substr(resto, RSTART + RLENGTH)
        if (v != "") vals = (vals == "" ? v : vals "|" v)
      }
      return vals
    }
    function emitir(decl, nombre,   v) {
      v = valores(decl)
      if (v ~ /\|/) print nombre "\t" v
    }
    {
      linea = $0; sub(/\/\/.*/, "", linea); gsub(/\r/, "", linea)
      todo = todo " " linea
      # Una union se escribe tanto en un renglon como repartida con el `|` al
      # principio de cada uno. Se pegan antes de mirarlas, si no la segunda forma
      # se lee como tres lineas sueltas y la verdad queda sin autoridad.
      t = linea; gsub(/^[ \t]+|[ \t]+$/, "", t)
      if (t == "") next
      if (t ~ /^\|/ || pendiente ~ /[=|]$/) pendiente = pendiente " " t
      else { if (pendiente != "") sent[++ns] = pendiente; pendiente = t }
    }
    END {
      if (pendiente != "") sent[++ns] = pendiente
      # `type X = "a" | "b"` — sin exigir el punto y coma final, que casi nadie escribe.
      for (i = 1; i <= ns; i++) {
        d = sent[i]
        if (d ~ /^(export )?(declare )?type [A-Za-z_][A-Za-z0-9_]* *=/) {
          sub(/^export /, "", d); sub(/^declare /, "", d)
          split(d, p, " "); emitir(d, p[2])
        }
      }
      gsub(/[ \t\r]+/, " ", todo)
      # `const X = ["a", "b"] as const`
      t = todo
      while (match(t, /const [A-Za-z_][A-Za-z0-9_]* = \[[^]]*\]/)) {
        d = substr(t, RSTART, RLENGTH); t = substr(t, RSTART + RLENGTH)
        split(d, p, " "); emitir(d, p[2])
      }
      # `enum X { A = "a" }`
      t = todo
      while (match(t, /enum [A-Za-z_][A-Za-z0-9_]* \{[^}]*\}/)) {
        d = substr(t, RSTART, RLENGTH); t = substr(t, RSTART + RLENGTH)
        split(d, p, " "); emitir(d, p[2])
      }
    }
  ' "$1"
}

# `CREATE TYPE nombre AS ENUM ("a", "b");` de una migración.
autoridad_sql() {
  awk '
    { sub(/--.*/, ""); todo = todo " " tolower($0); crudo = crudo " " $0 }
    END {
      gsub(/[ \t\r]+/, " ", todo); gsub(/[ \t\r]+/, " ", crudo)
      t = todo; c = crudo
      while (match(t, /create type [a-z_][a-z0-9_.\"]* as enum *\([^)]*\)/)) {
        d = substr(c, RSTART, RLENGTH); t = substr(t, RSTART + RLENGTH); c = substr(c, RSTART + RLENGTH)
        split(d, p, " "); nombre = p[3]; gsub(/[\"\.]/, "", nombre)
        vals = ""; resto = d
        while (match(resto, "\047[^\047]*\047|\"[^\"]*\"")) {
          v = substr(resto, RSTART + 1, RLENGTH - 2)
          resto = substr(resto, RSTART + RLENGTH)
          if (v != "") vals = (vals == "" ? v : vals "|" v)
        }
        if (vals ~ /\|/) print nombre "\t" vals
      }
    }
  ' "$1"
}

# `class Nombre(str, Enum):` con un `A = "valor"` por renglón.
autoridad_python() {
  awk '
    /^class [A-Za-z_][A-Za-z0-9_]*\(.*[Ee]num.*\) *:/ {
      if (vals != "") print nombre "\t" vals
      nombre = $2; sub(/\(.*/, "", nombre); vals = ""; dentro = 1; next
    }
    dentro && /^[A-Za-z]/ { if (vals != "") print nombre "\t" vals; dentro = 0; vals = "" }
    dentro && match($0, "= *[\047\"][^\047\"]*[\047\"]") {
      v = substr($0, RSTART, RLENGTH); gsub(/^= *[\047\"]|[\047\"]$/, "", v)
      if (v != "") vals = (vals == "" ? v : vals "|" v)
    }
    END { if (vals != "") print nombre "\t" vals }
  ' "$1"
}

