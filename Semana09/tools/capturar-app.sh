#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
nombre="${1:-app-formulario}"
case "$nombre" in
  app-formulario|app-caso1|app-caso4|app-validacion) ;;
  *) echo 'Usa app-formulario, app-caso1, app-caso4 o app-validacion'; exit 1 ;;
esac
mkdir -p docs/capturas
xcrun simctl io booted screenshot "docs/capturas/$nombre.png"
echo "Captura guardada en docs/capturas/$nombre.png"
