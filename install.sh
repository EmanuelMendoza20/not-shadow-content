#!/usr/bin/env bash
#
# Not Shadow Content - instalador para Zen Browser
#
# Copia el mod al perfil de Zen y lo registra en zen-themes.json.
# No hace peticiones de red ni modifica nada fuera del perfil detectado.
#
set -euo pipefail

MOD_ID="not-shadow-content"
MOD_NAME="Not Shadow Content"
MOD_DESCRIPTION="Removes the drop shadow from the web content panel."
MOD_AUTHOR="EmanuelMendoza20"
MOD_VERSION="1.0.0"
REPO="https://github.com/EmanuelMendoza20/not-shadow-content"
RAW_BASE="https://raw.githubusercontent.com/EmanuelMendoza20/not-shadow-content/main"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_CSS="$SCRIPT_DIR/chrome.css"

die() {
  printf 'ERROR: %s\n' "$1" >&2
  exit 1
}

usage() {
  cat <<EOF
$MOD_NAME - instalador para Zen Browser

Uso:
  ./install.sh            Instala o actualiza el mod
  ./install.sh --remove   Desinstala el mod
  ./install.sh --help     Muestra esta ayuda

Entorno:
  ZEN_PROFILE   Ruta al perfil de Zen. Si no se define, se autodetecta
                buscando zen-themes.json en los perfiles de Zen.
EOF
}

find_profile() {
  if [[ -n "${ZEN_PROFILE:-}" ]]; then
    [[ -f "$ZEN_PROFILE/zen-themes.json" ]] ||
      die "ZEN_PROFILE no contiene zen-themes.json: $ZEN_PROFILE"
    printf '%s\n' "$ZEN_PROFILE"
    return
  fi

  local base="$HOME/Library/Application Support/zen/Profiles"
  [[ -d "$base" ]] || die "no se encontro el directorio de perfiles de Zen: $base"

  local dir first=""
  for dir in "$base"/*/; do
    [[ -f "${dir}zen-themes.json" ]] || continue
    if [[ "$dir" == *"Default (release)"* ]]; then
      printf '%s\n' "${dir%/}"
      return
    fi
    [[ -n "$first" ]] || first="${dir%/}"
  done

  [[ -n "$first" ]] || die "no se encontro ningun perfil de Zen con zen-themes.json"
  printf '%s\n' "$first"
}

patch_registry() {
  local registry="$1" mode="$2"

  cp -p "$registry" "$registry.bak"

  python3 - "$registry" "$mode" <<PY || die "no se pudo actualizar $registry"
import json, sys

path, mode = sys.argv[1], sys.argv[2]
mod_id = "$MOD_ID"
raw_base = "$RAW_BASE"

with open(path, encoding="utf-8") as fh:
    data = json.load(fh)

changed = False

if mode == "install":
    entry = {
        "id": mod_id,
        "name": "$MOD_NAME",
        "description": "$MOD_DESCRIPTION",
        "homepage": "$REPO",
        "style": raw_base + "/chrome.css",
        "readme": raw_base + "/README.md",
        "author": "$MOD_AUTHOR",
        "version": "$MOD_VERSION",
        "tags": [],
    }
    previous = data.get(mod_id)
    if isinstance(previous, dict):
        entry["enabled"] = bool(previous.get("enabled", True))
    else:
        entry["enabled"] = True
    data[mod_id] = entry
    changed = True
elif mod_id in data:
    del data[mod_id]
    changed = True

if not changed:
    sys.exit(0)

with open(path, "w", encoding="utf-8") as fh:
    json.dump(data, fh, separators=(",", ":"), ensure_ascii=False)
PY
}

do_install() {
  local profile="$1"
  local target="$profile/chrome/zen-themes/$MOD_ID"

  [[ -f "$SRC_CSS" ]] || die "no se encontro chrome.css en $SCRIPT_DIR"

  if [[ -L "$target" ]]; then
    printf 'Quitando symlink previo: %s\n' "$target"
    rm "$target"
  elif [[ -e "$target" ]]; then
    rm -rf "$target"
  fi

  mkdir -p "$target"
  cp "$SRC_CSS" "$target/chrome.css"
  printf 'Instalado: %s\n' "$target/chrome.css"

  patch_registry "$profile/zen-themes.json" install
  printf 'Registrado en: %s (backup en .bak)\n' "$profile/zen-themes.json"

  printf '\nListo. Reinicia Zen o desactiva y reactiva el mod en Ajustes -> Mods.\n'
}

do_remove() {
  local profile="$1"
  local target="$profile/chrome/zen-themes/$MOD_ID"
  local registry="$profile/zen-themes.json"

  local found=0
  if [[ -e "$target" || -L "$target" ]]; then
    rm -rf "$target"
    printf 'Eliminado: %s\n' "$target"
    found=1
  fi

  if [[ -f "$registry" ]] &&
    grep -q "\"$MOD_ID\"" "$registry"; then
    patch_registry "$registry" remove
    printf 'Registro eliminado de: %s (backup en .bak)\n' "$registry"
    found=1
  fi

  if [[ "$found" -eq 0 ]]; then
    printf 'No habia nada instalado en %s\n' "$profile"
  else
    printf '\nListo. Reinicia Zen para aplicar los cambios.\n'
  fi
}

main() {
  local action="install"
  case "${1:-}" in
    --remove | uninstall) action="remove" ;;
    --help | -h) usage; return 0 ;;
    "") ;;
    *) usage >&2; die "argumento desconocido: $1" ;;
  esac

  command -v python3 >/dev/null 2>&1 ||
    die "se requiere python3 para actualizar zen-themes.json.
Instala las Command Line Tools (xcode-select --install) y volve a intentarlo."

  local profile
  profile="$(find_profile)"
  printf 'Perfil: %s\n\n' "$profile"

  if [[ "$action" == "install" ]]; then
    do_install "$profile"
  else
    do_remove "$profile"
  fi
}

main "$@"
