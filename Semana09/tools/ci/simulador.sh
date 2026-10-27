#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../.."

mkdir -p artifacts-ci/capturas
simulador=""
grabacion=""

finalizar() {
    local estado="$1"
    set +e
    if [[ -n "$grabacion" ]]; then
        kill -INT "$grabacion" 2>/dev/null
        wait "$grabacion"
    fi
    if [[ -n "$simulador" ]]; then
        if [[ "$estado" -ne 0 ]]; then
            xcrun simctl io "$simulador" screenshot artifacts-ci/capturas/ultimo-estado.png
        fi
        xcrun simctl shutdown "$simulador"
        xcrun simctl delete "$simulador"
    fi
    if [[ -d artifacts-ci/BoletaPago.xcresult ]]; then
        xcrun xcresulttool export attachments \
            --path artifacts-ci/BoletaPago.xcresult \
            --output-path artifacts-ci/capturas > artifacts-ci/exportar-capturas.log 2>&1
    fi
    if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
        {
            echo '## Semana09 · Simulador de iPhone'
            if [[ "$estado" -eq 0 ]]; then
                echo 'Compilación, pruebas del motor y cinco pruebas de interfaz completadas.'
                echo '| Caso | Neto comprobado en la pantalla |'
                echo '| --- | ---: |'
                echo '| 1 · ONP, mes completo | S/ 2,175.00 |'
                echo '| 2 · Hijos y 27 días | S/ 1,516.41 |'
                echo '| 3 · AFP, extras y adelanto | S/ 2,631.73 |'
                echo '| 4 · Evaluación | S/ 3,011.17 |'
                echo 'También se comprobó que 31 días muestra un error y retira la boleta anterior.'
            else
                echo 'La ejecución falló. Consultar los logs y el informe .xcresult del artifact.'
            fi
            echo 'Descargar **Semana09-evidencias** para ver las capturas, la grabación y los resultados.'
        } >> "$GITHUB_STEP_SUMMARY"
    fi
    exit "$estado"
}
trap 'finalizar "$?"' EXIT

{ xcodebuild -version; swift --version; } | tee artifacts-ci/entorno.txt
swift test 2>&1 | tee artifacts-ci/pruebas-motor.log
swift run boleta-check artifacts-ci/resultados-swift.json 2>&1 | tee artifacts-ci/control-swift.log

xcrun simctl list runtimes --json > artifacts-ci/runtimes.json
runtime="$(python3 - <<'PY'
import json
from pathlib import Path

runtimes = json.loads(Path('artifacts-ci/runtimes.json').read_text())['runtimes']
disponibles = [r for r in runtimes if r.get('isAvailable') and r['identifier'].startswith('com.apple.CoreSimulator.SimRuntime.iOS-18-')]
if not disponibles:
    raise SystemExit('No hay un runtime iOS 18 disponible para Xcode 16.4.')
print(max(disponibles, key=lambda r: tuple(map(int, r['version'].split('.'))))['identifier'])
PY
)"
simulador="$(xcrun simctl create 'Boleta Semana09 CI' \
    com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro "$runtime")"
echo "iPhone 16 Pro · $runtime · $simulador" | tee artifacts-ci/simulador.txt

xcodebuild build-for-testing \
    -project BoletaPago.xcodeproj -scheme BoletaPago -configuration Debug \
    -sdk iphonesimulator -destination "platform=iOS Simulator,id=$simulador" \
    -derivedDataPath .derivedData ONLY_ACTIVE_ARCH=YES CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
    2>&1 | tee artifacts-ci/compilacion.log

ditto -c -k --sequesterRsrc --keepParent \
    .derivedData/Build/Products/Debug-iphonesimulator/BoletaPago.app \
    .derivedData/BoletaPago-simulador.zip

xcrun simctl boot "$simulador"
xcrun simctl bootstatus "$simulador" -b
xcrun simctl status_bar "$simulador" override --time '9:41' --dataNetwork wifi \
    --wifiMode active --wifiBars 3 --batteryState charged --batteryLevel 100
xcrun simctl install "$simulador" .derivedData/Build/Products/Debug-iphonesimulator/BoletaPago.app
xcrun simctl launch "$simulador" pe.academico.semana09.boleta -AppleLanguages '(es)' -AppleLocale es_PE
sleep 3
xcrun simctl io "$simulador" screenshot artifacts-ci/capturas/00-formulario.png
xcrun simctl terminate "$simulador" pe.academico.semana09.boleta

xcrun simctl io "$simulador" recordVideo --codec=h264 \
    artifacts-ci/recorrido-simulador.mp4 > artifacts-ci/grabacion.log 2>&1 &
grabacion=$!

xcodebuild test-without-building \
    -project BoletaPago.xcodeproj -scheme BoletaPago -configuration Debug \
    -destination "platform=iOS Simulator,id=$simulador" \
    -derivedDataPath .derivedData -resultBundlePath artifacts-ci/BoletaPago.xcresult \
    -parallel-testing-enabled NO -maximum-concurrent-test-simulator-destinations 1 \
    ONLY_ACTIVE_ARCH=YES CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
    2>&1 | tee artifacts-ci/pruebas-interfaz.log
